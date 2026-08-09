//
//  DoubleBookingWaitlistConfirmedViewController.swift
//  MyPT
//
//  Double Booking Waitlist Confirmation Screen.
//

import UIKit

final class DoubleBookingWaitlistConfirmedViewController: CommonViewController {

    var classTitle: String = "Morning Flow Yoga"
    var classTime: String = "Wed, 9 Jul • 7-8 AM"
    var classLocation: String = "Silicon Oasis"
    var trainerName: String = ""
    var distance: String = ""

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let backButtonDiameter: CGFloat = 40
        static let badgeSide: CGFloat = 120
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let iconTileSide: CGFloat = 38
        static let ctaHeight: CGFloat = 48
    }

    private enum Palette {
        static let headerTitle = UIColor(hex: "#FAFAFA")
        static let headerSubtext = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let divider = UIColor.white.withAlphaComponent(0.10)
        static let cardFill = UIColor(hex: "#18191C")
        static let cardStroke = UIColor(hex: "#232323")
        static let tileFill = UIColor(hex: "#101113")
        static let pillStroke = UIColor(hex: "#FAFAFA")
        static let pillFill = UIColor.white.withAlphaComponent(0.10)
        static let pillText = UIColor(hex: "#FFCC33")
        static let rowTitle = UIColor(hex: "#FAFAFA")
        static let rowSubtitle = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let infoBoxFill = UIColor(hex: "#121415")
        static let infoBoxBorder = UIColor(hex: "#FFCC33").withAlphaComponent(0.3)
        static let infoBoxText = UIColor(hex: "#FAFAFA").withAlphaComponent(0.85)
        static let ctaFill = UIColor(hex: "#CCFF00")
        static let ctaText = UIColor.black
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let backButton = UIButton(type: .custom)
    private let badgeView = SlotConfirmedSuccessBadgeView()

    private let headerTitleLabel = UILabel()
    private let headerSubtextLabel = UILabel()

    private let detailsCardView = UIView()
    private let categoryPillLabel = UILabel()
    private let classTitleLabel = UILabel()
    private let dateTimeLabel = UILabel()

    private let locationTitleLabel = UILabel()
    private let locationDistanceLabel = UILabel()

    private let trainerNameLabel = UILabel()

    private let infoBoxView = UIView()
    private let infoIconView = UIImageView()
    private let infoTextLabel = UILabel()

    private static let bookingsTabIndex = 2

    private let ctaContainerView = UIView()
    private let viewBookingButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        populateData()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupViews() {
        view.backgroundColor = UIColor(hex: "#050607")
        setupScrollView()
        setupHeader()
        setupDetailsCard()
        setupInfoBox()
        setupCTA()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupHeader() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "ic_back_chevron_20") ?? UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        backButton.layer.cornerRadius = Metric.backButtonDiameter / 2
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        badgeView.translatesAutoresizingMaskIntoConstraints = false

        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        headerTitleLabel.textColor = Palette.headerTitle
        headerTitleLabel.textAlignment = .center
        headerTitleLabel.text = "You're on the waitlist"

        headerSubtextLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSubtextLabel.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        headerSubtextLabel.textColor = Palette.headerSubtext
        headerSubtextLabel.textAlignment = .center
        headerSubtextLabel.numberOfLines = 0
        headerSubtextLabel.text = "You already have an overlapping booking. We'll notify you as soon as a spot opens up and your priority window opens."

        contentView.addSubview(backButton)
        contentView.addSubview(badgeView)
        contentView.addSubview(headerTitleLabel)
        contentView.addSubview(headerSubtextLabel)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalInset),
            backButton.widthAnchor.constraint(equalToConstant: Metric.backButtonDiameter),
            backButton.heightAnchor.constraint(equalToConstant: Metric.backButtonDiameter),

            badgeView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            badgeView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            badgeView.widthAnchor.constraint(equalToConstant: Metric.badgeSide),
            badgeView.heightAnchor.constraint(equalToConstant: Metric.badgeSide),

            headerTitleLabel.topAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: 20),
            headerTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalInset),
            headerTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalInset),

            headerSubtextLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 8),
            headerSubtextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalInset),
            headerSubtextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalInset)
        ])
    }

    private func setupDetailsCard() {
        detailsCardView.translatesAutoresizingMaskIntoConstraints = false
        detailsCardView.backgroundColor = Palette.cardFill
        detailsCardView.layer.cornerRadius = Metric.cardCornerRadius
        detailsCardView.layer.borderWidth = 1
        detailsCardView.layer.borderColor = Palette.cardStroke.cgColor

        categoryPillLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryPillLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        categoryPillLabel.textColor = Palette.pillText
        categoryPillLabel.text = "OVERLAPPING WAITLIST"
        let pillRow = makeCategoryPillRow()

        classTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        classTitleLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        classTitleLabel.textColor = .white
        classTitleLabel.numberOfLines = 2

        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        dateTimeLabel.textColor = Palette.rowSubtitle

        locationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        locationTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        locationTitleLabel.textColor = Palette.rowTitle
        locationDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        locationDistanceLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        locationDistanceLabel.textColor = Palette.rowSubtitle
        let locationRow = makeDetailRow(icon: DoubleBookingWaitlistConfirmedViewController.icon(["ic_location_pin_small"], systemFallback: "mappin.and.ellipse"),
                                        iconSide: 14,
                                        titleLabel: locationTitleLabel,
                                        subtitleLabel: locationDistanceLabel)

        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerNameLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        trainerNameLabel.textColor = Palette.rowTitle
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

        contentView.addSubview(detailsCardView)
        detailsCardView.addSubview(stack)

        NSLayoutConstraint.activate([
            detailsCardView.topAnchor.constraint(equalTo: headerSubtextLabel.bottomAnchor, constant: 24),
            detailsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalInset),
            detailsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalInset),

            stack.topAnchor.constraint(equalTo: detailsCardView.topAnchor, constant: Metric.cardPadding),
            stack.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: Metric.cardPadding),
            stack.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -Metric.cardPadding),
            stack.bottomAnchor.constraint(equalTo: detailsCardView.bottomAnchor, constant: -Metric.cardPadding)
        ])
    }

    /// Android's `glass_pill_bg`: translucent stroke + 10%-white fill pill,
    /// height >= 24, 12h/4v padding.
    private func makeCategoryPillRow() -> UIView {
        let pill = UIView()
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = Palette.pillFill
        pill.layer.cornerRadius = 8
        pill.layer.borderWidth = 1
        pill.layer.borderColor = Palette.pillStroke.withAlphaComponent(0.2).cgColor
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

    /// Icon tile + title/subtitle vertical stack - Android's location row.
    private func makeDetailRow(icon: UIImage?, iconSide: CGFloat, titleLabel: UILabel, subtitleLabel: UILabel) -> UIStackView {
        let iconTile = makeIconTile(image: icon, iconSide: iconSide)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [iconTile, textStack])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    /// Icon tile + single title label - Android's trainer row (no subtitle line here).
    private func makeSingleLineDetailRow(icon: UIImage?, iconSide: CGFloat, titleLabel: UILabel) -> UIStackView {
        let iconTile = makeIconTile(image: icon, iconSide: iconSide)
        let row = UIStackView(arrangedSubviews: [iconTile, titleLabel])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    /// Android's `location_icon_bg`: 38pt rounded-square tile, dark fill.
    private func makeIconTile(image: UIImage?, iconSide: CGFloat) -> UIView {
        let tile = UIView()
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.backgroundColor = Palette.tileFill
        tile.layer.cornerRadius = 12

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

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = Palette.divider
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
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

    private func setupInfoBox() {
        infoBoxView.translatesAutoresizingMaskIntoConstraints = false
        infoBoxView.backgroundColor = Palette.infoBoxFill
        infoBoxView.layer.cornerRadius = 12
        infoBoxView.layer.borderWidth = 1
        infoBoxView.layer.borderColor = Palette.infoBoxBorder.cgColor

        infoIconView.translatesAutoresizingMaskIntoConstraints = false
        infoIconView.image = DoubleBookingWaitlistConfirmedViewController
            .icon(["ic_info_hexagon_18"], systemFallback: "info.circle.fill")?
            .withRenderingMode(.alwaysTemplate)
        infoIconView.tintColor = Palette.pillText
        infoIconView.contentMode = .scaleAspectFit

        infoTextLabel.translatesAutoresizingMaskIntoConstraints = false
        infoTextLabel.font = AppFont.medium.size(13.0, familyName: familyFunnelSans)
        infoTextLabel.textColor = Palette.infoBoxText
        infoTextLabel.numberOfLines = 0
        infoTextLabel.text = "Priority Notice: Your waitlist position for this overlapping slot becomes active 3 hours prior to class start or if your existing booking is cancelled."

        contentView.addSubview(infoBoxView)
        infoBoxView.addSubview(infoIconView)
        infoBoxView.addSubview(infoTextLabel)

        NSLayoutConstraint.activate([
            infoBoxView.topAnchor.constraint(equalTo: detailsCardView.bottomAnchor, constant: 16),
            infoBoxView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalInset),
            infoBoxView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalInset),

            infoIconView.topAnchor.constraint(equalTo: infoBoxView.topAnchor, constant: 16),
            infoIconView.leadingAnchor.constraint(equalTo: infoBoxView.leadingAnchor, constant: 16),
            infoIconView.widthAnchor.constraint(equalToConstant: 20),
            infoIconView.heightAnchor.constraint(equalToConstant: 20),

            infoTextLabel.topAnchor.constraint(equalTo: infoBoxView.topAnchor, constant: 14),
            infoTextLabel.leadingAnchor.constraint(equalTo: infoIconView.trailingAnchor, constant: 12),
            infoTextLabel.trailingAnchor.constraint(equalTo: infoBoxView.trailingAnchor, constant: -14),
            infoTextLabel.bottomAnchor.constraint(equalTo: infoBoxView.bottomAnchor, constant: -14)
        ])
    }

    private func setupCTA() {
        ctaContainerView.translatesAutoresizingMaskIntoConstraints = false
        ctaContainerView.backgroundColor = UIColor(hex: "#0A0D0C")

        viewBookingButton.translatesAutoresizingMaskIntoConstraints = false
        viewBookingButton.setTitle("View Bookings", for: .normal)
        viewBookingButton.setTitleColor(Palette.ctaText, for: .normal)
        viewBookingButton.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyFunnelSans)
        viewBookingButton.backgroundColor = Palette.ctaFill
        viewBookingButton.layer.cornerRadius = 24
        viewBookingButton.addTarget(self, action: #selector(didTapViewBookings), for: .touchUpInside)

        view.addSubview(ctaContainerView)
        ctaContainerView.addSubview(viewBookingButton)

        NSLayoutConstraint.activate([
            ctaContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ctaContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ctaContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            viewBookingButton.topAnchor.constraint(equalTo: ctaContainerView.topAnchor, constant: 12),
            viewBookingButton.leadingAnchor.constraint(equalTo: ctaContainerView.leadingAnchor, constant: 20),
            viewBookingButton.trailingAnchor.constraint(equalTo: ctaContainerView.trailingAnchor, constant: -20),
            viewBookingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            viewBookingButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight),

            scrollView.bottomAnchor.constraint(equalTo: ctaContainerView.topAnchor)
        ])
    }

    private func populateData() {
        classTitleLabel.text = classTitle
        dateTimeLabel.text = classTime
        locationTitleLabel.text = classLocation
        locationDistanceLabel.text = distance.isEmpty ? "" : (distance.contains("away") ? distance : "\(distance) away")
        trainerNameLabel.text = trainerName.isEmpty ? "" : (trainerName.hasPrefix("Trainer:") ? trainerName : "Trainer: \(trainerName)")
    }

    @objc private func didTapBack() {
        // This screen is always reached via `pushViewController` (see
        // DoubleBookingSheetViewController.joinWaitlistTapped() and
        // GroupTrainingDetailViewController), never `present` - `dismiss`
        // was a no-op here (or worse, could dismiss an unrelated ancestor's
        // modal). Same pattern as SlotConfirmedViewController's back button.
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapViewBookings() {
        // Port of SlotConfirmedViewController.viewMyBookingsTapped() - this
        // screen is pushed, not presented, so it lands on the Bookings tab
        // directly rather than dismissing first like the sheet's own
        // "Manage Existing Booking" button does.
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

    /// `tabBarController` is the normal answer (this screen is pushed onto a
    /// tab's navigation stack); the window walk is only a safety net.
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
