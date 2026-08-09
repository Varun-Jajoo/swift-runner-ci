//
//  SlotConfirmedViewController.swift
//  MyPT
//
//  "Your slot is confirmed" — the success screen shown after a group-class
//  booking succeeds (free-for-member confirm, Tabby/CCAvenue payment), and the
//  read-only receipt for a booking that already exists.
//
//  Android reference (ground truth for layout, copy and logic):
//    app/src/main/java/co/com/mypt/UpComingClasses/SlotConfirmedActivity.kt
//    app/src/main/res/layout/activity_slot_confirmed.xml
//    Drawables ported programmatically (per the plan's Phase-2 decision 4):
//        bg_confirm_slot_success_xml     -> #000A04 + radial #331A3D22 -> #00000A04
//                                           (r = 400dp, centre 0.1 / -0.1)
//        ic_slot_confirmed_success_badge -> 120pt teal disc + white tick, drawn from
//                                           the vector's own path data
//        circle_action_btn_bg            -> GlassCircularIconButton
//        card_details_bg                 -> #18191C fill, #232323 stroke, top-centre sheen
//        glass_pill_bg                   -> 8pt radius, #33FAFAFA stroke, top sheen
//        location_icon_bg                -> 38pt tile, #1AFFFFFF -> #101113 wash
//        confirmed_cancellation_bottom_bg-> #2B2B2C fill, #232323 stroke, 16dp radius
//        important_note_bg               -> #1ADB812E fill, #4DDB812E stroke, 12dp radius
//        btn_cta_gradient_shadow         -> GradientCTAButton with a 2pt band
//
//  Deliberately kept separate from `PaymentSuccessViewController`: that screen is
//  the app's generic storyboard-backed billing receipt (bill breakdown, sound
//  effect, `BillingFlow` switch); this one is a card-heavy Group-Classes design
//  with a different information model. Same rationale as keeping the Group
//  Training Detail screen separate from the legacy `ClassDetailsViewController`.
//
//  Entry points:
//    · fresh booking  — `ConfirmSlotSheetViewController.navigateToSlotConfirmed()`
//                       (Phase 5) and, later, the payment screens (Phase 7/8).
//    · read-only      — `GroupTrainingDetailViewController`'s "BOOKED" CTA, and
//                       (Phase 11) the Bookings-tab list. See `isReadOnly`.
//

import UIKit

// MARK: - SlotConfirmedSuccessBadgeView

/// 120pt success badge, a direct port of `ic_slot_confirmed_success_badge.xml`.
///
/// The vector is drawn in a 120×120 viewport as three paths: a 60pt `#036F82`
/// disc at 20% alpha, a 93.33pt solid `#036F82` disc on top of it, and a white
/// tick. (The larger disc fully covers the smaller one — that overdraw is in the
/// Android asset, and is reproduced rather than "fixed" so the two platforms stay
/// pixel-comparable if the asset is ever corrected.)
final class SlotConfirmedSuccessBadgeView: UIView {

    /// The vector's `android:viewportWidth`/`viewportHeight`.
    private static let viewport: CGFloat = 120

    private let haloLayer = CAShapeLayer()
    private let discLayer = CAShapeLayer()
    private let tickLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        let teal = UIColor(hex: "#036F82")
        haloLayer.fillColor = teal.withAlphaComponent(0.2).cgColor
        discLayer.fillColor = teal.cgColor
        tickLayer.fillColor = UIColor.white.cgColor

