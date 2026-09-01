//
//  SgptPricingViewController.swift
//  MyPT
//
//  SGPT "Built As One" plan-purchase screen — reached from
//  SgptSessionDetailViewController's "GET CREDIT & RESERVE" CTA.
//
//  Figma: "Pricing" frame (node 11226:22475). Built from Homepage.storyboard's
//  "SgptPricingViewController" scene, same pattern as
//  SgptSessionDetailViewController: the hero is hand-placed in IB, everything
//  below it is built in code into one empty container (`contentContainer`).
//
//  The hero is the flattened Figma export ("Pricing Banner" node 11226:22476 -
//  curtain glow + team photo + "BUILT AS ONE" title all baked into one image,
//  asset `sgpt-pricing-hero`), not hand-layered from separate pieces - this
//  sidesteps needing a fallback for Figma's "Brigends Expanded" title font,
//  which isn't bundled in this project, and is the exact same asset already
//  verified pixel-for-pixel on the Android build.
//
//  Plan cards come from api/sgpt-packages (credits, price, validity, and the
//  admin's highlight/deal pill). Three placeholder cards render first so the
//  screen is never empty, then the column is rebuilt once packs arrive.
//
//  The countdown is real: a pack flagged as a limited-time deal carries the
//  seconds remaining, counted down here as days / hours / minutes. The server
//  only reports a deal while it is still running, so an expired one simply
//  arrives as a normal plan and the row hides itself. Seconds (not an end
//  timestamp) keep it immune to device clock skew.
//
//  Purchase hands off to the payment summary; Terms & Conditions is a stub.
//

import UIKit

final class SgptPricingViewController: CommonViewController {

    // MARK: - Outlets

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var backButtonTopConstraint: NSLayoutConstraint!

    // MARK: - Palette / copy

    private enum Palette {
        static let bg = UIColor(hex: "#0E0B14")
        static let cardCenterFill = UIColor(hex: "#0E0B14")
        static let cardSideFill = UIColor(hex: "#15111E")
        static let centerBorder = UIColor(hex: "#8A2BE1")
        static let badgeCenterFill = UIColor(hex: "#1A062D")
        static let badgeSideFill = UIColor(hex: "#352B45")
        static let dividerMid = UIColor(hex: "#384751")
        static let ctaInk = UIColor(hex: "#141514")
        static let lime = UIColor(hex: "#E0FE08")
    }

    /// Matches the fixed pt values in makePlanCard() exactly - those are
    /// each card's *initial* size (Deal of the Day starts centered), these
    /// are what any card becomes once it's the one the carousel centers on.
    private enum PricingMetric {
        static let mainCardWidth: CGFloat = 146
        static let mainCardHeight: CGFloat = 187
        static let sideCardWidth: CGFloat = 133
        static let sideCardHeight: CGFloat = 170
        static let mainBadgeWidth: CGFloat = 124
        static let mainBadgeHeight: CGFloat = 34
        static let sideBadgeWidth: CGFloat = 113
        static let sideBadgeHeight: CGFloat = 31

        /// Cards are built at the main size and shrunk by transform, never by
        /// mutating constraints - a constraint-only shrink left the card's
        /// fixed-size contents at center size inside a side-size box, which is
        /// what cropped them. Figma's four main->side ratios all agree
        /// (133/146, 170/187, 113/124, 31/34 - within 0.3pt), so one uniform
        /// scale reproduces every one of them.
        static let sideScale: CGFloat = sideCardWidth / mainCardWidth
    }

    /// Mirrors SgptPricingActivity.kt's own `PricingCard` - a reference to
    /// one card's outer view/badge plus the width/height constraints that
    /// need updating whenever the carousel's centered card changes.
    private struct PricingCardRef {
        let card: SgptGlassBorderView
        let badge: UILabel
    }

    private struct PlanCard {
        let badge: String
        let isCenter: Bool
        let headline: String
        let validDays: Int
        let price: String
        let originalPrice: String?
        let perSession: String
    }

    /// Placeholder cards shown until api/sgpt-packages returns, so the screen
    /// never renders empty. Replaced wholesale by `applyPacks(_:)`.
    private var plans: [PlanCard] = [
        PlanCard(badge: "Best Deal", isCenter: false, headline: "10 credit", validDays: 90, price: "AED 1,100", originalPrice: nil, perSession: "AED 110/session"),
        PlanCard(badge: "Deal of the Day", isCenter: true, headline: "16 sessions", validDays: 120, price: "AED 1,848", originalPrice: "1,998", perSession: "AED 84/session"),
        PlanCard(badge: "Value Price", isCenter: false, headline: "24 credit", validDays: 90, price: "AED 1,100", originalPrice: nil, perSession: "AED 110/session")
    ]

    /// Club whose pricing to show; blank fetches every club's packs.
    var studioId: String = ""

    /// Session the user came from, forwarded to the payment summary so its
    /// top card shows the real class rather than the generic fallback.
    var sessionName: String = ""
    var sessionTrainerName: String = ""
    var sessionDate: String = ""
    var sessionTime: String = ""
    var sessionImageURL: String = ""

