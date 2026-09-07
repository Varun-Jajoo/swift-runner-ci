//
//  SgptSessionDetailViewController.swift
//  MyPT
//
//  Small Group PT (SGPT) session detail screen.
//
//  Figma: "Group class Detail" frame (node 11144:60311) — visually reuses the
//  Group Classes detail screen's component set (GlassCardView, PillChipView,
//  GradientCTAButton, GlassCircularIconButton, GradientFadeView — all from
//  GroupClassUIComponents.swift) since SGPT and Group Classes share the same
//  design system. See GroupTrainingDetailViewController.swift for the sibling
//  screen this one is styled after.
//
//  Built from Homepage.storyboard's "SgptSessionDetailViewController" scene
//  (storyboardIdentifier of the same name), not programmatically — this
//  module builds on Storyboard, matching GroupTrainingDetailViewController's
//  own approach (see GroupClasses.storyboard on group-classes-storyboard-
//  changes). The scroll view, hero, pager dots, title, chip stack, trainer
//  row, and bottom bar are declared in Interface Builder; everything below
//  the trainer row is an empty container view wired to an IBOutlet and
//  filled here in code (bindSeatsCard(), etc.) — the same trade
//  GroupTrainingDetailViewController itself makes for its repeated checklist
//  rows (`appendInfoRows`, built in code, not hand-placed in IB).
//
//  Scope: `GET api/sgpt-upcoming` (SgptSessionModel) only carries id/name/
//  trainer/studio/date/time/image/duration/maxSize/bookedCount/remainingSeats
//  — there is no class-detail/book/waitlist endpoint for SGPT yet, unlike
//  Group Classes. Every field the Figma frame shows beyond that list (trainer
//  rating/bio, the warm-up/main/cool-down session breakdown, "how Small Group
//  PT works", the fixed "what's included" checklist) is rendered as static
//  app copy, not per-session data — same as how GroupTrainingDetailViewController
//  itself hard-codes "What to bring"/"Things to know" defaults and a fixed
//  trainer subtitle. The bottom CTA pushes SgptPricingViewController - the
//  cancellation-policy/terms/view-profile rows are still stubs, since only
//  the reserve flow has a real next screen so far — see policyRowTapped().
//

import UIKit
import SDWebImage

final class SgptSessionDetailViewController: CommonViewController {

    // MARK: - Input

    /// Set before this screen is pushed.
    var session = SgptSessionModel()
    private var storeToken: UUID?

    // MARK: - Outlets (declared in Homepage.storyboard)

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var heroFadeView: GradientFadeView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pillSessionTag: PillChipView!
    @IBOutlet weak var pillMaxSize: PillChipView!
    @IBOutlet weak var pillDuration: PillChipView!
    @IBOutlet weak var trainerPhotoView: UIImageView!
    @IBOutlet weak var trainerRowNameLabel: UILabel!
    @IBOutlet weak var bottomBarContainer: UIView!

    /// Top offset of the back/share buttons above the hero image. Storyboard
    /// ships a `52` design-time constant (roughly right for a notched
    /// iPhone); `viewDidLayoutSubviews` overwrites it with the real device's
    /// `safeAreaInsets.top`, since a flat constant sits too close to the
    /// Dynamic Island on newer phones and leaves excess gap on others.
    @IBOutlet weak var heroTopButtonsTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var seatsCardContainer: UIView!
    @IBOutlet weak var detailsGridContainer: UIView!
    @IBOutlet weak var aboutContainer: UIView!
    @IBOutlet weak var sessionStepsContainer: UIView!
    @IBOutlet weak var trainerCardContainer: UIView!
    @IBOutlet weak var includedContainer: UIView!
    @IBOutlet weak var howItWorksContainer: UIView!
    @IBOutlet weak var moreContainer: UIView!

    // MARK: - Layout constants

    private enum Metric {
        static let iconTileSide: CGFloat = 38
        static let ctaHeight: CGFloat = 48
    }

    private enum Palette {
        static let bg = GroupClassColor.bg.color                       // #000A04
        static let cardSurface = GroupClassColor.bg2.color              // #131416
        static let cardStroke = GroupClassColor.bg3.color               // #101113
        static let hairline = UIColor.white.withAlphaComponent(0.10)
        static let bodyText75 = UIColor.white.withAlphaComponent(0.75)
        static let bodyText55 = UIColor.white.withAlphaComponent(0.55)
        static let aboutText = UIColor.white.withAlphaComponent(0.6)
        static let aboutFade = UIColor(hex: "#000A04")
        static let readMoreFill = UIColor(hex: "#1D1E1D")
        static let violetStroke = UIColor(hex: "#1A062D")
        static let violetTile = UIColor(hex: "#19112A")
        static let violetFillLight = UIColor(hex: "#8A2BE2").withAlphaComponent(0.10)
        static let ctaInk = UIColor(hex: "#141514")
    }

    private enum Copy {
        static let defaultTitle = "Small Group PT"
        static let sessionTag = "SMALL GROUP PT"
        static let seatsTagline = "Small groups mean more coaching, less waiting."
        static let about = "A small group personal training session — the trainer adapts pacing and coaching to whoever's in the room that day, not a fixed script. Suitable for all levels, with modifications offered throughout."
        static let readMore = "READ MORE ABOUT THE SESSION"
        static let showLess = "SHOW LESS ABOUT THE SESSION"
        static let trainerBio = "Certified trainer with hands-on experience coaching small groups — programming that adapts mid-session to the group's real output, not just the plan."
        static let trainerRatingValue = "4.2"
        static let trainerRatingCount = "12k ratings"
        static let howItWorksTitle = "How Small Group PT works"
        static let priceFallback = "1 credit"
        static let ctaTitle = "GET CREDIT & RESERVE"
        static let ctaBookedTitle = "VIEW BOOKING"
        static let ctaRenewTitle = "RENEW NOW"
        static let ctaComingSoonTitle = "Coming soon"
        static let ctaComingSoonMessage = "Reserving Small Group PT sessions from the app isn't available yet."
    }

    private static let aboutCollapsedLineLimit = 5

    // MARK: - Views populated in code (kept for later reference from populate())

    private let seatsProgressBar = SgptSeatsProgressView()
    private let seatsCountLabel = UILabel()
    private let aboutLabel = UILabel()
    private let aboutFadeView = GradientFadeView()
    private var isAboutExpanded = false

    /// This member already holds a seat, so the CTA reads BOOKED and no longer
    /// reserves. Comes from is_booked on the detail response, and is set again
    /// locally the moment a booking succeeds.
    private var isAlreadyBooked = false
    private weak var reserveButton: GradientCTAButton?
    private let barCaptionLabel = UILabel()
    private let barValueLabel = UILabel()
    /// Membership lapsed while credits are still good: a renewal, not a sale.
    private var eligibility: SgptEligibilityModel?
    private var shouldRenew: Bool { eligibility?.shouldRenew == true }
    private let readMoreButton = UIButton(type: .system)
    private let dateValueLabel = UILabel()
    private let timeValueLabel = UILabel()
    private let durationValueLabel = UILabel()
    private let venueValueLabel = UILabel()

