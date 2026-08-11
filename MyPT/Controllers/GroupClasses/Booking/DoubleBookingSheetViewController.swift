//
//  DoubleBookingSheetViewController.swift
//  MyPT
//
//  "You already have an active booking" bottom sheet — shown by the free-booking
//  spam guard whenever a member already has another active free-class booking.
//
//  Android reference (ground truth for copy, colors and layout):
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
//  Assets ported 1:1 from the Android drawables (not approximated): the hero photo,
//  the two phone-mockup illustrations and the dot-pattern card background are the
//  same PNGs Android bundles (`img_double_booking_hero`, `img_manage_booking_mock`,
//  `img_waitlist_mock`, copied byte-for-byte); the OR connector, the two number
//  badges and the close glyph were vector drawables (`ic_double_booking_or_connector`,
//  `ic_number_1_badge`, `ic_number_2_badge`, `ic_close_24`) with SVG-identical path
//  syntax, converted to real SVG and rasterized at high scale to PNG.
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
    var studioLat: Double = 0
    var studioLng: Double = 0
    /// From class-detail's `special_waitlist_notify_hours` / the book-class response's
    /// `notification_window_hours` — whichever triggered this sheet.
    var notifyHours: Int = 3
}

// MARK: - DoubleBookingSheetViewController

final class DoubleBookingSheetViewController: CommonViewController, UIAdaptivePresentationControllerDelegate {

    // MARK: Input / output

    var input = DoubleBookingSheetInput()

    /// Non-nil only in the pre-check mode: no booking/waitlist row exists yet, and
    /// firing this is the ONLY moment the real book-class / join-waitlist POST happens.
    /// Nil means entry already happened server-side before this sheet was shown.
    var onJoinConfirmed: (() -> Void)?

    // MARK: Layout constants
    //
    // Every value here is Android's own dp figure from
    // `dialog_double_booking_bottom_sheet.xml`, ported 1:1 as points.

    private enum Metric {
        static let horizontalInset: CGFloat = 12
        static let handleSize = CGSize(width: 64, height: 5)
        static let closeButtonSide: CGFloat = 24
        static let heroSize = CGSize(width: 254, height: 162)
        static let connectorSize = CGSize(width: 22, height: 150)
        static let cardMinHeight: CGFloat = 115
        static let cardCornerRadius: CGFloat = 8
        static let graphicColumnWidth: CGFloat = 112
        static let mockSize = CGSize(width: 78, height: 61)
        static let numberBadgeSide: CGFloat = 13
        static let ctaHeight: CGFloat = 48
        static let sheetCornerRadius: CGFloat = 20
    }

    /// Hex values taken straight from `dialog_double_booking_bottom_sheet.xml` /
    /// `bg_double_booking_card.xml` / `bg_btn_not_now.xml`.
    private enum Palette {
        static let sheetBg = UIColor(hex: "#040509")
        static let handle = UIColor(hex: "#393C43")
        static let title = UIColor(hex: "#F0F0F0")
        static let dividerLabel = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let dividerLine = UIColor.white.withAlphaComponent(0.10)           // #1AFFFFFF
        static let heroTileFill = UIColor(hex: "#040509")
        // `bg_double_booking_card.xml`'s own solid color - NOT the same as the
        // sheet's own #131416 background (easy to mix up, one hex digit apart).
        static let cardFill = UIColor(hex: "#131615")
        // GlassCardView applies `strokeAlpha` via `.withAlphaComponent`, which
        // REPLACES a color's alpha rather than multiplying it - this must stay a
        // fully opaque base color, with the 0.30 (Android's #4D999999) applied via
        // `card.strokeAlpha` at the call site instead of baked in here.
        static let cardStroke = UIColor(hex: "#999999")
        static let cardStrokeAlpha: CGFloat = 0.30
        static let cardTitle = UIColor.white
        static let itemText = UIColor(hex: "#B3B3B3")
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
        static let manageItem1 = "Complete or Cancel your upcoming booking"
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
    private let heroImageView = UIImageView()
    private let waitlistNotifyLabel = UILabel()
    private let manageButton = UIButton(type: .system)
    private let joinButton = GradientCTAButton()

    /// Content height fed to the sheet's custom detent, recomputed after layout.
    private var resolvedSheetHeight: CGFloat = 0

