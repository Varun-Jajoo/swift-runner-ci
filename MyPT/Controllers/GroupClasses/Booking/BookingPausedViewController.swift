//
//  BookingPausedViewController.swift
//  MyPT
//
//  "Booking Temporarily Paused" — the terminal blacklist screen. Every booking/
//  waitlist path in the module (Confirm Slot sheet, Class Payment's Tabby and
//  Card paths, Group Training Detail's waitlist CTA) lands here once the
//  backend reports the user blacklisted, closing out every stub since Phase 4.
//
//  Android reference (ground truth for layout, copy and logic):
//    app/src/main/java/co/com/mypt/UpComingClasses/BookingPausedActivity.kt
//    app/src/main/res/layout/activity_booking_paused.xml
//
//  Both the glass back button and "VIEW BOOKING" just `finish()` on Android —
//  reproduced here as a plain pop, matching Waitlist Confirmed (Phase 9), not
//  Slot Confirmed's tab-jump (Phase 6).
//

import UIKit

final class BookingPausedViewController: CommonViewController {

    // MARK: - Input
    //
    // Mirrors the intent extras `BookingPausedActivity` reads — the three
    // `BlacklistDetailModel` fields every blacklisted booking/waitlist response
    // carries, with Android's own fallback copy as the default.

    var reason: String = "2 consecutive no-shows for group classes"
    var resumesOn: String = "12 August 2026, 6:00 PM"
    /// Raw hours-remaining value (e.g. `"24"`) — the "(N hours remaining)" wrapper
    /// is applied in `populateUI()`, matching Android's own formatting exactly.
    var hoursRemaining: String = "24"

