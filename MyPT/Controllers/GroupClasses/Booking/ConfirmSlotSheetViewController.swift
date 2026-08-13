//
//  ConfirmSlotSheetViewController.swift
//  MyPT
//
//  "Confirm your slot" bottom sheet — the free-for-member booking confirmation
//  step between Group Training Detail and Slot Confirmed.
//
//  Android reference (ground truth for layout, copy and logic):
//    app/src/main/res/layout/dialog_confirm_slot_bottom_sheet.xml
//    app/src/main/java/co/com/mypt/UpComingClasses/GroupTrainingDetailActivity.kt
//        · showConfirmSlotBottomSheet(title, time, location)   (lines 441–607)
//        · getDynamicDurationStr(timeStr)                      (lines 741–763)
//    Drawables ported programmatically (per the plan's Phase-2 decision 4):
//        bottom_sheet_dialog_bg  -> #121315, 20dp top corners
//        card_details_bg         -> #18191C fill, #232323 stroke, top-centre radial sheen
//        location_icon_bg        -> 38dp tile, #1AFFFFFF -> #101113 wash, #101113 hairline
//        chip_60_mins_bg         -> 8dp radius, #33FAFAFA stroke, #33FFFFFF -> #00FFFFFF (L→R)
//        important_note_bg       -> #1ADB812E fill, #4DDB812E stroke, 12dp radius
//        btn_cta_gradient_shadow -> GradientCTAButton with a 2pt band
//        ic_top_handle_bar       -> 64×5 #393C43 pill
//
//  Android hosts this sheet as a `BottomSheetDialog` inflated *inside* the detail
//  Activity, so its confirm handler can call `startActivity` and `fetchClassDetail()`
//  directly. On iOS the sheet is a real modal view controller, so those two effects
//  are surfaced back to the presenter as `onBookingSucceeded` (detail refresh) and a
//  push onto the presenter's navigation controller (Slot Confirmed).
//

import UIKit

// MARK: - ConfirmSlotSheetInput

/// Everything `showConfirmSlotBottomSheet` reads on Android: its three explicit
/// arguments plus the Activity fields it reaches for (`trainerName`, the
/// `tvLocationDistance` label text, `isFreeForUser`, `scheduleId`, `classPrice`).
struct ConfirmSlotSheetInput {

    /// `schedule_id` for the `book-class` POST. Blank replicates Android's
    /// "skip the API and go straight to Slot Confirmed" debug branch.
    var scheduleId: String = ""
    var title: String = ""
    /// Already formatted for display, e.g. `Wed, 9 Jul • 7-8 AM`.
    var time: String = ""
    var location: String = ""
    /// The detail screen's distance label text — Android copies it verbatim, so it
    /// still carries the trailing " away".
    var distance: String = ""
    var trainerName: String = ""
    var price: String = ""
    /// Drives the CTA label: `true` -> "CONFIRM YOUR SLOT", `false` -> "PROCEED TO PAYMENT".
    var isFreeForUser: Bool = true
    /// When true, this is a waitlist join, not a booking - confirming calls
    /// `onWaitlistJoinConfirmed` instead of POSTing book-class. Was previously
    /// missing entirely: `GroupTrainingDetailViewController` called
    /// `joinWaitlist()` straight from the outer CTA tap with no confirmation
    /// sheet at all for the plain (non-special) waitlist case - the member
    /// was joined on a single tap with no chance to review or back out,
    /// unlike every other path on this screen (booking, special-waitlist),
    /// which always confirms first.
    var isWaitlistJoin: Bool = false
}

// MARK: - ConfirmSlotSheetViewController

final class ConfirmSlotSheetViewController: CommonViewController {

    // MARK: Input / output

    var input = ConfirmSlotSheetInput()

    /// Port of the `fetchClassDetail()` call Android makes on a successful booking
    /// (it refreshes the detail screen behind the sheet before navigating away).
    var onBookingSucceeded: (() -> Void)?

    /// Fires instead of navigating to Slot Confirmed when the book-class response
    /// turns out to be a special-waitlist payload (`waitlist_type == "special"`) -
    /// this sheet is only ever shown when class-detail's `will_special_waitlist`
    /// pre-check read false, but that flag can go stale between the fetch and the
    /// tap (e.g. the member booked something else elsewhere in the meantime), so
    /// the response itself is still the source of truth. Mirrors the identical
    /// post-hoc check `GroupTrainingDetailViewController.handleFreeBookingResponse()`
    /// already does for the eager (pre-check-true) tap path - this sheet is the
    /// other place a free booking gets POSTed from and needs the same fallback.
    var onSpecialWaitlistTriggered: ((_ notifyHours: Int?) -> Void)?