    /// Push target for Waitlist Confirmed / the Bookings tab. Seeded by
    /// `present(from:input:onJoinConfirmed:)` and resolved again lazily, because
    /// `presentingViewController` goes `nil` the moment a dismissal begins.
    private weak var hostNavigationController: UINavigationController?

    /// In post-hoc mode (`onJoinConfirmed == nil`) the special-waitlist row is
    /// ALREADY committed server-side before this sheet ever shows - there's
    /// nothing left to "confirm" or "cancel" here. Dismissing via the X, a
    /// swipe-down, or a tap outside must still land the member on the
    /// overlapping-waitlist confirmation screen, or they end up ambiguously
    /// "on some waitlist" with no idea which one. Guards against
    /// double-navigating when a button already routed somewhere specific
    /// (Join / Manage Booking) before the dismissal completed.
    private var handledNav = false

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

        presentationController?.delegate = self
        // Post-hoc mode: no safe "swipe away and pretend nothing happened"
        // state exists - force an explicit button tap (X/Join/Manage).
        isModalInPresentation = onJoinConfirmed != nil ? false : true
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

        let total = ceil(contentHeight + 16)
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
        guard onJoinConfirmed == nil else {
            dismiss(animated: true)
            return
        }

        // Post-hoc mode: the row already exists server-side - closing must
        // still land the member on the overlapping-waitlist confirmation
        // screen, not silently vanish.
        handledNav = true
        let navigationController = resolveHostNavigationController()
        hostNavigationController = navigationController
        dismiss(animated: true) { [weak self] in
            self?.pushDoubleBookingConfirmed(on: navigationController)
        }
    }

    /// Port of `btnJoinWaitlistDoubleBooking.setOnClickListener`.
    @objc private func joinWaitlistTapped() {
        TapticEngine.selection.feedback()
        handledNav = true

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

        dismiss(animated: true) { [weak self] in
            self?.pushDoubleBookingConfirmed(on: navigationController)
        }
    }

    /// Port of `btnManageExistingBooking.setOnClickListener`: dismiss, then land on
    /// the Bookings tab. Previously replicated `SlotConfirmedViewController.
    /// viewMyBookingsTapped()`'s own resolve-then-pop-both dance, but that
    /// screen is always reached by a PUSH (so its `navigationController` IS
    /// reliably the current tab's stack) - this sheet is PRESENTED, and when
    /// `resolveTabBarController()` failed to find the tab bar in that context,
    /// the fallback (`hostNavigationController?.popToRootViewController`) only
    /// popped whatever stack presented this sheet WITHOUT ever switching tabs -
    /// landing on Home whenever that happened to be the presenting tab, instead
    /// of Bookings. Reusing the same tab-switch `AppDelegate` already uses for
    /// the local "spot opened up" notification sidesteps that guesswork
    /// entirely - it always lands on Bookings.
    @objc private func manageBookingTapped() {
        TapticEngine.selection.feedback()
        handledNav = true

        dismiss(animated: true) {
            AppDelegate.jumpToBookingsTab()
        }
    }