        layer.addSublayer(haloLayer)
        layer.addSublayer(discLayer)
        layer.addSublayer(tickLayer)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: SlotConfirmedSuccessBadgeView.viewport,
                      height: SlotConfirmedSuccessBadgeView.viewport)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }

        // Uniform scale on the shorter side keeps the artwork circular even if the
        // host lays the badge out in a non-square box.
        let scale = min(bounds.width, bounds.height) / SlotConfirmedSuccessBadgeView.viewport
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        haloLayer.frame = bounds
        discLayer.frame = bounds
        tickLayer.frame = bounds

        let halo = UIBezierPath(arcCenter: CGPoint(x: 60, y: 60),
                                radius: 30,
                                startAngle: 0,
                                endAngle: .pi * 2,
                                clockwise: true)
        halo.apply(scaleTransform)
        haloLayer.path = halo.cgPath

        let disc = UIBezierPath(arcCenter: CGPoint(x: 60, y: 60),
                                radius: 46.6667,
                                startAngle: 0,
                                endAngle: .pi * 2,
                                clockwise: true)
        disc.apply(scaleTransform)
        discLayer.path = disc.cgPath

        let tick = SlotConfirmedSuccessBadgeView.tickPath()
        tick.apply(scaleTransform)
        tickLayer.path = tick.cgPath

        CATransaction.commit()
    }

    /// The vector's third `<path>`, transcribed control point for control point.
    private static func tickPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 54.7629, y: 77.1197))
        path.addCurve(to: CGPoint(x: 53.0188, y: 76.4137),
                      controlPoint1: CGPoint(x: 54.0985, y: 77.1197),
                      controlPoint2: CGPoint(x: 53.4756, y: 76.8705))
        path.addLine(to: CGPoint(x: 42.1388, y: 65.2015))
        path.addCurve(to: CGPoint(x: 42.0557, y: 61.5887),
                      controlPoint1: CGPoint(x: 41.1006, y: 64.2464),
                      controlPoint2: CGPoint(x: 41.0591, y: 62.6269))
        path.addCurve(to: CGPoint(x: 45.6686, y: 61.5056),
                      controlPoint1: CGPoint(x: 43.0109, y: 60.5505),
                      controlPoint2: CGPoint(x: 44.6304, y: 60.5090))
        path.addLine(to: CGPoint(x: 53.6417, y: 67.1948))
        path.addCurve(to: CGPoint(x: 55.1782, y: 67.0287),
                      controlPoint1: CGPoint(x: 54.0985, y: 67.6101),
                      controlPoint2: CGPoint(x: 54.8044, y: 67.5270))
        path.addLine(to: CGPoint(x: 74.0728, y: 43.6907))
        path.addCurve(to: CGPoint(x: 77.6441, y: 43.1924),
                      controlPoint1: CGPoint(x: 74.9034, y: 42.5695),
                      controlPoint2: CGPoint(x: 76.5229, y: 42.3203))
        path.addCurve(to: CGPoint(x: 78.1424, y: 46.7637),
                      controlPoint1: CGPoint(x: 78.7653, y: 44.0229),
                      controlPoint2: CGPoint(x: 79.0145, y: 45.6424))
        path.addLine(to: CGPoint(x: 56.7977, y: 76.0815))
        path.addCurve(to: CGPoint(x: 54.9705, y: 77.0781),
                      controlPoint1: CGPoint(x: 56.3409, y: 76.6629),
                      controlPoint2: CGPoint(x: 55.6765, y: 77.0366))
        path.addCurve(to: CGPoint(x: 54.7629, y: 77.1197),
                      controlPoint1: CGPoint(x: 54.8875, y: 77.1197),
                      controlPoint2: CGPoint(x: 54.8460, y: 77.1197))
        path.close()
        return path
    }
}

// MARK: - SlotConfirmedViewController

final class SlotConfirmedViewController: CommonViewController {

    // MARK: - Input
    //
    // One property per intent extra `SlotConfirmedActivity` reads. The defaults are
    // Android's own `?: "…"` fallbacks, so "caller did not set it" renders exactly
    // what Android renders when the extra is absent.

    /// `title`
    var classTitle: String = "Morning Flow Yoga"
    /// `time` — already formatted for display, e.g. `Wed, 9 Jul • 7-8 AM`.
    var classTime: String = "Wed, 9 Jul • 7-8 AM"
    /// `location`
    var classLocation: String = "Silicon Oasis"
    /// `trainer_name` — blank leaves the layout's "Trainer: Sara K." placeholder.
    var trainerName: String = ""
    /// `distance` — blank leaves the layout's "2.1 km away" placeholder.
    var distance: String = ""
    /// `price` / `total_price` — blank hides the price row *and* its divider.
    var classPrice: String = ""

    // MARK: - Deferred booking POST (Android's `sendBookingData`)
    //
    // Android fires `book-class` from *this* screen when it is started with a
    // `schedule_id` — that is how the paid paths (`ClassPaymentScreenActivity`,
    // `CCavenueWebCLassActivity`) commit the booking after the gateway returns.
    // The free-for-member path deliberately omits `schedule_id`, because
    // `ConfirmSlotSheetViewController` has already POSTed by the time it pushes
    // this screen. Left at its default here, this whole mechanism is inert; Phase 7
    // and Phase 8 are the callers that will set it.

    /// `schedule_id`. Empty (the default) means "already booked — do not POST".
    var scheduleId: String = ""
    /// `transaction_id` from the payment gateway.
    var transactionId: String = ""
    /// `selectedPaymentOption`. Android's fallback for this extra is `"paid"`.
    var paymentType: String = "paid"