    /// Fires instead of the book-class POST when `input.isWaitlistJoin` is true -
    /// the presenter sets this to its own `joinWaitlist()`.
    var onWaitlistJoinConfirmed: (() -> Void)?

    // MARK: Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        // Android's 24dp is the *only* bottom clearance it reserves — its system
        // gesture bar doesn't stack on top of app padding the way iOS's home
        // indicator does here (`scrollView` is pinned to the safe-area guide, which
        // already reserves ~34pt on its own). Any additional margin here stacks on
        // top of that reserved safe-area strip, which is what made the gap below
        // the CTA read as oversized — the safe area alone is enough breathing room.
        static let bottomInset: CGFloat = 0
        static let handleSize = CGSize(width: 64, height: 5)
        static let closeButtonSide: CGFloat = 24
        static let cardPadding: CGFloat = 20
        static let cardCornerRadius: CGFloat = 16
        static let iconTileSide: CGFloat = 38
        static let rowIconSide: CGFloat = 18
        static let warningIconSide: CGFloat = 16
        static let ctaHeight: CGFloat = 48
        static let sheetCornerRadius: CGFloat = 20
    }

    /// Hex values taken straight from `dialog_confirm_slot_bottom_sheet.xml`; only
    /// the module-wide slots (gold, lime) come from `GroupClassColor`.
    private enum Palette {
        static let sheetBg = UIColor(hex: "#121315")
        static let handle = UIColor(hex: "#393C43")
        static let title = UIColor(hex: "#F0F0F0")
        static let subtext = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)   // #8CFAFAFA
        static let cardFill = UIColor(hex: "#18191C")
        static let cardStroke = UIColor(hex: "#232323")
        static let tileFill = UIColor(hex: "#101113")
        static let rowTitle = UIColor(hex: "#FAFAFA")
        static let rowSubtitle = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let divider = UIColor.white.withAlphaComponent(0.10)             // #1AFFFFFF
        static let chipStroke = UIColor(hex: "#FAFAFA").withAlphaComponent(0.2) // #33FAFAFA
        static let chipText = UIColor(hex: "#F0F0F0")
        static let policyText = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75) // #BFFAFAFA
        static let ctaInk = UIColor(hex: "#000000")
    }

    /// Copy that is hard-coded in the Android layout / Kotlin.
    private enum Copy {
        static let title = "Confirm your slot"
        static let subtitle = "Review your class details before confirming"
        static let importantNoteTitle = "IMPORTANT NOTE"
        static let importantNoteBody = "If you miss two classes consecutively (no-show or late cancellation), you will be blacklisted from group classes for "
        static let importantNoteEmphasis = "48 hours."
        static let policyPrefix = "By confirming, you agree to our "
        static let policyEmphasis = "Cancellation Policy"
        static let confirmCTA = "CONFIRM YOUR SLOT"
        static let paymentCTA = "PROCEED TO PAYMENT"
        /// Same wording as the detail screen's own waitlist CTA
        /// (GroupTrainingDetailViewController's `setCTATitle("JOIN WAITLIST")`),
        /// and the mirror of `leaveWaitlistCTA` on the cancel sheet.
        static let joinWaitlistCTA = "JOIN WAITLIST"
        static let defaultDuration = "60 MINS"
        static let defaultTrainer = "Sara K."
        static let trainerSubtitle = "Certified MyPT Trainer"
        static let bookingFailed = "Booking failed. Please try again."
        static let loginRequired = "Please log in to proceed"
    }

    // MARK: Views

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let closeButton = UIButton(type: .system)

    private let classTitleLabel = UILabel()
    private let classDateTimeLabel = UILabel()
    private let durationChipLabel = UILabel()

    private let locationTitleLabel = UILabel()
    private let locationDistanceLabel = UILabel()

    private let trainerNameLabel = UILabel()

    private let ctaButton = GradientCTAButton()

    /// Content height fed to the sheet's custom detent, recomputed after layout.
    private var resolvedSheetHeight: CGFloat = 0

    /// Push target for Slot Confirmed. Seeded by `present(from:input:...)` and
    /// resolved again lazily, because `presentingViewController` goes `nil` the
    /// moment a dismissal begins — which is exactly when the push has to happen.
    private weak var hostNavigationController: UINavigationController?

    // MARK: Init

    init(input: ConfirmSlotSheetInput) {
        self.input = input
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        self.input = ConfirmSlotSheetInput()
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

    /// Android shows the dialog `STATE_EXPANDED` with `skipCollapsed = true`, i.e.
    /// exactly one stop sized to its `wrap_content` body — a content-sized custom
    /// detent is the iOS equivalent. `[.medium(), .large()]` is only the pre-iOS-16
    /// fallback (the app-wide idiom, see `ChooseAddressPopUpVC`).
    ///
    /// The availability guards are load-bearing: the **target**'s
    /// `IPHONEOS_DEPLOYMENT_TARGET` is 13.0 (only the project-level setting is 17.5),
    /// which is why every existing call site in the app wraps `sheetPresentationController`
    /// in `if #available(iOS 15.0, *)`.
    private func configureSheetPresentation() {
        if #available(iOS 15.0, *) {
            guard let sheet = sheetPresentationController else { return }

            sheet.preferredCornerRadius = Metric.sheetCornerRadius
            // The layout draws Android's own `ic_top_handle_bar`, so the system
            // grabber would render a second, misaligned pill.
            sheet.prefersGrabberVisible = false

            if #available(iOS 16.0, *) {
                let detent = UISheetPresentationController.Detent.custom(
                    identifier: UISheetPresentationController.Detent.Identifier("confirmSlotContent")
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

    /// Measures the laid-out content and re-resolves the custom detent when it moves.
    /// The `> 0.5` guard is what stops `invalidateDetents()` -> relayout -> measure
    /// from looping: the second pass measures the same height and bails.
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

    /// Port of the `findViewById` block in `showConfirmSlotBottomSheet`.
    private func populateUI() {
        classTitleLabel.text = input.title
        classDateTimeLabel.text = input.time
        locationTitleLabel.text = input.location

        // Android only overwrites the placeholder when the detail label is non-blank.
        let distance = input.distance.trimmingCharacters(in: .whitespacesAndNewlines)
        if !distance.isEmpty {
            locationDistanceLabel.text = distance
        }

        durationChipLabel.text = durationText(for: input.time)

        let trainer = input.trainerName.trimmingCharacters(in: .whitespacesAndNewlines)
        trainerNameLabel.text = "Trainer: " + (trainer.isEmpty ? Copy.defaultTrainer : trainer)

        if input.isWaitlistJoin {
            setCTATitle(Copy.joinWaitlistCTA)
        } else {
            setCTATitle(input.isFreeForUser ? Copy.confirmCTA : Copy.paymentCTA)
        }
    }

    private func setCTATitle(_ title: String) {
        ctaButton.configure(title: title,
                            font: AppFont.medium.size(14.0, familyName: familyFunnelSans),
                            titleColor: Palette.ctaInk)
    }

    /// Port of `getDynamicDurationStr(timeStr)`: reads `7-8 AM` out of the display
    /// string and turns the hour delta into minutes, wrapping a non-positive delta
    /// by 12 hours exactly like the Kotlin.
    private func durationText(for timeStr: String) -> String {
        let trimmed = timeStr.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return Copy.defaultDuration }

        // `Wed, 9 Jul • 7-8 AM` -> `7-8 AM`; a bullet-less string is used as-is.
        let timePart: String
        if let bullet = trimmed.range(of: "•") {
            timePart = String(trimmed[bullet.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            timePart = trimmed
        }

        // Kotlin uses `split("-")` + `parts[1]`, i.e. the *second* segment.
        let parts = timePart.components(separatedBy: "-")
        guard parts.count > 1 else { return Copy.defaultDuration }

        // Equivalent of `replace("[^0-9:]".toRegex(), "")`.
        let startDigits = String(parts[0].filter { $0.isNumber || $0 == ":" })
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let endDigits = String(parts[1].filter { $0.isNumber || $0 == ":" })
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let startHour = Int(startDigits.components(separatedBy: ":").first ?? "") ?? 7
        let endHour = Int(endDigits.components(separatedBy: ":").first ?? "") ?? 8

        var diffHours = endHour - startHour
        if diffHours <= 0 { diffHours += 12 }
        return "\(diffHours * 60) MINS"
    }

    // MARK: Login gate

    /// Same token read as `GroupTrainingDetailViewController` / `NetworkManager`'s
    /// request adapter. Android performs this check inside the confirm handler (not
    /// at presentation time), so the gate stays here.
    ///
    /// - Returns: `true` when the caller may proceed, `false` when the sheet was
    ///            dismissed and the user routed to login.
    private func requireLogin() -> Bool {
        let token = (appUserDefaults.getAccessToken() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !token.isEmpty && token != "-1" { return true }

        // Android: dismiss -> toast -> PhoneNumberScreenActivity. The iOS
        // counterpart of that screen is reached through `goToMainView()`.
        dismiss(animated: true) {
            AlertHelper.shared.showCustomeAlert(title: "", message: Copy.loginRequired, actions: ["OK"]) { _ in
                if appUserDefaults.clearUserDefault() {
                    appSceneDelegate?.goToMainView()
                }
            }
        }
        return false
    }

    // MARK: Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    /// Port of `btnConfirmSlotAction.setOnClickListener`. Branch order is Android's,
    /// verbatim: login gate -> waitlist-join detour -> paid detour ->
    /// missing-schedule shortcut -> book-class.
    ///
    /// The waitlist-join check MUST come before the paid detour: a full paid/
    /// premium class still routes here with `isWaitlistJoin = true` and
    /// `isFreeForUser = false` (`GroupTrainingDetailViewController.ctaTapped()`'s
    /// `isWaitlistMode` branch fires regardless of `isFreeForUser`), and
    /// joining a waitlist is never itself a payment — `joinWaitlistApi` posts
    /// `price`, not `payment_type`, same as Android's `joinWaitlistDirectly`.
    /// With the checks the other way round, tapping "JOIN WAITLIST" on a
    /// premium class fell into the paid-detour stub below and just dismissed
    /// the sheet — the tap did nothing, and since `joinWaitlist()` never ran,
    /// `fetchClassDetail()` never refreshed the class's seat/waitlist counts
    /// either.
    @objc private func confirmTapped() {
        TapticEngine.selection.feedback()

        guard requireLogin() else { return }

        if input.isWaitlistJoin {
            dismiss(animated: true) { [weak self] in
                self?.onWaitlistJoinConfirmed?()
            }
            return
        }

        if !input.isFreeForUser {
            // Android pushes ClassPaymentScreenActivity here with schedule_id and a
            // "50.00" fallback price. On iOS the detail screen already routes paid
            // classes straight to payment without opening this sheet, so this branch
            // is only reachable if a future caller presents it for a paid class.
            // TODO(Phase 7): dismiss, then push ClassPaymentViewController with
            // input.scheduleId and (input.price non-blank && != "0" ? input.price : "50.00").
            debugPrint("[ConfirmSlotSheet] CTA 'PROCEED TO PAYMENT' — Class Payment screen lands in Phase 7. Dismissing.")
            dismiss(animated: true)
            return
        }

        if input.scheduleId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Android's no-schedule shortcut: skip the API and show Slot Confirmed.
            navigateToSlotConfirmed()
            return
        }

        bookFreeSlot()
    }

    // MARK: Network — POST api/book-class

    /// `schedule_id` / `transaction_id="" ` / `payment_type="free"`, exactly the
    /// param trio Android builds for the free-for-member path.
    private func bookFreeSlot() {
        let scheduleId = input.scheduleId

        UpcomingClassVM.bookGroupClassApi(scheduleId: scheduleId,
                                          transactionId: "",
                                          paymentType: "free") { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleBookingResponse(result)
            }
        }
    }

    /// Port of the `ResponseData.response(data)` body. `result == nil` stands in for
    /// Android's `error(VolleyError)` branch.
    ///
    /// NOTE: `NetworkManager.genericAPICall` only invokes its completion on a 2xx (or
    /// on a no-internet short-circuit, with `nil`); a non-2xx response never calls
    /// back at all, so a hard HTTP failure leaves the sheet open rather than
    /// dismissing it. That is the app-wide behaviour of every existing call site, not
    /// something introduced here.
    private func handleBookingResponse(_ result: BookClassBaseModel?) {
        guard let result = result else {
            if presentedViewController != nil {
                // NetworkManager's no-internet short-circuit already presented its own
                // "check network" alert on top of this sheet before calling back with nil.
                // self.dismiss() here would just dismiss that alert (self.presentedViewController
                // is non-nil, so UIKit routes the dismiss to it) and leave the sheet stuck open
                // underneath a second, stacked "Booking failed" alert. Dismiss from the
                // presenter instead, which takes the sheet and the alert down together.
                presentingViewController?.dismiss(animated: true)
            } else {
                dismiss(animated: true) {
                    AlertHelper.shared.showCustomeAlert(title: "", message: Copy.bookingFailed, actions: ["OK"], completion: nil)
                }
            }
            return
        }

        if result.status == true {
            // Android calls `fetchClassDetail()` before navigating so the detail
            // screen behind the sheet comes back showing "BOOKED".
            onBookingSucceeded?()

            // pendingConfirmation, not isSpecial: without confirmSpecialWaitlist
            // sent (this call never sends it - see performFreeBooking()'s own
            // first attempt for the only place that does), the backend never
            // creates the row for a special diversion, so there's nothing here
            // to treat as already-succeeded. onSpecialWaitlistTriggered's
            // caller shows the double-booking sheet as a genuine choice.
            if result.specialWaitlist?.pendingConfirmation == true {
                let notifyHours = result.specialWaitlist?.notificationWindowHours?.intValue
                dismiss(animated: true) { [weak self] in
                    self?.onSpecialWaitlistTriggered?(notifyHours)
                }
                return
            }

            navigateToSlotConfirmed()
            return
        }

        if isBlacklisted(result) {
            // Android fallbacks, replicated: reason / resumes_on / hours_remaining.
            let reason = result.blacklistDetail?.reason ?? "2 consecutive no-shows for group classes"
            let resumesOn = result.blacklistDetail?.resumesOn ?? "12 August 2026, 6:00 PM"
            let hoursRemaining = result.blacklistDetail?.hoursRemaining?.value ?? "24"

            let navigationController = resolveHostNavigationController()
            hostNavigationController = navigationController
            dismiss(animated: true) {
                let controller = BookingPausedViewController()
                controller.reason = reason
                controller.resumesOn = resumesOn
                controller.hoursRemaining = hoursRemaining
                controller.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(controller, animated: true)
            }
            return
        }

        // Android: `resp.optString("msg", "Booking failed. Please try again.")` in a Toast.
        let trimmedMessage = (result.msg ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let message = trimmedMessage.isEmpty ? Copy.bookingFailed : trimmedMessage
        dismiss(animated: true) {
            AlertHelper.shared.showCustomeAlert(title: "", message: message, actions: ["OK"], completion: nil)
        }
    }

    /// Android's blacklist test, replicated verbatim (see the doc comment on
    /// `BookClassBaseModel` in `MyPT/Model/BookedSlotModel.swift`).
    private func isBlacklisted(_ model: BookClassBaseModel) -> Bool {
        if model.isBlacklisted == true { return true }
        if model.code == "BLACKLISTED" { return true }
        let message = (model.msg ?? "").lowercased()
        return message.contains("blacklisted") || message.contains("paused")
    }

    // MARK: Navigation — Slot Confirmed (Phase 6)

    /// Real destination. `SlotConfirmedViewController`
    /// (`Controllers/GroupClasses/Booking/SlotConfirmedViewController.swift`) exposes
    /// these six settable properties, mirroring the extras `SlotConfirmedActivity`
    /// reads (`title`, `time`, `location`, `trainer_name`, `distance`, `price`):
    ///
    ///     var classTitle: String
    ///     var classTime: String
    ///     var classLocation: String
    ///     var trainerName: String
    ///     var distance: String
    ///     var classPrice: String
    ///
    /// Its `isReadOnly` flag is deliberately left `false` here: this *is* the fresh
    /// post-booking flow, so the back button unwinds to the tab root exactly like
    /// Android's `FLAG_ACTIVITY_CLEAR_TOP` return to `MainActivity`.
    ///
    /// `classPrice` is deliberately left empty here: Android does **not** forward a
    /// price from this sheet (only the detail screen's "BOOKED" re-entry does), and
    /// `SlotConfirmedActivity` hides its whole price row when the extra is blank —
    /// which is correct for a free-for-member booking.
    ///
    /// The booking has already been made by the time we get here, so no
    /// `schedule_id` is handed over — that would make Slot Confirmed re-POST
    /// `book-class` (Android guards the same way: the sheet's intent omits it).
    private func navigateToSlotConfirmed() {
        let navigationController = resolveHostNavigationController()
        hostNavigationController = navigationController

        let title = input.title
        let time = input.time
        let location = input.location
        let trainer = input.trainerName
        let distance = input.distance

        dismiss(animated: true) {
            let controller = SlotConfirmedViewController()
            controller.classTitle = title
            controller.classTime = time
            controller.classLocation = location
            controller.trainerName = trainer
            controller.distance = distance
            controller.classPrice = ""
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
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
}

// MARK: - Presentation helper

extension ConfirmSlotSheetViewController {

    /// Single entry point used by `GroupTrainingDetailViewController`.
    @discardableResult
    static func present(from presenter: UIViewController,
                        input: ConfirmSlotSheetInput,
                        onBookingSucceeded: (() -> Void)? = nil,
                        onSpecialWaitlistTriggered: ((_ notifyHours: Int?) -> Void)? = nil,
                        onWaitlistJoinConfirmed: (() -> Void)? = nil) -> ConfirmSlotSheetViewController {
        let controller = ConfirmSlotSheetViewController(input: input)
        controller.onBookingSucceeded = onBookingSucceeded
        controller.onSpecialWaitlistTriggered = onSpecialWaitlistTriggered
        controller.onWaitlistJoinConfirmed = onWaitlistJoinConfirmed
        // Captured up front: for a sheet presentation UIKit reports the *container*
        // (nav/tab controller) as `presentingViewController`, and it goes `nil` the
        // instant dismissal starts — so the push target is resolved here, where the
        // presenter's own stack is unambiguous.
        controller.hostNavigationController = presenter.navigationController ?? (presenter as? UINavigationController)
        presenter.present(controller, animated: true)
        return controller
    }
}

// MARK: - Layout

private extension ConfirmSlotSheetViewController {

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
        contentStack.setCustomSpacing(12, after: handleRow)

        // 2 — title / subtitle + close X
        let headerRow = makeHeaderRow()
        contentStack.addArrangedSubview(headerRow)
        contentStack.setCustomSpacing(12, after: headerRow)

        // 3 — class / location / trainer details card
        let detailsCard = makeDetailsCard()
        contentStack.addArrangedSubview(detailsCard)
        contentStack.setCustomSpacing(12, after: detailsCard)

        // 4 — amber IMPORTANT NOTE box
        let noteBox = makeImportantNoteBox()
        contentStack.addArrangedSubview(noteBox)
        contentStack.setCustomSpacing(12, after: noteBox)

        // 5 — cancellation-policy line
        let policyLabel = makePolicyLabel()
        contentStack.addArrangedSubview(policyLabel)
        // Android's `layout_marginTop="16dp"` on the CTA itself.
        contentStack.setCustomSpacing(16, after: policyLabel)

        // 6 — CTA
        contentStack.addArrangedSubview(makeCTA())
    }

    // MARK: Handle

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

    // MARK: Header

    func makeHeaderRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        titleLabel.textColor = Palette.title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.text = Copy.title

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        subtitleLabel.textColor = Palette.subtext
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .left
        // Android `lineSpacingExtra="4dp"`.
        subtitleLabel.attributedText = NSAttributedString(
            string: Copy.subtitle,
            attributes: [
                .font: AppFont.regular.size(16.0, familyName: familyFunnelSans),
                .foregroundColor: Palette.subtext,
                .paragraphStyle: ConfirmSlotSheetViewController.paragraphStyle(lineSpacing: 4, alignment: .left)
            ]
        )

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 8
        container.addSubview(textStack)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let closeSymbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let closeImg = UIImage(systemName: "xmark", withConfiguration: closeSymbolConfig) ?? ConfirmSlotSheetViewController.icon(["ic_close_x_34"], systemFallback: "xmark")
        closeButton.setImage(closeImg?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = Palette.title
        closeButton.accessibilityLabel = "Close"
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.contentHorizontalAlignment = .center
        closeButton.contentVerticalAlignment = .center
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        container.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 4),
            closeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: -4),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),

            textStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textStack.topAnchor.constraint(equalTo: container.topAnchor),
            textStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            textStack.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8)
        ])
        return container
    }

    // MARK: Details card

    func makeDetailsCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        // `card_details_bg`'s radial layer is centred at (0.5, -0.1) with a
        // #14FFFFFF start — a top-centre sheen at ~8% alpha.
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        // Row 1 — class title / time + duration chip
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

        let classRow = makeCardRow(icon: ConfirmSlotSheetViewController.icon(["ic_yoga_18"], systemFallback: "figure.yoga"),
                                   titleLabel: classTitleLabel,
                                   subtitleLabel: classDateTimeLabel,
                                   accessory: makeDurationChip())

        // Row 2 — location
        locationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        locationTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        locationTitleLabel.textColor = Palette.rowTitle
        locationTitleLabel.numberOfLines = 2
        locationTitleLabel.lineBreakMode = .byWordWrapping

        locationDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        locationDistanceLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        locationDistanceLabel.textColor = Palette.rowSubtitle
        locationDistanceLabel.numberOfLines = 1
        locationDistanceLabel.lineBreakMode = .byTruncatingTail
        // Android ships this placeholder and only replaces it when the detail
        // screen's distance label is non-blank.
        locationDistanceLabel.text = "2.1 km away"

        let locationRow = makeCardRow(icon: ConfirmSlotSheetViewController.icon(["ic_location_pin_small"], systemFallback: "mappin.and.ellipse"),
                                      titleLabel: locationTitleLabel,
                                      subtitleLabel: locationDistanceLabel,
                                      accessory: nil)

        // Row 3 — trainer
        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerNameLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        trainerNameLabel.textColor = Palette.rowTitle
        trainerNameLabel.numberOfLines = 1
        trainerNameLabel.lineBreakMode = .byTruncatingTail

        let trainerSubtitleLabel = UILabel()
        trainerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerSubtitleLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        trainerSubtitleLabel.textColor = Palette.rowSubtitle
        trainerSubtitleLabel.numberOfLines = 1
        trainerSubtitleLabel.lineBreakMode = .byTruncatingTail
        trainerSubtitleLabel.text = Copy.trainerSubtitle

        let trainerRow = makeCardRow(icon: ConfirmSlotSheetViewController.icon(["ic_trainer_running_18"], systemFallback: "figure.run"),
                                     titleLabel: trainerNameLabel,
                                     subtitleLabel: trainerSubtitleLabel,
                                     accessory: nil)

        // A uniform 15pt stack spacing reproduces Android's
        // `layout_marginVertical="15dp"` on both dividers.
        let stack = UIStackView(arrangedSubviews: [classRow,
                                                   makeDivider(),
                                                   locationRow,
                                                   makeDivider(),
                                                   trainerRow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 15
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: Metric.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Metric.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Metric.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Metric.cardPadding)
        ])
        return card
    }

    /// 38pt icon tile + two-line text block, with an optional trailing accessory.
    func makeCardRow(icon: UIImage?,
                     titleLabel: UILabel,
                     subtitleLabel: UILabel,
                     accessory: UIView?) -> UIView {
        let iconTile = makeIconTile(image: icon)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        // `.fill` so a long studio name truncates inside the row instead of
        // overflowing past the chip.
        textStack.alignment = .fill
        textStack.spacing = 2
        // Lowest hugging priority in the row -> the stack absorbs the slack, which
        // is what pins the chip to the trailing edge.
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        var arranged: [UIView] = [iconTile, textStack]
        if let accessory = accessory {
            accessory.setContentHuggingPriority(.required, for: .horizontal)
            accessory.setContentCompressionResistancePriority(.required, for: .horizontal)
            arranged.append(accessory)
        }

        let row = UIStackView(arrangedSubviews: arranged)
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    /// Android's `location_icon_bg`: 38dp rounded square, top-down
    /// `#1AFFFFFF -> #101113` wash with a `#101113` hairline.
    func makeIconTile(image: UIImage?) -> UIView {
        let tile = GlassCardView(cornerRadius: 12)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = Palette.tileFill
        tile.fillAlpha = 1.0
        tile.strokeColor = UIColor(hex: "#101113")
        tile.strokeAlpha = 1.0
        tile.sheenOrigin = .topCenter
        tile.sheenAlpha = 0.08

        let iconView = UIImageView(image: image)
        iconView.translatesAutoresizingMaskIntoConstraints = false
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

    /// `chip_60_mins_bg`: 8dp radius, `#33FAFAFA` stroke, left-to-right
    /// `#33FFFFFF -> #00FFFFFF` fill.
    func makeDurationChip() -> UIView {
        let chip = GradientFadeView()
        chip.translatesAutoresizingMaskIntoConstraints = false
        chip.gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        chip.gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        chip.setColors([UIColor.white.withAlphaComponent(0.2),
                        UIColor.white.withAlphaComponent(0.0)])
        chip.layer.cornerRadius = 8
        chip.layer.masksToBounds = true
        chip.layer.borderWidth = 1
        chip.layer.borderColor = Palette.chipStroke.cgColor

        durationChipLabel.translatesAutoresizingMaskIntoConstraints = false
        durationChipLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        durationChipLabel.textColor = Palette.chipText
        durationChipLabel.numberOfLines = 1
        durationChipLabel.textAlignment = .center
        durationChipLabel.text = Copy.defaultDuration
        // Belt-and-suspenders against the chip stretching to fill the row's
        // leftover horizontal space: the label itself (not just the chip as the
        // row's accessory) refuses to grow or compress past its own text size.
        durationChipLabel.setContentHuggingPriority(.required, for: .horizontal)
        durationChipLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        chip.addSubview(durationChipLabel)

        NSLayoutConstraint.activate([
            chip.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            chip.widthAnchor.constraint(equalTo: durationChipLabel.widthAnchor, constant: 24),
            durationChipLabel.topAnchor.constraint(equalTo: chip.topAnchor, constant: 4),
            durationChipLabel.bottomAnchor.constraint(equalTo: chip.bottomAnchor, constant: -4),
            durationChipLabel.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            durationChipLabel.centerYAnchor.constraint(equalTo: chip.centerYAnchor)
        ])
        return chip
    }

    func makeDivider() -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = Palette.divider
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    // MARK: Important note

    func makeImportantNoteBox() -> UIView {
        let box = UIView()
        box.translatesAutoresizingMaskIntoConstraints = false
        // `important_note_bg`: #1ADB812E fill, #4DDB812E stroke, 12dp radius.
        box.backgroundColor = GroupClassColor.gold.color.withAlphaComponent(0.10)
        box.layer.cornerRadius = 12
        box.layer.masksToBounds = true
        box.layer.borderWidth = 1
        box.layer.borderColor = GroupClassColor.gold.color.withAlphaComponent(0.30).cgColor

        let warningIcon = UIImageView(image: ConfirmSlotSheetViewController.icon(["ic_warning_hex_16", "info-hexagon"], systemFallback: "exclamationmark.triangle.fill")?
            .withRenderingMode(.alwaysTemplate))
        warningIcon.translatesAutoresizingMaskIntoConstraints = false
        warningIcon.tintColor = GroupClassColor.gold.color
        warningIcon.contentMode = .scaleAspectFit

        let headingLabel = UILabel()
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        headingLabel.textColor = GroupClassColor.gold.color
        headingLabel.numberOfLines = 1
        headingLabel.text = Copy.importantNoteTitle

        let headingRow = UIStackView(arrangedSubviews: [warningIcon, headingLabel])
        headingRow.translatesAutoresizingMaskIntoConstraints = false
        headingRow.axis = .horizontal
        headingRow.alignment = .center
        headingRow.spacing = 8

        // Wrapper keeps the icon+heading hugging the leading edge inside a `.fill` stack.
        let headingWrapper = UIView()
        headingWrapper.translatesAutoresizingMaskIntoConstraints = false
        headingWrapper.addSubview(headingRow)

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.numberOfLines = 0
        bodyLabel.attributedText = ConfirmSlotSheetViewController.importantNoteText()

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
            stack.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -16)
        ])
        return box
    }

    // MARK: Policy line

    func makePolicyLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = ConfirmSlotSheetViewController.policyText()
        // Was purely decorative colored text with no tap action. The label is
        // one short centered line, so making the whole thing tappable (rather
        // than a precise tap-range limited to just the "Cancellation Policy"
        // span) is indistinguishable to the user.
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(policyLabelTapped)))
        return label
    }

    @objc private func policyLabelTapped() {
        // This sheet only ever shows for a free booking (paid classes route
        // straight to `ClassPaymentViewController` instead) - deterministically
        // the free variant, same reasoning as Android's identical call site.
        CancellationPolicySheetViewController.present(from: self, isFree: true)
    }

    // MARK: CTA

    func makeCTA() -> UIView {
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        // `btn_cta_gradient_shadow` offsets the body by 2dp over the grey band.
        ctaButton.bandThickness = 2
        setCTATitle(Copy.confirmCTA)
        // Android's CTA centres `[text][8dp][16dp chevron]` inside a
        // `paddingHorizontal="16dp"` button — handled by the shared component.
        ctaButton.horizontalContentInset = 16
        ctaButton.setTrailingIcon(
            ConfirmSlotSheetViewController.icon(["ic_chevron_right_16_dark", "chevron-right"],
                                                systemFallback: "chevron.right"),
            tint: Palette.ctaInk)
        ctaButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        ctaButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight).isActive = true
        return ctaButton
    }
}