    /// Builds and pushes the overlapping-waitlist confirmation screen. Shared by
    /// every post-hoc dismissal path (X tap, swipe-down, Join Waitlist tap) since
    /// the row already exists server-side regardless of how this sheet closes.
    private func pushDoubleBookingConfirmed(on navigationController: UINavigationController?) {
        let controller = DoubleBookingWaitlistConfirmedViewController()
        controller.classTitle = input.classTitle
        controller.classTime = input.classTime
        controller.classLocation = input.classLocation
        controller.trainerName = input.trainerName
        controller.distance = input.distance
        controller.studioLat = input.studioLat
        controller.studioLng = input.studioLng
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: UIAdaptivePresentationControllerDelegate

    /// Catches interactive dismissal (swipe-down / tap-outside) that bypasses
    /// every button above. `isModalInPresentation` blocks this in post-hoc mode
    /// already, but this is the safety net if that ever gets bypassed.
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard !handledNav, onJoinConfirmed == nil else { return }
        handledNav = true
        pushDoubleBookingConfirmed(on: resolveHostNavigationController())
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
        contentStack.layoutMargins = UIEdgeInsets(top: 12,
                                                  left: Metric.horizontalInset,
                                                  bottom: 16,
                                                  right: Metric.horizontalInset)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // 1 — drag handle
        let handleRow = makeHandleRow()
        contentStack.addArrangedSubview(handleRow)

        // 2 — close X (own row, marginTop 4dp)
        let closeRow = makeCloseRow()
        contentStack.addArrangedSubview(closeRow)
        contentStack.setCustomSpacing(4, after: handleRow)

        // 3 — hero (marginTop 4dp)
        let hero = makeHeroTile()
        contentStack.addArrangedSubview(hero)
        contentStack.setCustomSpacing(4, after: closeRow)

        // 4 — headline (marginTop 11dp)
        let headline = makeHeadlineLabel()
        contentStack.addArrangedSubview(headline)
        contentStack.setCustomSpacing(11, after: hero)

        // 5 — "To Reserve This Slot" gradient divider (marginTop 18dp)
        let dividerRow = makeSectionDividerRow()
        contentStack.addArrangedSubview(dividerRow)
        contentStack.setCustomSpacing(18, after: headline)

        // 6 — connector + cards row (marginTop 18dp)
        let connectorRow = makeConnectorAndCardsRow()
        contentStack.addArrangedSubview(connectorRow)
        contentStack.setCustomSpacing(18, after: dividerRow)

        // 7 — thin divider (marginTop 26dp)
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = Palette.dividerLine
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentStack.addArrangedSubview(divider)
        contentStack.setCustomSpacing(26, after: connectorRow)

        // 8 — buttons row (marginTop 26dp)
        let buttonsRow = makeButtonsRow()
        contentStack.addArrangedSubview(buttonsRow)
        contentStack.setCustomSpacing(26, after: divider)
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

    /// `ic_close_24` - a real two-tone (#F0F0F0/#FFFFFF) rasterized asset, used
    /// as-is (not tinted) so both stroke colors survive.
    func makeCloseRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(named: "ic-double-booking-close") ?? UIImage(systemName: "xmark"), for: .normal)
        // Only affects the `xmark` fallback (the real asset is a bundled PNG
        // rendered as-is, not a template image, so tintColor is a no-op on
        // it) - without this, a fallback SF Symbol with no explicit tint
        // renders in UIKit's default blue instead of matching the sheet.
        closeButton.tintColor = Palette.title
        closeButton.accessibilityLabel = "Close"
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.contentHorizontalAlignment = .fill
        closeButton.contentVerticalAlignment = .fill
        // Android's ImageView carries `android:padding="2dp"` on top of its 24dp
        // box, so the glyph itself renders at ~20dp - without this the glyph
        // fills the full 24pt box edge-to-edge and reads visibly larger/more
        // cramped than Android's.
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

