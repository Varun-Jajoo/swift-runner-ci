//
//  DoubleBookingWaitlistConfirmedViewController.swift
//  MyPT
//
//  "You're on the waitlist" (overlapping-booking variant) — shown after a
//  post-hoc or pre-check double-booking join. Sibling screen to
//  SlotConfirmedViewController, sharing the SAME Android drawables:
//    app/src/main/res/layout/activity_double_booking_waitlist_confirmed.xml
//    bg_confirm_slot_success       -> same "confirm-success-bg" raster asset
//    ic_slot_confirmed_success_badge -> SlotConfirmedSuccessBadgeView
//    circle_action_btn_bg          -> GlassCircularIconButton
//    card_details_bg               -> GlassCardView (#18191C fill, #232323 stroke, top-centre sheen)
//    glass_pill_bg                 -> transparent-fill pill, #33FAFAFA stroke, top sheen (see makePill)
//    location_icon_bg              -> GlassCardView icon tile (#101113 fill+stroke, top-centre sheen)
//    waitlist_notify_card_bg       -> blue-tinted GlassCardView (#000814 fill, blue wash + stroke,
//                                     top-centre white sheen) - NOT the amber important_note_bg used
//                                     on SlotConfirmedViewController; this screen's own box is blue.
//    btn_cta_gradient_shadow       -> GradientCTAButton, 2pt band
//

import UIKit

final class DoubleBookingWaitlistConfirmedViewController: CommonViewController {