// MARK: - Attributed copy + icon resolution

private extension ConfirmSlotSheetViewController {

    static func paragraphStyle(lineSpacing: CGFloat, alignment: NSTextAlignment) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.alignment = alignment
        return style
    }

    /// Port of the `warningHtml` string: the trailing "48 hours." is bold gold.
    static func importantNoteText() -> NSAttributedString {
        let paragraph = paragraphStyle(lineSpacing: 3, alignment: .left)

        let base: [NSAttributedString.Key: Any] = [
            .font: AppFont.regular.size(12.0, familyName: familyFunnelSans),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraph
        ]
        let emphasis: [NSAttributedString.Key: Any] = [
            .font: AppFont.bold.size(12.0, familyName: familyFunnelSans),
            .foregroundColor: GroupClassColor.gold.color,
            .paragraphStyle: paragraph
        ]

        let result = NSMutableAttributedString(string: Copy.importantNoteBody, attributes: base)
        result.append(NSAttributedString(string: Copy.importantNoteEmphasis, attributes: emphasis))
        return result
    }

    /// Port of the `policyHtml` string: "Cancellation Policy" is bold lime.
    static func policyText() -> NSAttributedString {
        let paragraph = paragraphStyle(lineSpacing: 0, alignment: .center)

        let base: [NSAttributedString.Key: Any] = [
            .font: AppFont.regular.size(12.0, familyName: familyFunnelSans),
            .foregroundColor: Palette.policyText,
            .paragraphStyle: paragraph
        ]
        let emphasis: [NSAttributedString.Key: Any] = [
            .font: AppFont.bold.size(12.0, familyName: familyFunnelSans),
            .foregroundColor: GroupClassColor.lime.color,
            .paragraphStyle: paragraph
        ]

        let result = NSMutableAttributedString(string: Copy.policyPrefix, attributes: base)
        result.append(NSAttributedString(string: Copy.policyEmphasis, attributes: emphasis))
        return result
    }

    /// First bundled asset wins; a system symbol is the last resort.
    ///
    /// Every candidate list leads with the *Android* drawable name, so importing the
    /// real glyphs later under those exact names upgrades the sheet with no code
    /// change. Does **not** fall through to unrelated already-bundled iOS assets —
    /// those render a wrong-looking glyph rather than a missing one. `info-hexagon`
    /// and `chevron-right` are real rendered Group-Classes assets (not placeholders)
    /// and are tried first.
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