    /// iOS-only viewing mode, used when the screen is opened to *review* a booking
    /// that already exists rather than as the last step of making one — the
    /// "BOOKED" CTA on Group Training Detail, and (Phase 11) a group-class row in
    /// the Bookings tab.
    ///
    /// Concretely it changes two things and nothing else:
    ///   1. The `book-class` POST is suppressed unconditionally, even if
    ///      `scheduleId` is set. Android's Bookings-list adapters pass
    ///      `schedule_id` into this screen, which makes it re-POST `book-class`
    ///      for an already-confirmed booking; this flag is what stops iOS
    ///      inheriting that.
    ///   2. The glass back button pops one level (back to Detail / the Bookings
    ///      list) instead of unwinding the whole stack to the tab root, which is
    ///      what the fresh-booking flow does to mirror Android's
    ///      `FLAG_ACTIVITY_CLEAR_TOP` return to `MainActivity`.
    ///
    /// Copy, layout and the "VIEW MY BOOKINGS" CTA are identical in both modes —
    /// Android has no alternate wording, so none is invented here.
    var isReadOnly: Bool = false

    /// `user_classes.id` for this booking - required to call `cancel-class-booking`.
    /// Only meaningful (and only ever set by the caller) alongside `isReadOnly`.
    var bookingId: String = ""
    /// Shows the "CANCEL BOOKING" link above the main CTA. The Bookings list
    /// only sets this for its Upcoming tab - a Cancelled or Completed booking
    /// has nothing left to cancel.
    var canCancelBooking: Bool = false