    var classTitle: String = "Morning Flow Yoga"
    var classTime: String = "Wed, 9 Jul • 7-8 AM"
    var classLocation: String = "Silicon Oasis"
    var trainerName: String = ""
    var distance: String = ""
    var studioLat: Double = 0
    var studioLng: Double = 0

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let backButtonDiameter: CGFloat = 40
        static let badgeSide: CGFloat = 120
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let iconTileSide: CGFloat = 38
        static let infoBoxIconSide: CGFloat = 20
        static let ctaHeight: CGFloat = 48
    }

    /// Hex values taken straight from `activity_double_booking_waitlist_confirmed.xml`
    /// and its drawables - only the module-wide blue/gold slots come from `GroupClassColor`.
    private enum Palette {
        static let headerTitle = UIColor(hex: "#FAFAFA")
        static let headerSubtext = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let divider = UIColor.white.withAlphaComponent(0.10)                 // #1AFFFFFF
        static let cardFill = UIColor(hex: "#18191C")
        static let cardStroke = UIColor(hex: "#232323")
        static let tileFill = UIColor(hex: "#101113")
        static let pillStroke = UIColor(hex: "#FAFAFA")                             // @ ~20% -> #33FAFAFA
        static let pillText = UIColor(hex: "#FFCC33")
        static let rowTitle = UIColor(hex: "#FAFAFA")
        static let rowSubtitle = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)    // #8CFAFAFA
        // `waitlist_notify_card_bg`: blue #000814 base, blue wash + stroke - a
        // DIFFERENT box than SlotConfirmedViewController's amber "IMPORTANT NOTE".
        static let infoBoxFill = GroupClassColor.blueCardBg.color
        static let infoBoxStroke = GroupClassColor.blue.color
        static let infoBoxText = UIColor(hex: "#FAFAFA").withAlphaComponent(0.85)    // #D8FAFAFA
        static let infoIconTint = UIColor(hex: "#FFCC33")
        static let ctaInk = UIColor(hex: "#131416")
    }

    private enum Copy {
        static let headerTitle = "You\u{2019}re on the List!"
        static let headerSubtext = "Since you already have a free class booked, we\u{2019}ve saved your spot on a pending waitlist for this one instead \u{2014} we\u{2019}ll let you know the moment it\u{2019}s your turn."
        // Android's equivalent screen also handles a "normal" (non-overlapping)
        // waitlist entry and swaps this pill to plain "WAITLISTED" for that
        // case (DoubleBookingWaitlistConfirmedActivity.kt) - this screen is
        // only ever reached for the special/overlapping case, so it keeps
        // the distinct label unconditionally rather than the generic one.
        static let categoryPill = "PENDING WAITLIST"
        static let importantNote = "Heads up: your spot becomes active 3 hours before class starts, or right away if your other booking gets cancelled."
        static let viewBookingCTA = "VIEW BOOKING"
    }

    private static let bookingsTabIndex = 2

    // MARK: Views

    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let backButton = GlassCircularIconButton()
    private let badgeView = SlotConfirmedSuccessBadgeView()
    private let headerTitleLabel = UILabel()
    private let headerSubtextLabel = UILabel()

    private let categoryPillLabel = UILabel()
    private let classTitleLabel = UILabel()
    private let dateTimeLabel = UILabel()
    private let locationTitleLabel = UILabel()
    private let locationDistanceLabel = UILabel()
    private let trainerNameLabel = UILabel()

    private let infoIconView = UIImageView()
    private let infoTextLabel = UILabel()

    private let footerView = UIView()
    private let ctaButton = GradientCTAButton()

    // MARK: Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GroupClassColor.bg.color
        buildLayout()
        populateUI()

        // Arms a "N spots opened up" local notification for the next time
        // the app backgrounds after this waitlist join.
        WaitlistOpenSlotsNotifier.armOnNextBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    private func populateUI() {
        classTitleLabel.text = classTitle
        dateTimeLabel.text = classTime
        locationTitleLabel.text = GroupClassCardFormatter.cleanStudioName(classLocation)

        // Device location first, server-passed distance only as a last-resort
        // fallback - see GroupClassCardFormatter.distanceText()'s doc comment.
        let resolvedDistance = GroupClassCardFormatter.distanceText(
            userLat: nil, userLng: nil,
            studioLat: studioLat, studioLng: studioLng,
            fallback: distance
        )
        if !resolvedDistance.isEmpty {
            locationDistanceLabel.text = resolvedDistance
        }

        let trimmedTrainer = trainerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTrainer.isEmpty {
            trainerNameLabel.text = trimmedTrainer.hasPrefix("Trainer:") ? trimmedTrainer : "Trainer: \(trimmedTrainer)"
        }
    }

    // MARK: Actions

    @objc private func didTapBack() {
        // Always reached via pushViewController (DoubleBookingSheetViewController /
        // GroupTrainingDetailViewController) - never present - so this pops, it
        // never dismisses (same fix rationale as SlotConfirmedViewController).
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapViewBookings() {
        let hostNavigationController = navigationController

        guard let tabBarController = resolveTabBarController(),
              let tabs = tabBarController.viewControllers,
              tabs.indices.contains(DoubleBookingWaitlistConfirmedViewController.bookingsTabIndex) else {
            hostNavigationController?.popToRootViewController(animated: true)
            return
        }

        (tabs[DoubleBookingWaitlistConfirmedViewController.bookingsTabIndex] as? UINavigationController)?
            .popToRootViewController(animated: false)
        tabBarController.selectedIndex = DoubleBookingWaitlistConfirmedViewController.bookingsTabIndex

        hostNavigationController?.popToRootViewController(animated: false)
    }

    private func resolveTabBarController() -> UITabBarController? {
        if let tabBarController = tabBarController { return tabBarController }

        var candidate = UIApplication.shared.windows.first(where: \.isKeyWindow)?.rootViewController
        while let current = candidate {
            if let tabBarController = current as? UITabBarController { return tabBarController }
            candidate = current.presentedViewController ?? current.children.first
        }
        return nil
    }

    /// First bundled asset wins; a system symbol is the last resort - same
    /// convention every other Group Classes screen uses.
    private static func icon(_ names: [String], systemFallback: String? = nil) -> UIImage? {
        for name in names {
            if let image = UIImage(named: name) { return image }
        }
        if let systemFallback = systemFallback {
            return UIImage(systemName: systemFallback)
        }
        return nil
    }
}

// MARK: - Layout

private extension DoubleBookingWaitlistConfirmedViewController {

    func buildLayout() {
        buildBackgroundWash()
        buildFooter()
        buildScrollView()
    }

    // MARK: Background

    /// `android:background="@drawable/bg_confirm_slot_success"` - the same raster
    /// asset SlotConfirmedViewController uses (`confirm-success-bg`).
    func buildBackgroundWash() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: "confirm-success-bg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: Footer CTA

