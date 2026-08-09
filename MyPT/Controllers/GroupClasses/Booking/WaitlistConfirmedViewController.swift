//
//  WaitlistConfirmedViewController.swift
//  MyPT
//
//  "You're on the waitlist" — shown after `join-waitlist` succeeds.
//
//  Android reference (ground truth for layout, copy and logic):
//    app/src/main/java/co/com/mypt/UpComingClasses/WaitlistConfirmedActivity.kt
//    app/src/main/res/layout/activity_waitlist_confirmed.xml
//
//  Deliberately simpler than Slot Confirmed (Phase 6): a single flat details
//  card with no price row (joining a waitlist isn't a payment), and both the
//  glass back button and "VIEW BOOKING" just pop back to Group Training Detail
//  — unlike Slot Confirmed, this never jumps to the Bookings tab.
//
//  Reuses `SlotConfirmedSuccessBadgeView` as-is (same 120pt vector badge,
//  already module-visible) rather than re-declaring it — the plan's suggestion
//  to factor a shared shell doesn't pay for itself when the existing type
//  already fits with zero changes.
//
//  Entry point: `GroupTrainingDetailViewController`'s "JOIN WAITLIST" CTA, after
//  a successful `POST join-waitlist` (blacklist still routes to a Phase-10 stub).
//

import UIKit

final class WaitlistConfirmedViewController: CommonViewController {

    // MARK: - Input
    //
    // Mirrors the intent extras `WaitlistConfirmedActivity` reads: title / time /
    // location / trainer_name / distance. No price — Android never passes one.

    var classTitle: String = "Morning Flow Yoga"
    var classTime: String = "Wed, 9 Jul • 7-8 AM"
    var classLocation: String = "Silicon Oasis"
    var trainerName: String = ""
    var distance: String = ""

    // MARK: - Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let backButtonDiameter: CGFloat = 40
        static let badgeSide: CGFloat = 120
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let iconTileSide: CGFloat = 38
        static let notifyIconTileSide: CGFloat = 38
        static let ctaHeight: CGFloat = 48
    }

    private enum Palette {
        static let headerTitle = UIColor(hex: "#FAFAFA")
        static let headerSubtext = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let divider = UIColor.white.withAlphaComponent(0.10)                 // #1AFFFFFF
        static let cardFill = UIColor(hex: "#18191C")
        static let cardStroke = UIColor(hex: "#232323")
        static let tileFill = UIColor(hex: "#101113")
        static let pillStroke = UIColor(hex: "#FAFAFA")
        static let pillText = UIColor(hex: "#F0F0F0")
        static let classTitleColor = UIColor.white
        static let classDateTime = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let rowTitle = UIColor.white
        static let rowSubtitle = UIColor.white.withAlphaComponent(0.4)               // #66FFFFFF
        static let notifyCardFill = GroupClassColor.blueCardBg.color                // #000814
        static let notifyCardStroke = GroupClassColor.blue.color.withAlphaComponent(0.30) // #4D0865FE
        static let notifyTileFill = UIColor(hex: "#001233")
        static let notifyDivider = GroupClassColor.blue.color.withAlphaComponent(0.10) // #1A0865FE
        static let notifyTitle = UIColor.white
        static let notifySubtitle = UIColor(hex: "#959595")
        static let notifyInfoText = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let ctaInk = UIColor(hex: "#131416")
    }

    private enum Copy {
        static let headerTitle = "You\u{2019}re on the waitlist"
        static let headerSubtext = "We\u{2019}ll notify you as soon as a spot opens up. Be ready to confirm & secure your booking"
        static let categoryPill = "GROUP CLASS"
        static let trainerPlaceholder = "Trainer: Sara K."
        static let trainerSubtitle = "Certified MyPT Trainer"
        static let distancePlaceholder = "2.1 km away"
        static let notifyTitle = "We\u{2019}ll notify you instantly"
        static let notifySubtitle = "Enable notifications to get instant alerts when a spot opens."
        static let notifyInfoText = "Spots are booked on a first-confirmed basis"
        static let viewBookingCTA = "VIEW BOOKING"
    }

    // MARK: - Views

    /// `android:background="@drawable/bg_confirm_slot_success"` — the same
    /// raster photo Slot Confirmed uses (light rays, sparkle particles, a
    /// blue-teal glow), not the flat radial wash this used to approximate it with.
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let backButton = GlassCircularIconButton()

    private let classTitleLabel = UILabel()
    private let classDateTimeLabel = UILabel()
    private let locationTitleLabel = UILabel()
    private let locationDistanceLabel = UILabel()
    private let trainerTitleLabel = UILabel()

    private let footerView = UIView()
    private let ctaButton = GradientCTAButton()

    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

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

    // MARK: - Populate

    private func populateUI() {
        classTitleLabel.text = classTitle
        classDateTimeLabel.text = classTime
        locationTitleLabel.text = classLocation

        let trimmedDistance = distance.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedDistance.isEmpty {
            locationDistanceLabel.text = trimmedDistance.contains("away") ? trimmedDistance : "\(trimmedDistance) away"
        }

        let trimmedTrainer = trainerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTrainer.isEmpty {
            trainerTitleLabel.text = trimmedTrainer.hasPrefix("Trainer:") ? trimmedTrainer : "Trainer: \(trimmedTrainer)"
        }
    }

    // MARK: - Actions

    private static let bookingsTabIndex = 2

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    /// Was just `popViewController` (matching Android's old `finish()`) - closed
    /// back to Group Training Detail instead of actually taking the member to
    /// their bookings, unlike Slot Confirmed / Double Booking Waitlist
    /// Confirmed's own "VIEW BOOKING" buttons. Same tab-jump pattern as those.
    @objc private func viewBookingTapped() {
        TapticEngine.selection.feedback()

        let hostNavigationController = navigationController

        guard let tabBarController = resolveTabBarController(),
              let tabs = tabBarController.viewControllers,
              tabs.indices.contains(WaitlistConfirmedViewController.bookingsTabIndex) else {
            hostNavigationController?.popToRootViewController(animated: true)
            return
        }

        (tabs[WaitlistConfirmedViewController.bookingsTabIndex] as? UINavigationController)?
            .popToRootViewController(animated: false)
        tabBarController.selectedIndex = WaitlistConfirmedViewController.bookingsTabIndex

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
}

