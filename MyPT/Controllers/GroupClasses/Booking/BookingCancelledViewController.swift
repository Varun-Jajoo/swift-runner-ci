//
//  BookingCancelledViewController.swift
//  MyPT
//
//  "Booking Cancelled" - the post-cancellation confirmation screen, reached
//  from `SlotConfirmedViewController.cancelBookingTapped()` after a
//  successful `cancel-class-booking` call.
//
//  Deliberately built as a duplicate/reskin of `BookingPausedViewController`
//  (the terminal blacklist screen) rather than a new design from scratch, per
//  explicit design direction — same shell, icon/copy/card content swapped for
//  a cancellation-success context instead of a ban.
//
//  Android reference (ground truth): `BookingCancelledActivity.kt` /
//  `activity_booking_cancelled.xml`, itself a duplicate of
//  `BookingPausedActivity.kt` / `activity_booking_paused.xml`.
//

import UIKit

final class BookingCancelledViewController: CommonViewController {

    // MARK: - Input

    var classTitle: String = "Morning Flow Yoga"
    var classTime: String = "Wed, 9 Jul • 7-8 AM"

    // MARK: - Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let backButtonDiameter: CGFloat = 40
        static let badgeSide: CGFloat = 94
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let iconTileSide: CGFloat = 38
        static let ctaHeight: CGFloat = 48
    }

    private enum Palette {
        static let headerTitle = UIColor(hex: "#FAFAFA")
        static let headerSubtext = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let cardFill = UIColor(hex: "#18191C")
        static let cardStroke = UIColor(hex: "#232323")
        static let tileFill = UIColor(hex: "#101113")
        static let rowTitle = UIColor(hex: "#FAFAFA")
        static let rowSubtitle = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let ctaInk = UIColor(hex: "#131416")
    }

    private enum Copy {
        static let headerTitle = "Booking Cancelled"
        static let headerSubtext = "Your spot has been released for other members."
        static let viewBookingsCTA = "VIEW MY BOOKINGS"
    }

    // MARK: - Views

    /// Same background photo as Slot Confirmed - a cancellation this screen
    /// frames as a completed, positive action, not a failure state.
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let footerView = UIView()
    private let ctaButton = GradientCTAButton()

    private let classTitleLabel = UILabel()
    private let classDateTimeLabel = UILabel()

    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GroupClassColor.bg.color
        buildLayout()
        populateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Populate

    private func populateUI() {
        classTitleLabel.text = classTitle
        classDateTimeLabel.text = classTime
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popToRootViewController(animated: true)
    }

    /// This screen is only ever reached from a Bookings-tab row (via
    /// `SlotConfirmedViewController`'s read-only mode), so its own nav stack
    /// root already *is* the Bookings list - no tab-jump plumbing needed.
    @objc private func viewMyBookingsTapped() {
        TapticEngine.selection.feedback()
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Layout

private extension BookingCancelledViewController {

    func buildLayout() {
        buildBackgroundImage()
        buildFooter()
        buildScrollView()
    }

    func buildBackgroundImage() {
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
        view.addSubview(footerView)

        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.bandThickness = 2
        ctaButton.configure(title: Copy.viewBookingsCTA,
                            font: AppFont.semibold.size(16.0, familyName: familyFunnelSans),
                            titleColor: Palette.ctaInk)
        ctaButton.addTarget(self, action: #selector(viewMyBookingsTapped), for: .touchUpInside)
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
        contentStack.setCustomSpacing(28, after: backRow)

        let badgeRow = makeBadgeRow()
        contentStack.addArrangedSubview(badgeRow)
        contentStack.setCustomSpacing(24, after: badgeRow)

        let titleLabel = makeHeaderTitleLabel()
        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(8, after: titleLabel)

        let subtextLabel = makeHeaderSubtextLabel()
        contentStack.addArrangedSubview(subtextLabel)
        contentStack.setCustomSpacing(28, after: subtextLabel)

        contentStack.addArrangedSubview(makeSummaryCard())
    }

    func makeBackButtonRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let backButton = GlassCircularIconButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.configure(icon: BookingCancelledViewController.icon(["ic_back_chevron_20"], systemFallback: "chevron.left"),
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

    /// Reuses `SlotConfirmedSuccessBadgeView` (the hand-drawn teal checkmark
    /// disc, defined alongside `SlotConfirmedViewController`) instead of a new
    /// asset - the same success iconography, just at the ban screen's smaller
    /// 94pt size instead of 120pt.
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
        label.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
        label.textColor = Palette.headerTitle
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Copy.headerTitle
        return label
    }

    func makeHeaderSubtextLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        label.textColor = Palette.headerSubtext
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Copy.headerSubtext
        return label
    }

    // MARK: Cancelled booking summary card

    func makeSummaryCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        let iconTile = GlassCardView(cornerRadius: 12)
        iconTile.translatesAutoresizingMaskIntoConstraints = false
        iconTile.fillColor = Palette.tileFill
        iconTile.fillAlpha = 1.0
        iconTile.strokeColor = UIColor(hex: "#101113")
        iconTile.strokeAlpha = 1.0
        iconTile.sheenOrigin = .topCenter
        iconTile.sheenAlpha = 0.08

        let iconView = UIImageView(image: BookingCancelledViewController.icon(["ic_calendar_cross_18", "calendar-cross"], systemFallback: "calendar.badge.exclamationmark")?
            .withRenderingMode(.alwaysTemplate))
        iconView.tintColor = .white
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconTile.addSubview(iconView)

        classTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        classTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        classTitleLabel.textColor = Palette.rowTitle
        classTitleLabel.numberOfLines = 1
        classTitleLabel.lineBreakMode = .byTruncatingTail

        classDateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        classDateTimeLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        classDateTimeLabel.textColor = Palette.rowSubtitle
        classDateTimeLabel.numberOfLines = 1
        classDateTimeLabel.lineBreakMode = .byTruncatingTail

        let textStack = UIStackView(arrangedSubviews: [classTitleLabel, classDateTimeLabel])
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
        card.addSubview(row)

        NSLayoutConstraint.activate([
            iconTile.widthAnchor.constraint(equalToConstant: Metric.iconTileSide),
            iconTile.heightAnchor.constraint(equalToConstant: Metric.iconTileSide),
            iconView.centerXAnchor.constraint(equalTo: iconTile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconTile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            row.topAnchor.constraint(equalTo: card.topAnchor, constant: Metric.cardPadding),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Metric.cardPadding),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Metric.cardPadding),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Metric.cardPadding)
        ])
        return card
    }
}

// MARK: - Icon resolution

private extension BookingCancelledViewController {

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
