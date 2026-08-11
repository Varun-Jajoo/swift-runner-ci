//
//  ClassCancelledByAdminViewController.swift
//  MyPT
//
//  "This class has been cancelled" — shown in place of the read-only
//  SlotConfirmedViewController receipt when a booking's cancellation was the
//  ADMIN cancelling the whole class schedule (GroupClassService::
//  cancelClassSchedule()), not the member's own cancel. A member who
//  cancelled their own booking already knows why; a member whose class got
//  pulled out from under them by an admin needs to be told plainly, not left
//  to infer it from a plain "Cancelled" pill on the usual receipt screen.
//
//  Layout borrows two existing screens rather than inventing new visual
//  language: the class-detail card is SlotConfirmedViewController's own
//  recipe (pill row, title, date/time, location/trainer rows) unchanged, and
//  the hero icon + header is BookingPausedViewController's red "banned"
//  treatment (`ic_error_circle_94`, same red/brown palette) - this is a
//  rejection, same visual register as being blacklisted, not a receipt.
//

import UIKit

// MARK: - ClassCancelledByAdminInput

struct ClassCancelledByAdminInput {
    var classTitle: String = ""
    /// Already formatted for display, e.g. `Wed, 9 Jul • 7-8 AM`.
    var classTime: String = ""
    var classLocation: String = ""
    var trainerName: String = ""
    var distance: String = ""
    var studioLat: Double = 0
    var studioLng: Double = 0
}

// MARK: - ClassCancelledByAdminViewController

final class ClassCancelledByAdminViewController: CommonViewController {

    var input = ClassCancelledByAdminInput()

    // MARK: Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let backButtonDiameter: CGFloat = 40
        static let errorIconSide: CGFloat = 94
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let iconTileSide: CGFloat = 38
        static let warningIconSide: CGFloat = 16
        static let ctaHeight: CGFloat = 48
    }

    /// Details card + note box hex values straight from
    /// `SlotConfirmedViewController`'s own Palette (unchanged, this is a
    /// receipt-style card same as any other booking's); header/icon hex
    /// values from `BookingPausedViewController`'s red "banned" Palette.
    private enum Palette {
        static let headerTitle = UIColor(hex: "#FAFAFA")
        static let headerSubtext = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let divider = UIColor.white.withAlphaComponent(0.10)
        // Red/brown card fill - BookingPausedViewController's own blacklist-card
        // colors, not SlotConfirmedViewController's plain dark card. Same
        // reasoning as the page background: this is a rejection, not a receipt.
        static let cardFill = UIColor(hex: "#291F1D")
        static let cardStroke = UIColor(hex: "#3E302D")
        // Red icon tiles - BookingPausedViewController's own redIconFill/Stroke,
        // not SlotConfirmedViewController's plain dark tileFill.
        static let tileFill = UIColor(hex: "#78271C")
        static let tileStroke = UIColor(hex: "#8E3225")
        static let pillStroke = UIColor(hex: "#FAFAFA")
        static let pillText = UIColor(hex: "#F0F0F0")
        static let classTitle = UIColor(hex: "#FFFFFF")
        static let classDateTime = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let rowTitle = UIColor(hex: "#FFFFFF")
        static let rowSubtitle = UIColor.white.withAlphaComponent(0.4)
        static let noteBody = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let manageButtonFill = UIColor(hex: "#1D1E1D")
        static let manageButtonStroke = UIColor.white.withAlphaComponent(0.10)
        static let manageButtonText = UIColor(hex: "#FAFAFA")
        static let ctaInk = UIColor(hex: "#131416")
    }

    private enum Copy {
        static let headerTitle = "This class has been cancelled"
        static let headerSubtext = "Unfortunately, this session will no longer take place. We apologize for the inconvenience."
        static let categoryPill = "GROUP CLASS"
        static let importantNoteTitle = "IMPORTANT NOTE"
        static let importantNoteBody = "If any payment has been made for this booking, it will be refunded to your original payment method within 48 working hours."
        static let trainerSubtitle = "Certified MyPT Trainer"
        static let exploreCTA = "EXPLORE CLASSES"
        static let viewBookingsCTA = "VIEW MY BOOKINGS"
    }

    // MARK: Views

    /// Same raster background BookingPausedViewController uses - a rejection,
    /// not a receipt, reads that way from the page background up.
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let footerView = UIView()
    private let exploreButton = UIButton(type: .system)
    private let viewBookingsButton = UIButton(type: .system)

    // MARK: Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GroupClassColor.bg.color
        buildBackgroundImage()
        buildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func exploreClassesTapped() {
        TapticEngine.selection.feedback()
        let controller = SeeAllGroupClassesViewController()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func viewBookingsTapped() {
        TapticEngine.selection.feedback()
        // Same reliable tab-switch AppDelegate already uses for the local
        // "spot opened up" notification and the double-booking sheet's
        // "Manage Your Booking" - always lands on Bookings regardless of
        // how deep this screen was pushed.
        AppDelegate.jumpToBookingsTab()
    }
}

