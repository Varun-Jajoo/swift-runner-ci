//
//  DoubleBookingSheetViewController.swift
//  MyPT
//
//  "You already have an active booking" bottom sheet — shown by the free-booking
//  spam guard whenever a member already has another active free-class booking.
//
//  Android reference (ground truth for copy and logic):
//    app/src/main/res/layout/dialog_double_booking_bottom_sheet.xml
//    app/src/main/java/co/com/mypt/UpComingClasses/GroupTrainingDetailActivity.kt
//        · showDoubleBookingBottomSheet(notifyHours, onJoinConfirmed)
//
//  Two presentation modes, mirroring Android exactly:
//   1. Entry already happened (bookFreeSlot()/joinWaitlist() already POSTed and the
//      response came back with waitlist_type == "special") — `onJoinConfirmed` is
//      nil, so tapping "Join the Waitlist" just confirms and pushes Waitlist Confirmed.
//   2. Pre-check (class-detail's `will_special_waitlist` was already true before the
//      user tapped Book Slot / Join Waitlist) — `onJoinConfirmed` is a closure that
//      fires the real book/join API call; nothing is created server-side until this
//      sheet's own CTA is tapped.
//
//  Drawables ported programmatically, same convention as `ConfirmSlotSheetViewController`:
//  Android's dot-pattern card backgrounds, phone-mockup illustrations and the
//  gradient-blended hero/connector graphics are bespoke raster assets with no iOS
//  equivalent asset pipeline in this repo — the layout below reproduces the same
//  information architecture and copy with the module's existing glass-card / icon-tile
//  primitives instead of 1:1 pixel parity.
//

import UIKit

// MARK: - DoubleBookingSheetInput

struct DoubleBookingSheetInput {
    var classTitle: String = ""
    /// Already formatted for display, e.g. `Wed, 9 Jul • 7-8 AM`.
    var classTime: String = ""
    var classLocation: String = ""
    var trainerName: String = ""
    /// The detail screen's distance label text, forwarded verbatim to Waitlist Confirmed.
    var distance: String = ""
    /// From class-detail's `special_waitlist_notify_hours` / the book-class response's
    /// `notification_window_hours` — whichever triggered this sheet.
    var notifyHours: Int = 3
}

// MARK: - DoubleBookingSheetViewController

final class DoubleBookingSheetViewController: CommonViewController {

    // MARK: Input / output

    var input = DoubleBookingSheetInput()

    /// Non-nil only in the pre-check mode: no booking/waitlist row exists yet, and
    /// firing this is the ONLY moment the real book-class / join-waitlist POST happens.
    /// Nil means entry already happened server-side before this sheet was shown.
    var onJoinConfirmed: (() -> Void)?