    private var packs: [SgptPackModel] = []
    private var featuredPack: SgptPackModel?
    private var dealSecondsLeft: Int = 0
    private var pricingStoreToken: UUID?
    private var countdownTimer: Timer?
    private var countdownValueLabels: [UILabel] = []
    private var countdownRow: UIView?

    private var cardsScrollView: UIScrollView?
    private let pricingDots = GroupClassCarouselDotsView()
    private var pricingCardRefs: [PricingCardRef] = []
    private var selectedPricingCardIndex: Int?
    private var purchaseButton: GradientCTAButton?
    /// Which card to scroll to on first layout - not the same as
    /// `centeredPricingCard` below, which must start nil (see
    /// performInitialPricingCenteringIfNeeded()).
    private var initialCenterPricingCard: UIView?
    /// Starts nil on purpose, matching SgptPricingActivity.kt's own
    /// `centeredCard` var: updateCenteredPricingCard() only does its full
    /// styling+pulse-start work when the nearest card differs from this, so
    /// pre-seeding it with the initially-centered card would make the very
    /// first update() call a no-op and the pulse would never start.
    private var centeredPricingCard: UIView?
    private var isSettlingPricingScroll = false
    private var hasCenteredPricingCardsInitially = false

    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainScrollView?.contentInsetAdjustmentBehavior = .never
        mainScrollView?.isDirectionalLockEnabled = true
        view.backgroundColor = Palette.bg
        heroImageView.image = UIImage(named: "sgpt-pricing-hero")
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        buildContent()
        loadPacks()
    }

    deinit {
        countdownTimer?.invalidate()
    }

    // MARK: - Packs

    /// Credit packs from api/sgpt-packages. The screen ships three placeholder
    /// cards so it never renders empty; once packs arrive the whole content
    /// column is rebuilt from them.
    private func loadPacks() {
        SgptVM.sgptPackagesApi(studioId: studioId) { [weak self] result in
            guard let self = self, let packs = result, !packs.isEmpty else { return }
            DispatchQueue.main.async {
                self.applyPacks(packs)
            }
        }
    }

    private func applyPacks(_ packs: [SgptPackModel]) {
        self.packs = packs

        // The middle card is the one the CTA buys initially, matching Android.
        let centerIndex = packs.count > 1 ? 1 : 0
        featuredPack = packs[centerIndex]
        selectedPricingCardIndex = centerIndex

        plans = packs.enumerated().map { index, pack in
            let credits = pack.credits ?? 0
            let pill = (pack.dealPillText?.isEmpty == false ? pack.dealPillText : pack.specialMsg) ?? ""

            return PlanCard(
                badge: pill.isEmpty ? (pack.name ?? "Plan") : pill,
                isCenter: index == centerIndex,
                headline: credits == 1 ? "1 credit" : "\(credits) credits",
                validDays: pack.validity ?? 0,
                price: Self.money(pack.price ?? 0),
                originalPrice: Self.originalPrice(for: pack),
                perSession: "\(Self.money(pack.pricePerSession ?? 0))/session"
            )
        }

        rebuildContent()
        startDealCountdown()
    }

    /// Struck-through "before" price, derived from the saving badge the admin
    /// set (e.g. "SAVE AED 300"). No badge means nothing to strike through.
    private static func originalPrice(for pack: SgptPackModel) -> String? {
        let digits = (pack.msg ?? "").filter { $0.isNumber }
        guard let saving = Double(digits), saving > 0, let price = pack.price else { return nil }
        return money(price + saving)
    }

    private static func money(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.maximumFractionDigits = value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        let number = formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
        return "AED \(number)"
    }

    /// Rebuilds the card column in place once real packs land.
    private func rebuildContent() {
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        pricingCardRefs.removeAll()
        cardsScrollView = nil
        centeredPricingCard = nil
        initialCenterPricingCard = nil
        hasCenteredPricingCardsInitially = false
        buildContent()
        view.setNeedsLayout()
    }

    /// Counts the featured deal down as days / hours / minutes.
    ///
    private func startDealCountdown() {
        countdownTimer?.invalidate()

        guard let deal = packs.first(where: { ($0.isDeal ?? false) && ($0.dealEndsInSeconds ?? 0) > 0 }),
              let seconds = deal.dealEndsInSeconds else {
            countdownRow?.isHidden = true
            return
        }

        let endsAt: Date
        if let iso = deal.dealEndsAt, let parsed = ISO8601DateFormatter().date(from: iso) {
            endsAt = parsed
        } else {
            endsAt = Date().addingTimeInterval(TimeInterval(seconds))
        }

        countdownRow?.isHidden = false
        dealSecondsLeft = max(0, Int(endsAt.timeIntervalSinceNow))
        renderCountdown()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            let remaining = Int(endsAt.timeIntervalSinceNow)
            if remaining <= 0 {
                self.countdownRow?.isHidden = true
                timer.invalidate()
                return
            }
            self.dealSecondsLeft = remaining
            self.renderCountdown()
        }
    }

    private func renderCountdown() {
        guard countdownValueLabels.count >= 3 else { return }
        let days = dealSecondsLeft / 86400
        let hours = (dealSecondsLeft % 86400) / 3600
        let minutes = (dealSecondsLeft % 3600) / 60
        countdownValueLabels[0].text = String(format: "%02d", days)
        countdownValueLabels[1].text = String(format: "%02d", hours)
        countdownValueLabels[2].text = String(format: "%02d", minutes)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true

        SgptStore.shared.startWatchingPricing()
        if pricingStoreToken == nil {
            pricingStoreToken = SgptStore.shared.observe { [weak self] event in
                if case .pricingPublished = event { self?.loadPacks() }
            }
        }
        startDealCountdown()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SgptStore.shared.removeObserver(pricingStoreToken)
        pricingStoreToken = nil
        SgptStore.shared.stopWatchingPricing()
        countdownTimer?.invalidate()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // safeArea + 12 is the module-wide back-button offset (Group Classes'
        // SeeAll/payment screens and SgptPaymentSummary all use it). This screen
        // previously used max(topInset, 20) + 8, which put its back button at a
        // different height from every other Group Classes / SGPT screen.
        backButtonTopConstraint?.constant = view.safeAreaInsets.top + 12
        performInitialPricingCenteringIfNeeded()
    }

    // The hero-frame diagnostic that used to live here confirmed the frame
    // geometry is actually correct (heroImageView resolves to x=-4, width
    // 401 on a 393pt screen - a full 4pt overscan past both edges, with the
    // container's clipsToBounds=true cropping it exactly to the screen), so
    // whatever's still visible isn't a missing/gap region in the layout.
    // Removed now that it answered that question.

    /// Figma's initial state centers "Deal of the Day" with both side cards
    /// peeking equally - the 3 cards together are wider than the screen (the
    /// Figma frame itself is 430pt), so this replicates that as the starting
    /// scroll position. Runs once, after the scroll view has real bounds -
    /// matches SgptPricingActivity.kt's own `scrollView.post { centerOn(...) }`.
    private func performInitialPricingCenteringIfNeeded() {
        guard !hasCenteredPricingCardsInitially, let scrollView = cardsScrollView,
              scrollView.bounds.width > 0, let target = initialCenterPricingCard else { return }
        // The actual root cause of the reported "pulls back to middle card"
        // bug: row.leadingAnchor/trailingAnchor pin flush to
        // contentLayoutGuide, so contentSize is only as wide as the 3 cards
        // + spacing + the 24pt peek margins (~502pt on a 393pt screen ->
        // maxOffset ~109). Centering a SIDE card requires the viewport's
        // CENTER x to cross the midpoint between it and the main card, which
        // works out to needing the viewport center to swing further than
        // offset 0/maxOffset allow on EITHER edge - so a side card can
        // never become "nearest" no matter how hard the user drags: they
        // hit the hard content edge first and the native scroll-view
        // rubber-band bounces back, which is exactly the "scrolls for a
        // split second then pulls back to the middle card" symptom. This
        // was never a delegate-logic bug - it's a missing-scroll-headroom
        // bug. Fix: pad both edges with contentInset so the scrollable
        // range extends far enough past the last real card for it to
        // actually reach the viewport's center once it grows to main size.
        let sideInset = max((scrollView.bounds.width - PricingMetric.mainCardWidth) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        centerPricingCard(target, animated: false)
        // centeredPricingCard is still nil here, so this does its full
        // styling+pulse-start work rather than a no-op - matches
        // SgptPricingActivity.kt's own centerOn(...) + updateCenteredCard()
        // pairing exactly. Sizes are applied explicitly too, even though
        // they're a no-op in practice (makePlanCard already gives Deal of
        // the Day the main size up front) - keeps this path honest about
        // what actually determines the on-screen sizes, rather than relying
        // on the initial constants happening to already agree.
        updateCenteredPricingCard()
        applyPricingCardSizes(centeredCard: target, animated: false)
        hasCenteredPricingCardsInitially = true
    }

    @IBAction func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    /// Purchases whichever card is currently centered/selected.
    @objc private func purchaseTapped() {
        let credits: Int
        let price: Int
        let savings: Int

        let chosenPack: SgptPackModel? = {
            if let index = selectedPricingCardIndex, index < packs.count {
                return packs[index]
            }
            return featuredPack
        }()

        if let pack = chosenPack {
            credits = pack.credits ?? 0
            price = Int(pack.price ?? 0)
            savings = Int((pack.msg ?? "").filter { $0.isNumber }) ?? 0
        } else {
            let chosenCard: PlanCard? = {
                if let index = selectedPricingCardIndex, index < plans.count {
                    return plans[index]
                }
                return plans.first(where: { $0.isCenter }) ?? plans.first
            }()
            credits = Int((chosenCard?.headline ?? "").filter { $0.isNumber }) ?? 0
            price = Int((chosenCard?.price ?? "").filter { $0.isNumber }) ?? 0
            savings = 0
        }

        SgptPaymentSummaryViewController.start(from: self,
                                               credits: credits,
                                               price: price,
                                               savings: savings,
                                               sessionName: sessionName,
                                               trainerName: sessionTrainerName,
                                               date: sessionDate,
                                               time: sessionTime,
                                               image: sessionImageURL)
    }

    @objc private func termsTapped() {
        showComingSoon(message: "Purchasing Small Group PT credits from the app isn't available yet.")
    }

    private func showComingSoon(message: String) {
        let alert = UIAlertController(title: "Coming soon", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Cards carousel scroll handling

extension SgptPricingViewController: UIScrollViewDelegate {
    // Carousel-only: the outer vertical scroll view must never drive card
    // recentring/resizing, or scrolling the page top-to-bottom judders.
    private func isPricingCarousel(_ scrollView: UIScrollView) -> Bool {
        scrollView === cardsScrollView
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isPricingCarousel(scrollView), (scrollView.isDragging || scrollView.isDecelerating) else { return }
        updateCenteredPricingCard()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard isPricingCarousel(scrollView) else { return }
        let proposedTargetX = targetContentOffset.pointee.x
        let viewportCenter = proposedTargetX + scrollView.bounds.width / 2
        if let nearest = pricingCardRefs.min(by: { abs($0.card.center.x - viewportCenter) < abs($1.card.center.x - viewportCenter) }) {
            let targetOffset = nearest.card.center.x - scrollView.bounds.width / 2
            let minOffset = -scrollView.adjustedContentInset.left
            let maxOffset = max(scrollView.contentSize.width - scrollView.bounds.width + scrollView.adjustedContentInset.right, minOffset)
            targetContentOffset.pointee.x = min(max(targetOffset, minOffset), maxOffset)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard isPricingCarousel(scrollView) else { return }
        if !decelerate { snapPricingCardsToNearest() }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard isPricingCarousel(scrollView) else { return }
        snapPricingCardsToNearest()
    }
}

// MARK: - Content building

private extension SgptPricingViewController {

    func buildContent() {
        let column = UIStackView()
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 0
        column.isLayoutMarginsRelativeArrangement = true
        column.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        contentContainer.addSubview(column)
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            column.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            column.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            column.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])

        let title = UILabel()
        title.font = AppFont.medium.size(22.0, familyName: familyClashDisplay)
        title.textColor = .white
        title.textAlignment = .center
        title.text = "Select your plan"

        let subtitle = UILabel()
        subtitle.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        subtitle.textColor = .white.withAlphaComponent(0.55)
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0
        subtitle.text = "Create unique audio with your favorite celebrity's voice loerm ispum"

        let textColumn = UIStackView(arrangedSubviews: [title, subtitle])
        textColumn.axis = .vertical
        textColumn.alignment = .fill
        textColumn.spacing = 6
        textColumn.isLayoutMarginsRelativeArrangement = true
        textColumn.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        column.addArrangedSubview(textColumn)
        column.setCustomSpacing(18, after: textColumn)

        column.addArrangedSubview(makeStarDivider())
        column.setCustomSpacing(22, after: column.arrangedSubviews.last!)

        let cardsScroll = makeCardsRow()
        column.addArrangedSubview(cardsScroll)
        column.setCustomSpacing(14, after: cardsScroll)

        column.addArrangedSubview(makeDotPager())
        column.setCustomSpacing(20, after: column.arrangedSubviews.last!)

        column.addArrangedSubview(makeCountdownRow())
        column.setCustomSpacing(20, after: column.arrangedSubviews.last!)

        let cta = makePurchaseButton()
        let ctaWrapper = UIView()
        ctaWrapper.translatesAutoresizingMaskIntoConstraints = false
        ctaWrapper.addSubview(cta)
        cta.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cta.topAnchor.constraint(equalTo: ctaWrapper.topAnchor),
            cta.bottomAnchor.constraint(equalTo: ctaWrapper.bottomAnchor),
            cta.leadingAnchor.constraint(equalTo: ctaWrapper.leadingAnchor, constant: 24),
            cta.trailingAnchor.constraint(equalTo: ctaWrapper.trailingAnchor, constant: -24),
            cta.heightAnchor.constraint(equalToConstant: 48)
        ])
        column.addArrangedSubview(ctaWrapper)
        column.setCustomSpacing(16, after: ctaWrapper)

        column.addArrangedSubview(makeTermsLabel())

        // Pull the plan content up to start where the hero's own baked-in
        // fade completes without using UIStackView negative spacing (which causes
        // jumpy/broken layout calculations inside a UIScrollView during vertical scroll).
        if let stack = contentContainer.superview as? UIStackView,
           let heroView = stack.arrangedSubviews.first {
            stack.setCustomSpacing(0, after: heroView)
        }
    }

    // MARK: Star divider

    func makeStarDivider() -> UIView {
        let leftLine = GradientFadeView()
        leftLine.gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        leftLine.gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        leftLine.setColors([UIColor.white.withAlphaComponent(0.0), UIColor.white])
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        leftLine.widthAnchor.constraint(equalToConstant: 51).isActive = true
        leftLine.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let rightLine = GradientFadeView()
        rightLine.gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        rightLine.gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        rightLine.setColors([UIColor.white.withAlphaComponent(0.0), UIColor.white])
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        rightLine.widthAnchor.constraint(equalToConstant: 51).isActive = true
        rightLine.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let star = UIImageView(image: UIImage(named: "sgpt-ic-sparkle") ?? UIImage(systemName: "sparkle"))
        star.tintColor = UIColor(white: 0.85, alpha: 1)
        star.contentMode = .scaleAspectFit
        star.widthAnchor.constraint(equalToConstant: 11).isActive = true
        star.heightAnchor.constraint(equalToConstant: 14).isActive = true

        let row = UIStackView(arrangedSubviews: [leftLine, star, rightLine])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: wrapper.topAnchor),
            row.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            row.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor)
        ])
        return wrapper
    }

    // MARK: Pricing cards

    func makeCardsRow() -> UIView {
        // HorizontalOnlyScrollView, not UIScrollView: a vertical drag must
        // never engage this carousel, or scrolling the page (especially the
        // bounce at the very bottom) shifts and re-scales the cards.
        let scroll = HorizontalOnlyScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = false
        scroll.alwaysBounceHorizontal = true
        scroll.isDirectionalLockEnabled = true
        scroll.decelerationRate = .fast
        scroll.clipsToBounds = true
        scroll.delegate = self
        cardsScrollView = scroll

        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 21
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        scroll.addSubview(row)

        for plan in plans {
            let card = makePlanCard(plan)
            row.addArrangedSubview(card)
            if plan.isCenter { initialCenterPricingCard = card }
        }

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            row.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            row.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor),
            scroll.heightAnchor.constraint(equalToConstant: 195)
        ])
        return scroll
    }

    private func makePlanCard(_ plan: PlanCard) -> UIView {
        // Android's cards are all ONE view swapping between
        // bg_pricing_card_center/_side (and badge_center/_side) as the
        // carousel's centered card changes on scroll - previously this used
        // TWO different Swift types (a plain UIView for the always-center
        // role, SgptGlassBorderView for the always-side role), which can't
        // support that: whichever card the user scrolls to center needs to
        // BECOME the glass-ring-free bordered look, then become the glass
        // ring again once it's no longer centered. SgptGlassBorderView now
        // exposes setPricingCardStyle(isCenter:) to toggle between both
        // looks on the same view, matching Android's drawable swap.
        let card = SgptGlassBorderView()
        card.setPricingCardStyle(isCenter: plan.isCenter, centerFillColor: Palette.cardCenterFill,
                                 sideFillColor: Palette.cardSideFill, centerBorderColor: Palette.centerBorder)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.isUserInteractionEnabled = true
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pricingCardTapped(_:))))
        // Main size for every card, centered or not - see PricingMetric.sideScale.
        card.widthAnchor.constraint(equalToConstant: PricingMetric.mainCardWidth).isActive = true
        card.heightAnchor.constraint(equalToConstant: PricingMetric.mainCardHeight).isActive = true
        card.transform = plan.isCenter ? .identity : CGAffineTransform(scaleX: PricingMetric.sideScale, y: PricingMetric.sideScale)

        let badge = UILabel()
        badge.font = AppFont.medium.size(13, familyName: familyClashDisplay)
        badge.textColor = .white
        badge.textAlignment = .center
        badge.text = plan.badge
        // Both badges get a 1pt ~30%-white stroke (bg_pricing_badge_center/
        // side both have one; this had neither).
        badge.layer.masksToBounds = true
        badge.layer.borderWidth = 1
        badge.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.widthAnchor.constraint(equalToConstant: PricingMetric.mainBadgeWidth).isActive = true
        badge.heightAnchor.constraint(equalToConstant: PricingMetric.mainBadgeHeight).isActive = true
        applyPricingBadgeStyle(badge, isCenter: plan.isCenter)

        pricingCardRefs.append(PricingCardRef(card: card, badge: badge))

        let headline = UILabel()
        headline.font = AppFont.medium.size(22, familyName: familyFunnelSans)
        headline.textColor = .white
        headline.textAlignment = .center
        headline.text = plan.headline

        let validRow = makeValidForRow(days: plan.validDays)

        let divider = GradientFadeView()
        divider.gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        divider.gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        divider.setColors([Palette.dividerMid.withAlphaComponent(0), Palette.dividerMid, Palette.dividerMid.withAlphaComponent(0)], locations: [0, 0.5, 1])
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: 120).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let priceRow = makePriceRow(plan)

        let perSession = UILabel()
        perSession.font = AppFont.regular.size(12, familyName: familyFunnelSans)
        perSession.textColor = .white.withAlphaComponent(0.55)
        perSession.textAlignment = .center
        perSession.text = plan.perSession

        let column = UIStackView(arrangedSubviews: [badge, headline, validRow, divider, priceRow, perSession])
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .center
        column.spacing = 10
        column.setCustomSpacing(15, after: badge)
        card.addSubview(column)

        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            column.leadingAnchor.constraint(greaterThanOrEqualTo: card.leadingAnchor, constant: 6),
            column.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -6),
            column.centerXAnchor.constraint(equalTo: card.centerXAnchor)
        ])
        return card
    }

    /// Deal of the Day badge: exact Figma radial sheen gradient style (node 11226:22491) -
    /// rich dark purple background (#1F0833) with a vibrant radial sheen/glow layer (#A855F7 -> #6B1FB3 -> #1F0833)
    /// and a 1pt #C084FC border.
    func applyPricingBadgeStyle(_ badge: UILabel, isCenter: Bool) {
        badge.backgroundColor = isCenter ? UIColor(hex: "#1F0833") : Palette.badgeSideFill
        badge.layer.cornerRadius = PricingMetric.mainBadgeHeight / 2
        badge.clipsToBounds = true

        guard isCenter else {
            badge.layer.borderWidth = 1
            badge.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor
            return
        }

        let size = CGSize(width: PricingMetric.mainBadgeWidth, height: PricingMetric.mainBadgeHeight)
        if let image = Self.radialBadgeImage(size: size) {
            badge.backgroundColor = UIColor(patternImage: image)
        }
        badge.textColor = .white
        badge.layer.borderWidth = 1.0
        badge.layer.borderColor = UIColor(hex: "#C084FC").withAlphaComponent(0.45).cgColor
    }

    private static func radialBadgeImage(size: CGSize) -> UIImage? {
        guard size.width > 0, size.height > 0 else { return nil }

        let glow = CAGradientLayer()
        glow.type = .radial
        glow.colors = [UIColor(hex: "#A855F7").withAlphaComponent(0.85).cgColor,
                       UIColor(hex: "#6B1FB3").withAlphaComponent(0.65).cgColor,
                       UIColor(hex: "#1F0833").cgColor]
        glow.locations = [0.0, 0.5, 1.0]
        glow.startPoint = CGPoint(x: 0.5, y: 0.1)
        glow.endPoint = CGPoint(x: 1.0, y: 1.0)
        glow.frame = CGRect(origin: .zero, size: size)

        return UIGraphicsImageRenderer(size: size).image { context in
            glow.render(in: context.cgContext)
        }
    }

    // MARK: Cards carousel (scroll-driven highlight, matches SgptPricingActivity.kt)

    /// Whichever card's own fixed center is nearest the viewport's center
    /// (SgptPricingActivity.kt's `cards.minByOrNull { abs(...) }`).
    private func nearestPricingCard(in scrollView: UIScrollView) -> PricingCardRef? {
        let viewportCenter = scrollView.contentOffset.x + scrollView.bounds.width / 2
        return pricingCardRefs.min { abs($0.card.center.x - viewportCenter) < abs($1.card.center.x - viewportCenter) }
    }

    /// Whichever card is nearest the viewport's center gets the "main" card's
    /// LOOK (violet border, glass ring hidden, glowing badge, pulse) AND the
    /// actual resize, together, live during an active drag. These two used
    /// to be split - style live, resize deferred to snapPricingCardsToNearest()
    /// - out of a (mistaken) worry that resizing mid-gesture would flip
    /// "nearest" back and forth every scroll delta. In practice this method
    /// only ever runs once per actual nearest-change (the guard below), not
    /// on every delta, so there's nothing to oscillate; what the split
    /// actually caused was worse - a side card would instantly get the
    /// center LOOK (violet border, no glass ring) while still sitting at
    /// its small side SIZE until the drag ended, reading as a half-updated/
    /// flattened card. The real snap-back bug this split was guarding
    /// against turned out to be the missing scroll headroom fixed in
    /// performInitialPricingCenteringIfNeeded() (contentInset), not this.
    func updateCenteredPricingCard() {
        guard let scrollView = cardsScrollView, let nearest = nearestPricingCard(in: scrollView) else { return }
        selectPricingCard(nearest, animated: false)
    }

    /// Style + size + pulse for whichever card becomes centered, shared by
    /// both selection paths: scroll-driven and tap-driven.
    private func selectPricingCard(_ ref: PricingCardRef, animated: Bool = true) {
        guard ref.card !== centeredPricingCard else { return }
        stopPricingCenterPulse()
        centeredPricingCard = ref.card
        UISelectionFeedbackGenerator().selectionChanged()

        for other in pricingCardRefs {
            let isCentered = other.card === ref.card
            other.card.setPricingCardStyle(isCenter: isCentered, centerFillColor: Palette.cardCenterFill,
                                           sideFillColor: Palette.cardSideFill, centerBorderColor: Palette.centerBorder)
            applyPricingBadgeStyle(other.badge, isCenter: isCentered)
        }
        applyPricingCardSizes(centeredCard: ref.card, animated: animated)
        if let index = pricingCardRefs.firstIndex(where: { $0.card === ref.card }) {
            selectedPricingCardIndex = index
            pricingDots.setSelectedPage(index)
            updatePurchaseButtonLabel()
        }
        startPricingCenterPulse(on: ref.card)
    }

    private func updatePurchaseButtonLabel() {
        let credits: Int
        if let index = selectedPricingCardIndex, index < packs.count, let c = packs[index].credits {
            credits = c
        } else if let index = selectedPricingCardIndex, index < plans.count {
            credits = Int(plans[index].headline.filter { $0.isNumber }) ?? 16
        } else {
            credits = 16
        }
        let title = "PURCHASE \(credits) \(credits == 1 ? "CREDIT" : "CREDITS")"
        purchaseButton?.configure(title: title, font: AppFont.medium.size(14.0, familyName: familyFunnelSans), titleColor: Palette.ctaInk)
    }

    /// Tapping a side card ("Best Deal"/"Value Price") selects AND scrolls
    /// it to center, same as Android's own card-tap-to-center behavior -
    /// dragging shouldn't be the only way to bring a side card forward.
    @objc private func pricingCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedCard = gesture.view,
              let ref = pricingCardRefs.first(where: { $0.card === tappedCard }) else { return }
        selectPricingCard(ref, animated: true)
        centerPricingCard(ref.card, animated: true)
    }

    func applyPricingCardSizes(centeredCard: UIView, animated: Bool) {
        let block = { [weak self] in
            guard let self = self else { return }
            for ref in self.pricingCardRefs {
                let isCentered = ref.card === centeredCard
                ref.card.transform = isCentered
                    ? .identity
                    : CGAffineTransform(scaleX: PricingMetric.sideScale, y: PricingMetric.sideScale)
            }
        }
        if animated {
            UIView.animate(withDuration: 0.20, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: block)
        } else {
            block()
        }
    }

    func centerPricingCard(_ card: UIView, animated: Bool) {
        guard let scrollView = cardsScrollView else { return }
        let target = card.center.x - scrollView.bounds.width / 2
        let minOffset = -scrollView.adjustedContentInset.left
        let maxOffset = max(scrollView.contentSize.width - scrollView.bounds.width + scrollView.adjustedContentInset.right, minOffset)
        let clamped = min(max(target, minOffset), maxOffset)

        // Already there: re-setting the same offset still starts an animation,
        // which reads as a small sideways yank if this is reached while the
        // page is being scrolled vertically. Sub-pixel tolerance because the
        // clamped target rarely lands on an exact match.
        if abs(scrollView.contentOffset.x - clamped) < 0.5 {
            return
        }

        scrollView.setContentOffset(CGPoint(x: clamped, y: 0), animated: animated)
    }

    func snapPricingCardsToNearest() {
        guard !isSettlingPricingScroll, let scrollView = cardsScrollView,
              let nearest = nearestPricingCard(in: scrollView) else { return }
        isSettlingPricingScroll = true
        selectPricingCard(nearest, animated: true)
        centerPricingCard(nearest.card, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.isSettlingPricingScroll = false
        }
    }

    /// Highlights the centered card cleanly without running an infinite layer
    /// animation loop that invalidates GPU layers during vertical scrolling.
    func startPricingCenterPulse(on card: UIView) {
        card.layer.borderWidth = 2.0
    }

    func stopPricingCenterPulse() {
        // No-op: handled by setPricingCardStyle
    }

    func makeValidForRow(days: Int) -> UIView {
        let label = UILabel()
        label.font = AppFont.regular.size(12, familyName: familyFunnelSans)
        label.textColor = .white.withAlphaComponent(0.55)
        label.text = "Valid for \(days) days"

        let leftDot = SgptDiamondView()
        leftDot.widthAnchor.constraint(equalToConstant: 4).isActive = true
        leftDot.heightAnchor.constraint(equalToConstant: 4).isActive = true
        let rightDot = SgptDiamondView()
        rightDot.widthAnchor.constraint(equalToConstant: 4).isActive = true
        rightDot.heightAnchor.constraint(equalToConstant: 4).isActive = true

        let row = UIStackView(arrangedSubviews: [leftDot, label, rightDot])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 7
        return row
    }

    private func makePriceRow(_ plan: PlanCard) -> UIView {
        let priceLabel = UILabel()
        priceLabel.font = AppFont.medium.size(18, familyName: familyFunnelSans)
        priceLabel.textColor = .white
        priceLabel.text = plan.price

        // Driven by whether this pack HAS a saving to strike through, not by
        // which card happens to be centered at build time - the centered card
        // changes as the carousel scrolls, so gating on plan.isCenter meant a
        // side card that later became centered could never show its old price.
        guard let original = plan.originalPrice else {
            return priceLabel
        }

        let originalLabel = UILabel()
        originalLabel.attributedText = NSAttributedString(string: original, attributes: [
            .font: AppFont.regular.size(12.0, familyName: familyFunnelSans),
            .foregroundColor: UIColor.white.withAlphaComponent(0.75),
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ])

        let row = UIStackView(arrangedSubviews: [priceLabel, originalLabel])
        row.axis = .horizontal
        row.alignment = .lastBaseline
        row.spacing = 6
        return row
    }

    // MARK: Dot pager (static decorative)

    /// Same indicator the home carousels use, so this one is bounded the same
    /// way: GroupClassCarouselDotsView renders at most `maxVisibleDots` and
    /// slides that window as the selection moves, instead of growing one dot
    /// per pack forever. Previously these dots were a fixed decorative row
    /// that neither counted the real packs nor tracked the centered card.
    func makeDotPager() -> UIView {
        pricingDots.translatesAutoresizingMaskIntoConstraints = false
        pricingDots.setPageCount(plans.count)
        pricingDots.setSelectedPage(plans.firstIndex(where: { $0.isCenter }) ?? 0)

        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.backgroundColor = UIColor(hex: "#131416")
        row.layer.cornerRadius = 10
        row.layer.masksToBounds = true
        row.addSubview(pricingDots)

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(row)
        NSLayoutConstraint.activate([
            pricingDots.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
            pricingDots.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8),
            pricingDots.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 10),
            pricingDots.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -10),

            row.topAnchor.constraint(equalTo: wrapper.topAnchor),
            row.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            row.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor)
        ])
        return wrapper
    }

    // MARK: Countdown (static — no real backend deadline)

    func makeCountdownRow() -> UIView {
        let label = UILabel()
        label.font = AppFont.medium.size(12.0, familyName: familyClashDisplay)
        label.textColor = .white.withAlphaComponent(0.75)
        label.text = "DEAL ENDS IN:"

        func box(_ text: String) -> UIView {
            let container = SgptGlassBorderView()
            container.cornerRadius = 12
            container.fillColor = UIColor(hex: "#15111E")
            container.translatesAutoresizingMaskIntoConstraints = false
            container.widthAnchor.constraint(equalToConstant: 41).isActive = true
            container.heightAnchor.constraint(equalToConstant: 40).isActive = true

            let valueLabel = UILabel()
            countdownValueLabels.append(valueLabel)
            valueLabel.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
            valueLabel.textColor = .white
            valueLabel.textAlignment = .center
            valueLabel.text = text
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(valueLabel)
            NSLayoutConstraint.activate([
                valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
            return container
        }

        func colon() -> UIView {
            let colonLabel = UILabel()
            colonLabel.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
            colonLabel.textColor = .white.withAlphaComponent(0.2)
            colonLabel.text = ":"
            return colonLabel
        }

        countdownValueLabels.removeAll()
        let row = UIStackView(arrangedSubviews: [label, box("00"), colon(), box("00"), colon(), box("00")])
        countdownRow = row
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 4
        row.setCustomSpacing(12, after: label)

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        row.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: wrapper.topAnchor),
            row.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            row.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor)
        ])
        return wrapper
    }

    // MARK: CTA + terms

    func makePurchaseButton() -> GradientCTAButton {
        let button = GradientCTAButton()
        button.configure(title: "PURCHASE 16 CREDITS", font: AppFont.medium.size(14.0, familyName: familyFunnelSans), titleColor: Palette.ctaInk)
        button.setTrailingIcon(UIImage(systemName: "chevron.right"), tint: Palette.ctaInk)
        button.addTarget(self, action: #selector(purchaseTapped), for: .touchUpInside)
        self.purchaseButton = button
        updatePurchaseButtonLabel()
        return button
    }

    func makeTermsLabel() -> UIView {
        let full = "By confirming, you agree to our Terms & Conditions"
        let attributed = NSMutableAttributedString(string: full, attributes: [
            .font: AppFont.regular.size(12.0, familyName: familyFunnelSans),
            .foregroundColor: UIColor.white.withAlphaComponent(0.75)
        ])
        if let range = full.range(of: "Terms & Conditions") {
            attributed.addAttribute(.foregroundColor, value: Palette.lime, range: NSRange(range, in: full))
        }

        let label = UILabel()
        label.attributedText = attributed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsTapped)))
        return label
    }
}

/// Horizontal carousel that refuses to claim a vertical drag.
///
/// `isDirectionalLockEnabled` is not enough on its own: it constrains a scroll
/// only AFTER that scroll has begun, so a mostly-vertical swipe that starts on
/// the carousel still engages it. Scrolling the page to the very bottom does
/// exactly that - the rubber-band at the end of the vertical scroll hands the
/// carousel a gesture, which changes which card is "nearest", which re-centres
/// and re-scales the cards. That is the jitter/pop seen at the bottom of the
/// pricing screen.
///
/// Deciding at `gestureRecognizerShouldBegin` means a vertical gesture is never
/// claimed at all and stays with the enclosing page scroll view, so the cards
/// cannot move while the user is scrolling up or down.
final class HorizontalOnlyScrollView: UIScrollView {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
              pan === panGestureRecognizer else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        let translation = pan.translation(in: self)

        // No translation yet (a tap, or the very first callback) - defer to the
        // default so taps on a card still work.
        if translation.x == 0 && translation.y == 0 {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        return abs(translation.x) > abs(translation.y)
    }
}
