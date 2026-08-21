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

    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var contentContainer: UIView!

    // MARK: - Palette / copy

    private enum Palette {
        static let bg = UIColor(hex: "#0E0B14")
        static let cardCenterFill = UIColor(hex: "#0E0B14")
        static let centerBorder = UIColor(hex: "#8A2BE1")
        static let badgeCenterFill = UIColor(hex: "#1A062D")
        static let badgeSideFill = UIColor(hex: "#352B45")
        static let dividerMid = UIColor(hex: "#384751")
        static let ctaInk = UIColor(hex: "#141514")
        static let lime = UIColor(hex: "#E0FE08")
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
    private var centerCardView: UIView?

    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bg
        heroImageView.image = UIImage(named: "sgpt-pricing-hero")
        buildContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerDealOfDayCard()
    }

    private var hasCenteredCards = false

    /// Figma's initial state centers "Deal of the Day" with both side cards
    /// peeking equally - the 3 cards together are wider than the screen (the
    /// Figma frame itself is 430pt), so this replicates that as the starting
    /// scroll position. Runs once, after the scroll view has real bounds.
    private func centerDealOfDayCard() {
        guard !hasCenteredCards, let scrollView = cardsScrollView, let centerCard = centerCardView,
              scrollView.bounds.width > 0 else { return }
        let target = (centerCard.frame.midX) - scrollView.bounds.width / 2
        scrollView.contentOffset = CGPoint(x: max(target, 0), y: 0)
        hasCenteredCards = true
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
            if plan.isCenter { centerCardView = card }
        }

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: scroll.topAnchor),
            row.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            row.heightAnchor.constraint(equalTo: scroll.heightAnchor),
            scroll.heightAnchor.constraint(equalToConstant: 187)
        ])
        return scroll
    }

    func makePlanCard(_ plan: PlanCard) -> UIView {
        let width: CGFloat = plan.isCenter ? 146 : 133
        let height: CGFloat = plan.isCenter ? 187 : 170

        let card = SgptGlassBorderView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.cornerRadius = plan.isCenter ? 32 : 29
        card.fillColor = Palette.cardCenterFill
        card.widthAnchor.constraint(equalToConstant: width).isActive = true
        card.heightAnchor.constraint(equalToConstant: height).isActive = true

        if plan.isCenter {
            card.layer.borderWidth = 2
            card.layer.borderColor = Palette.centerBorder.cgColor
        }

        let badge = UILabel()
        badge.font = AppFont.medium.size(plan.isCenter ? 13 : 12, familyName: familyClashDisplay)
        badge.textColor = .white
        badge.textAlignment = .center
        badge.text = plan.badge
        badge.backgroundColor = plan.isCenter ? Palette.badgeCenterFill : Palette.badgeSideFill
        badge.layer.cornerRadius = (plan.isCenter ? 34 : 31) / 2
        badge.layer.masksToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.widthAnchor.constraint(equalToConstant: plan.isCenter ? 124 : 113).isActive = true
        badge.heightAnchor.constraint(equalToConstant: plan.isCenter ? 34 : 31).isActive = true

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

    func makePriceRow(_ plan: PlanCard) -> UIView {
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
        track.widthAnchor.constraint(equalToConstant: 32).heightAnchor.constraint(equalToConstant: 4).isActive = true
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