    // MARK: Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let handleSize = CGSize(width: 64, height: 5)
        static let closeButtonSide: CGFloat = 24
        static let cardPadding: CGFloat = 16
        static let cardCornerRadius: CGFloat = 12
        static let iconTileSide: CGFloat = 38
        static let rowIconSide: CGFloat = 18
        static let numberBadgeSide: CGFloat = 16
        static let ctaHeight: CGFloat = 48
        static let sheetCornerRadius: CGFloat = 20
        static let bookingsTabIndex = 2
    }

    /// Hex values taken straight from `dialog_double_booking_bottom_sheet.xml` /
    /// `bg_double_booking_card.xml` / `bg_btn_not_now.xml`.
    private enum Palette {
        static let sheetBg = UIColor(hex: "#131416")
        static let handle = UIColor(hex: "#393C43")
        static let title = UIColor(hex: "#F0F0F0")
        static let dividerLabel = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let dividerLine = UIColor.white.withAlphaComponent(0.10)           // #1AFFFFFF
        static let cardFill = UIColor(hex: "#131416")
        // GlassCardView applies `strokeAlpha` via `.withAlphaComponent`, which
        // REPLACES a color's alpha rather than multiplying it - this must stay a
        // fully opaque base color, with the 0.30 (Android's #4D999999) applied via
        // `card.strokeAlpha` at the call site instead of baked in here.
        static let cardStroke = UIColor(hex: "#999999")
        static let cardStrokeAlpha: CGFloat = 0.30
        static let cardTitle = UIColor.white
        static let itemText = UIColor(hex: "#B3B3B3")
        static let tileFill = UIColor(hex: "#101113")
        static let numberBadgeFill = GroupClassColor.lime.color.withAlphaComponent(0.16)
        static let numberBadgeText = GroupClassColor.lime.color
        static let manageButtonFill = UIColor(hex: "#1D1E1D")
        static let manageButtonStroke = UIColor.white.withAlphaComponent(0.10)
        static let manageButtonText = UIColor(hex: "#FAFAFA")
        static let ctaInk = UIColor.black
    }

    /// Copy that is hard-coded in the Android layout / Kotlin.
    private enum Copy {
        static let title = "You already have an active booking"
        static let dividerLabel = "To Reserve This Slot"
        static let manageCardTitle = "Manage Current Booking"
        static let manageItem1 = "Cancel your upcoming class"
        static let manageItem2 = "Your spot will be available to book this session"
        static let waitlistCardTitle = "Join the Waitlist"
        static let waitlistItem2 = "Spots are first-come, first-served"
        static let manageCTA = "MANAGE YOUR BOOKING"
        static let joinCTA = "JOIN THE WAITLIST"

        /// Verbatim port of the Kotlin string built in `showDoubleBookingBottomSheet`:
        /// `"We'll send an alert $notifyHours hour" + (plural ? "s" : "") + " before class if a spot opens"`.
        static func notifyHoursText(_ hours: Int) -> String {
            let unit = hours == 1 ? "hour" : "hours"
            return "We'll send an alert \(hours) \(unit) before class if a spot opens"
        }
    }

    // MARK: Views

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let closeButton = UIButton(type: .system)
    private let waitlistNotifyLabel = UILabel()
    private let manageButton = UIButton(type: .system)
    private let joinButton = GradientCTAButton()

    /// Content height fed to the sheet's custom detent, recomputed after layout.
    private var resolvedSheetHeight: CGFloat = 0

    /// Push target for Waitlist Confirmed / the Bookings tab. Seeded by
    /// `present(from:input:onJoinConfirmed:)` and resolved again lazily, because
    /// `presentingViewController` goes `nil` the moment a dismissal begins.
    private weak var hostNavigationController: UINavigationController?

    // MARK: Init

    init(input: DoubleBookingSheetInput) {
        self.input = input
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        self.input = DoubleBookingSheetInput()
        super.init(coder: coder)
        modalPresentationStyle = .pageSheet
    }

    // MARK: Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Palette.sheetBg
        buildLayout()
        populateUI()
        configureSheetPresentation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateResolvedSheetHeight()
    }

    // MARK: Sheet presentation

    /// Same content-sized custom-detent recipe as `ConfirmSlotSheetViewController`
    /// (see that file's doc comment for why the availability guards are load-bearing).
    private func configureSheetPresentation() {
        if #available(iOS 15.0, *) {
            guard let sheet = sheetPresentationController else { return }

            sheet.preferredCornerRadius = Metric.sheetCornerRadius
            sheet.prefersGrabberVisible = false

            if #available(iOS 16.0, *) {
                let detent = UISheetPresentationController.Detent.custom(
                    identifier: UISheetPresentationController.Detent.Identifier("doubleBookingContent")
                ) { [weak self] context in
                    guard let self = self, self.resolvedSheetHeight > 0 else {
                        return context.maximumDetentValue
                    }
                    return min(self.resolvedSheetHeight, context.maximumDetentValue)
                }
                sheet.detents = [detent]
            } else {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
            }
        }
    }

    private func updateResolvedSheetHeight() {
        guard view.bounds.width > 0 else { return }

        let fitting = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let contentHeight = contentStack.systemLayoutSizeFitting(
            fitting,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        let total = ceil(contentHeight + view.safeAreaInsets.bottom)
        guard total > 0, abs(total - resolvedSheetHeight) > 0.5 else { return }

        resolvedSheetHeight = total
        if #available(iOS 16.0, *) {
            sheetPresentationController?.invalidateDetents()
        }
    }

    // MARK: Populate

    private func populateUI() {
        waitlistNotifyLabel.text = Copy.notifyHoursText(input.notifyHours)
    }

    // MARK: Login gate
    //
    // Unlike `ConfirmSlotSheetViewController`, this sheet never POSTs directly —
    // both the pre-check and post-hoc callers already gate login before this sheet
    // is ever presented (mirrors Android: `showDoubleBookingBottomSheet` is only
    // ever reached after `requireLogin()`/`joinWaitlistDirectly`'s own token check).

    // MARK: Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    /// Port of `btnJoinWaitlistDoubleBooking.setOnClickListener`.
    @objc private func joinWaitlistTapped() {
        TapticEngine.selection.feedback()

        if let onJoinConfirmed = onJoinConfirmed {
            // Entry hasn't happened yet - this tap is the explicit confirmation,
            // so fire the real join call now.
            dismiss(animated: true) {
                onJoinConfirmed()
            }
            return
        }

        // The special-waitlist row was already created server-side by whichever
        // call triggered this sheet - just tell the member it's done.
        let navigationController = resolveHostNavigationController()
        hostNavigationController = navigationController

        let title = input.classTitle
        let time = input.classTime
        let location = input.classLocation
        let trainer = input.trainerName
        let distance = input.distance

        dismiss(animated: true) {
            let controller = WaitlistConfirmedViewController()
            controller.classTitle = title
            controller.classTime = time
            controller.classLocation = location
            controller.trainerName = trainer
            controller.distance = distance
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    /// Port of `btnManageExistingBooking.setOnClickListener`: dismiss, then land on
    /// the Bookings tab exactly like `SlotConfirmedViewController.viewMyBookingsTapped()`.
    @objc private func manageBookingTapped() {
        TapticEngine.selection.feedback()

        // Resolved *before* dismiss starts - `presentingViewController` (and the
        // tab-bar walk that depends on it) goes `nil` the instant dismissal begins.
        let tabBarController = resolveTabBarController()
        let hostNavigationController = resolveHostNavigationController()
        self.hostNavigationController = hostNavigationController

        dismiss(animated: true) {
            guard let tabBarController = tabBarController,
                  let tabs = tabBarController.viewControllers,
                  tabs.indices.contains(Metric.bookingsTabIndex) else {
                hostNavigationController?.popToRootViewController(animated: true)
                return
            }

            (tabs[Metric.bookingsTabIndex] as? UINavigationController)?
                .popToRootViewController(animated: false)
            tabBarController.selectedIndex = Metric.bookingsTabIndex
            hostNavigationController?.popToRootViewController(animated: false)
        }
    }

    private func resolveHostNavigationController() -> UINavigationController? {
        if let navigationController = hostNavigationController { return navigationController }
        if let navigationController = presentingViewController as? UINavigationController { return navigationController }
        if let navigationController = presentingViewController?.navigationController { return navigationController }
        if let tabBarController = presentingViewController as? UITabBarController {
            return tabBarController.selectedViewController as? UINavigationController
        }
        return nil
    }

    private func resolveTabBarController() -> UITabBarController? {
        if let tabBarController = tabBarController { return tabBarController }
        if let tabBarController = presentingViewController?.tabBarController { return tabBarController }

        var candidate = UIApplication.shared.windows.first(where: \.isKeyWindow)?.rootViewController
        while let current = candidate {
            if let tabBarController = current as? UITabBarController { return tabBarController }
            candidate = current.presentedViewController ?? current.children.first
        }
        return nil
    }
}

// MARK: - Presentation helper

extension DoubleBookingSheetViewController {

    /// Single entry point used by `GroupTrainingDetailViewController`. Pass
    /// `onJoinConfirmed` only for the pre-check mode (no booking/waitlist row
    /// exists yet); omit it for the post-hoc mode (already created).
    @discardableResult
    static func present(from presenter: UIViewController,
                        input: DoubleBookingSheetInput,
                        onJoinConfirmed: (() -> Void)? = nil) -> DoubleBookingSheetViewController {
        let controller = DoubleBookingSheetViewController(input: input)
        controller.onJoinConfirmed = onJoinConfirmed
        controller.hostNavigationController = presenter.navigationController ?? (presenter as? UINavigationController)
        presenter.present(controller, animated: true)
        return controller
    }
}

// MARK: - Layout

private extension DoubleBookingSheetViewController {

    func buildLayout() {
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
        contentStack.layoutMargins = UIEdgeInsets(top: 8,
                                                  left: Metric.horizontalInset,
                                                  bottom: 20,
                                                  right: Metric.horizontalInset)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // 1 — drag handle + close X
        let handleRow = makeHandleRow()
        contentStack.addArrangedSubview(handleRow)
        contentStack.setCustomSpacing(4, after: handleRow)

        let closeRow = makeCloseRow()
        contentStack.addArrangedSubview(closeRow)

        // 2 — headline
        let headline = makeHeadlineLabel()
        contentStack.addArrangedSubview(headline)
        contentStack.setCustomSpacing(18, after: headline)

        // 3 — "To Reserve This Slot" gradient divider
        let dividerRow = makeSectionDividerRow()
        contentStack.addArrangedSubview(dividerRow)
        contentStack.setCustomSpacing(16, after: dividerRow)

        // 4 — the two cards
        let manageCard = makeManageBookingCard()
        contentStack.addArrangedSubview(manageCard)
        contentStack.setCustomSpacing(12, after: manageCard)

        let waitlistCard = makeWaitlistCard()
        contentStack.addArrangedSubview(waitlistCard)
        contentStack.setCustomSpacing(26, after: waitlistCard)

        // 5 — thin divider
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = Palette.dividerLine
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentStack.addArrangedSubview(divider)
        contentStack.setCustomSpacing(26, after: divider)

        // 6 — buttons row
        contentStack.addArrangedSubview(makeButtonsRow())
    }

    func makeHandleRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = Palette.handle
        bar.layer.cornerRadius = Metric.handleSize.height / 2
        bar.layer.masksToBounds = true
        container.addSubview(bar)

        NSLayoutConstraint.activate([
            bar.widthAnchor.constraint(equalToConstant: Metric.handleSize.width),
            bar.heightAnchor.constraint(equalToConstant: Metric.handleSize.height),
            bar.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bar.topAnchor.constraint(equalTo: container.topAnchor),
            bar.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    func makeCloseRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(DoubleBookingSheetViewController.icon(["ic_close_24", "ic_close_x_34"], systemFallback: "xmark")?
            .withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = Palette.title
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.contentHorizontalAlignment = .fill
        closeButton.contentVerticalAlignment = .fill
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        container.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: container.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: Metric.closeButtonSide),
            closeButton.heightAnchor.constraint(equalToConstant: Metric.closeButtonSide)
        ])
        return container
    }

    func makeHeadlineLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        label.textColor = Palette.title
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Copy.title
        return label
    }

    func makeSectionDividerRow() -> UIView {
        let leftLine = UIView()
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        leftLine.backgroundColor = Palette.dividerLine
        leftLine.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let rightLine = UIView()
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        rightLine.backgroundColor = Palette.dividerLine
        rightLine.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        label.textColor = Palette.dividerLabel
        label.text = Copy.dividerLabel
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [leftLine, label, rightLine])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        return row
    }

    // MARK: Cards

    func makeManageBookingCard() -> UIView {
        return makeCard(icon: DoubleBookingSheetViewController.icon(["ic_calendar_18"], systemFallback: "calendar.badge.clock"),
                        title: Copy.manageCardTitle,
                        row1: makeChecklistRow(number: 1, text: Copy.manageItem1),
                        row2: makeChecklistRow(number: 2, text: Copy.manageItem2))
    }

    /// Android's XML keeps the dynamic `tvWaitlistNotifyHours` copy as item 1 and
    /// the static "first-come, first-served" line as item 2 - order preserved here.
    func makeWaitlistCard() -> UIView {
        return makeCard(icon: DoubleBookingSheetViewController.icon(["ic_bell_18"], systemFallback: "bell.badge"),
                        title: Copy.waitlistCardTitle,
                        row1: makeChecklistRow(number: 1, label: waitlistNotifyLabel),
                        row2: makeChecklistRow(number: 2, text: Copy.waitlistItem2))
    }

    /// One `bg_double_booking_card`-equivalent: icon tile + title, then the two
    /// already-built numbered checklist rows, in the order given.
    func makeCard(icon: UIImage?, title: String, row1: UIView, row2: UIView) -> UIView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = Palette.cardStrokeAlpha
        card.showsSheen = false

        let iconTile = makeIconTile(image: icon)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(15.0, familyName: familyClashDisplay)
        titleLabel.textColor = Palette.cardTitle
        titleLabel.numberOfLines = 1
        titleLabel.text = title

        let headerRow = UIStackView(arrangedSubviews: [iconTile, titleLabel])
        headerRow.translatesAutoresizingMaskIntoConstraints = false
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.spacing = 10

        let stack = UIStackView(arrangedSubviews: [headerRow, row1, row2])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: Metric.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Metric.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Metric.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Metric.cardPadding)
        ])
        return card
    }

    /// `location_icon_bg`-equivalent 38pt tile, reused from the Confirm Slot sheet's
    /// visual language for the card's leading icon.
    func makeIconTile(image: UIImage?) -> UIView {
        let tile = GlassCardView(cornerRadius: 10)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = Palette.tileFill
        tile.fillAlpha = 1.0
        tile.strokeColor = UIColor(hex: "#101113")
        tile.strokeAlpha = 1.0
        tile.sheenOrigin = .topCenter
        tile.sheenAlpha = 0.08

        let iconView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = Palette.numberBadgeText
        iconView.contentMode = .scaleAspectFit
        tile.addSubview(iconView)

        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: Metric.iconTileSide),
            tile.heightAnchor.constraint(equalToConstant: Metric.iconTileSide),
            iconView.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: Metric.rowIconSide),
            iconView.heightAnchor.constraint(equalToConstant: Metric.rowIconSide)
        ])
        return tile
    }

    /// `ic_number_1_badge`/`ic_number_2_badge` + body text, built from a plain
    /// numbered circle (no bespoke badge assets available on iOS).
    func makeChecklistRow(number: Int, text: String) -> UIView {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.regular.size(11.0, familyName: familyFunnelSans)
        label.textColor = Palette.itemText
        label.numberOfLines = 0
        label.text = text
        return makeChecklistRow(number: number, label: label)
    }

    func makeChecklistRow(number: Int, label: UILabel) -> UIView {
        label.font = AppFont.regular.size(11.0, familyName: familyFunnelSans)
        label.textColor = Palette.itemText
        label.numberOfLines = 0

        let badge = makeNumberBadge(number)

        let row = UIStackView(arrangedSubviews: [badge, label])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 6
        return row
    }

    func makeNumberBadge(_ number: Int) -> UIView {
        let badge = UIView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = Palette.numberBadgeFill
        badge.layer.cornerRadius = Metric.numberBadgeSide / 2
        badge.layer.masksToBounds = true

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.semibold.size(9.0, familyName: familyFunnelSans)
        label.textColor = Palette.numberBadgeText
        label.textAlignment = .center
        label.text = "\(number)"
        badge.addSubview(label)

        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: Metric.numberBadgeSide),
            badge.heightAnchor.constraint(equalToConstant: Metric.numberBadgeSide),
            label.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: badge.centerYAnchor)
        ])
        return badge
    }

    // MARK: Buttons row

    func makeButtonsRow() -> UIView {
        manageButton.translatesAutoresizingMaskIntoConstraints = false
        manageButton.backgroundColor = Palette.manageButtonFill
        manageButton.layer.cornerRadius = 8
        manageButton.layer.borderWidth = 1
        manageButton.layer.borderColor = Palette.manageButtonStroke.cgColor
        manageButton.setTitle(Copy.manageCTA, for: .normal)
        manageButton.setTitleColor(Palette.manageButtonText, for: .normal)
        manageButton.titleLabel?.font = AppFont.medium.size(11.5, familyName: familyFunnelSans)
        manageButton.addTarget(self, action: #selector(manageBookingTapped), for: .touchUpInside)
        manageButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight).isActive = true

        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.bandThickness = 2
        joinButton.configure(title: Copy.joinCTA,
                             font: AppFont.semibold.size(11.5, familyName: familyFunnelSans),
                             titleColor: Palette.ctaInk)
        joinButton.horizontalContentInset = 12
        joinButton.setTrailingIcon(
            DoubleBookingSheetViewController.icon(["ic_chevron_right_16_dark", "chevron-right"],
                                                  systemFallback: "chevron.right"),
            tint: Palette.ctaInk)
        joinButton.addTarget(self, action: #selector(joinWaitlistTapped), for: .touchUpInside)
        joinButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight).isActive = true

        let row = UIStackView(arrangedSubviews: [manageButton, joinButton])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fillEqually
        row.spacing = 10
        return row
    }
}

// MARK: - Icon resolution

private extension DoubleBookingSheetViewController {

    /// Same resolution order as `ConfirmSlotSheetViewController.icon(_:systemFallback:)`:
    /// first bundled asset wins, a system symbol is the last resort.
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