    /// `bottomFooterLayout`: no background of its own, so the page wash shows through.
    func buildFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = .clear
        view.addSubview(footerView)

        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.bandThickness = 2
        ctaButton.configure(title: Copy.viewBookingCTA,
                            font: AppFont.semibold.size(15.0, familyName: familyFunnelSans),
                            titleColor: Palette.ctaInk)
        ctaButton.addTarget(self, action: #selector(didTapViewBookings), for: .touchUpInside)
        footerView.addSubview(ctaButton)

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            ctaButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 12),
            ctaButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: Metric.horizontalInset),
            ctaButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -Metric.horizontalInset),
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            ctaButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight)
        ])
    }

    // MARK: Scroll container

    func buildScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 0
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 20, left: Metric.horizontalInset, bottom: 24, right: Metric.horizontalInset)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        let backRow = makeBackButtonRow()
        contentStack.addArrangedSubview(backRow)
        contentStack.setCustomSpacing(34, after: backRow)

        let badgeRow = makeBadgeRow()
        contentStack.addArrangedSubview(badgeRow)
        contentStack.setCustomSpacing(22, after: badgeRow)

        let titleLabel = makeHeaderTitleLabel()
        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(8, after: titleLabel)

        let subtextRow = makeHeaderSubtextRow()
        contentStack.addArrangedSubview(subtextRow)
        contentStack.setCustomSpacing(22, after: subtextRow)

        let divider = makeDivider()
        contentStack.addArrangedSubview(divider)
        contentStack.setCustomSpacing(20, after: divider)

        let detailsCard = makeDetailsCard()
        contentStack.addArrangedSubview(detailsCard)
        contentStack.setCustomSpacing(16, after: detailsCard)

        contentStack.addArrangedSubview(makeInfoBox())
    }

    // MARK: Header

    func makeBackButtonRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.configure(icon: DoubleBookingWaitlistConfirmedViewController.icon(["ic_back_chevron_20"], systemFallback: "chevron.left"),
                             diameter: Metric.backButtonDiameter)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        container.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            backButton.topAnchor.constraint(equalTo: container.topAnchor),
            backButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            backButton.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            backButton.widthAnchor.constraint(equalToConstant: Metric.backButtonDiameter),
            backButton.heightAnchor.constraint(equalToConstant: Metric.backButtonDiameter)
        ])
        return container
    }

    func makeBadgeRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        badgeView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(badgeView)

        NSLayoutConstraint.activate([
            badgeView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            badgeView.topAnchor.constraint(equalTo: container.topAnchor),
            badgeView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            badgeView.widthAnchor.constraint(equalToConstant: Metric.badgeSide),
            badgeView.heightAnchor.constraint(equalToConstant: Metric.badgeSide)
        ])
        return container
    }

    func makeHeaderTitleLabel() -> UILabel {
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        headerTitleLabel.textColor = Palette.headerTitle
        headerTitleLabel.textAlignment = .center
        headerTitleLabel.numberOfLines = 0
        headerTitleLabel.text = Copy.headerTitle
        return headerTitleLabel
    }

    /// Android gives the subtext `paddingHorizontal="16dp"` on top of the screen's
    /// own 20dp gutter, and `lineSpacingExtra="4dp"`.
    func makeHeaderSubtextRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        headerSubtextLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSubtextLabel.numberOfLines = 0
        headerSubtextLabel.attributedText = NSAttributedString(
            string: Copy.headerSubtext,
            attributes: [
                .font: AppFont.medium.size(14.0, familyName: familyFunnelSans),
                .foregroundColor: Palette.headerSubtext,
                .paragraphStyle: DoubleBookingWaitlistConfirmedViewController.paragraphStyle(lineSpacing: 4, alignment: .center)
            ]
        )
        container.addSubview(headerSubtextLabel)

        NSLayoutConstraint.activate([
            headerSubtextLabel.topAnchor.constraint(equalTo: container.topAnchor),
            headerSubtextLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            headerSubtextLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            headerSubtextLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        return container
    }

    static func paragraphStyle(lineSpacing: CGFloat, alignment: NSTextAlignment) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.alignment = alignment
        return style
    }

    func makeDivider() -> UIView {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = Palette.divider
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    // MARK: Details card

    /// `card_details_bg`: `#18191C` fill, `#232323` hairline, top-centre sheen -
    /// identical recipe to SlotConfirmedViewController's own details card.
    func makeDetailsCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        let pillRow = makeCategoryPillRow()

        classTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        classTitleLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        classTitleLabel.textColor = .white
        classTitleLabel.numberOfLines = 2

        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        dateTimeLabel.textColor = Palette.rowSubtitle
        dateTimeLabel.numberOfLines = 1
        dateTimeLabel.lineBreakMode = .byTruncatingTail

        locationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        locationTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        locationTitleLabel.textColor = Palette.rowTitle
        locationTitleLabel.numberOfLines = 1
        locationTitleLabel.lineBreakMode = .byTruncatingTail

        locationDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        locationDistanceLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        locationDistanceLabel.textColor = Palette.rowSubtitle
        locationDistanceLabel.numberOfLines = 1
        locationDistanceLabel.lineBreakMode = .byTruncatingTail

        let locationRow = makeDetailRow(icon: DoubleBookingWaitlistConfirmedViewController.icon(["ic_location_pin_small"], systemFallback: "mappin.and.ellipse"),
                                        iconSide: 14,
                                        titleLabel: locationTitleLabel,
                                        subtitleLabel: locationDistanceLabel)

        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerNameLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        trainerNameLabel.textColor = Palette.rowTitle
        trainerNameLabel.numberOfLines = 1
        trainerNameLabel.lineBreakMode = .byTruncatingTail

        let trainerRow = makeSingleLineDetailRow(icon: DoubleBookingWaitlistConfirmedViewController.icon(["ic_trainer_running_18"], systemFallback: "figure.run"),
                                                 iconSide: 16,
                                                 titleLabel: trainerNameLabel)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 0

        let divider1 = makeDivider()
        let divider2 = makeDivider()

        stack.addArrangedSubview(pillRow)
        stack.setCustomSpacing(12, after: pillRow)
        stack.addArrangedSubview(classTitleLabel)
        stack.setCustomSpacing(4, after: classTitleLabel)
        stack.addArrangedSubview(dateTimeLabel)
        stack.setCustomSpacing(12, after: dateTimeLabel)
        stack.addArrangedSubview(divider1)
        stack.setCustomSpacing(12, after: divider1)
        stack.addArrangedSubview(locationRow)
        stack.setCustomSpacing(12, after: locationRow)
        stack.addArrangedSubview(divider2)
        stack.setCustomSpacing(12, after: divider2)
        stack.addArrangedSubview(trainerRow)

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: Metric.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Metric.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Metric.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Metric.cardPadding)
        ])
        return card
    }

    /// `glass_pill_bg`: 8dp radius, **transparent fill** (not a 10%-white fill -
    /// that was a mismatch in the previous version of this screen), `#33FAFAFA`
    /// hairline, and a `#33FFFFFF` radial sheen centred near the top-left.
    func makeCategoryPillRow() -> UIView {
        let pill = GlassCardView(cornerRadius: 8)
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.fillColor = .white
        pill.fillAlpha = 0.0
        pill.strokeColor = Palette.pillStroke
        pill.strokeAlpha = 0.2
        pill.sheenColor = .white
        pill.sheenAlpha = 0.2
        pill.sheenOrigin = .topCenter
        pill.sheenEdge = .bottomRight

        categoryPillLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryPillLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        categoryPillLabel.textColor = Palette.pillText
        categoryPillLabel.textAlignment = .center
        categoryPillLabel.numberOfLines = 1
        categoryPillLabel.text = Copy.categoryPill
        pill.addSubview(categoryPillLabel)

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(pill)

        NSLayoutConstraint.activate([
            categoryPillLabel.topAnchor.constraint(equalTo: pill.topAnchor, constant: 4),
            categoryPillLabel.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -4),
            categoryPillLabel.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 12),
            categoryPillLabel.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12),

            pill.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            pill.topAnchor.constraint(equalTo: wrapper.topAnchor),
            pill.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            pill.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            pill.trailingAnchor.constraint(lessThanOrEqualTo: wrapper.trailingAnchor)
        ])
        return wrapper
    }

    /// 38pt icon tile + title/subtitle vertical stack - Android's location row.
    func makeDetailRow(icon: UIImage?, iconSide: CGFloat, titleLabel: UILabel, subtitleLabel: UILabel) -> UIStackView {
        let iconTile = makeIconTile(image: icon, iconSide: iconSide)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 2
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [iconTile, textStack])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    /// Icon tile + single title label - Android's trainer row (no subtitle line here).
    func makeSingleLineDetailRow(icon: UIImage?, iconSide: CGFloat, titleLabel: UILabel) -> UIStackView {
        let iconTile = makeIconTile(image: icon, iconSide: iconSide)
        let row = UIStackView(arrangedSubviews: [iconTile, titleLabel])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    /// `location_icon_bg`: 38dp rounded square, top-down `#1AFFFFFF -> #101113`
    /// wash with a `#101113` hairline and a faint top-centre sheen - identical
    /// recipe to SlotConfirmedViewController's icon tiles.
    func makeIconTile(image: UIImage?, iconSide: CGFloat) -> UIView {
        let tile = GlassCardView(cornerRadius: 12)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = Palette.tileFill
        tile.fillAlpha = 1.0
        tile.strokeColor = Palette.tileFill
        tile.strokeAlpha = 1.0
        tile.sheenOrigin = .topCenter
        tile.sheenAlpha = 0.08

        let iconView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
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

    // MARK: Priority notice box

    /// `waitlist_notify_card_bg`: blue `#000814` base fill, a top-to-bottom blue
    /// wash, a `#4D0865FE` (blue @ ~30%) stroke, and a faint top-centre white
    /// sheen. This is a DIFFERENT box than SlotConfirmedViewController's amber
    /// "IMPORTANT NOTE" (`important_note_bg`) - easy to conflate since both hold
    /// a warning-style icon + paragraph, but Android renders this one in blue.
    func makeInfoBox() -> UIView {
        let box = GlassCardView(cornerRadius: 12)
        box.translatesAutoresizingMaskIntoConstraints = false
        box.fillColor = Palette.infoBoxFill
        box.fillAlpha = 1.0
        box.strokeColor = Palette.infoBoxStroke
        box.strokeAlpha = 0.30
        box.washColors = [Palette.infoBoxStroke.withAlphaComponent(0.10), Palette.infoBoxStroke.withAlphaComponent(0.0)]
        box.sheenColor = .white
        box.sheenOrigin = .topCenter
        box.sheenAlpha = 0.08

        infoIconView.translatesAutoresizingMaskIntoConstraints = false
        infoIconView.image = DoubleBookingWaitlistConfirmedViewController
            .icon(["ic_info_hexagon_18"], systemFallback: "info.circle.fill")?
            .withRenderingMode(.alwaysTemplate)
        infoIconView.tintColor = Palette.infoIconTint
        infoIconView.contentMode = .scaleAspectFit

        infoTextLabel.translatesAutoresizingMaskIntoConstraints = false
        infoTextLabel.font = AppFont.medium.size(13.0, familyName: familyFunnelSans)
        infoTextLabel.textColor = Palette.infoBoxText
        infoTextLabel.numberOfLines = 0
        infoTextLabel.text = Copy.importantNote

        box.addSubview(infoIconView)
        box.addSubview(infoTextLabel)

        NSLayoutConstraint.activate([
            infoIconView.topAnchor.constraint(equalTo: box.topAnchor, constant: 16),
            infoIconView.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
            infoIconView.widthAnchor.constraint(equalToConstant: Metric.infoBoxIconSide),
            infoIconView.heightAnchor.constraint(equalToConstant: Metric.infoBoxIconSide),

            infoTextLabel.topAnchor.constraint(equalTo: box.topAnchor, constant: 16),
            infoTextLabel.leadingAnchor.constraint(equalTo: infoIconView.trailingAnchor, constant: 12),
            infoTextLabel.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16),
            infoTextLabel.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -16)
        ])
        return box
    }
}