    /// Android wraps the hero in a near-black (#0A0A0A) tile so the lighten-blend
    /// composite has something dark enough to disappear into instead of showing a
    /// rectangle edge against the sheet's lighter #131416 background - same trick
    /// `SlotOpenViewController.makeHeroBlock()` uses for its own hero photo.
    func makeHeroTile() -> UIView {
        let tile = UIView()
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.backgroundColor = Palette.heroTileFill
        tile.clipsToBounds = true

        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.image = UIImage(named: "img-double-booking-hero")
        heroImageView.contentMode = .scaleAspectFit
        heroImageView.backgroundColor = .clear
        heroImageView.layer.isOpaque = false
        heroImageView.layer.compositingFilter = "lightenBlendMode"
        tile.addSubview(heroImageView)

        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: Metric.heroSize.width),
            tile.heightAnchor.constraint(equalToConstant: Metric.heroSize.height),
            heroImageView.topAnchor.constraint(equalTo: tile.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: tile.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: tile.trailingAnchor),
            heroImageView.bottomAnchor.constraint(equalTo: tile.bottomAnchor)
        ])

        // Centered horizontally within the full-width row (Android's
        // `layout_gravity="center_horizontal"` on a `wrap_content` FrameLayout).
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(tile)
        NSLayoutConstraint.activate([
            tile.topAnchor.constraint(equalTo: row.topAnchor),
            tile.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            tile.centerXAnchor.constraint(equalTo: row.centerXAnchor)
        ])
        return row
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

    /// Android fades these in from each outer edge toward the label
    /// (`bg_gradient_divider_line` / `_reversed`: `#05FFFFFF` -> `#4DFFFFFF` and
    /// reversed) rather than using a flat line - a plain solid color here was a
    /// visible miss against the 1:1 port.
    /// The two gradient lines have no intrinsic size and no width constraint
    /// of their own - inside a `.fill`-distribution stack that's a known
    /// Auto Layout ambiguity (two equally-weighted, zero-intrinsic-size
    /// flexible views don't reliably split 50/50; the solver is free to
    /// collapse one to zero width since any split still satisfies every
    /// constraint, which is exactly what made the left line disappear while
    /// the label rendered off-center instead of in the middle). Tying them
    /// to an explicit equal-width relationship (design spec: 112.75pt each
    /// at the sheet's own reference width) forces the only valid solution to
    /// be a true 50/50 split, without hard-coding an absolute width that
    /// would fight the row's own full-width stretch on other screen sizes.
    func makeSectionDividerRow() -> UIView {
        let leftLine = GradientLineView(startAlpha: 0.02, endAlpha: 0.30)
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        leftLine.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let rightLine = GradientLineView(startAlpha: 0.30, endAlpha: 0.02)
        rightLine.translatesAutoresizingMaskIntoConstraints = false
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

        // Activated only now that leftLine/rightLine share `row` as a common
        // ancestor - setting this cross-view constraint active any earlier
        // (before either view was in a hierarchy) threw "Unable to activate
        // constraint ... because they have no common ancestor" every single
        // time this sheet loaded, crashing on the very first presentation.
        rightLine.widthAnchor.constraint(equalTo: leftLine.widthAnchor).isActive = true
        return row
    }

    // MARK: Connector + cards

    /// Android's horizontal row: the OR connector (22×150) pinned to the leading
    /// edge, `gravity="center_vertical"` against the two-card column beside it.
    func makeConnectorAndCardsRow() -> UIView {
        let connector = UIImageView(image: UIImage(named: "ic-double-booking-or-connector"))
        connector.translatesAutoresizingMaskIntoConstraints = false
        connector.contentMode = .scaleAspectFit
        connector.setContentHuggingPriority(.required, for: .horizontal)
        connector.setContentCompressionResistancePriority(.required, for: .horizontal)

        let cardsColumn = UIStackView(arrangedSubviews: [makeManageBookingCard(), makeWaitlistCard()])
        cardsColumn.translatesAutoresizingMaskIntoConstraints = false
        cardsColumn.axis = .vertical
        cardsColumn.alignment = .fill
        cardsColumn.spacing = 12

        let row = UIStackView(arrangedSubviews: [connector, cardsColumn])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 6

        NSLayoutConstraint.activate([
            connector.widthAnchor.constraint(equalToConstant: Metric.connectorSize.width),
            connector.heightAnchor.constraint(equalToConstant: Metric.connectorSize.height)
        ])
        return row
    }

    func makeManageBookingCard() -> UIView {
        return makeCard(mockImageName: "img-manage-booking-mock",
                        title: Copy.manageCardTitle,
                        row1: makeChecklistRow(number: 1, text: Copy.manageItem1),
                        row2: makeChecklistRow(number: 2, text: Copy.manageItem2))
    }

    /// Android's XML keeps the dynamic `tvWaitlistNotifyHours` copy as item 1 and
    /// the static "first-come, first-served" line as item 2 - order preserved here.
    func makeWaitlistCard() -> UIView {
        return makeCard(mockImageName: "img-waitlist-mock",
                        title: Copy.waitlistCardTitle,
                        row1: makeChecklistRow(number: 1, label: waitlistNotifyLabel),
                        row2: makeChecklistRow(number: 2, text: Copy.waitlistItem2))
    }

    /// One `bg_double_booking_card`: text column (title + two numbered checklist
    /// rows) on the left, a 112pt-wide dot-pattern + phone-mockup graphic column
    /// on the right - matches Android's exact two-column card, no leading icon
    /// tile (the card has no icon before its title, unlike the Confirm Slot sheet's
    /// rows - an earlier iOS pass invented one that Android's XML doesn't have).
    func makeCard(mockImageName: String, title: String, row1: UIView, row2: UIView) -> UIView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = Palette.cardStrokeAlpha
        card.showsSheen = false
        card.heightAnchor.constraint(greaterThanOrEqualToConstant: Metric.cardMinHeight).isActive = true

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(15.0, familyName: familyClashDisplay)
        titleLabel.textColor = Palette.cardTitle
        titleLabel.numberOfLines = 1
        titleLabel.text = title

        let textStack = UIStackView(arrangedSubviews: [titleLabel, row1, row2])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 6
        card.addSubview(textStack)

        let graphicColumn = makeGraphicColumn(mockImageName: mockImageName)
        card.addSubview(graphicColumn)

        NSLayoutConstraint.activate([
            // Android centers this block vertically (`gravity="center_vertical"`
            // on the card) when the card is taller than the text needs (i.e. it
            // hit the 115dp minHeight) - equal slack above and below. Pinning
            // top AND bottom to exact equality instead forced textStack to
            // stretch to fill that slack, which spread out unevenly across
            // title/row1/row2 (whichever had the lowest hugging priority)
            // instead, showing up as an oversized gap between items 1 and 2.
            textStack.topAnchor.constraint(greaterThanOrEqualTo: card.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: graphicColumn.leadingAnchor, constant: -4),

            graphicColumn.topAnchor.constraint(equalTo: card.topAnchor),
            graphicColumn.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            graphicColumn.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            graphicColumn.widthAnchor.constraint(equalToConstant: Metric.graphicColumnWidth)
        ])
        return card
    }

    /// The card's right-hand 112pt column: the dot-pattern background filling the
    /// full card height, with the phone-mockup illustration bottom-left aligned
    /// over it (`layout_gravity="bottom|start"`, `marginStart="10dp"`).
    func makeGraphicColumn(mockImageName: String) -> UIView {
        let column = UIView()
        column.translatesAutoresizingMaskIntoConstraints = false
        column.clipsToBounds = true

        // A plain UIView painted via CALayer.contents, NOT a UIImageView.
        // UIImageView carries the image's own intrinsic content size, and even
        // with all 4 edges pinned (as this was), that size could still leak
        // into resolving `card`'s otherwise-ambiguous height (only bounded by
        // `>= cardMinHeight`, no upper bound) - which is what actually caused
        // the cards to balloon to the dots image's native size instead of the
        // text content's. A plain UIView has no intrinsic size at all, so
        // there's nothing left that could do that.
        let dotsView = UIView()
        dotsView.translatesAutoresizingMaskIntoConstraints = false
        dotsView.clipsToBounds = true
        dotsView.layer.contentsGravity = .resizeAspectFill
        dotsView.layer.contents = UIImage(named: "bg-double-booking-dots")?.cgImage
        column.addSubview(dotsView)

        let mockView = UIImageView(image: UIImage(named: mockImageName))
        mockView.translatesAutoresizingMaskIntoConstraints = false
        mockView.contentMode = .scaleAspectFit
        column.addSubview(mockView)

        NSLayoutConstraint.activate([
            dotsView.topAnchor.constraint(equalTo: column.topAnchor),
            dotsView.leadingAnchor.constraint(equalTo: column.leadingAnchor),
            dotsView.trailingAnchor.constraint(equalTo: column.trailingAnchor),
            dotsView.bottomAnchor.constraint(equalTo: column.bottomAnchor),

            mockView.widthAnchor.constraint(equalToConstant: Metric.mockSize.width),
            mockView.heightAnchor.constraint(equalToConstant: Metric.mockSize.height),
            mockView.bottomAnchor.constraint(equalTo: column.bottomAnchor),
            mockView.leadingAnchor.constraint(equalTo: column.leadingAnchor, constant: 10)
        ])
        return column
    }

    /// `ic_number_1_badge`/`ic_number_2_badge` (real rasterized assets, #F2EBC0
    /// circle + #141514 numeral) + body text.
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

        let badge = UIImageView(image: UIImage(named: "ic-double-booking-number-\(number)"))
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: Metric.numberBadgeSide),
            badge.heightAnchor.constraint(equalToConstant: Metric.numberBadgeSide)
        ])

        let row = UIStackView(arrangedSubviews: [badge, label])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 6
        return row
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

// MARK: - Gradient divider line

/// Horizontal left-to-right fade, ported from the two `bg_gradient_divider_line`
/// shape drawables (both white, differing only in which end is more opaque).
private final class GradientLineView: UIView {
    private let gradientLayer = CAGradientLayer()

    init(startAlpha: CGFloat, endAlpha: CGFloat) {
        super.init(frame: .zero)
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(startAlpha).cgColor,
            UIColor.white.withAlphaComponent(endAlpha).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

// MARK: - Icon resolution

private extension DoubleBookingSheetViewController {

    /// Same resolution order as `ConfirmSlotSheetViewController.icon(_:systemFallback:)`:
    /// first bundled asset wins, a system symbol is the last resort. Only the join
    /// button's chevron still needs this - every other glyph in this sheet is now a
    /// real bundled asset referenced directly by name.
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