    // MARK: - Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let backButtonDiameter: CGFloat = 40
        static let errorIconSide: CGFloat = 94
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let iconContainerSide: CGFloat = 38
        static let ctaHeight: CGFloat = 48
    }

    private enum Palette {
        static let headerTitle = UIColor(hex: "#FAFAFA")
        static let headerSubtext = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let divider = UIColor.white.withAlphaComponent(0.10)                  // #1AFFFFFF
        static let brownCardFill = UIColor(hex: "#291F1D")
        static let brownCardStroke = UIColor(hex: "#3E302D")
        static let redIconFill = UIColor(hex: "#78271C")
        static let redIconStroke = UIColor(hex: "#8E3225")
        static let fieldLabel = UIColor(hex: "#959595")
        static let reasonTitle = UIColor(hex: "#FAFAFA")
        static let reasonDescription = UIColor(hex: "#959595")
        static let resumesDate = UIColor(hex: "#FAFAFA")
        static let daysRemainingColor = UIColor(hex: "#959595")
        static let notifyCardFill = GroupClassColor.blueCardBg.color                 // #000814
        static let notifyCardStroke = GroupClassColor.blue.color.withAlphaComponent(0.30) // #4D0865FE
        static let notifyTileFill = UIColor(hex: "#001233")
        static let notifyTitle = UIColor.white
        static let notifySubtitle = UIColor(hex: "#959595")
        static let ctaInk = UIColor(hex: "#131416")
    }

    private enum Copy {
        static let headerTitle = "Booking Temporarily\nPaused"
        static let headerSubtext = "You\u{2019}re currently not eligible to book group classes."
        static let reasonFieldLabel = "REASON"
        static let reasonDescription = "To keep it fair for everyone, we\u{2019}ve temporarily paused your booking access."
        static let resumesFieldLabel = "BOOKING ACCESS RESUMES ON"
        static let notifyTitle = "Don\u{2019}t miss an update"
        static let notifySubtitle = "Turn on push notifications so we can notify you when your booking access resumes."
        static let viewBookingCTA = "VIEW BOOKING"
    }

    // MARK: - Views

    /// `android:background="@drawable/bg_booking_paused_screen"` — a raster
    /// photo (new in this push), visually near-identical to Slot/Waitlist
    /// Confirmed's background. Previously this screen had no background
    /// treatment at all.
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let footerView = UIView()
    private let ctaButton = GradientCTAButton()

    private let reasonTitleLabel = UILabel()
    private let resumesDateLabel = UILabel()
    private let daysRemainingLabel = UILabel()

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
        reasonTitleLabel.text = reason
        resumesDateLabel.text = resumesOn

        let trimmed = hoursRemaining.trimmingCharacters(in: .whitespacesAndNewlines)
        daysRemainingLabel.text = trimmed.hasPrefix("(") ? trimmed : "(\(trimmed) hours remaining)"
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func viewBookingTapped() {
        TapticEngine.selection.feedback()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Layout

private extension BookingPausedViewController {

    func buildLayout() {
        buildBackgroundImage()
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
        // `llBottomButtons` on Android *does* carry a solid `#000814` background
        // — unlike Slot/Waitlist Confirmed's transparent footers, this one is
        // genuinely opaque per `activity_booking_paused.xml`.
        footerView.backgroundColor = UIColor(hex: "#000814")
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

        let errorRow = makeErrorIconRow()
        contentStack.addArrangedSubview(errorRow)
        contentStack.setCustomSpacing(24, after: errorRow)

        let titleLabel = makeHeaderTitleLabel()
        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(8, after: titleLabel)

        let subtextLabel = makeHeaderSubtextLabel()
        contentStack.addArrangedSubview(subtextLabel)
        contentStack.setCustomSpacing(28, after: subtextLabel)

        let brownCard = makeBlacklistDetailCard()
        contentStack.addArrangedSubview(brownCard)
        contentStack.setCustomSpacing(16, after: brownCard)

        contentStack.addArrangedSubview(makeNotifyCard())
    }

    func makeBackButtonRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let backButton = GlassCircularIconButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.configure(icon: BookingPausedViewController.icon(["ic_back_chevron_20"], systemFallback: "chevron.left"),
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

        // `error-circle` ships its own baked-in red/white artwork — do not tint.
        let iconView = UIImageView(image: BookingPausedViewController.icon(["ic_error_circle_94", "error-circle"]))
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

    // MARK: Brown blacklist-detail card

    func makeBlacklistDetailCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.brownCardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.brownCardStroke
        card.strokeAlpha = 1.0
        card.showsSheen = false

        reasonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        reasonTitleLabel.font = AppFont.semibold.size(16.0, familyName: familyFunnelSans)
        reasonTitleLabel.textColor = Palette.reasonTitle
        reasonTitleLabel.numberOfLines = 0

        let reasonDescriptionLabel = UILabel()
        reasonDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        reasonDescriptionLabel.numberOfLines = 0
        reasonDescriptionLabel.attributedText = NSAttributedString(
            string: Copy.reasonDescription,
            attributes: [
                .font: AppFont.regular.size(12.0, familyName: familyFunnelSans),
                .foregroundColor: Palette.reasonDescription,
                .paragraphStyle: BookingPausedViewController.paragraphStyle(lineSpacing: 2)
            ]
        )

        let reasonRow = makeFieldRow(icon: BookingPausedViewController.icon(["ic_calendar_cross_18", "calendar-cross"]),
                                     fieldLabel: Copy.reasonFieldLabel,
                                     valueLabel: reasonTitleLabel,
                                     extraLabel: reasonDescriptionLabel)

        resumesDateLabel.translatesAutoresizingMaskIntoConstraints = false
        resumesDateLabel.font = AppFont.bold.size(18.0, familyName: familyFunnelSans)
        resumesDateLabel.textColor = Palette.resumesDate
        resumesDateLabel.numberOfLines = 0

        daysRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
        daysRemainingLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        daysRemainingLabel.textColor = Palette.daysRemainingColor
        daysRemainingLabel.numberOfLines = 1

        let resumesRow = makeFieldRow(icon: BookingPausedViewController.icon(["ic_calendar_tick_18", "calendar-tick"]),
                                      fieldLabel: Copy.resumesFieldLabel,
                                      valueLabel: resumesDateLabel,
                                      extraLabel: daysRemainingLabel)

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = Palette.divider
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let stack = UIStackView(arrangedSubviews: [reasonRow, divider, resumesRow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 20

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: Metric.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Metric.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Metric.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Metric.cardPadding)
        ])
        return card
    }

    /// One "REASON" / "BOOKING ACCESS RESUMES ON" field: a 38pt red icon tile,
    /// an uppercase field label, a value label, and a trailing detail label.
    func makeFieldRow(icon: UIImage?, fieldLabel: String, valueLabel: UILabel, extraLabel: UILabel) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = Palette.redIconFill
        iconContainer.layer.cornerRadius = 12
        iconContainer.layer.masksToBounds = true
        iconContainer.layer.borderWidth = 1
        iconContainer.layer.borderColor = Palette.redIconStroke.cgColor

        let iconView = UIImageView(image: icon?.withRenderingMode(.alwaysTemplate))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconView)

        let fieldLabelView = UILabel()
        fieldLabelView.translatesAutoresizingMaskIntoConstraints = false
        fieldLabelView.font = AppFont.semibold.size(11.0, familyName: familyFunnelSans)
        fieldLabelView.textColor = Palette.fieldLabel
        fieldLabelView.numberOfLines = 1
        fieldLabelView.text = fieldLabel

        let textStack = UIStackView(arrangedSubviews: [fieldLabelView, valueLabel, extraLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 4

        row.addSubview(iconContainer)
        row.addSubview(textStack)

        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            iconContainer.topAnchor.constraint(equalTo: row.topAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: Metric.iconContainerSide),
            iconContainer.heightAnchor.constraint(equalToConstant: Metric.iconContainerSide),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            textStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            textStack.topAnchor.constraint(equalTo: row.topAnchor),
            textStack.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])
        return row
    }

    // MARK: Notify card (blue) — a single icon+text+chevron row, unlike Phase 9's
    // two-section card with a divider and separate info row.

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

        let tile = GlassCardView(cornerRadius: 12)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = Palette.notifyTileFill
        tile.fillAlpha = 1.0
        tile.strokeColor = UIColor(hex: "#101113")
        tile.strokeAlpha = 1.0
        tile.sheenOrigin = .topCenter
        tile.sheenAlpha = 0.08

        let bellIcon = UIImageView(image: BookingPausedViewController.icon(["ic_bell_18", "bell"])?.withRenderingMode(.alwaysTemplate))
        bellIcon.translatesAutoresizingMaskIntoConstraints = false
        bellIcon.tintColor = .white
        bellIcon.contentMode = .scaleAspectFit
        tile.addSubview(bellIcon)

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
                .paragraphStyle: BookingPausedViewController.paragraphStyle(lineSpacing: 4)
            ]
        )

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 4

        let chevron = UIImageView(image: BookingPausedViewController.icon(["ic_arrow_right_chevron", "chevron-right"], systemFallback: "chevron.right")?
            .withRenderingMode(.alwaysTemplate))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = .white
        chevron.contentMode = .scaleAspectFit

        let row = UIStackView(arrangedSubviews: [tile, textStack, chevron])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        // Asymmetric on Android: `marginEnd=12dp` bell-tile-to-text,
        // `marginStart=8dp` text-to-chevron — not one uniform gap.
        row.spacing = 12
        row.setCustomSpacing(8, after: textStack)

        card.addSubview(row)
        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: Metric.iconContainerSide),
            tile.heightAnchor.constraint(equalToConstant: Metric.iconContainerSide),
            bellIcon.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            bellIcon.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            bellIcon.widthAnchor.constraint(equalToConstant: 18),
            bellIcon.heightAnchor.constraint(equalToConstant: 18),

            chevron.widthAnchor.constraint(equalToConstant: 20),
            chevron.heightAnchor.constraint(equalToConstant: 20),

            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }
}

// MARK: - Attributed copy + icon resolution

private extension BookingPausedViewController {

    static func paragraphStyle(lineSpacing: CGFloat) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
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