    // MARK: - Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let contentTopInset: CGFloat = 20
        static let contentBottomInset: CGFloat = 24
        static let backButtonDiameter: CGFloat = 40
        static let badgeSide: CGFloat = 120
        static let subtextInset: CGFloat = 16
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let iconTileSide: CGFloat = 38
        static let warningIconSide: CGFloat = 16
        static let policyBarMinHeight: CGFloat = 103
        static let policyBarInset: CGFloat = 16
        static let policyIconSide: CGFloat = 20
        static let policyChevronSide: CGFloat = 16
        /// The details card's `layout_marginBottom` — how far the policy strip
        /// peeks out below it.
        static let policyBarPeek: CGFloat = 50
        static let ctaHeight: CGFloat = 48
    }

    /// Hex values taken straight from `activity_slot_confirmed.xml`; only the
    /// module-wide slots (page background, gold) come from `GroupClassColor`.
    private enum Palette {
        static let headerTitle = UIColor(hex: "#FAFAFA")
        static let headerSubtext = UIColor(hex: "#959595")
        static let divider = UIColor.white.withAlphaComponent(0.10)              // #1AFFFFFF
        static let policyFill = UIColor(hex: "#2B2B2C")
        static let policyStroke = UIColor(hex: "#232323")
        static let policyText = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75) // #BFFAFAFA
        static let cardFill = UIColor(hex: "#18191C")
        static let cardStroke = UIColor(hex: "#232323")
        static let tileFill = UIColor(hex: "#101113")
        static let pillStroke = UIColor(hex: "#FAFAFA")                          // @ 20% -> #33FAFAFA
        static let pillText = UIColor(hex: "#F0F0F0")
        static let classTitle = UIColor(hex: "#FFFFFF")
        static let classDateTime = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let rowTitle = UIColor(hex: "#FFFFFF")
        static let rowSubtitle = UIColor.white.withAlphaComponent(0.4)           // #66FFFFFF
        static let noteBody = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)   // #8CFAFAFA
        static let ctaInk = UIColor(hex: "#131416")
        static let cancelText = UIColor(hex: "#FF6B6B")
    }

    /// Copy that is hard-coded in the Android layout / Kotlin.
    private enum Copy {
        static let headerTitle = "Your slot is confirmed"
        static let headerSubtext = "Your slot is confirmed. Manage your booking anytime from My Bookings."
        static let categoryPill = "GROUP CLASS"
        static let cancellationPolicy = "Cancellation Policy"
        static let importantNoteTitle = "IMPORTANT NOTE"
        static let importantNoteBody = "If you miss two classes consecutively (no-show or late cancellation), you will be blacklisted from group classes for "
        static let importantNoteEmphasis = "48 hours."
        static let trainerPlaceholder = "Trainer: Sara K."
        static let trainerSubtitle = "Certified MyPT Trainer"
        static let distancePlaceholder = "2.1 km away"
        static let priceSubtitle = "Group Class Cost"
        static let viewBookingsCTA = "VIEW MY BOOKINGS"
        static let cancelBookingCTA = "CANCEL BOOKING"
        static let cancelConfirmTitle = "Cancel this booking?"
        static let cancelConfirmMessage = "This will free up your spot for other members."
    }

    /// Index of the Bookings tab in `CustomTabViewController`.
    ///
    /// Verified against `CustomTabViewController.setupTabbar(homeType:)`, whose
    /// `viewControllers` array is
    /// `[home, libraryVC ("Plans"), bookingsVC ("Bookings"), moreVC ("Menu")]`, and
    /// against the app's existing tab-jump idiom in
    /// `SessionConformVC.onTapShowQRCode` (`tabBar.selectedIndex = 2`).
    private static let bookingsTabIndex = 2

    // MARK: - Views

    /// `android:background="@drawable/bg_confirm_slot_success"` — a raster photo
    /// (light rays, sparkle particles, a blue-teal glow), not the flat radial
    /// wash `bg_confirm_slot_success_xml.xml` describes; that XML is dead code
    /// on Android (unreferenced by any layout) and was ported here by mistake.
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let backButton = GlassCircularIconButton()

    private let classTitleLabel = UILabel()
    private let classDateTimeLabel = UILabel()
    private let locationTitleLabel = UILabel()
    private let locationDistanceLabel = UILabel()
    private let trainerTitleLabel = UILabel()
    private let priceTitleLabel = UILabel()

    /// `divConfirmedPrice` / `rowConfirmedPrice` — hidden together when no price.
    private let priceDivider = UIView()
    private let priceRow = UIStackView()

    private let footerView = UIView()
    private let footerStack = UIStackView()
    private let cancelButton = UIButton(type: .system)
    private let ctaButton = GradientCTAButton()

    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = GroupClassColor.bg.color
        buildLayout()
        populateUI()

        // Android: `if (!scheduleId.isNullOrEmpty()) sendBookingData(...)`.
        if !isReadOnly, !scheduleId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            sendBookingData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Populate

    /// Port of the `findViewById` block in `SlotConfirmedActivity.onCreate`.
    private func populateUI() {
        classTitleLabel.text = classTitle
        classDateTimeLabel.text = classTime
        // Android: `rawLocation.substringBefore(",").trim()` when the string
        // contains a comma (e.g. "DSO Club, Dubai" -> "DSO Club"); this is
        // specific to Slot Confirmed — Waitlist Confirmed does not do this.
        if let commaRange = classLocation.range(of: ",") {
            locationTitleLabel.text = String(classLocation[..<commaRange.lowerBound])
                .trimmingCharacters(in: .whitespaces)
        } else {
            locationTitleLabel.text = classLocation
        }

        // Android: only overwrite the placeholder when the extra is non-blank, and
        // append " away" when the caller has not already.
        let trimmedDistance = distance.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedDistance.isEmpty {
            locationDistanceLabel.text = trimmedDistance.contains("away") ? trimmedDistance : "\(trimmedDistance) away"
        }

        let trimmedTrainer = trainerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTrainer.isEmpty {
            trainerTitleLabel.text = trimmedTrainer.hasPrefix("Trainer:") ? trimmedTrainer : "Trainer: \(trimmedTrainer)"
        }

        applyPrice()
    }

    private func applyPrice() {
        let rawPrice = classPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanValue = rawPrice
            .replacingOccurrences(of: "AED", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let isFreeOrZero = rawPrice.isEmpty ||
            cleanValue.caseInsensitiveCompare("free") == .orderedSame ||
            cleanValue == "0" ||
            cleanValue == "0.00" ||
            cleanValue == "0.0" ||
            (Double(cleanValue) ?? 0.0) <= 0.0

        if !isFreeOrZero {
            priceTitleLabel.text = "\(cleanValue) AED"
            priceDivider.isHidden = false
            priceRow.isHidden = false
        } else {
            priceDivider.isHidden = true
            priceRow.isHidden = true
        }
    }

    // MARK: - Network — POST api/book-class

    /// Port of `sendBookingData(scheduleId, transactionId, paymentType)`.
    ///
    /// Android fires this and only logs the response — the screen is already
    /// showing "confirmed" by then, so there is no success/failure UI to drive.
    /// Replicated as-is; `UpcomingClassVM.bookGroupClassApi` shows the same blocking
    /// loader Android's `ProgressDialog` does.
    private func sendBookingData() {
        UpcomingClassVM.bookGroupClassApi(scheduleId: scheduleId,
                                          transactionId: transactionId,
                                          paymentType: paymentType) { result in
            debugPrint("[SlotConfirmed] book-class response status=\(String(describing: result?.status)) msg=\(String(describing: result?.msg))")
        }
    }

    // MARK: - Navigation

    /// Resolves the app's tab host. `tabBarController` is the normal answer (this
    /// screen is pushed onto a tab's navigation stack); the window walk is only a
    /// safety net for a future modal presentation.
    private func resolveTabBarController() -> UITabBarController? {
        if let tabBarController = tabBarController { return tabBarController }

        // `UIApplication.shared.windows` is the app-wide idiom (see
        // `CommonViewController.statusBarColor(setColor:)`).
        var candidate = UIApplication.shared.windows.first(where: \.isKeyWindow)?.rootViewController
        while let current = candidate {
            if let tabBarController = current as? UITabBarController { return tabBarController }
            candidate = current.presentedViewController ?? current.children.first
        }
        return nil
    }

    /// Mirrors the fix in Android's `UpcomingBookingDetails.sendCancelData()`:
    /// a group-class booking has to go through `cancel-class-booking`
    /// (its row lives in `user_classes`), not the personal-training
    /// `cancel-session` endpoint - that one "succeeds" without ever touching
    /// this booking's real row, so the class keeps showing as booked
    /// everywhere except this one screen's own local state.
    @objc private func cancelBookingTapped() {
        guard !bookingId.isEmpty else { return }

        AlertHelper.shared.showCustomeAlert(title: Copy.cancelConfirmTitle,
                                            message: Copy.cancelConfirmMessage,
                                            actions: ["Ok", "Cancel"],
                                            withCancel: true) { [weak self] tappedIndex in
            guard let self = self, tappedIndex == 0 else { return }

            let params: [String: Any] = ["booking_id": self.bookingId]
            NetworkManager.shared.genericAPICall(serviceEndPoint: .cancel_class_booking,
                                                 method: .post,
                                                 parameters: params,
                                                 isShowLoading: true) { [weak self] responseData, _ in
                guard let self = self else { return }
                let succeeded = responseData
                    .flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
                    .flatMap { $0["status"] as? Bool } ?? false

                DispatchQueue.main.async {
                    if succeeded {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        AlertHelper.shared.showCustomeAlert(title: "", message: "Could not cancel booking. Please try again.", actions: ["OK"], completion: nil)
                    }
                }
            }
        }
    }

    /// Port of Android's `navigateHome`: `MainActivity` with `FLAG_ACTIVITY_CLEAR_TOP`
    /// and **no** `key_tab` extra, i.e. tear down everything above the tab host and
    /// leave the selected tab alone.
    ///
    /// In read-only mode the screen was reached from a screen the user still wants
    /// (Detail / the Bookings list), so it steps back one level instead.
    @objc private func backTapped() {
        if isReadOnly {
            navigationController?.popViewController(animated: true)
            return
        }
        navigationController?.popToRootViewController(animated: true)
    }

    /// Port of Android's `navigateToBookings`: `MainActivity` with
    /// `FLAG_ACTIVITY_CLEAR_TOP` plus a tab selection.
    ///
    /// Android puts `key_tab = R.id.plans` there, but `R.id.plans` is wired in
    /// `MainActivity.setUpBottomNavigation()` to `ID_CALENDAR` (`calendarFragment`),
    /// not to `R.id.bookings`/`bookingFragment` — an Android-side mismatch with the
    /// button's own "VIEW MY BOOKINGS" label. iOS follows the label and the approved
    /// plan and goes to the real Bookings tab (`bookingsVC`,
    /// `BookingListViewController`), which is also the list Phase 11 branches.
    @objc private func viewMyBookingsTapped() {
        TapticEngine.selection.feedback()

        let hostNavigationController = navigationController

        guard let tabBarController = resolveTabBarController(),
              let tabs = tabBarController.viewControllers,
              tabs.indices.contains(SlotConfirmedViewController.bookingsTabIndex) else {
            // No tab host (e.g. a debug push from a standalone stack): the closest
            // equivalent is unwinding to whatever is at the root.
            hostNavigationController?.popToRootViewController(animated: true)
            return
        }

        // Reset the destination stack first so the tab lands on the list itself and
        // not on whatever detail screen was left open there.
        (tabs[SlotConfirmedViewController.bookingsTabIndex] as? UINavigationController)?
            .popToRootViewController(animated: false)
        tabBarController.selectedIndex = SlotConfirmedViewController.bookingsTabIndex

        // …then clear the group-classes stack behind us (now off-screen, so unanimated).
        hostNavigationController?.popToRootViewController(animated: false)
    }
}