    private var trainerDetail: SgptSessionDetailModel?
    private let trainerRowExperienceLabel = UILabel()
    private let trainerCardNameLabel = UILabel()
    private let trainerRatingLabel = UILabel()
    private let trainerRatingCountLabel = UILabel()
    private let trainerSkillsRow = UIStackView()
    private let trainerRatingStatLabel = UILabel()
    private let trainerExperienceStatLabel = UILabel()

    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bg
        // Without this the scroll view inherits `.automatic`, which inserts a
        // top inset the height of the safe area and pushes the hero down off
        // the top edge. Every other hero screen in the module sets it.
        scrollView.contentInsetAdjustmentBehavior = .never
        buildSections()
        populate()
        isAlreadyBooked = session.isBooked ?? false
        applyBookedState()
        loadTrainerDetail()
        loadRenewalState()
    }

    private func loadRenewalState() {
        let studioId = (session.studioId?.value).flatMap { $0.isEmpty ? nil : $0 } ?? ""
        SgptVM.sgptEligibilityApi(studioId: studioId) { [weak self] result in
            guard let self = self, let result = result else { return }
            DispatchQueue.main.async {
                self.eligibility = result
                self.applyBookedState()
            }
        }
    }

    /// Sends a lapsed member to the renewal list they already have, rather than
    /// to pricing, which would sell them credits they still hold.
    private func openRenewal() {
        DashboardVM.getPlansApi { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let plans = result?.data ?? []
                guard !plans.isEmpty else {
                    self.showComingSoon()
                    return
                }
                let vc: RenewPlanVC = .instantiate(appStoryboard: .newBookingModule)
                vc.userPlans = plans
                vc.modalPresentationStyle = .automatic
                self.present(vc, animated: true)
            }
        }
    }

    private func loadTrainerDetail() {
        let sessionId = session.id?.value ?? ""
        guard !sessionId.isEmpty else { return }

        SgptVM.sgptDetailApi(sessionId: sessionId) { [weak self] detail in
            guard let self = self, let detail = detail else { return }
            DispatchQueue.main.async {
                self.trainerDetail = detail
                if let name = detail.trainerName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
                    self.session.trainerName = name
                    self.trainerRowNameLabel.text = name
                    self.trainerCardNameLabel.text = name
                }
                self.applyTrainerDetail()
            }
        }
    }

    private func applyTrainerDetail() {
        if let description = trainerDetail?.description?.trimmingCharacters(in: .whitespacesAndNewlines),
           !description.isEmpty {
            aboutLabel.text = description
            view.layoutIfNeeded()
            updateAboutOverflowState()
        }

        let experience = SgptSessionDetailViewController.experienceText(trainerDetail?.trainerExperience?.value)
        trainerRowExperienceLabel.text = experience
        trainerRowExperienceLabel.isHidden = experience.isEmpty

        let rating = (trainerDetail?.trainerRating?.value).flatMap { $0.isEmpty || $0 == "0" ? nil : $0 }
        trainerRatingLabel.text = rating ?? "—"
        trainerRatingStatLabel.text = rating ?? "—"

        let ratingCount = trainerDetail?.trainerRatingCount ?? 0
        trainerRatingCountLabel.text = ratingCount > 0 ? "· \(ratingCount) ratings" : "· No ratings yet"

        trainerExperienceStatLabel.text = SgptSessionDetailViewController.experienceStatText(trainerDetail?.trainerExperience?.value)

        layoutSkillChips(trainerDetail?.trainerSpecialities ?? [])
    }

    private static func experienceText(_ raw: String?) -> String {
        let years = experienceYears(raw)
        guard !years.isEmpty else {
            return raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        return years == "1" ? "1 yr experience" : "\(years) yrs experience"
    }

    private static func experienceStatText(_ raw: String?) -> String {
        let years = experienceYears(raw)
        return years.isEmpty ? "—" : years
    }

    private static func experienceYears(_ raw: String?) -> String {
        guard let raw = raw else { return "" }
        var digits = ""
        var index = raw.startIndex
        while index < raw.endIndex, raw[index] == " " { index = raw.index(after: index) }
        while index < raw.endIndex, raw[index].isNumber {
            digits.append(raw[index])
            index = raw.index(after: index)
        }
        guard !digits.isEmpty else { return "" }
        while index < raw.endIndex, raw[index] == " " { index = raw.index(after: index) }
        if index < raw.endIndex, raw[index] == "+" { digits.append("+") }
        return digits
    }

    private func layoutSkillChips(_ specialities: [String]) {
        trainerSkillsRow.arrangedSubviews.forEach {
            trainerSkillsRow.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        guard !specialities.isEmpty else {
            trainerSkillsRow.isHidden = true
            return
        }
        trainerSkillsRow.isHidden = false

        let cardWidth = trainerCardContainer.bounds.width > 0 ? trainerCardContainer.bounds.width : view.bounds.width - 40
        let budget = cardWidth - 32
        let spacing = trainerSkillsRow.spacing

        let chips = specialities
            .map { name -> (chip: UIView, width: CGFloat) in
                let chip = makeSkillChip(name.uppercased())
                return (chip, chip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width)
            }
            .sorted { $0.width < $1.width }

        var used: CGFloat = 0
        var shown = 0
        for (index, entry) in chips.enumerated() {
            let advance = entry.width + (shown > 0 ? spacing : 0)
            let leftoverAfter = chips.count - (index + 1)
            let reserve: CGFloat = leftoverAfter > 0 ? overflowChipWidth(leftoverAfter) + spacing : 0
            if used + advance + reserve > budget && shown > 0 { break }
            trainerSkillsRow.addArrangedSubview(entry.chip)
            used += advance
            shown += 1
        }

        if shown == 0 {
            trainerSkillsRow.addArrangedSubview(chips[0].chip)
            shown = 1
        }
        let remaining = chips.count - shown
        if remaining > 0 {
            trainerSkillsRow.addArrangedSubview(makeSkillChip("+\(remaining)"))
        }
    }

    private func overflowChipWidth(_ remaining: Int) -> CGFloat {
        return makeSkillChip("+\(remaining)").systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true

        let sessionId = session.id?.value ?? ""
        guard !sessionId.isEmpty else { return }

        SgptStore.shared.startWatching(sessionId: sessionId)
        if storeToken == nil {
            storeToken = SgptStore.shared.observe { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .seatsChanged(let id) where id == sessionId:
                    self.applyLiveState()
                case .statusChanged(let id, _) where id == sessionId:
                    self.applyLiveState()
                case .sessionUpdated(let id, _) where id == sessionId:
                    self.applyLiveState()
                default:
                    break
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SgptStore.shared.removeObserver(storeToken)
        storeToken = nil
        let sessionId = session.id?.value ?? ""
        if !sessionId.isEmpty {
            SgptStore.shared.stopWatching(sessionId: sessionId)
        }
    }

    private func applyLiveState() {
        let sessionId = session.id?.value ?? ""
        guard !sessionId.isEmpty, let state = SgptStore.shared.state(for: sessionId) else { return }

        if let maxSize = state.maxSize {
            session.maxSize = FlexibleValue(value: String(maxSize))
        }
        if let booked = state.bookedCount {
            session.bookedCount = FlexibleValue(value: String(booked))
        }
        if let remaining = state.remainingSeats {
            session.remainingSeats = FlexibleValue(value: String(remaining))
        }

        let maxSize = GroupClassCardFormatter.intValue(session.maxSize, defaultValue: 0)
        let booked = GroupClassCardFormatter.intValue(session.bookedCount, defaultValue: 0)
        let progress = maxSize > 0 ? CGFloat(booked) / CGFloat(maxSize) : 0
        // A seat taken by someone else while this screen is open should be seen
        // moving; first paint stays instant so it doesn't run up from empty.
        seatsProgressBar.setProgress(progress, animated: viewIfLoaded?.window != nil)
        seatsCountLabel.attributedText = seatsCountText(booked: booked, maxSize: maxSize)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateHeroTopButtonsOffset()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Also called from here, not just viewSafeAreaInsetsDidChange -
        // that hook only fires on an actual CHANGE in safeAreaInsets, and
        // on this screen's push transition the final inset can already be
        // correct on the very first layout pass with no further change to
        // trigger it, so it never fired at all and the button stayed at
        // whatever the constraint's design-time value was. Recomputing
        // this here on every layout pass is harmless (same inputs always
        // give the same constant) and guarantees it's set at least once
        // with the real, settled value by the time the screen is visible.
        updateHeroTopButtonsOffset()
        updateAboutOverflowState()
    }

    /// The nav row lives inside the hero (so it scrolls away with it), which
    /// means it cannot use the safe-area guide directly.
    ///
    /// This was previously +4 (tightened from +12 because this hero is 400pt
    /// vs Group Classes' 364pt), but that put the back button at a different
    /// height from every other Group Classes / SGPT screen. Hero height changes
    /// where the hero *ends*, not where the status bar is, so the back button's
    /// offset from the top shouldn't follow it - realigned to the module-wide
    /// safeArea + 12.
    private func updateHeroTopButtonsOffset() {
        heroTopButtonsTopConstraint.constant = view.safeAreaInsets.top + 12
    }

    // MARK: - Populate

    private func populate() {
        titleLabel.text = SgptSessionDetailViewController.titleText(for: session)
        titleLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)

        let trainerName = (session.trainerName?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 } ?? "MyPT Trainer"
        trainerRowNameLabel.text = trainerName
        trainerRowNameLabel.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        trainerRowNameLabel.textColor = Palette.bodyText75
        installTrainerRowExperienceLabel()

        let fallback = UIImage(named: "class-card-placeholder")
        if let imageURL = session.image, !imageURL.isEmpty, let url = URL(string: imageURL) {
            heroImageView.sd_setImage(with: url, placeholderImage: fallback)
        } else {
            heroImageView.image = fallback
        }
        heroFadeView.setColors([Palette.bg.withAlphaComponent(0.0), Palette.bg])
        trainerPhotoView.image = icon(system: "person.crop.circle.fill")
        trainerPhotoView.tintColor = .white.withAlphaComponent(0.4)
        trainerPhotoView.layer.cornerRadius = 9.188

        styleChip(pillSessionTag)
        styleChip(pillMaxSize)
        styleChip(pillDuration)
        pillSessionTag.configure(text: Copy.sessionTag, font: AppFont.medium.size(12.0, familyName: familyFunnelSans), textColor: UIColor(hex: "#F0F0F0"))
        let booked = GroupClassCardFormatter.intValue(session.bookedCount, defaultValue: 0)
        let maxSize = GroupClassCardFormatter.intValue(session.maxSize, defaultValue: max(booked, 1))
        pillMaxSize.configure(text: "MAX \(maxSize) PEOPLE", font: AppFont.medium.size(12.0, familyName: familyFunnelSans), textColor: UIColor(hex: "#F0F0F0"))
        pillDuration.configure(text: "\(GroupClassCardFormatter.intValue(session.duration, defaultValue: 60)) MIN", font: AppFont.medium.size(12.0, familyName: familyFunnelSans), textColor: UIColor(hex: "#F0F0F0"))

        let progress = maxSize > 0 ? CGFloat(booked) / CGFloat(maxSize) : 0
        seatsProgressBar.setProgress(progress)
        seatsCountLabel.attributedText = seatsCountText(booked: booked, maxSize: maxSize)

        dateValueLabel.text = SgptSessionDetailViewController.formattedDate(session.date)
        timeValueLabel.text = SgptSessionDetailViewController.formattedTime(session.time)
        durationValueLabel.text = "\(GroupClassCardFormatter.intValue(session.duration, defaultValue: 60)) min"
        venueValueLabel.text = (session.studioName?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 } ?? "MyPT Studio"
    }

    private func installTrainerRowExperienceLabel() {
        guard trainerRowExperienceLabel.superview == nil,
              let row = trainerRowNameLabel.superview as? UIStackView,
              let index = row.arrangedSubviews.firstIndex(of: trainerRowNameLabel) else { return }

        trainerRowExperienceLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        trainerRowExperienceLabel.textColor = Palette.bodyText55
        trainerRowExperienceLabel.numberOfLines = 1
        trainerRowExperienceLabel.isHidden = true

        row.removeArrangedSubview(trainerRowNameLabel)
        trainerRowNameLabel.removeFromSuperview()

        let column = UIStackView(arrangedSubviews: [trainerRowNameLabel, trainerRowExperienceLabel])
        column.axis = .vertical
        column.alignment = .leading
        column.spacing = 2
        row.insertArrangedSubview(column, at: index)
    }

    private func styleChip(_ chip: PillChipView) {
        chip.fillColor = .clear
        chip.strokeColor = UIColor.white.withAlphaComponent(0.2)
        chip.contentInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        chip.titleLabel.lineBreakMode = .byTruncatingTail
    }

    private func seatsCountText(booked: Int, maxSize: Int) -> NSAttributedString {
        let result = NSMutableAttributedString(
            string: String(format: "%02d", booked),
            attributes: [.font: AppFont.medium.size(20.0, familyName: familyClashDisplay), .foregroundColor: UIColor.white])
        result.append(NSAttributedString(
            string: "/\(String(format: "%02d", maxSize)) joined",
            attributes: [.font: AppFont.regular.size(14.0, familyName: familyClashDisplay),
                        .foregroundColor: UIColor.white.withAlphaComponent(0.55)]))
        return result
    }

    // MARK: - Static formatting

    static func titleText(for item: SgptSessionModel) -> String {
        if let name = item.sessionName, !name.isEmpty { return name }
        return Copy.defaultTitle
    }

    /// `date`: "yyyy-MM-dd" -> "EEE d MMM".
    static func formattedDate(_ dateStr: String?) -> String {
        guard let dateStr = dateStr, !dateStr.isEmpty else { return "--" }
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "yyyy-MM-dd"
        guard let date = input.date(from: dateStr) else { return "--" }
        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.dateFormat = "EEE d MMM"
        return output.string(from: date)
    }

    /// `time`: "HH:mm:ss" -> "h:mm a".
    static func formattedTime(_ timeStr: String?) -> String {
        guard let timeStr = timeStr, !timeStr.isEmpty else { return "--" }
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "HH:mm:ss"
        guard let date = input.date(from: timeStr) else { return "--" }
        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.dateFormat = "h:mm a"
        return output.string(from: date)
    }

    // MARK: - Actions (connected in Homepage.storyboard)

    @IBAction func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func shareTapped() {
        let text = "\(titleLabel.text ?? Copy.defaultTitle) — Small Group PT on MyPT"
        present(UIActivityViewController(activityItems: [text], applicationActivities: nil), animated: true)
    }

    /// Reserve routes on credit balance: holding credits opens the checkout
    /// sheet, otherwise the member goes to pricing to buy some. A failed or
    /// unauthenticated balance lookup falls through to pricing too, so the CTA
    /// always leads somewhere. Mirrors Android's
    /// SgptSessionDetailActivity.openCheckoutOrPricing().
    @IBAction func reserveTapped() {
        guard !isAlreadyBooked else {
            showBookingConfirmation()
            return
        }
        if shouldRenew {
            openRenewal()
            return
        }
        SgptVM.sgptCreditsApi(isShowLoader: true) { [weak self] credits in
            DispatchQueue.main.async {
                guard let self = self else { return }

                let balance = credits?.remainingCredits ?? 0
                guard credits?.hasCredits == true, balance > 0 else {
                    self.pushPricing()
                    return
                }

                let total = credits?.totalCredits ?? 0
                let input = SgptCheckoutInput(
                    session: self.session,
                    creditsUsed: 1,
                    creditsBalance: balance,
                    creditsTotal: total,
                    expiresInDays: credits?.expiresInDays
                )
                SgptCheckoutSheetViewController.present(
                    from: self,
                    input: input,
                    onConfirm: { [weak self] in
                        self?.bookWithCredits(expiresInDays: credits?.expiresInDays,
                                              creditsTotal: total)
                    },
                    onViewProfile: { [weak self] in self?.viewProfileTapped() }
                )
            }
        }
    }

    private func pushPricing() {
        let vc: SgptPricingViewController = .instantiate(appStoryboard: .sgpt)
        vc.sessionId = session.id?.value ?? ""
        vc.session = session
        // Without a club id, eligibility and bundles answer for no club in
        // particular. api/sgpt-upcoming carries one now, and api/sgpt-detail
        // fills it in for sessions opened before that call landed.
        vc.studioId = (session.studioId?.value).flatMap { $0.isEmpty ? nil : $0 }
            ?? (trainerDetail?.studioId?.value ?? "")
        vc.sessionName = session.sessionName ?? ""
        vc.sessionTrainerName = session.trainerName ?? ""
        // Formatted here rather than downstream: these helpers live on this
        // screen and already produce the exact strings the summary card shows.
        // "--" is their empty marker, which the summary's meta line should
        // drop rather than print.
        let date = Self.formattedDate(session.date)
        let time = Self.formattedTime(session.time)
        vc.sessionDate = date == "--" ? "" : date
        vc.sessionTime = time == "--" ? "" : time
        vc.sessionImageURL = session.image ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }

    /// Spends a credit on this session via api/sgpt-book, then re-reads the
    /// session so the seats card reflects the booking just made.
    private func bookWithCredits(expiresInDays: Int?, creditsTotal: Int) {
        let sessionId = session.id?.value ?? ""
        guard !sessionId.isEmpty else { return }

        SgptVM.sgptBookApi(sessionId: sessionId) { [weak self] result, errorMessage in
            DispatchQueue.main.async {
                guard let self = self else { return }

                guard let result = result else {
                    let message = errorMessage ?? "Could not reserve this session. Please try again."
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }

                let remaining = result.remainingCredits ?? 0

                // Reflect the seat just taken without re-fetching the screen.
                if let seats = result.remainingSeats {
                    let maxSize = GroupClassCardFormatter.intValue(self.session.maxSize, defaultValue: 0)
                    let booked = max(0, maxSize - seats)
                    self.session.remainingSeats = FlexibleValue(value: String(seats))
                    self.session.bookedCount = FlexibleValue(value: String(booked))

                    let progress = maxSize > 0 ? CGFloat(booked) / CGFloat(maxSize) : 0
                    self.seatsProgressBar.setProgress(progress, animated: true)
                    self.seatsCountLabel.attributedText = self.seatsCountText(booked: booked, maxSize: maxSize)
                }

                self.session.isBooked = true
                self.isAlreadyBooked = true
                self.applyBookedState()

                var input = SgptBookingSuccessInput(session: self.session)
                input.mode = .bookedWithExistingCredits
                input.creditsUsed = 1
                input.creditsRemaining = remaining
                input.expiresInDays = expiresInDays
                input.creditsTotal = creditsTotal
                SgptBookingSuccessViewController.start(from: self, input: input)
            }
        }
    }

    @objc private func readMoreTapped() {
        isAboutExpanded.toggle()
        aboutLabel.numberOfLines = isAboutExpanded ? 0 : SgptSessionDetailViewController.aboutCollapsedLineLimit
        readMoreButton.setTitle(isAboutExpanded ? Copy.showLess : Copy.readMore, for: .normal)
        UIView.animate(withDuration: 0.2) { self.view.layoutIfNeeded() }
        updateAboutOverflowState()
    }

    @objc private func policyRowTapped() {
        showComingSoon()
    }

    @objc private func viewProfileTapped() {
        let trainerId = trainerDetail?.trainerId?.value ?? ""
        guard !trainerId.isEmpty else {
            showComingSoon()
            return
        }

        let vc: TrainerDescriptionViewController = .instantiate(appStoryboard: .booking)
        vc.inputParam = DetailsParam(
            trainer_id: trainerId,
            studio_id: trainerDetail?.studioId?.value ?? "",
            type: "gym",
            long: String(GroupClassCardFormatter.doubleValue(session.studioLng, defaultValue: 55.2708)),
            lat: String(GroupClassCardFormatter.doubleValue(session.studioLat, defaultValue: 25.2048))
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showBookingConfirmation() {
        var input = SgptBookingSuccessInput(session: session)
        input.mode = .bookedWithExistingCredits
        input.creditsUsed = 1
        SgptBookingSuccessViewController.start(from: self, input: input)
    }

    private func applyBookedState() {
        guard let button = reserveButton else { return }
        let title: String
        if isAlreadyBooked {
            title = Copy.ctaBookedTitle
        } else if shouldRenew {
            title = Copy.ctaRenewTitle
            applyRenewalBarCopy()
        } else {
            title = Copy.ctaTitle
            barCaptionLabel.text = "PER SESSION FEE"
            barValueLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
            barValueLabel.text = Copy.priceFallback
        }
        button.configure(title: title,
                         font: AppFont.medium.size(14.0, familyName: familyFunnelSans),
                         titleColor: Palette.ctaInk)
        button.setTrailingIcon(UIImage(named: "sgpt-ic-chevron-right") ?? icon(system: "chevron.right"),
                               tint: Palette.ctaInk)
        button.isEnabled = true
        button.alpha = 1
    }

    private func applyRenewalBarCopy() {
        let club = (eligibility?.membershipStudioName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        barCaptionLabel.text = club.isEmpty
            ? "GYM MEMBERSHIP EXPIRED"
            : "MEMBERSHIP EXPIRED · \(club)".uppercased()

        let credits = eligibility?.remainingCredits ?? 0
        var line = credits == 1 ? "1 credit still valid" : "\(credits) credits still valid"
        if let until = eligibility?.creditsExpireOn, !until.isEmpty {
            line += " until \(Self.formattedDate(until))"
        }
        barValueLabel.font = AppFont.medium.size(15.0, familyName: familyClashDisplay)
        barValueLabel.text = line
    }

    private func showComingSoon() {
        let alert = UIAlertController(title: Copy.ctaComingSoonTitle, message: Copy.ctaComingSoonMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /// Hides the collapsed-copy scrim/button once the full paragraph already
    /// fits within the collapsed line limit.
    private func updateAboutOverflowState() {
        guard aboutLabel.bounds.width > 0, let text = aboutLabel.text, !text.isEmpty else { return }
        let fullHeight = (text as NSString).boundingRect(
            with: CGSize(width: aboutLabel.bounds.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: aboutLabel.font as Any],
            context: nil).height
        let lineHeight = aboutLabel.font.lineHeight
        let collapsedHeight = lineHeight * CGFloat(SgptSessionDetailViewController.aboutCollapsedLineLimit)
        let overflows = fullHeight > collapsedHeight + 1
        aboutFadeView.isHidden = isAboutExpanded || !overflows
        readMoreButton.isHidden = !overflows
    }
}

// MARK: - Section building (each fills the empty container IBOutlet wired to it)

private extension SgptSessionDetailViewController {

    func buildSections() {
        fill(seatsCardContainer, with: makeSeatsCard())
        fill(detailsGridContainer, with: makeDetailsGrid())
        fill(aboutContainer, with: makeAboutBlock())
        fill(sessionStepsContainer, with: makeSessionSteps())
        fill(trainerCardContainer, with: makeTrainerCard())

        let includedStack = UIStackView()
        includedStack.axis = .vertical
        includedStack.alignment = .fill
        includedStack.spacing = 0
        appendInfoRows(SgptSessionDetailViewController.whatsIncludedRows, to: includedStack)
        fill(includedContainer, with: includedStack)

        fill(howItWorksContainer, with: makeHowItWorksCard())

        // Same real assets Android uses (ic_person_age_18/ic_clock_18,
        // already bundled for Group Classes) instead of generic SF Symbols.
        let moreColumn = UIStackView(arrangedSubviews: [
            makePolicyRow(icon: "ic_person_age_18", systemFallback: "person.fill", title: "Cancellation policy"),
            makePolicyRow(icon: "ic_clock_18", systemFallback: "clock.fill", title: "Terms and conditions")
        ])
        moreColumn.axis = .vertical
        moreColumn.alignment = .fill
        moreColumn.spacing = 8
        fill(moreContainer, with: moreColumn)

        fill(bottomBarContainer, with: makeBottomBar())
    }

    /// Pins `content` to fill `container` and lets `container`'s own height
    /// (a placeholder constraint in IB) resize to match - every section
    /// container in the storyboard exists purely to receive one of these.
    func fill(_ container: UIView, with content: UIView) {
        content.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: container.topAnchor),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    // MARK: Group seats card

    func makeSeatsCard() -> UIView {
        // Matches Android's bg_group_seats_photo: a flattened Figma export
        // (the card's actual violet glow/gradient look, not reproducible
        // with a flat fill + stroke), clipped to the card's own corner
        // radius with no separate border on top - see sgpt-seats-card-bg
        // in Assets.xcassets/Sgpt.
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 12
        card.clipsToBounds = true

        let bgImageView = UIImageView(image: UIImage(named: "sgpt-seats-card-bg"))
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.contentMode = .scaleToFill
        card.addSubview(bgImageView)
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: card.topAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        titleLabel.textColor = Palette.bodyText75
        titleLabel.text = "Group seats available"

        seatsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        seatsCountLabel.textAlignment = .right

        seatsProgressBar.translatesAutoresizingMaskIntoConstraints = false

        let personTile = UIView()
        personTile.translatesAutoresizingMaskIntoConstraints = false
        personTile.backgroundColor = UIColor(hex: "#8A2BE2").withAlphaComponent(0.5)
        personTile.layer.cornerRadius = 6.3

        let personIcon = UIImageView(image: UIImage(named: "sgpt-ic-profile-2user") ?? icon(system: "person.2.fill"))
        personIcon.translatesAutoresizingMaskIntoConstraints = false
        personIcon.tintColor = .white
        personIcon.contentMode = .scaleAspectFit
        personTile.addSubview(personIcon)

        let taglineLabel = UILabel()
        taglineLabel.translatesAutoresizingMaskIntoConstraints = false
        taglineLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        taglineLabel.textColor = .white.withAlphaComponent(0.8)
        taglineLabel.numberOfLines = 2
        taglineLabel.text = Copy.seatsTagline

        let taglineRow = UIStackView(arrangedSubviews: [personTile, taglineLabel])
        taglineRow.translatesAutoresizingMaskIntoConstraints = false
        taglineRow.axis = .horizontal
        taglineRow.alignment = .center
        taglineRow.spacing = 10

        let headerRow = UIStackView(arrangedSubviews: [titleLabel, seatsCountLabel])
        headerRow.translatesAutoresizingMaskIntoConstraints = false
        headerRow.axis = .horizontal
        headerRow.alignment = .center

        let column = UIStackView(arrangedSubviews: [headerRow, seatsProgressBar, taglineRow])
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 10
        card.addSubview(column)

        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: card.topAnchor, constant: 13),
            column.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            column.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            column.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -13),

            personTile.widthAnchor.constraint(equalToConstant: 20),
            personTile.heightAnchor.constraint(equalToConstant: 20),
            personIcon.centerXAnchor.constraint(equalTo: personTile.centerXAnchor),
            personIcon.centerYAnchor.constraint(equalTo: personTile.centerYAnchor),
            personIcon.widthAnchor.constraint(equalToConstant: 11),
            personIcon.heightAnchor.constraint(equalToConstant: 11)
        ])
        return card
    }

    // MARK: Session Details grid

    func makeDetailsGrid() -> UIView {
        let dateCell = makeGridCell(valueLabel: dateValueLabel, caption: "Date")
        let timeCell = makeGridCell(valueLabel: timeValueLabel, caption: "Time")
        let durationCell = makeGridCell(valueLabel: durationValueLabel, caption: "Duration")
        let venueCell = makeGridCell(valueLabel: venueValueLabel, caption: "Venue")

        let row1 = UIStackView(arrangedSubviews: [dateCell, timeCell])
        row1.translatesAutoresizingMaskIntoConstraints = false
        row1.axis = .horizontal
        row1.alignment = .fill
        row1.distribution = .fillEqually
        row1.spacing = 10

        let row2 = UIStackView(arrangedSubviews: [durationCell, venueCell])
        row2.translatesAutoresizingMaskIntoConstraints = false
        row2.axis = .horizontal
        row2.alignment = .fill
        row2.distribution = .fillEqually
        row2.spacing = 10

        let column = UIStackView(arrangedSubviews: [row1, row2])
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 10
        return column
    }

    func makeGridCell(valueLabel: UILabel, caption: String) -> UIView {
        // Android's bg_dark_radial_sheen_12: solid fill + stroke + an 8%
        // white radial sheen biased top-center - this was a flat fill with
        // no sheen at all.
        let card = GlassCardView(cornerRadius: 12)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardSurface
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        valueLabel.textColor = UIColor(hex: "#F0F0F0")
        valueLabel.numberOfLines = 1
        valueLabel.lineBreakMode = .byTruncatingTail

        let captionLabel = UILabel()
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        captionLabel.textColor = .white.withAlphaComponent(0.8)
        captionLabel.text = caption

        let column = UIStackView(arrangedSubviews: [valueLabel, captionLabel])
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .leading
        column.spacing = 4
        card.addSubview(column)

        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            column.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            column.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16),
            column.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    // MARK: About block

    func makeAboutBlock() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds = true

        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        aboutLabel.textColor = Palette.aboutText
        aboutLabel.numberOfLines = SgptSessionDetailViewController.aboutCollapsedLineLimit
        aboutLabel.lineBreakMode = .byTruncatingTail
        aboutLabel.text = Copy.about

        aboutFadeView.translatesAutoresizingMaskIntoConstraints = false
        aboutFadeView.setColors([Palette.aboutFade.withAlphaComponent(0.0), Palette.aboutFade.withAlphaComponent(0.85), Palette.aboutFade], locations: [0.0, 0.5, 1.0])

        readMoreButton.translatesAutoresizingMaskIntoConstraints = false
        readMoreButton.setTitle(Copy.readMore, for: .normal)
        readMoreButton.setTitleColor(.white, for: .normal)
        readMoreButton.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        readMoreButton.backgroundColor = Palette.readMoreFill
        readMoreButton.layer.cornerRadius = 8
        readMoreButton.layer.borderWidth = 1
        readMoreButton.layer.borderColor = Palette.hairline.cgColor
        readMoreButton.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)

        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        textContainer.clipsToBounds = true
        textContainer.addSubview(aboutLabel)
        textContainer.addSubview(aboutFadeView)

        let column = UIStackView(arrangedSubviews: [textContainer, readMoreButton])
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 8
        container.addSubview(column)

        NSLayoutConstraint.activate([
            aboutLabel.topAnchor.constraint(equalTo: textContainer.topAnchor),
            aboutLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            aboutLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            aboutLabel.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor),

            aboutFadeView.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            aboutFadeView.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            aboutFadeView.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor),
            aboutFadeView.heightAnchor.constraint(equalToConstant: 40),

            readMoreButton.heightAnchor.constraint(equalToConstant: 42),

            column.topAnchor.constraint(equalTo: container.topAnchor),
            column.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            column.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            column.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    // MARK: Session steps (static — no per-session breakdown API)

    func makeSessionSteps() -> UIView {
        // Icons are the same real Figma glyphs Android uses (workout-
        // stretching / equipment-bench-press / yoga-02, downloaded straight
        // from the Figma node), not generic SF Symbol stand-ins - see
        // ic_workout_stretching_22/ic_equipment_bench_press_20/ic_yoga_02_18
        // in Assets.xcassets/Sgpt.
        let steps: [(icon: String, systemFallback: String, title: String, tag: String, body: String)] = [
            ("ic_workout_stretching_22", "figure.flexibility", "Warm-up", "10 MINS", "Dynamic mobility work and activation drills to get the group moving safely."),
            ("ic_equipment_bench_press_20", "dumbbell.fill", "Main Training", "35 MINS", "Coached sets and supersets, paced and adjusted to the group in the room."),
            ("ic_yoga_02_18", "figure.mind.and.body", "Cool-down", "5 MINS", "Stretching and a breathing reset to close out the session.")
        ]

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Figma node 11150:61492: 1pt line connecting the FIRST icon tile's
        // centre to the LAST tile's centre, #ACADAF fading to transparent
        // at ~60% and back - matches Android's bg_session_steps_connector
        // and layoutStepsConnector(), which this was missing entirely.
        let connectorLine = GradientFadeView()
        connectorLine.translatesAutoresizingMaskIntoConstraints = false
        let connectorColor = UIColor(hex: "#ACADAF")
        connectorLine.setColors([connectorColor, connectorColor.withAlphaComponent(0), connectorColor],
                                 locations: [0, 0.6, 1])
        container.addSubview(connectorLine)

        let column = UIStackView()
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 20
        container.addSubview(column)

        var firstIconTile: UIView?
        var lastIconTile: UIView?

        for step in steps {
            // Android's real bg_icon_tile_violet (its own comment: "bright
            // violet tile, not the near-black one used before") - a lighter
            // #3A2058 border (not the app-wide #1A062D violetStroke used on
            // other cards) and a much stronger, violet-tinted sheen than
            // the generic 8%-white one every other card on this screen uses.
            // Android's own glow (bg_icon_tile_violet.xml) is a radial spot
            // centered at (0.5, 0.34) - slightly above middle, not the top
            // edge - with gradientRadius=24dp on a 38dp tile, AND it fades
            // to a still-partly-opaque #4D8A2BE1 (30% alpha blueviolet) at
            // its edge rather than fully transparent, which is what keeps a
            // violet tint at the tile's corners instead of settling back to
            // the flat base fill. The center/edge overrides reproduce that
            // exact hotspot+radius (iconTileSide is also 38pt here, so the
            // dp numbers carry over 1:1); sheenEndColor/Alpha reproduce the
            // partly-opaque fade.
            let iconTile = makeIconTile(image: UIImage(named: step.icon) ?? icon(system: step.systemFallback), iconSide: 20,
                                        tileColor: Palette.violetTile, borderColor: UIColor(hex: "#3A2058"),
                                        sheenColor: UIColor(hex: "#B98CF0"), sheenAlpha: 0.85,
                                        sheenCenterOverride: CGPoint(x: 0.5, y: 0.34),
                                        sheenEdgeOverride: CGPoint(x: 0.5, y: 0.34 + 24.0 / 38.0),
                                        sheenEndColor: UIColor(hex: "#8A2BE1"), sheenEndAlpha: 0.30)
            firstIconTile = firstIconTile ?? iconTile
            lastIconTile = iconTile

            let stepTitle = UILabel()
            stepTitle.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            stepTitle.textColor = Palette.bodyText75
            stepTitle.text = step.title

            let tag = PillChipView(text: step.tag)
            tag.fillColor = .clear
            tag.strokeColor = UIColor.white.withAlphaComponent(0.2)
            tag.contentInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
            tag.configure(text: step.tag, font: AppFont.medium.size(12.0, familyName: familyFunnelSans), textColor: UIColor(hex: "#F0F0F0"))

            // Android packs title+pill together at the leading edge with a
            // fixed 10px gap and lets the row's own trailing space sit
            // empty (no grow on either child) - now that the pill has a
            // real intrinsic size (previous fix), simply putting it next to
            // a plain UILabel with no trailing spacer let the label (the
            // only view *without* required hugging) absorb 100% of this
            // row's slack width, pushing the pill all the way to the far
            // right instead of sitting beside the title. The trailing
            // spacer is the one that should absorb the slack instead.
            stepTitle.setContentHuggingPriority(.required, for: .horizontal)
            let titleRowSpacer = UIView()

            let titleRow = UIStackView(arrangedSubviews: [stepTitle, tag, titleRowSpacer])
            titleRow.axis = .horizontal
            titleRow.alignment = .center
            titleRow.spacing = 10

            let bodyLabel = UILabel()
            bodyLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            bodyLabel.textColor = Palette.bodyText55
            bodyLabel.numberOfLines = 0
            bodyLabel.text = step.body

            let textColumn = UIStackView(arrangedSubviews: [titleRow, bodyLabel])
            textColumn.axis = .vertical
            textColumn.alignment = .fill
            textColumn.spacing = 4

            let row = UIStackView(arrangedSubviews: [iconTile, textColumn])
            row.translatesAutoresizingMaskIntoConstraints = false
            row.axis = .horizontal
            row.alignment = .top
            row.spacing = 10
            column.addArrangedSubview(row)
        }

        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: container.topAnchor),
            column.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            column.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            column.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        if let first = firstIconTile, let last = lastIconTile {
            NSLayoutConstraint.activate([
                connectorLine.widthAnchor.constraint(equalToConstant: 1),
                connectorLine.centerXAnchor.constraint(equalTo: first.centerXAnchor),
                connectorLine.topAnchor.constraint(equalTo: first.centerYAnchor),
                connectorLine.bottomAnchor.constraint(equalTo: last.centerYAnchor)
            ])
        }
        return container
    }

    // MARK: Trainer card (static rating/bio — no per-trainer profile API for SGPT)

    func makeTrainerCard() -> UIView {
        // Matches Android's real trainer card: a 200pt full-width photo
        // banner (violet-wash gradient backdrop + placeholder glyph +
        // bottom scrim fading into the info section) above the padded
        // info column - this used to build a small 64x64 circular avatar
        // inline next to the name instead, a completely different layout.
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Palette.cardSurface
        card.layer.cornerRadius = 20
        card.clipsToBounds = true

        // Photo banner: Figma's "Image Frame" gradient backdrop
        // (#000A04 -> #1A062D -> rgba(138,43,225,0.1)), a placeholder glyph
        // standing in for the real trainer photo (no photo API for SGPT
        // trainers yet), and a bottom scrim fading into the card's own
        // surface color so the banner blends into the info section below.
        let photoBanner = UIView()
        photoBanner.translatesAutoresizingMaskIntoConstraints = false
        photoBanner.clipsToBounds = true
        card.addSubview(photoBanner)

        let backdropGradient = GradientFadeView()
        backdropGradient.translatesAutoresizingMaskIntoConstraints = false
        backdropGradient.setColors([UIColor(hex: "#000A04"), UIColor(hex: "#1A062D"), UIColor(hex: "#8A2BE2").withAlphaComponent(0.1)])
        photoBanner.addSubview(backdropGradient)

        let avatarIcon = UIImageView(image: icon(system: "person.crop.circle.fill"))
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarIcon.contentMode = .scaleAspectFit
        avatarIcon.tintColor = .white.withAlphaComponent(0.25)
        photoBanner.addSubview(avatarIcon)

        let photoScrim = GradientFadeView()
        photoScrim.translatesAutoresizingMaskIntoConstraints = false
        photoScrim.setColors([Palette.cardSurface.withAlphaComponent(0), Palette.cardSurface.withAlphaComponent(0), Palette.cardSurface],
                              locations: [0, 0.38, 1])
        photoBanner.addSubview(photoScrim)

        NSLayoutConstraint.activate([
            photoBanner.topAnchor.constraint(equalTo: card.topAnchor),
            photoBanner.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            photoBanner.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            photoBanner.heightAnchor.constraint(equalToConstant: 200),

            backdropGradient.topAnchor.constraint(equalTo: photoBanner.topAnchor),
            backdropGradient.leadingAnchor.constraint(equalTo: photoBanner.leadingAnchor),
            backdropGradient.trailingAnchor.constraint(equalTo: photoBanner.trailingAnchor),
            backdropGradient.bottomAnchor.constraint(equalTo: photoBanner.bottomAnchor),

            avatarIcon.centerXAnchor.constraint(equalTo: photoBanner.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: photoBanner.centerYAnchor),
            avatarIcon.widthAnchor.constraint(equalToConstant: 88),
            avatarIcon.heightAnchor.constraint(equalToConstant: 88),

            photoScrim.leadingAnchor.constraint(equalTo: photoBanner.leadingAnchor),
            photoScrim.trailingAnchor.constraint(equalTo: photoBanner.trailingAnchor),
            photoScrim.bottomAnchor.constraint(equalTo: photoBanner.bottomAnchor),
            photoScrim.heightAnchor.constraint(equalToConstant: 90)
        ])

        let nameLabel = trainerCardNameLabel
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        nameLabel.textColor = UIColor(hex: "#F0F0F0")
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.text = trainerRowNameLabel.text

        let starIcon = UIImageView(image: UIImage(named: "sgpt-ic-star") ?? icon(system: "star.fill"))
        starIcon.tintColor = UIColor(hex: "#FFCC33")
        starIcon.contentMode = .scaleAspectFit
        trainerRatingLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        trainerRatingLabel.textColor = .white
        trainerRatingLabel.text = Copy.trainerRatingValue
        trainerRatingCountLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        trainerRatingCountLabel.textColor = UIColor(hex: "#959595")
        trainerRatingCountLabel.text = Copy.trainerRatingCount
        let ratingBlock = UIStackView(arrangedSubviews: [starIcon, trainerRatingLabel, trainerRatingCountLabel])
        ratingBlock.axis = .horizontal
        ratingBlock.alignment = .center
        ratingBlock.spacing = 4
        ratingBlock.setContentHuggingPriority(.required, for: .horizontal)
        ratingBlock.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([starIcon.widthAnchor.constraint(equalToConstant: 16), starIcon.heightAnchor.constraint(equalToConstant: 16)])

        let nameRow = UIStackView(arrangedSubviews: [nameLabel, ratingBlock])
        nameRow.axis = .horizontal
        nameRow.alignment = .center
        nameRow.spacing = 12

        let skillsRow = trainerSkillsRow
        skillsRow.translatesAutoresizingMaskIntoConstraints = false
        skillsRow.axis = .horizontal
        skillsRow.alignment = .center
        skillsRow.spacing = 5
        skillsRow.isHidden = true

        // Same fix as the header chip row (sgd069 shim in the storyboard):
        // every arranged subview here is a required-hugging pill with no
        // flexible sibling to absorb slack, so letting column's .fill
        // alignment force-stretch this row wide creates the identical
        // unsatisfiable conflict - one pill's width breaking unpredictably.
        // A shim satisfies column's fill alignment while skillsRow itself
        // hugs its real combined width and stays leading-aligned.
        let skillsRowShim = UIView()
        skillsRowShim.translatesAutoresizingMaskIntoConstraints = false
        skillsRowShim.addSubview(skillsRow)
        NSLayoutConstraint.activate([
            skillsRow.topAnchor.constraint(equalTo: skillsRowShim.topAnchor),
            skillsRow.leadingAnchor.constraint(equalTo: skillsRowShim.leadingAnchor),
            skillsRow.bottomAnchor.constraint(equalTo: skillsRowShim.bottomAnchor),
            skillsRowShim.trailingAnchor.constraint(greaterThanOrEqualTo: skillsRow.trailingAnchor)
        ])

        let bioLabel = UILabel()
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        bioLabel.textColor = .white.withAlphaComponent(0.6)
        bioLabel.numberOfLines = 0
        bioLabel.text = Copy.trainerBio

        let statsRow = UIStackView(arrangedSubviews: [
            makeStatCell(valueLabel: trainerRatingStatLabel, value: Copy.trainerRatingValue, caption: "Rating"),
            makeStatCell(valueLabel: trainerExperienceStatLabel, value: "—", caption: "years Exp."),
            makeStatCell(value: "504", caption: "Session held")
        ])
        statsRow.axis = .horizontal
        statsRow.alignment = .fill
        statsRow.distribution = .fillEqually
        statsRow.spacing = 10

        let viewProfileButton = UIButton(type: .system)
        viewProfileButton.translatesAutoresizingMaskIntoConstraints = false
        viewProfileButton.setTitle("VIEW PROFILE", for: .normal)
        viewProfileButton.setTitleColor(.white, for: .normal)
        viewProfileButton.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        viewProfileButton.backgroundColor = Palette.readMoreFill
        viewProfileButton.layer.cornerRadius = 8
        viewProfileButton.layer.borderWidth = 1
        viewProfileButton.layer.borderColor = Palette.hairline.cgColor
        viewProfileButton.addTarget(self, action: #selector(viewProfileTapped), for: .touchUpInside)
        viewProfileButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        viewProfileButton.semanticContentAttribute = .forceRightToLeft
        viewProfileButton.setImage(UIImage(named: "sgpt-ic-chevron-right") ?? icon(system: "chevron.right"), for: .normal)
        viewProfileButton.tintColor = .white.withAlphaComponent(0.4)
        viewProfileButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

        let column = UIStackView(arrangedSubviews: [nameRow, skillsRowShim, bioLabel, statsRow, viewProfileButton])
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 16
        card.addSubview(column)

        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: photoBanner.bottomAnchor, constant: 16),
            column.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            column.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            column.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    func makeSkillChip(_ text: String) -> UIView {
        let chip = PillChipView(text: text)
        chip.fillColor = .clear
        chip.strokeColor = Palette.hairline
        chip.contentInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        chip.configure(text: text, font: AppFont.medium.size(12.0, familyName: familyFunnelSans), textColor: .white)
        return chip
    }

    func makeStatCell(valueLabel: UILabel, value: String, caption: String) -> UIView {
        return makeStatCell(value: value, caption: caption, valueLabel: valueLabel)
    }

    func makeStatCell(value: String, caption: String, valueLabel providedValueLabel: UILabel? = nil) -> UIView {
        // Same bg_dark_radial_sheen_12 recipe as makeGridCell() - was
        // missing the sheen here too.
        let card = GlassCardView(cornerRadius: 12)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardSurface
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        let valueLabel = providedValueLabel ?? UILabel()
        valueLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        valueLabel.textColor = UIColor(hex: "#F0F0F0")
        valueLabel.textAlignment = .center
        valueLabel.text = value

        let captionLabel = UILabel()
        captionLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        captionLabel.textColor = .white.withAlphaComponent(0.8)
        captionLabel.textAlignment = .center
        captionLabel.text = caption

        let column = UIStackView(arrangedSubviews: [valueLabel, captionLabel])
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .center
        column.spacing = 4
        card.addSubview(column)

        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            column.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            column.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            column.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8)
        ])
        return card
    }

    // MARK: What's included rows

    // Icons and copy match Android's includedTowel/Rope/Shoes/Clothes rows
    // exactly (ic_towel_18/ic_skipping_18/ic_shoes_18/ic_clothes_18 - the
    // same assets already bundled for Group Classes' "what to bring" list).
    // This used to show generic SF Symbols and the wrong second row copy
    // ("Bring your own water bottle" instead of "Bring your skipping rope").
    static var whatsIncludedRows: [(icon: String, systemFallback: String, text: String)] {
        return [
            ("ic_towel_18", "drop.fill", "Bring a towel — sweating is guaranteed"),
            ("ic_skipping_18", "figure.walk", "Bring your skipping rope"),
            ("ic_shoes_18", "shoeprints.fill", "Training shoes with lateral support"),
            ("ic_clothes_18", "tshirt.fill", "Comfortable workout clothing")
        ]
    }

    func appendInfoRows(_ rows: [(icon: String, systemFallback: String, text: String)], to column: UIStackView) {
        for (index, row) in rows.enumerated() {
            let image = UIImage(named: row.icon) ?? icon(system: row.systemFallback)
            let view = makeInfoRow(icon: image, text: row.text)
            column.addArrangedSubview(view)
            if index < rows.count - 1 {
                column.setCustomSpacing(10, after: view)
            }
        }
    }

    func makeInfoRow(icon: UIImage?, text: String) -> UIView {
        let iconTile = makeIconTile(image: icon, iconSide: 18, tileColor: Palette.cardSurface, borderColor: Palette.cardStroke)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        label.textColor = UIColor(hex: "#F0F0F0")
        label.numberOfLines = 0
        label.text = text

        let row = UIStackView(arrangedSubviews: [iconTile, label])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    // MARK: How Small Group PT works

    func makeHowItWorksCard() -> UIView {
        // Matches Android's bg_how_it_works_photo: same flattened-export
        // trick as the seats card - the real on-device tone is dark/
        // saturated purple (confirmed on Android's own on-device
        // screenshot), not the flat violetFillLight this used before, and
        // there's no separate border on top of it.
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 12
        card.clipsToBounds = true

        let bgImageView = UIImageView(image: UIImage(named: "sgpt-how-it-works-bg"))
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.contentMode = .scaleToFill
        card.addSubview(bgImageView)
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: card.topAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        let heading = UILabel()
        heading.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        heading.textColor = UIColor(hex: "#F0F0F0")
        heading.text = Copy.howItWorksTitle
        heading.setContentHuggingPriority(.required, for: .horizontal)

        // Line/star tints match Android's exact values (#4DFFFFFF / #D9D9D9)
        // - the previous 10%-white hairline + #F0F0F0 star were too faint
        // to read against the busier photo background. And per Android's own
        // comment on this block: the line+star sit on their OWN row below
        // the heading text, a fixed ~220pt-wide accent - not stretched full
        // width beside the heading, which is what this used to do.
        let headingLine = UIView()
        headingLine.backgroundColor = UIColor.white.withAlphaComponent(0.30)
        headingLine.widthAnchor.constraint(equalToConstant: 198).isActive = true
        headingLine.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let headingStar = UIImageView(image: UIImage(named: "sgpt-ic-sparkle") ?? icon(system: "sparkle"))
        headingStar.tintColor = UIColor(hex: "#D9D9D9")
        headingStar.contentMode = .scaleAspectFit
        headingStar.widthAnchor.constraint(equalToConstant: 8).isActive = true
        headingStar.heightAnchor.constraint(equalToConstant: 8).isActive = true

        let lineStarRow = UIStackView(arrangedSubviews: [headingLine, headingStar])
        lineStarRow.translatesAutoresizingMaskIntoConstraints = false
        lineStarRow.axis = .horizontal
        lineStarRow.alignment = .center
        lineStarRow.spacing = 6
        lineStarRow.isLayoutMarginsRelativeArrangement = true
        lineStarRow.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

        let headingRow = UIStackView(arrangedSubviews: [heading, lineStarRow])
        headingRow.translatesAutoresizingMaskIntoConstraints = false
        headingRow.axis = .vertical
        headingRow.alignment = .leading
        headingRow.spacing = 8

        let items: [(number: String, title: String, body: String)] = [
            ("01", "Your trainer, your session", "The trainer customizes the program for attendees, not a generic template."),
            ("02", "Coached reps, not just counted", "Real-time cues on form, load, and pace. Every set matters."),
            ("03", "Shared cost, personal attention", "Splitting the session among a small group lowers the price but keeps quality.")
        ]

        let itemsColumn = UIStackView()
        itemsColumn.translatesAutoresizingMaskIntoConstraints = false
        itemsColumn.axis = .vertical
        itemsColumn.alignment = .fill
        itemsColumn.spacing = 16

        for item in items {
            let numberLabel = UILabel()
            numberLabel.font = AppFont.semibold.size(32.0, familyName: familyClashDisplay)
            numberLabel.textColor = .white.withAlphaComponent(0.3)
            numberLabel.text = item.number
            numberLabel.setContentHuggingPriority(.required, for: .horizontal)

            let itemTitle = UILabel()
            itemTitle.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            itemTitle.textColor = Palette.bodyText75
            itemTitle.numberOfLines = 0
            itemTitle.text = item.title

            let itemBody = UILabel()
            itemBody.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            itemBody.textColor = Palette.bodyText55
            itemBody.numberOfLines = 0
            itemBody.text = item.body

            let textColumn = UIStackView(arrangedSubviews: [itemTitle, itemBody])
            textColumn.axis = .vertical
            textColumn.alignment = .fill
            textColumn.spacing = 3

            let row = UIStackView(arrangedSubviews: [numberLabel, textColumn])
            row.axis = .horizontal
            row.alignment = .top
            row.spacing = 12
            itemsColumn.addArrangedSubview(row)

            if item.number != items.last?.number {
                itemsColumn.addArrangedSubview(makeHairline(color: Palette.hairline))
            }
        }

        let column = UIStackView(arrangedSubviews: [headingRow, itemsColumn])
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 18
        card.addSubview(column)

        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            column.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            column.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            column.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }

    // MARK: Policy rows (stubbed — no cancellation/terms content wired for SGPT yet)

    func makePolicyRow(icon iconName: String, systemFallback: String, title: String) -> UIView {
        let container = UIStackView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .vertical
        container.alignment = .fill
        container.spacing = 0
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(policyRowTapped)))

        let iconImage = UIImage(named: iconName) ?? icon(system: systemFallback)
        let iconTile = makeIconTile(image: iconImage, iconSide: 18, tileColor: Palette.cardSurface, borderColor: Palette.cardStroke)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        label.textColor = .white
        label.numberOfLines = 0
        label.text = title
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let chevron = UIImageView(image: UIImage(named: "sgpt-ic-chevron-right") ?? icon(system: "chevron.right"))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = .white.withAlphaComponent(0.4)
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            chevron.widthAnchor.constraint(equalToConstant: 16),
            chevron.heightAnchor.constraint(equalToConstant: 16)
        ])

        let row = UIStackView(arrangedSubviews: [iconTile, label, chevron])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)

        container.addArrangedSubview(row)
        container.addArrangedSubview(makeHairline(color: Palette.hairline))
        return container
    }

    // MARK: Bottom CTA bar

    /// Matches Android's bottomBarLayout: a price label on the left and a
    /// compact button on the right, not one button stretched full width -
    /// this used to be a single edge-to-edge GradientCTAButton with no price
    /// shown at all.
    func makeBottomBar() -> UIView {
        let feeLabel = barCaptionLabel
        feeLabel.font = AppFont.regular.size(10.0, familyName: familyFunnelSans)
        feeLabel.textColor = .white.withAlphaComponent(0.4)
        feeLabel.text = "PER SESSION FEE"

        let priceLabel = barValueLabel
        priceLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        priceLabel.textColor = .white
        priceLabel.numberOfLines = 2
        priceLabel.text = Copy.priceFallback

        let priceStack = UIStackView(arrangedSubviews: [feeLabel, priceLabel])
        priceStack.axis = .vertical
        priceStack.alignment = .leading
        priceStack.spacing = 2
        priceStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let button = GradientCTAButton()
        reserveButton = button
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(title: Copy.ctaTitle, font: AppFont.medium.size(14.0, familyName: familyFunnelSans), titleColor: Palette.ctaInk)
        button.setTrailingIcon(UIImage(named: "sgpt-ic-chevron-right") ?? icon(system: "chevron.right"), tint: Palette.ctaInk)
        button.addTarget(self, action: #selector(reserveTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.heightAnchor.constraint(equalToConstant: Metric.ctaHeight).isActive = true
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 140).isActive = true

        let row = UIStackView(arrangedSubviews: [priceStack, button])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        // Left/right/top only - the bottom gap above the home indicator is
        // handled below by pinning the row itself to the safe area, not by
        // padding here, since the card's own surface needs to extend all
        // the way to the true screen edge (see the note on row.bottomAnchor).
        row.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 20)

        // Figma's exact CTA bar surface: 16pt top corners only, a 2pt blue
        // (#01368F) top border, and an 8%-white radial sheen centred just
        // above the bar. A flat 2pt strip laid on top of the rounded card
        // doesn't work - the corner mask clips a straight rectangle before
        // it reaches the curve, so the border faded out right at both
        // corners instead of following the rounded edge. Using the same
        // "colored outer box + inset inner surface" trick
        // GroupTrainingDetailViewController's own bottom bar already proves
        // (buildBottomBar(): bottomBar/surface) sidesteps that entirely -
        // both layers share the identical corner mask, so the 2pt reveal
        // follows the curve exactly instead of being clipped by it.
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(hex: "#01368F")
        card.layer.cornerRadius = 16
        card.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card.clipsToBounds = true

        let surface = GlassCardView(cornerRadius: 16)
        surface.translatesAutoresizingMaskIntoConstraints = false
        surface.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        surface.fillColor = UIColor(hex: "#131416")
        surface.fillAlpha = 1.0
        surface.showsSheen = true
        surface.sheenOrigin = .topCenter
        surface.sheenAlpha = 0.08
        card.addSubview(surface)
        surface.addSubview(row)

        NSLayoutConstraint.activate([
            surface.topAnchor.constraint(equalTo: card.topAnchor, constant: 2),
            surface.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            surface.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            surface.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            row.topAnchor.constraint(equalTo: surface.topAnchor),
            row.leadingAnchor.constraint(equalTo: surface.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: surface.trailingAnchor),
            // surface's OWN safe area guide, not view's or card's - this
            // method returns `card` before it's ever added to the view
            // hierarchy (fill() does that afterward, from buildSections()),
            // so activating a constraint against anything outside this
            // subtree crashes with "no common ancestor" (confirmed via
            // crash log). surface and row already share an ancestor
            // (surface itself) regardless of attachment, and once fill()
            // attaches card flush to the screen's bottom edge, surface's
            // safe area guide resolves to the identical real inset the
            // view's own guide would have anyway.
            row.bottomAnchor.constraint(equalTo: surface.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        return card
    }

    // MARK: Small builders

    func makeHairline(color: UIColor) -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = color
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    func makeIconTile(image: UIImage?, iconSide: CGFloat, tileColor: UIColor, borderColor: UIColor,
                      sheenColor: UIColor = .white, sheenAlpha: CGFloat = 0.08,
                      sheenEdge: CAGradientPoint = .bottomRight,
                      sheenCenterOverride: CGPoint? = nil, sheenEdgeOverride: CGPoint? = nil,
                      sheenEndColor: UIColor? = nil, sheenEndAlpha: CGFloat = 0) -> UIView {
        let tile = GlassCardView(cornerRadius: 12)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = tileColor
        tile.fillAlpha = 1.0
        tile.strokeColor = borderColor
        tile.strokeAlpha = 1.0
        tile.sheenOrigin = .topCenter
        tile.sheenEdge = sheenEdge
        tile.sheenColor = sheenColor
        tile.sheenAlpha = sheenAlpha
        tile.sheenCenterOverride = sheenCenterOverride
        tile.sheenEdgeOverride = sheenEdgeOverride
        tile.sheenEndColor = sheenEndColor
        tile.sheenEndAlpha = sheenEndAlpha

        let iconView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
        iconView.contentMode = .scaleAspectFit
        tile.addSubview(iconView)

        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: Metric.iconTileSide),
            tile.heightAnchor.constraint(equalToConstant: Metric.iconTileSide),
            iconView.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: iconSide),
            iconView.heightAnchor.constraint(equalToConstant: iconSide)
        ])
        return tile
    }

    func icon(system: String) -> UIImage? {
        return UIImage(systemName: system)
    }
}
