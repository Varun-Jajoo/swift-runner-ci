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
//  Scope: there is no plans/pricing/purchase API for SGPT yet, so the 3 plan
//  cards, copy, and countdown below are static app content matching Figma
//  exactly, not per-session or per-user data. The countdown is a frozen
//  display (01:59:48, as Figma shows it), not a real ticking deadline - there
//  is no backend expiry to count down to. The purchase CTA and Terms &
//  Conditions link are stubs.
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
    }

    /// Mirrors SgptPricingActivity.kt's own `PricingCard` - a reference to
    /// one card's outer view/badge plus the width/height constraints that
    /// need updating whenever the carousel's centered card changes.
    private struct PricingCardRef {
        let card: SgptGlassBorderView
        let badge: UILabel
        let cardWidthConstraint: NSLayoutConstraint
        let cardHeightConstraint: NSLayoutConstraint
        let badgeWidthConstraint: NSLayoutConstraint
        let badgeHeightConstraint: NSLayoutConstraint
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

    private let plans: [PlanCard] = [
        PlanCard(badge: "Best Deal", isCenter: false, headline: "10 credit", validDays: 90, price: "AED 1,100", originalPrice: nil, perSession: "AED 110/session"),
        PlanCard(badge: "Deal of the Day", isCenter: true, headline: "16 sessions", validDays: 120, price: "AED 1,848", originalPrice: "1,998", perSession: "AED 84/session"),
        PlanCard(badge: "Value Price", isCenter: false, headline: "24 credit", validDays: 90, price: "AED 1,100", originalPrice: nil, perSession: "AED 110/session")
    ]

    private var cardsScrollView: UIScrollView?
    private var pricingCardRefs: [PricingCardRef] = []
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
        view.backgroundColor = Palette.bg
        heroImageView.image = UIImage(named: "sgpt-pricing-hero")
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        buildContent()
        setupScrollDebugLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topInset = view.safeAreaInsets.top
        backButtonTopConstraint?.constant = max(topInset, 20) + 8
        performInitialPricingCenteringIfNeeded()
    }

    // The hero-frame diagnostic that used to live here confirmed the frame
    // geometry is actually correct (heroImageView resolves to x=-4, width
    // 401 on a 393pt screen - a full 4pt overscan past both edges, with the
    // container's clipsToBounds=true cropping it exactly to the screen), so
    // whatever's still visible isn't a missing/gap region in the layout.
    // Removed now that it answered that question.

    /// TEMPORARY - the carousel snap-back report persisted even after
    /// splitting live style-swap from the deferred resize (see
    /// updateCenteredPricingCard()/applyPricingCardSizes()'s comments), so
    /// there's still something wrong with the live scroll state that static
    /// reasoning about the code hasn't caught. A modal alert can't diagnose
    /// this one - presenting it would cancel the very touch gesture being
    /// tested. This is a plain, non-blocking overlay label instead, updated
    /// on every scroll/settle callback, so a screenshot taken mid-drag (the
    /// physical volume+side-button shortcut, which doesn't interrupt an
    /// active touch) can capture exactly what the code believes is
    /// happening at the moment the snap-back is visible. Remove once
    /// root-caused.
    private let scrollDebugLabel = UILabel()

    private func setupScrollDebugLabel() {
        scrollDebugLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollDebugLabel.numberOfLines = 0
        scrollDebugLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        scrollDebugLabel.textColor = .white
        scrollDebugLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        scrollDebugLabel.text = "scroll debug: waiting for first scroll event"
        view.addSubview(scrollDebugLabel)
        NSLayoutConstraint.activate([
            scrollDebugLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            scrollDebugLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            scrollDebugLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -4)
        ])
    }

    private func updateScrollDebugLabel(context: String) {
        guard let scrollView = cardsScrollView else { return }
        let names = pricingCardRefs.map { ref -> String in
            if ref.card === centeredPricingCard { return "*" }
            return " "
        }
        let nearestIndex = nearestPricingCard(in: scrollView).flatMap { nearest in
            pricingCardRefs.firstIndex { $0.card === nearest.card }
        }
        scrollDebugLabel.text = """
        [\(context)] offset=\(Int(scrollView.contentOffset.x)) inset L=\(Int(scrollView.contentInset.left)) R=\(Int(scrollView.contentInset.right))
        tracking=\(scrollView.isTracking ? "T" : "F") dragging=\(scrollView.isDragging ? "T" : "F") decel=\(scrollView.isDecelerating ? "T" : "F") settling=\(isSettlingPricingScroll ? "T" : "F")
        nearestIdx=\(nearestIndex.map(String.init) ?? "-") centered=\(names.joined())
        card widths=\(pricingCardRefs.map { Int($0.cardWidthConstraint.constant) })
        """
    }

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

    @objc private func purchaseTapped() {
        showComingSoon(message: "Purchasing Small Group PT credits from the app isn't available yet.")
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCenteredPricingCard()
        updateScrollDebugLabel(context: "didScroll")
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateScrollDebugLabel(context: "endDragging decelerate=\(decelerate)")
        if !decelerate { snapPricingCardsToNearest() }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateScrollDebugLabel(context: "endDecelerating")
        snapPricingCardsToNearest()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        updateScrollDebugLabel(context: "willBeginDragging")
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
        // fade completes rather than leaving a dead gap of solid background
        // - same tuning correction made on Android after the first pass left
        // too much empty space between the fade and "Select your plan".
        if let stack = contentContainer.superview as? UIStackView,
           let heroView = stack.arrangedSubviews.first {
            stack.setCustomSpacing(-100, after: heroView)
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

        let star = UIImageView(image: UIImage(systemName: "sparkle"))
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
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.clipsToBounds = false
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

        // Pinned to contentLayoutGuide, not the scroll view's own anchors -
        // pinning directly to scroll.leadingAnchor/trailingAnchor would force
        // row's width to equal the scroll view's visible frame width, which
        // fights the cards' own fixed-width constraints (146/133pt) since 3
        // cards + spacing is wider than any phone screen. That conflict was
        // why nothing in the row rendered at all. contentLayoutGuide lets
        // row take its own intrinsic (wider) width and derives contentSize
        // from it, which is what actually makes the row scrollable.
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            row.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            row.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor),
            scroll.heightAnchor.constraint(equalToConstant: 187)
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
        let cardWidthConstraint = card.widthAnchor.constraint(equalToConstant: plan.isCenter ? PricingMetric.mainCardWidth : PricingMetric.sideCardWidth)
        let cardHeightConstraint = card.heightAnchor.constraint(equalToConstant: plan.isCenter ? PricingMetric.mainCardHeight : PricingMetric.sideCardHeight)
        cardWidthConstraint.isActive = true
        cardHeightConstraint.isActive = true

        let badge = UILabel()
        badge.font = AppFont.medium.size(plan.isCenter ? 13 : 12, familyName: familyClashDisplay)
        badge.textColor = .white
        badge.textAlignment = .center
        badge.text = plan.badge
        // Both badges get a 1pt ~30%-white stroke (bg_pricing_badge_center/
        // side both have one; this had neither).
        badge.layer.masksToBounds = true
        badge.layer.borderWidth = 1
        badge.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor
        badge.translatesAutoresizingMaskIntoConstraints = false
        let badgeWidthConstraint = badge.widthAnchor.constraint(equalToConstant: plan.isCenter ? PricingMetric.mainBadgeWidth : PricingMetric.sideBadgeWidth)
        let badgeHeightConstraint = badge.heightAnchor.constraint(equalToConstant: plan.isCenter ? PricingMetric.mainBadgeHeight : PricingMetric.sideBadgeHeight)
        badgeWidthConstraint.isActive = true
        badgeHeightConstraint.isActive = true
        applyPricingBadgeStyle(badge, isCenter: plan.isCenter)

        pricingCardRefs.append(PricingCardRef(card: card, badge: badge,
                                              cardWidthConstraint: cardWidthConstraint, cardHeightConstraint: cardHeightConstraint,
                                              badgeWidthConstraint: badgeWidthConstraint, badgeHeightConstraint: badgeHeightConstraint))

        let headline = UILabel()
        headline.font = AppFont.medium.size(plan.isCenter ? 22 : 20, familyName: familyFunnelSans)
        headline.textColor = .white
        headline.textAlignment = .center
        headline.text = plan.headline

        let validRow = makeValidForRow(days: plan.validDays, isCenter: plan.isCenter)

        let divider = GradientFadeView()
        divider.gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        divider.gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        divider.setColors([Palette.dividerMid.withAlphaComponent(0), Palette.dividerMid, Palette.dividerMid.withAlphaComponent(0)], locations: [0, 0.5, 1])
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: plan.isCenter ? 120 : 109).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let priceRow = makePriceRow(plan)

        let perSession = UILabel()
        perSession.font = AppFont.regular.size(plan.isCenter ? 12 : 11, familyName: familyFunnelSans)
        perSession.textColor = .white.withAlphaComponent(0.55)
        perSession.textAlignment = .center
        perSession.text = plan.perSession

        let column = UIStackView(arrangedSubviews: plan.isCenter
            ? [badge, headline, validRow, priceRow, perSession, divider]
            : [badge, headline, validRow, divider, priceRow, perSession])
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .center
        column.spacing = plan.isCenter ? 10 : 9
        column.setCustomSpacing(plan.isCenter ? 15 : 12, after: badge)
        card.addSubview(column)

        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: card.topAnchor, constant: plan.isCenter ? 8 : 9),
            column.leadingAnchor.constraint(greaterThanOrEqualTo: card.leadingAnchor, constant: 6),
            column.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -6),
            column.centerXAnchor.constraint(equalTo: card.centerXAnchor)
        ])
        return card
    }

    /// bg_pricing_badge_center also has a centred violet radial glow layer
    /// the side badge doesn't have. Corner radius is baked into Android's
    /// two badge drawables too (half of each one's own fixed height), so
    /// swapping "drawable" means swapping that as well, same as the card.
    func applyPricingBadgeStyle(_ badge: UILabel, isCenter: Bool) {
        badge.backgroundColor = isCenter ? Palette.badgeCenterFill : Palette.badgeSideFill
        badge.layer.cornerRadius = (isCenter ? PricingMetric.mainBadgeHeight : PricingMetric.sideBadgeHeight) / 2

        badge.layer.sublayers?.filter { $0.name == "sgptPricingBadgeGlow" }.forEach { $0.removeFromSuperlayer() }
        guard isCenter else { return }
        let glow = CAGradientLayer()
        glow.name = "sgptPricingBadgeGlow"
        glow.type = .radial
        glow.colors = [UIColor(hex: "#8A2BE1").withAlphaComponent(0.30).cgColor,
                       UIColor(hex: "#8A2BE1").withAlphaComponent(0.0).cgColor]
        glow.startPoint = CGPoint(x: 0.5, y: 0.5)
        glow.endPoint = CGPoint(x: 1.0, y: 0.5)
        glow.frame = CGRect(x: 0, y: 0, width: PricingMetric.mainBadgeWidth, height: PricingMetric.mainBadgeHeight)
        badge.layer.insertSublayer(glow, at: 0)
    }

    // MARK: Cards carousel (scroll-driven highlight, matches SgptPricingActivity.kt)

    /// Whichever card's own fixed center is nearest the viewport's center
    /// (SgptPricingActivity.kt's `cards.minByOrNull { abs(...) }`).
    private func nearestPricingCard(in scrollView: UIScrollView) -> PricingCardRef? {
        let viewportCenter = scrollView.contentOffset.x + scrollView.bounds.width / 2
        return pricingCardRefs.min { abs($0.card.frame.midX - viewportCenter) < abs($1.card.frame.midX - viewportCenter) }
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
        selectPricingCard(nearest)
    }

    /// Style + size + pulse for whichever card becomes centered, shared by
    /// both selection paths: scroll-driven (updateCenteredPricingCard,
    /// derives "nearest" from viewport geometry) and tap-driven
    /// (pricingCardTapped, already knows exactly which card). Recentering
    /// the scroll itself is deliberately NOT done here - scroll-driven
    /// selection must never fight the live gesture by re-offsetting the
    /// scroll view, only a tap (or the post-drag settle) should do that.
    private func selectPricingCard(_ ref: PricingCardRef) {
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
        applyPricingCardSizes(centeredCard: ref.card, animated: true)
        startPricingCenterPulse(on: ref.card)
    }

    /// Tapping a side card ("Best Deal"/"Value Price") selects AND scrolls
    /// it to center, same as Android's own card-tap-to-center behavior -
    /// dragging shouldn't be the only way to bring a side card forward.
    @objc private func pricingCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedCard = gesture.view,
              let ref = pricingCardRefs.first(where: { $0.card === tappedCard }) else { return }
        selectPricingCard(ref)
        centerPricingCard(ref.card, animated: true)
    }

    /// The actual 146x187/133x170 (and badge) resize - Figma's Deal-of-the-
    /// Day size for whichever card is centered, "side" size for the other
    /// two. Called from updateCenteredPricingCard() above (live, gated on an
    /// actual nearest-change) and from snapPricingCardsToNearest()/the
    /// initial-centering path as a final-state safety net - both paths
    /// agreeing on the same sizes makes the second call a no-op in the
    /// normal case.
    func applyPricingCardSizes(centeredCard: UIView, animated: Bool) {
        for ref in pricingCardRefs {
            let isCentered = ref.card === centeredCard
            ref.cardWidthConstraint.constant = isCentered ? PricingMetric.mainCardWidth : PricingMetric.sideCardWidth
            ref.cardHeightConstraint.constant = isCentered ? PricingMetric.mainCardHeight : PricingMetric.sideCardHeight
            ref.badgeWidthConstraint.constant = isCentered ? PricingMetric.mainBadgeWidth : PricingMetric.sideBadgeWidth
            ref.badgeHeightConstraint.constant = isCentered ? PricingMetric.mainBadgeHeight : PricingMetric.sideBadgeHeight
        }
        if animated {
            UIView.animate(withDuration: 0.25) { [weak self] in self?.view.layoutIfNeeded() }
        } else {
            view.layoutIfNeeded()
        }
    }

    func centerPricingCard(_ card: UIView, animated: Bool) {
        guard let scrollView = cardsScrollView else { return }
        let target = card.frame.midX - scrollView.bounds.width / 2
        // Must clamp against the INSET-aware range, not [0, contentSize -
        // bounds]: the whole point of the contentInset padding added in
        // performInitialPricingCenteringIfNeeded() is to let an edge card's
        // centered position fall in the padding beyond the real content, so
        // clamping to the un-padded range would silently cap it right back
        // to the old too-short range and undo that fix.
        let minOffset = -scrollView.adjustedContentInset.left
        let maxOffset = max(scrollView.contentSize.width - scrollView.bounds.width + scrollView.adjustedContentInset.right, minOffset)
        let clamped = min(max(target, minOffset), maxOffset)
        scrollView.setContentOffset(CGPoint(x: clamped, y: 0), animated: animated)
    }

    /// UIScrollView already has native "did the user stop scrolling" delegate
    /// callbacks (scrollViewDidEndDragging/scrollViewDidEndDecelerating),
    /// unlike Android's HorizontalScrollView which has neither - so this
    /// skips SgptPricingActivity.kt's Handler-based settle-delay polling
    /// entirely and just calls this from those two delegate methods instead.
    /// This is also the ONLY place the actual card/badge resize happens now
    /// (see applyPricingCardSizes()'s comment) - the user's finger is
    /// guaranteed to be off the screen and any momentum spent by the time
    /// either delegate method fires this, so there's nothing left to fight.
    func snapPricingCardsToNearest() {
        guard !isSettlingPricingScroll, let scrollView = cardsScrollView,
              let nearest = nearestPricingCard(in: scrollView) else { return }
        isSettlingPricingScroll = true
        applyPricingCardSizes(centeredCard: nearest.card, animated: true)
        centerPricingCard(nearest.card, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.isSettlingPricingScroll = false
        }
    }

    /// Same pulsing feel as the home carousel's spotlight effect / this
    /// screen's Android sibling (elevation looping between two values) -
    /// but a shadow (View.elevation's iOS equivalent) renders slightly
    /// OUTSIDE a layer's own bounds, and SgptGlassBorderView sets
    /// masksToBounds=true on itself (needed so its glass-ring gradient
    /// doesn't bleed past the card's rounded corners), which clips shadows
    /// away entirely - a shadow here would just never be visible. Pulsing
    /// the border width instead stays fully inside the layer's bounds, so
    /// it isn't clipped, while still reading as a "breathing" highlight.
    func startPricingCenterPulse(on card: UIView) {
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = 2
        animation.toValue = 4
        animation.duration = 2.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        card.layer.add(animation, forKey: "sgptPricingCenterPulse")
    }

    func stopPricingCenterPulse() {
        centeredPricingCard?.layer.removeAnimation(forKey: "sgptPricingCenterPulse")
    }

    func makeValidForRow(days: Int, isCenter: Bool) -> UIView {
        let label = UILabel()
        label.font = AppFont.regular.size(isCenter ? 12 : 10, familyName: familyFunnelSans)
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
        row.spacing = isCenter ? 7 : 6
        return row
    }

    private func makePriceRow(_ plan: PlanCard) -> UIView {
        let priceLabel = UILabel()
        priceLabel.font = AppFont.medium.size(plan.isCenter ? 18 : 16, familyName: familyFunnelSans)
        priceLabel.textColor = plan.isCenter ? .white : .white.withAlphaComponent(0.75)
        priceLabel.text = plan.price

        guard plan.isCenter, let original = plan.originalPrice else {
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

    func makeDotPager() -> UIView {
        func dot(active: Bool) -> UIView {
            let view = UIView()
            view.backgroundColor = UIColor.white.withAlphaComponent(active ? 0.94 : 0.2)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: active ? 14 : 4).isActive = true
            view.heightAnchor.constraint(equalToConstant: 4).isActive = true
            view.layer.cornerRadius = 2
            return view
        }

        let track = UIView()
        track.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        track.layer.cornerRadius = 2
        track.translatesAutoresizingMaskIntoConstraints = false
        track.widthAnchor.constraint(equalToConstant: 32).isActive = true
        track.heightAnchor.constraint(equalToConstant: 4).isActive = true
        let activeFill = dot(active: true)
        track.addSubview(activeFill)
        NSLayoutConstraint.activate([
            activeFill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            activeFill.centerYAnchor.constraint(equalTo: track.centerYAnchor)
        ])

        let row = UIStackView(arrangedSubviews: [dot(active: false), dot(active: false), track, dot(active: false), dot(active: false)])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 4
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        row.backgroundColor = UIColor(hex: "#131416")
        row.layer.cornerRadius = 10
        row.layer.masksToBounds = true
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

        let row = UIStackView(arrangedSubviews: [label, box("01"), colon(), box("59"), colon(), box("48")])
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