// MARK: - Layout

private extension SlotConfirmedViewController {

    func buildLayout() {
        buildBackgroundWash()
        buildFooter()
        buildScrollView()
    }

    // MARK: Background

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

    /// `bottomFooterLayout`: no background of its own, so the page wash shows
    /// through. Android pads it 12dp top / 24dp bottom; on iOS the bottom padding is
    /// taken off the safe-area guide instead, matching the Group Training Detail
    /// bottom bar.
    func buildFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = .clear
        view.addSubview(footerView)

        // Only shown for a group-class row opened from the Bookings tab's
        // Upcoming sub-tab (`canCancelBooking`) - a stack so hiding it
        // collapses the space instead of leaving a gap above the main CTA.
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle(Copy.cancelBookingCTA, for: .normal)
        cancelButton.setTitleColor(Palette.cancelText, for: .normal)
        cancelButton.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        cancelButton.addTarget(self, action: #selector(cancelBookingTapped), for: .touchUpInside)
        cancelButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancelButton.isHidden = !(isReadOnly && canCancelBooking && !bookingId.isEmpty)

        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        // `btn_cta_gradient_shadow` offsets the body by 2dp over the grey band.
        ctaButton.bandThickness = 2
        ctaButton.configure(title: Copy.viewBookingsCTA,
                            font: AppFont.semibold.size(16.0, familyName: familyFunnelSans),
                            titleColor: Palette.ctaInk)
        ctaButton.addTarget(self, action: #selector(viewMyBookingsTapped), for: .touchUpInside)
        ctaButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight).isActive = true

        footerStack.translatesAutoresizingMaskIntoConstraints = false
        footerStack.axis = .vertical
        footerStack.alignment = .fill
        footerStack.spacing = 4
        footerStack.addArrangedSubview(cancelButton)
        footerStack.addArrangedSubview(ctaButton)
        footerView.addSubview(footerStack)

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            footerStack.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 12),
            footerStack.leadingAnchor.constraint(equalTo: footerView.leadingAnchor,
                                                 constant: Metric.horizontalInset),
            footerStack.trailingAnchor.constraint(equalTo: footerView.trailingAnchor,
                                                  constant: -Metric.horizontalInset),
            footerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -12)
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
        contentStack.layoutMargins = UIEdgeInsets(top: Metric.contentTopInset,
                                                  left: Metric.horizontalInset,
                                                  bottom: Metric.contentBottomInset,
                                                  right: Metric.horizontalInset)
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

        // 1 — glass back button
        let backRow = makeBackButtonRow()
        contentStack.addArrangedSubview(backRow)
        contentStack.setCustomSpacing(34, after: backRow)

        // 2 — 120pt success badge
        let badgeRow = makeBadgeRow()
        contentStack.addArrangedSubview(badgeRow)
        contentStack.setCustomSpacing(22, after: badgeRow)

        // 3 — "Your slot is confirmed"
        let titleLabel = makeHeaderTitleLabel()
        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(8, after: titleLabel)

        // 4 — subtext
        let subtextRow = makeHeaderSubtextRow()
        contentStack.addArrangedSubview(subtextRow)
        contentStack.setCustomSpacing(22, after: subtextRow)

        // 5 — divider
        let divider = makeDivider()
        contentStack.addArrangedSubview(divider)
        contentStack.setCustomSpacing(20, after: divider)

        // 6 — stacked details card + peeking cancellation-policy strip
        let stackedCards = makeStackedCards()
        contentStack.addArrangedSubview(stackedCards)
        contentStack.setCustomSpacing(16, after: stackedCards)

        // 7 — amber IMPORTANT NOTE box
        contentStack.addArrangedSubview(makeImportantNoteBox())
    }

    // MARK: Header

    func makeBackButtonRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.configure(icon: SlotConfirmedViewController.icon(["ic_back_chevron_20"], systemFallback: "chevron.left"),
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

    /// Android gives the subtext `paddingHorizontal="16dp"` on top of the screen's
    /// own 20dp gutter, so it needs its own inset container.
    func makeHeaderSubtextRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        // Android `lineSpacingExtra="8dp"`.
        label.attributedText = NSAttributedString(
            string: Copy.headerSubtext,
            attributes: [
                .font: AppFont.regular.size(16.0, familyName: familyFunnelSans),
                .foregroundColor: Palette.headerSubtext,
                .paragraphStyle: SlotConfirmedViewController.paragraphStyle(lineSpacing: 8, alignment: .center)
            ]
        )
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Metric.subtextInset),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Metric.subtextInset)
        ])
        return container
    }

    // MARK: Stacked cards

    /// Android's `FrameLayout`: the 103dp cancellation strip is bottom-aligned and
    /// sits *behind* the details card, which carries a 50dp bottom margin — so the
    /// strip peeks out 50dp below the card and is overlapped for the rest of its
    /// height.
    func makeStackedCards() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Added first -> lower in the z-order, i.e. behind the card.
        let policyBar = makeCancellationPolicyBar()
        container.addSubview(policyBar)

        let detailsCard = makeDetailsCard()
        container.addSubview(detailsCard)

        // `wrap_content` + `minHeight="103dp"`: at least 103, exactly 103 unless the
        // strip's own content needs more.
        let policyBarHeight = policyBar.heightAnchor.constraint(equalToConstant: Metric.policyBarMinHeight)
        policyBarHeight.priority = .defaultHigh

        NSLayoutConstraint.activate([
            policyBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            policyBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            policyBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            policyBar.heightAnchor.constraint(greaterThanOrEqualToConstant: Metric.policyBarMinHeight),
            policyBarHeight,

            detailsCard.topAnchor.constraint(equalTo: container.topAnchor),
            detailsCard.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            detailsCard.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            detailsCard.bottomAnchor.constraint(equalTo: container.bottomAnchor,
                                                constant: -Metric.policyBarPeek)
        ])
        return container
    }

    /// `confirmed_cancellation_bottom_bg`: flat `#2B2B2C` fill, `#232323` hairline,
    /// 16dp radius. Its row and chevron are bottom-aligned so they land inside the
    /// 50dp strip that is not covered by the card above.
    ///
    /// The Android view sets `clickable="true"` but never attaches an
    /// `OnClickListener`, so it is decorative there; left non-interactive here
    /// rather than inventing a destination.
    func makeCancellationPolicyBar() -> UIView {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = Palette.policyFill
        bar.layer.cornerRadius = Metric.cardCornerRadius
        bar.layer.masksToBounds = true
        bar.layer.borderWidth = 1
        bar.layer.borderColor = Palette.policyStroke.cgColor

        let iconView = UIImageView(image: SlotConfirmedViewController.icon(["ic_chat_cancellation_20"], systemFallback: "bubble.left.fill")?
            .withRenderingMode(.alwaysTemplate))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = Palette.policyText
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        label.textColor = Palette.policyText
        label.numberOfLines = 1
        label.text = Copy.cancellationPolicy

        let row = UIStackView(arrangedSubviews: [iconView, label])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        bar.addSubview(row)

        let chevron = UIImageView(image: SlotConfirmedViewController.icon(["ic_chevron_right_16", "chevron-right"], systemFallback: "chevron.right")?
            .withRenderingMode(.alwaysTemplate))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = Palette.policyText
        chevron.contentMode = .scaleAspectFit
        bar.addSubview(chevron)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: Metric.policyIconSide),
            iconView.heightAnchor.constraint(equalToConstant: Metric.policyIconSide),

            row.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: Metric.policyBarInset),
            row.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -Metric.policyBarInset),
            row.topAnchor.constraint(greaterThanOrEqualTo: bar.topAnchor, constant: Metric.policyBarInset),
            row.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -12),

            chevron.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -Metric.policyBarInset),
            chevron.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -Metric.policyBarInset),
            chevron.widthAnchor.constraint(equalToConstant: Metric.policyChevronSide),
            chevron.heightAnchor.constraint(equalToConstant: Metric.policyChevronSide)
        ])
        return bar
    }

    /// `card_details_bg`: `#18191C` fill, `#232323` hairline, and a top-centre
    /// radial sheen (`#14FFFFFF` ≈ 8% white).
    func makeDetailsCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        // Row 1 — GROUP CLASS pill
        let pillRow = makeCategoryPillRow()

        // Row 2 — class title
        classTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        classTitleLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        classTitleLabel.textColor = Palette.classTitle
        classTitleLabel.numberOfLines = 0

        // Row 3 — date / time
        classDateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        classDateTimeLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        classDateTimeLabel.textColor = Palette.classDateTime
        classDateTimeLabel.numberOfLines = 1
        classDateTimeLabel.lineBreakMode = .byTruncatingTail

        // Row 4 — location
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

        let locationRow = makeDetailRow(icon: SlotConfirmedViewController.icon(["ic_location_pin_small"], systemFallback: "mappin.and.ellipse"),
                                        iconSide: 14,
                                        titleLabel: locationTitleLabel,
                                        subtitleLabel: locationDistanceLabel)

        // Row 5 — trainer
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

        let trainerRow = makeDetailRow(icon: SlotConfirmedViewController.icon(["ic_trainer_running_18"], systemFallback: "figure.run"),
                                       iconSide: 18,
                                       titleLabel: trainerTitleLabel,
                                       subtitleLabel: trainerSubtitleLabel)

        // Row 6 — price (hidden with its divider when no price was handed over)
        priceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        priceTitleLabel.textColor = Palette.rowTitle
        priceTitleLabel.numberOfLines = 1
        priceTitleLabel.lineBreakMode = .byTruncatingTail

        let priceSubtitleLabel = UILabel()
        priceSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceSubtitleLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        priceSubtitleLabel.textColor = Palette.rowSubtitle
        priceSubtitleLabel.numberOfLines = 1
        priceSubtitleLabel.lineBreakMode = .byTruncatingTail
        priceSubtitleLabel.text = Copy.priceSubtitle

        configureDetailRow(priceRow,
                           icon: SlotConfirmedViewController.icon(["ic_dirham_icon", "dirham-currency", "ic_aed"]),
                           iconSide: 18,
                           titleLabel: priceTitleLabel,
                           subtitleLabel: priceSubtitleLabel)

        let divider1 = makeDivider()
        let divider2 = makeDivider()
        configureDivider(priceDivider)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 0

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
        stack.setCustomSpacing(12, after: trainerRow)
        stack.addArrangedSubview(priceDivider)
        stack.setCustomSpacing(12, after: priceDivider)
        stack.addArrangedSubview(priceRow)

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: Metric.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Metric.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Metric.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Metric.cardPadding)
        ])
        return card
    }

    /// `glass_pill_bg`: 8dp radius (**not** a full capsule — which is why this does
    /// not reuse `PillChipView`, whose corner radius is always half its height),
    /// `#33FAFAFA` hairline, transparent fill, and a `#33FFFFFF` radial sheen.
    /// Android centres that sheen at x = 0.3; `.topCenter` (0.5) is the nearest
    /// origin the shared `CAGradientPoint` enum offers, and `.bottomRight` gives the
    /// falloff a non-zero horizontal radius (a `.bottomCenter` edge would collapse
    /// the radial ellipse to a zero-width sliver).
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

        // Wrapper keeps the pill hugging the leading edge inside a `.fill` stack.
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

    /// 38pt icon tile + two-line text block, with Android's 4dp vertical row padding.
    func makeDetailRow(icon: UIImage?,
                       iconSide: CGFloat,
                       titleLabel: UILabel,
                       subtitleLabel: UILabel) -> UIStackView {
        let row = UIStackView()
        configureDetailRow(row,
                           icon: icon,
                           iconSide: iconSide,
                           titleLabel: titleLabel,
                           subtitleLabel: subtitleLabel)
        return row
    }

    /// Configures an already-allocated row, so the price row can be a stored
    /// property (it has to be toggled after `applyPrice()` runs).
    func configureDetailRow(_ row: UIStackView,
                            icon: UIImage?,
                            iconSide: CGFloat,
                            titleLabel: UILabel,
                            subtitleLabel: UILabel) {
        let iconTile = makeIconTile(image: icon, iconSide: iconSide)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        // `.fill` so a long studio name truncates inside the row instead of
        // overflowing past the card edge.
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 2
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        // Android `paddingVertical="4dp"` on each row.
        row.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        row.addArrangedSubview(iconTile)
        row.addArrangedSubview(textStack)
    }

    /// Android's `location_icon_bg`: 38dp rounded square, top-down
    /// `#1AFFFFFF -> #101113` wash with a `#101113` hairline.
    func makeIconTile(image: UIImage?, iconSide: CGFloat) -> UIView {
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
            iconView.widthAnchor.constraint(equalToConstant: iconSide),
            iconView.heightAnchor.constraint(equalToConstant: iconSide)
        ])
        return tile
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

        let warningIcon = UIImageView(image: SlotConfirmedViewController.icon(["ic_warning_hex_16", "info-hexagon"], systemFallback: "exclamationmark.triangle.fill")?
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

        // Wrapper keeps the icon+heading hugging the leading edge inside a `.fill` stack.
        let headingWrapper = UIView()
        headingWrapper.translatesAutoresizingMaskIntoConstraints = false
        headingWrapper.addSubview(headingRow)

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.numberOfLines = 0
        bodyLabel.attributedText = SlotConfirmedViewController.importantNoteText()

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

    // MARK: Small builders

    func makeDivider() -> UIView {
        let line = UIView()
        configureDivider(line)
        return line
    }

    func configureDivider(_ line: UIView) {
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = Palette.divider
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}

// MARK: - Attributed copy + icon resolution

private extension SlotConfirmedViewController {

    static func paragraphStyle(lineSpacing: CGFloat, alignment: NSTextAlignment) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.alignment = alignment
        return style
    }

    /// Port of the `warningHtml` string: the trailing "48 hours." is bold gold.
    static func importantNoteText() -> NSAttributedString {
        // Android `lineSpacingExtra="3dp"`.
        let paragraph = paragraphStyle(lineSpacing: 3, alignment: .left)

        let base: [NSAttributedString.Key: Any] = [
            .font: AppFont.regular.size(12.0, familyName: familyFunnelSans),
            .foregroundColor: Palette.noteBody,
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

    /// First bundled asset wins.
    ///
    /// Every candidate list leads with the *Android* drawable name, so importing the
    /// real glyphs later under those exact names upgrades the screen with no code
    /// change; the tail entries are the closest already-bundled iOS assets.
    ///
    /// `chevron-right`, `dirham-currency` and `info-hexagon` are real rendered
    /// Group-Classes assets (not placeholders) and are tried first. Everything
    /// else falls to a system symbol rather than an unrelated bundled icon.
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
