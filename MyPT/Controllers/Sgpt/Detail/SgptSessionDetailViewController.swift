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
        static let trainerSkills = ["STRENGTH", "MOBILITY", "+2"]
        static let howItWorksTitle = "How Small Group PT works"
        static let priceFallback = "1 credit"
        static let ctaTitle = "GET CREDIT & RESERVE"
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
    private let readMoreButton = UIButton(type: .system)
    private let dateValueLabel = UILabel()
    private let timeValueLabel = UILabel()
    private let durationValueLabel = UILabel()
    private let venueValueLabel = UILabel()

    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bg
        buildSections()
        populate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // `view.safeAreaInsets.top` is 0 until the first real layout pass,
        // so this can't move to viewDidLoad/viewWillAppear - it has to live
        // here, re-running on every layout pass (rotation, size class
        // change) since the inset itself can change under those.
        heroTopButtonsTopConstraint.constant = view.safeAreaInsets.top + 22
        updateAboutOverflowState()
    }

    // MARK: - Populate

    private func populate() {
        titleLabel.text = SgptSessionDetailViewController.titleText(for: session)
        titleLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)

        let trainerName = (session.trainerName?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 } ?? "MyPT Trainer"
        trainerRowNameLabel.text = trainerName
        trainerRowNameLabel.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        trainerRowNameLabel.textColor = Palette.bodyText75

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

    @IBAction func reserveTapped() {
        let vc: SgptPricingViewController = .instantiate(appStoryboard: .homepage)
        navigationController?.pushViewController(vc, animated: true)
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

    private func showComingSoon() {
        let alert = UIAlertController(title: Copy.ctaComingSoonTitle, message: Copy.ctaComingSoonMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /// Hides the collapsed-copy scrim/button once the full paragraph already
    /// fits within the collapsed line limit.
    private func updateAboutOverflowState() {
        guard aboutLabel.bounds.width > 0 else { return }
        let fullHeight = aboutLabel.sizeThatFits(CGSize(width: aboutLabel.bounds.width, height: .greatestFiniteMagnitude)).height
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

        let moreColumn = UIStackView(arrangedSubviews: [
            makePolicyRow(system: "person.fill", title: "Cancellation policy"),
            makePolicyRow(system: "clock.fill", title: "Terms and conditions")
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

        let personIcon = UIImageView(image: icon(system: "person.2.fill"))
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
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Palette.cardSurface
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = Palette.cardStroke.cgColor
        card.clipsToBounds = true

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
            let iconTile = makeIconTile(image: UIImage(named: step.icon) ?? icon(system: step.systemFallback), iconSide: 20, tileColor: Palette.violetTile, borderColor: Palette.violetStroke)
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

            let titleRow = UIStackView(arrangedSubviews: [stepTitle, tag])
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

        // Name is its OWN row - Android stacks it above the rating row
        // (rather than Figma's single row) so a normal-length real trainer
        // name never truncates behind the rating block.
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        nameLabel.textColor = UIColor(hex: "#F0F0F0")
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.text = trainerRowNameLabel.text

        // Static placeholder rating — no per-trainer rating API for SGPT.
        let starIcon = UIImageView(image: icon(system: "star.fill"))
        starIcon.tintColor = UIColor(hex: "#FFCC33")
        starIcon.contentMode = .scaleAspectFit
        let ratingLabel = UILabel()
        ratingLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        ratingLabel.textColor = .white
        ratingLabel.text = Copy.trainerRatingValue
        let ratingCountLabel = UILabel()
        ratingCountLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        ratingCountLabel.textColor = UIColor(hex: "#959595")
        ratingCountLabel.text = Copy.trainerRatingCount
        let ratingRow = UIStackView(arrangedSubviews: [starIcon, ratingLabel, ratingCountLabel])
        ratingRow.axis = .horizontal
        ratingRow.alignment = .center
        ratingRow.spacing = 4
        NSLayoutConstraint.activate([starIcon.widthAnchor.constraint(equalToConstant: 16), starIcon.heightAnchor.constraint(equalToConstant: 16)])

        // Static placeholder specialities — no skills/tags API for SGPT trainers.
        let skillsRow = UIStackView(arrangedSubviews: Copy.trainerSkills.map { self.makeSkillChip($0) })
        skillsRow.axis = .horizontal
        skillsRow.alignment = .center
        skillsRow.spacing = 5

        let bioLabel = UILabel()
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        bioLabel.textColor = .white.withAlphaComponent(0.6)
        bioLabel.numberOfLines = 0
        bioLabel.text = Copy.trainerBio

        // Static placeholder stats — no per-trainer stats API for SGPT.
        let statsRow = UIStackView(arrangedSubviews: [
            makeStatCell(value: Copy.trainerRatingValue, caption: "Rating"),
            makeStatCell(value: "5yrs", caption: "Experience"),
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
        viewProfileButton.addTarget(self, action: #selector(policyRowTapped), for: .touchUpInside)
        viewProfileButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        viewProfileButton.semanticContentAttribute = .forceRightToLeft
        viewProfileButton.setImage(icon(system: "chevron.right"), for: .normal)
        viewProfileButton.tintColor = .white.withAlphaComponent(0.4)
        viewProfileButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

        let column = UIStackView(arrangedSubviews: [nameLabel, ratingRow, skillsRow, bioLabel, statsRow, viewProfileButton])
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 16
        column.setCustomSpacing(4, after: nameLabel)
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

    func makeStatCell(value: String, caption: String) -> UIView {
        let card = UIView()
        card.backgroundColor = Palette.cardSurface
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = Palette.cardStroke.cgColor
        card.clipsToBounds = true

        let valueLabel = UILabel()
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

        let headingStar = UIImageView(image: icon(system: "sparkle"))
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

    func makePolicyRow(system: String, title: String) -> UIView {
        let container = UIStackView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .vertical
        container.alignment = .fill
        container.spacing = 0
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(policyRowTapped)))

        let iconTile = makeIconTile(image: icon(system: system), iconSide: 18, tileColor: Palette.cardSurface, borderColor: Palette.cardStroke)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        label.textColor = .white
        label.numberOfLines = 0
        label.text = title
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let chevron = UIImageView(image: icon(system: "chevron.right"))
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
        let feeLabel = UILabel()
        feeLabel.font = AppFont.regular.size(10.0, familyName: familyFunnelSans)
        feeLabel.textColor = .white.withAlphaComponent(0.4)
        feeLabel.text = "PER SESSION FEE"

        let priceLabel = UILabel()
        priceLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        priceLabel.textColor = .white
        priceLabel.text = Copy.priceFallback

        let priceStack = UIStackView(arrangedSubviews: [feeLabel, priceLabel])
        priceStack.axis = .vertical
        priceStack.alignment = .leading
        priceStack.spacing = 2
        priceStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let button = GradientCTAButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(title: Copy.ctaTitle, font: AppFont.medium.size(14.0, familyName: familyFunnelSans), titleColor: Palette.ctaInk)
        button.setTrailingIcon(icon(system: "chevron.right"), tint: Palette.ctaInk)
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
        // Only top/left/right padding here - the container's own bottom
        // already sits 16pt above the safe area (sgd413 in the storyboard),
        // so an additional bottom margin here would double up that gap.
        row.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 20)
        return row
    }

    // MARK: Small builders

    func makeHairline(color: UIColor) -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = color
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    func makeIconTile(image: UIImage?, iconSide: CGFloat, tileColor: UIColor, borderColor: UIColor) -> UIView {
        let tile = GlassCardView(cornerRadius: 12)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = tileColor
        tile.fillAlpha = 1.0
        tile.strokeColor = borderColor
        tile.strokeAlpha = 1.0
        tile.sheenOrigin = .topCenter
        tile.sheenAlpha = 0.08

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