// MARK: - Layout

private extension ClassCancelledByAdminViewController {

    func buildLayout() {
        buildFooter()
        buildScrollView()
    }

    func buildBackgroundImage() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: "booking-paused-bg")
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
        // Opaque, same as BookingPausedViewController's own footer - not
        // transparent like SlotConfirmedViewController's.
        footerView.backgroundColor = UIColor(hex: "#000814")
        view.addSubview(footerView)

        exploreButton.translatesAutoresizingMaskIntoConstraints = false
        exploreButton.backgroundColor = .white
        exploreButton.layer.cornerRadius = 8
        exploreButton.setTitle(Copy.exploreCTA, for: .normal)
        exploreButton.setTitleColor(Palette.ctaInk, for: .normal)
        exploreButton.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        exploreButton.addTarget(self, action: #selector(exploreClassesTapped), for: .touchUpInside)
        exploreButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight).isActive = true

        viewBookingsButton.translatesAutoresizingMaskIntoConstraints = false
        viewBookingsButton.backgroundColor = Palette.manageButtonFill
        viewBookingsButton.layer.cornerRadius = 8
        viewBookingsButton.layer.borderWidth = 1
        viewBookingsButton.layer.borderColor = Palette.manageButtonStroke.cgColor
        viewBookingsButton.setTitle(Copy.viewBookingsCTA, for: .normal)
        viewBookingsButton.setTitleColor(Palette.manageButtonText, for: .normal)
        viewBookingsButton.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        viewBookingsButton.addTarget(self, action: #selector(viewBookingsTapped), for: .touchUpInside)
        viewBookingsButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight).isActive = true

        let buttonStack = UIStackView(arrangedSubviews: [exploreButton, viewBookingsButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.alignment = .fill
        buttonStack.spacing = 10
        footerView.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            buttonStack.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: Metric.horizontalInset),
            buttonStack.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -Metric.horizontalInset),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
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
        contentStack.setCustomSpacing(24, after: backRow)

        let errorRow = makeErrorIconRow()
        contentStack.addArrangedSubview(errorRow)
        contentStack.setCustomSpacing(24, after: errorRow)

        let titleLabel = makeHeaderTitleLabel()
        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(8, after: titleLabel)

        let subtextLabel = makeHeaderSubtextLabel()
        contentStack.addArrangedSubview(subtextLabel)
        contentStack.setCustomSpacing(28, after: subtextLabel)

        let detailsCard = makeDetailsCard()
        contentStack.addArrangedSubview(detailsCard)
        contentStack.setCustomSpacing(16, after: detailsCard)

        contentStack.addArrangedSubview(makeImportantNoteBox())
    }

    // MARK: Back + hero icon (BookingPausedViewController's own recipe)

    func makeBackButtonRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let backButton = GlassCircularIconButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.configure(icon: ClassCancelledByAdminViewController.icon(["ic_back_chevron_20"], systemFallback: "chevron.left"),
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

    func makeErrorIconRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Same baked-in red/white artwork BookingPausedViewController uses -
        // do not tint, it ships its own color.
        let iconView = UIImageView(image: ClassCancelledByAdminViewController.icon(["ic_error_circle_94", "error-circle"]))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        container.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: container.topAnchor),
            iconView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            iconView.widthAnchor.constraint(equalToConstant: Metric.errorIconSide),
            iconView.heightAnchor.constraint(equalToConstant: Metric.errorIconSide)
        ])
        return container
    }

    func makeHeaderTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.medium.size(22.0, familyName: familyClashDisplay)
        label.textColor = Palette.headerTitle
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Copy.headerTitle
        return label
    }

    func makeHeaderSubtextLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        label.textColor = Palette.headerSubtext
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Copy.headerSubtext
        return label
    }

    // MARK: Details card (SlotConfirmedViewController's own recipe, unchanged)

    func makeDetailsCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        let pill = makePill(text: Copy.categoryPill)

        let pillWrapper = UIView()
        pillWrapper.translatesAutoresizingMaskIntoConstraints = false
        pillWrapper.addSubview(pill)
        NSLayoutConstraint.activate([
            pill.topAnchor.constraint(equalTo: pillWrapper.topAnchor),
            pill.bottomAnchor.constraint(equalTo: pillWrapper.bottomAnchor),
            pill.leadingAnchor.constraint(equalTo: pillWrapper.leadingAnchor),
            pill.trailingAnchor.constraint(lessThanOrEqualTo: pillWrapper.trailingAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        titleLabel.textColor = Palette.classTitle
        titleLabel.numberOfLines = 0
        titleLabel.text = input.classTitle

        let dateTimeLabel = UILabel()
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        dateTimeLabel.textColor = Palette.classDateTime
        dateTimeLabel.numberOfLines = 1
        dateTimeLabel.text = input.classTime

        let locationTitleLabel = UILabel()
        locationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        locationTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        locationTitleLabel.textColor = Palette.rowTitle
        locationTitleLabel.numberOfLines = 1
        locationTitleLabel.text = GroupClassCardFormatter.cleanStudioName(input.classLocation)

        let locationDistanceLabel = UILabel()
        locationDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        locationDistanceLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        locationDistanceLabel.textColor = Palette.rowSubtitle
        locationDistanceLabel.numberOfLines = 1
        // Device location first, server-passed distance only as a last-resort
        // fallback - see GroupClassCardFormatter.distanceText()'s doc comment.
        locationDistanceLabel.text = GroupClassCardFormatter.distanceText(
            userLat: nil, userLng: nil,
            studioLat: input.studioLat, studioLng: input.studioLng,
            fallback: input.distance
        )

        let locationRow = makeDetailRow(icon: ClassCancelledByAdminViewController.icon(["ic_location_pin_small"], systemFallback: "mappin.and.ellipse"),
                                        iconSide: 14,
                                        titleLabel: locationTitleLabel,
                                        subtitleLabel: locationDistanceLabel)

        let trainerTitleLabel = UILabel()
        trainerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        trainerTitleLabel.textColor = Palette.rowTitle
        trainerTitleLabel.numberOfLines = 1
        let trimmedTrainer = input.trainerName.trimmingCharacters(in: .whitespacesAndNewlines)
        trainerTitleLabel.text = trimmedTrainer.isEmpty ? "Instructor" : (trimmedTrainer.hasPrefix("Trainer:") ? trimmedTrainer : "Trainer: \(trimmedTrainer)")

        let trainerSubtitleLabel = UILabel()
        trainerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerSubtitleLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        trainerSubtitleLabel.textColor = Palette.rowSubtitle
        trainerSubtitleLabel.numberOfLines = 1
        trainerSubtitleLabel.text = Copy.trainerSubtitle

        let trainerRow = makeDetailRow(icon: ClassCancelledByAdminViewController.icon(["ic_trainer_running_18"], systemFallback: "figure.run"),
                                       iconSide: 18,
                                       titleLabel: trainerTitleLabel,
                                       subtitleLabel: trainerSubtitleLabel)

        let divider1 = makeDivider()
        let divider2 = makeDivider()

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 0

        stack.addArrangedSubview(pillWrapper)
        stack.setCustomSpacing(12, after: pillWrapper)
        stack.addArrangedSubview(titleLabel)
        stack.setCustomSpacing(6, after: titleLabel)
        stack.addArrangedSubview(dateTimeLabel)
        stack.setCustomSpacing(16, after: dateTimeLabel)
        stack.addArrangedSubview(divider1)
        stack.setCustomSpacing(16, after: divider1)
        stack.addArrangedSubview(locationRow)
        stack.setCustomSpacing(16, after: locationRow)
        stack.addArrangedSubview(divider2)
        stack.setCustomSpacing(16, after: divider2)
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

    func makePill(text: String) -> UIView {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.semibold.size(11.0, familyName: familyFunnelSans)
        label.textColor = Palette.pillText
        label.text = text
        label.textAlignment = .center

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 100
        container.layer.borderWidth = 1
        container.layer.borderColor = Palette.pillStroke.withAlphaComponent(0.20).cgColor
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        return container
    }

    func makeDetailRow(icon: UIImage?, iconSide: CGFloat, titleLabel: UILabel, subtitleLabel: UILabel) -> UIStackView {
        let iconTile = GlassCardView(cornerRadius: 12)
        iconTile.translatesAutoresizingMaskIntoConstraints = false
        iconTile.fillColor = Palette.tileFill
        iconTile.fillAlpha = 1.0
        iconTile.strokeColor = Palette.tileStroke
        iconTile.strokeAlpha = 1.0
        iconTile.sheenOrigin = .topCenter
        iconTile.sheenAlpha = 0.08

        // Explicit white tint, not the icon's own baked color - guarantees
        // contrast against the red tile the way BookingPausedViewController's
        // own icon rows do.
        let iconView = UIImageView(image: icon?.withRenderingMode(.alwaysTemplate))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconTile.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconTile.widthAnchor.constraint(equalToConstant: Metric.iconTileSide),
            iconTile.heightAnchor.constraint(equalToConstant: Metric.iconTileSide),
            iconView.centerXAnchor.constraint(equalTo: iconTile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconTile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: iconSide),
            iconView.heightAnchor.constraint(equalToConstant: iconSide)
        ])

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

    func makeDivider() -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = Palette.divider
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    // MARK: Important note (gold, SlotConfirmedViewController's own recipe)

    func makeImportantNoteBox() -> UIView {
        let box = UIView()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.backgroundColor = GroupClassColor.gold.color.withAlphaComponent(0.10)
        box.layer.cornerRadius = 12
        box.layer.masksToBounds = true
        box.layer.borderWidth = 1
        box.layer.borderColor = GroupClassColor.gold.color.withAlphaComponent(0.30).cgColor

        let warningIcon = UIImageView(image: ClassCancelledByAdminViewController.icon(["ic_warning_hex_16", "info-hexagon"], systemFallback: "exclamationmark.triangle.fill")?
            .withRenderingMode(.alwaysTemplate))
        warningIcon.translatesAutoresizingMaskIntoConstraints = false
        warningIcon.tintColor = GroupClassColor.gold.color
        warningIcon.contentMode = .scaleAspectFit

        let headingLabel = UILabel()
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        headingLabel.textColor = GroupClassColor.gold.color
        headingLabel.numberOfLines = 1
        headingLabel.text = Copy.importantNoteTitle

        let headingRow = UIStackView(arrangedSubviews: [warningIcon, headingLabel])
        headingRow.translatesAutoresizingMaskIntoConstraints = false
        headingRow.axis = .horizontal
        headingRow.alignment = .center
        headingRow.spacing = 6

        let headingWrapper = UIView()
        headingWrapper.translatesAutoresizingMaskIntoConstraints = false
        headingWrapper.addSubview(headingRow)

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.numberOfLines = 0
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        bodyLabel.attributedText = NSAttributedString(string: Copy.importantNoteBody, attributes: [
            .font: AppFont.regular.size(12.0, familyName: familyFunnelSans),
            .foregroundColor: Palette.noteBody,
            .paragraphStyle: paragraph
        ])

        let stack = UIStackView(arrangedSubviews: [headingWrapper, bodyLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 6
        box.addSubview(stack)

        NSLayoutConstraint.activate([
            warningIcon.widthAnchor.constraint(equalToConstant: Metric.warningIconSide),
            warningIcon.heightAnchor.constraint(equalToConstant: Metric.warningIconSide),

            headingRow.topAnchor.constraint(equalTo: headingWrapper.topAnchor),
            headingRow.bottomAnchor.constraint(equalTo: headingWrapper.bottomAnchor),
            headingRow.leadingAnchor.constraint(equalTo: headingWrapper.leadingAnchor),
            headingRow.trailingAnchor.constraint(lessThanOrEqualTo: headingWrapper.trailingAnchor),

            stack.topAnchor.constraint(equalTo: box.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -12)
        ])
        return box
    }
}

// MARK: - Icon resolution

private extension ClassCancelledByAdminViewController {

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