// MARK: - Layout

private extension WaitlistConfirmedViewController {

    func buildLayout() {
        buildBackgroundWash()
        buildFooter()
        buildScrollView()
    }

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

    func buildFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = .clear
        view.addSubview(footerView)

        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.bandThickness = 2
        ctaButton.configure(title: Copy.viewBookingCTA,
                            font: AppFont.semibold.size(16.0, familyName: familyFunnelSans),
                            titleColor: Palette.ctaInk)
        ctaButton.addTarget(self, action: #selector(viewBookingTapped), for: .touchUpInside)
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

        contentStack.addArrangedSubview(makeNotifyCard())
    }

    // MARK: Header

    func makeBackButtonRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.configure(icon: WaitlistConfirmedViewController.icon(["ic_back_chevron_20"], systemFallback: "chevron.left"),
                             diameter: Metric.backButtonDiameter)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
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

        let badge = SlotConfirmedSuccessBadgeView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(badge)

        NSLayoutConstraint.activate([
            badge.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            badge.topAnchor.constraint(equalTo: container.topAnchor),
            badge.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            badge.widthAnchor.constraint(equalToConstant: Metric.badgeSide),
            badge.heightAnchor.constraint(equalToConstant: Metric.badgeSide)
        ])
        return container
    }

    func makeHeaderTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        label.textColor = Palette.headerTitle
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Copy.headerTitle
        return label
    }

    func makeHeaderSubtextRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = NSAttributedString(
            string: Copy.headerSubtext,
            attributes: [
                .font: AppFont.medium.size(14.0, familyName: familyFunnelSans),
                .foregroundColor: Palette.headerSubtext,
                .paragraphStyle: WaitlistConfirmedViewController.paragraphStyle(lineSpacing: 4, alignment: .center)
            ]
        )
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        return container
    }

    // MARK: Details card (single flat card — no stacked policy strip, no price row)

    func makeDetailsCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.showsSheen = false

        let pillRow = makeCategoryPillRow()

        classTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        classTitleLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        classTitleLabel.textColor = Palette.classTitleColor
        classTitleLabel.numberOfLines = 0

        classDateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        classDateTimeLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        classDateTimeLabel.textColor = Palette.classDateTime
        classDateTimeLabel.numberOfLines = 1
        classDateTimeLabel.lineBreakMode = .byTruncatingTail

        locationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        locationTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        locationTitleLabel.textColor = Palette.rowTitle
        locationTitleLabel.numberOfLines = 1
        locationTitleLabel.lineBreakMode = .byTruncatingTail

        locationDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        locationDistanceLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        locationDistanceLabel.textColor = Palette.rowSubtitle
        locationDistanceLabel.numberOfLines = 1
        locationDistanceLabel.lineBreakMode = .byTruncatingTail
        locationDistanceLabel.text = Copy.distancePlaceholder

        let locationRow = makeDetailRow(icon: WaitlistConfirmedViewController.icon(["ic_location_pin_small"], systemFallback: "mappin.and.ellipse"),
                                        iconSide: 14,
                                        titleLabel: locationTitleLabel,
                                        subtitleLabel: locationDistanceLabel)

        trainerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        trainerTitleLabel.textColor = Palette.rowTitle
        trainerTitleLabel.numberOfLines = 1
        trainerTitleLabel.lineBreakMode = .byTruncatingTail
        trainerTitleLabel.text = Copy.trainerPlaceholder

        let trainerSubtitleLabel = UILabel()
        trainerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerSubtitleLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        trainerSubtitleLabel.textColor = Palette.rowSubtitle
        trainerSubtitleLabel.numberOfLines = 1
        trainerSubtitleLabel.lineBreakMode = .byTruncatingTail
        trainerSubtitleLabel.text = Copy.trainerSubtitle

        let trainerRow = makeDetailRow(icon: WaitlistConfirmedViewController.icon(["ic_trainer_running_18"], systemFallback: "figure.run"),
                                       iconSide: 18,
                                       titleLabel: trainerTitleLabel,
                                       subtitleLabel: trainerSubtitleLabel)

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
        stack.addArrangedSubview(classDateTimeLabel)
        stack.setCustomSpacing(12, after: classDateTimeLabel)
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

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        label.textColor = Palette.pillText
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = Copy.categoryPill
        pill.addSubview(label)

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(pill)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: pill.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12),

            pill.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            pill.topAnchor.constraint(equalTo: wrapper.topAnchor),
            pill.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            pill.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            pill.trailingAnchor.constraint(lessThanOrEqualTo: wrapper.trailingAnchor)
        ])
        return wrapper
    }

    func makeDetailRow(icon: UIImage?,
                       iconSide: CGFloat,
                       titleLabel: UILabel,
                       subtitleLabel: UILabel) -> UIStackView {
        let iconTile = makeIconTile(image: icon, iconSide: iconSide, fill: Palette.tileFill)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 2
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        row.addArrangedSubview(iconTile)
        row.addArrangedSubview(textStack)
        return row
    }

    func makeIconTile(image: UIImage?, iconSide: CGFloat, fill: UIColor) -> UIView {
        let tile = GlassCardView(cornerRadius: 12)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = fill
        tile.fillAlpha = 1.0
        tile.strokeColor = UIColor(hex: "#101113")
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

    func makeDivider() -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = Palette.divider
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    // MARK: Notify card (blue)

    func makeNotifyCard() -> UIView {
        let card = GlassCardView(cornerRadius: 12)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.notifyCardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.notifyCardStroke
        card.strokeAlpha = 1.0
        // `waitlist_notify_card_bg`'s middle layer: `angle=270` linear,
        // `#190865FE -> #000865FE` — a faint top-to-bottom blue tint.
        card.washColors = [GroupClassColor.blue.color.withAlphaComponent(0.098),
                           GroupClassColor.blue.color.withAlphaComponent(0.0)]
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        let bellTile = makeIconTile(image: WaitlistConfirmedViewController.icon(["ic_bell_18", "bell"]),
                                    iconSide: 18,
                                    fill: Palette.notifyTileFill)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        titleLabel.textColor = Palette.notifyTitle
        titleLabel.numberOfLines = 1
        titleLabel.text = Copy.notifyTitle

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.numberOfLines = 0
        subtitleLabel.attributedText = NSAttributedString(
            string: Copy.notifySubtitle,
            attributes: [
                .font: AppFont.regular.size(14.0, familyName: familyFunnelSans),
                .foregroundColor: Palette.notifySubtitle,
                .paragraphStyle: WaitlistConfirmedViewController.paragraphStyle(lineSpacing: 4, alignment: .left)
            ]
        )

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 4

        let headRow = UIStackView(arrangedSubviews: [bellTile, textStack])
        headRow.translatesAutoresizingMaskIntoConstraints = false
        headRow.axis = .horizontal
        headRow.alignment = .center
        headRow.spacing = 12

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = Palette.notifyDivider
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let infoIcon = UIImageView(image: WaitlistConfirmedViewController.icon(["ic_info_hexagon_18", "info-hexagon"])?
            .withRenderingMode(.alwaysTemplate))
        infoIcon.translatesAutoresizingMaskIntoConstraints = false
        infoIcon.tintColor = Palette.notifyInfoText
        infoIcon.contentMode = .scaleAspectFit

        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = AppFont.medium.size(13.0, familyName: familyFunnelSans)
        infoLabel.textColor = Palette.notifyInfoText
        infoLabel.numberOfLines = 0
        infoLabel.text = Copy.notifyInfoText

        let infoRow = UIStackView(arrangedSubviews: [infoIcon, infoLabel])
        infoRow.translatesAutoresizingMaskIntoConstraints = false
        infoRow.axis = .horizontal
        infoRow.alignment = .center
        infoRow.spacing = 8

        let stack = UIStackView(arrangedSubviews: [headRow, divider, infoRow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 12

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            infoIcon.widthAnchor.constraint(equalToConstant: 18),
            infoIcon.heightAnchor.constraint(equalToConstant: 18),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }
}

// MARK: - Attributed copy + icon resolution

private extension WaitlistConfirmedViewController {

    static func paragraphStyle(lineSpacing: CGFloat, alignment: NSTextAlignment) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.alignment = alignment
        return style
    }

    static func icon(_ names: [String], systemFallback: String? = nil) -> UIImage? {
        for name in names {
            if let image = UIImage(named: name) { return image }
        }
        if let systemFallback = systemFallback {
            return UIImage(systemName: systemFallback)
        }
        return nil
    }
}
