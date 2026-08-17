//
//  SlotOpenViewController.swift
//  MyPT
//
//  "A spot opened up" — shown when a class spot has just become available:
//  to every waitlisted member at once (they all get the same push
//  notification when a booking is cancelled - `WaitlistNotifier::notifyAll`),
//  and to a brand-new user browsing a class that currently has an open spot
//  with people already waiting.
//
//  Everyone who taps "Confirm This Spot" has an equal shot regardless of
//  waitlist position: the backend serializes the claim with a row lock, so
//  whoever's request actually lands first wins
//  (`GroupClassService::claimOpenSpot`). The 10-minute countdown here is
//  purely a client-side urgency cue - it does not hold or expire the spot
//  server-side.
//
//  Android reference (ground truth for layout, copy and logic):
//    app/src/main/java/co/com/mypt/UpComingClasses/SlotOpenActivity.kt
//    app/src/main/res/layout/activity_slot_open.xml
//
//  Entry points:
//    · push notification tap (`waitlist_spot_available` deep link)
//    · `GroupTrainingDetailViewController`, when class-detail reports an open
//      seat with a non-empty waitlist queue
//

import UIKit

// MARK: - TimerRingView

/// Draws a gold ring around the countdown pill that shrinks as [progress]
/// falls from 1 (full time remaining) to 0 (expired) - traces the pill's
/// actual rounded-rect outline via a `UIBezierPath` + `strokeEnd`, so it
/// matches the pill's real corner radius exactly regardless of size.
final class TimerRingView: UIView {

    var progress: CGFloat = 1.0 {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressLayer.strokeEnd = max(0, min(1, progress))
            CATransaction.commit()
        }
    }

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let strokeWidthPx: CGFloat = 2

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

        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = GroupClassColor.cardStroke.color.withAlphaComponent(0.10).cgColor
        trackLayer.lineWidth = strokeWidthPx
        layer.addSublayer(trackLayer)

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = GroupClassColor.cardStroke.color.cgColor
        progressLayer.lineWidth = strokeWidthPx
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 1.0
        layer.addSublayer(progressLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }

        let inset = strokeWidthPx / 2
        let rect = bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 2)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        CATransaction.commit()
    }
}

// MARK: - SlotOpenViewController

final class SlotOpenViewController: CommonViewController {

    // MARK: Input

    var scheduleId: String = ""
    var classTitle: String = "Morning Flow Yoga"
    var classTime: String = "Wed, 9 Jul • 7-8 AM"
    var classLocation: String = "Silicon Oasis"
    var trainerName: String = ""
    /// Whatever the launching screen already knows, seeded into the labels
    /// immediately so there's no visible flash from the placeholder copy to
    /// the real counts while `fetchClassDetail()` is still in flight.
    var seedRemainingSeats: Int?
    var seedWaitlistCount: Int?
    var latitude: Double = GroupClassCardFormatter.fallbackLatitude
    var longitude: Double = GroupClassCardFormatter.fallbackLongitude
    /// From class-detail's `price` - only needed for the PAYMENT_REQUIRED
    /// redirect (a paid/mixed class's open spot can't be claimed for free).
    private var classPrice: String = ""
    private var studioLat: Double = 0
    private var studioLng: Double = 0
    /// Populated from class-detail's `class_id` once the fetch lands - this
    /// screen only ever starts with a scheduleId (from the push payload or
    /// the launching Detail screen). Realtime subscription starts once set.
    private var classId: Int = 0
    /// Handle for this screen's GroupClassStore subscription.
    private var storeObserverToken: UUID?

    /// Fires when the claim succeeds - the caller pushes Slot Confirmed.
    var onClaimed: ((_ classTitle: String, _ time: String, _ location: String, _ trainerName: String) -> Void)?

    // MARK: Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let closeButtonDiameter: CGFloat = 40
        static let heroWidth: CGFloat = 277.5
        static let heroHeight: CGFloat = 370
        // A *smaller* inset brings the text closer to the image's bottom edge
        // (further from the figures above it), not further away - Android
        // shipped 50pt first and it visibly collided with the figures; 22pt
        // is what actually cleared them once tested on device.
        static let headlineBottomInset: CGFloat = 22
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let iconTileSide: CGFloat = 38
        static let ctaHeight: CGFloat = 48
        static let notNowHeight: CGFloat = 42
        static let timerPillWidth: CGFloat = 104
        static let timerPillHeight: CGFloat = 37
    }

    private enum Palette {
        static let headline = UIColor(hex: "#FAFAFA")
        static let subtext = UIColor(hex: "#959595")
        static let divider = UIColor.white.withAlphaComponent(0.10)
        static let cardFill = UIColor(hex: "#18191C")
        static let cardStroke = UIColor(hex: "#232323")
        static let tileFill = UIColor(hex: "#101113")
        static let pillStroke = UIColor(hex: "#FAFAFA")
        static let pillText = UIColor(hex: "#F0F0F0")
        static let classTitleColor = UIColor.white
        static let classDateTime = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let rowTitle = UIColor.white
        static let rowSubtitle = UIColor.white.withAlphaComponent(0.4)
        static let urgencyCardFill = UIColor(hex: "#201200")
        static let urgencyCardStroke = GroupClassColor.gold.color.withAlphaComponent(0.30)
        static let urgencyTitle = UIColor.white
        static let urgencySubtitle = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
        static let timerPillFill = GroupClassColor.cardStroke.color.withAlphaComponent(0.10)
        static let timerText = UIColor.white
        static let ctaInk = UIColor(hex: "#131416")
        static let notNowStroke = UIColor.white.withAlphaComponent(0.10)
        static let notNowFill = UIColor(hex: "#1D1E1D")
        static let notNowText = UIColor(hex: "#FAFAFA")
    }

    private enum Copy {
        static let categoryPill = "GROUP CLASS"
        static let trainerPlaceholder = "Trainer: Sara K."
        static let trainerSubtitle = "Certified MyPT Trainer"
        static let urgencyTitle = "Confirm before anyone else!"
        static let confirmCTA = "CONFIRM THIS SPOT"
        static let notNowCTA = "NOT NOW"
        static let distancePlaceholder = "2.1 km away"
    }

    // MARK: Views

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let closeButton = GlassCircularIconButton()
    private let heroImageView = UIImageView()
    private let headlineLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let urgencyTitleLabel = UILabel()
    private let urgencySubtitleLabel = UILabel()
    private let timerLabel = UILabel()
    private let timerRing = TimerRingView()

    private let classTitleLabel = UILabel()
    private let classDateTimeLabel = UILabel()
    private let locationTitleLabel = UILabel()
    private let locationDistanceLabel = UILabel()
    private let trainerTitleLabel = UILabel()
    private let categoryPillLabel = UILabel()

    private let footerView = UIView()
    private let confirmButton = GradientCTAButton()
    private let notNowButton = UIButton(type: .system)

    // MARK: State

    private var countdownTimer: Timer?
    private var remainingSeconds: Int = 0
    private let totalCountdownSeconds = 10 * 60

    // MARK: Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Scoped to this screen only, not the shared GroupClassColor.bg token
        // (#000A04) other screens still use - matches Android's rendered look here.
        view.backgroundColor = UIColor(hex: "#020402")
        buildLayout()
        populateUI()
        startCountdown()
        fetchClassDetail()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromRealtime()
    }

    deinit {
        countdownTimer?.invalidate()
    }

    // MARK: Realtime (via GroupClassStore)

    private func subscribeToRealtime() {
        guard classId > 0 else { return }
        GroupClassStore.shared.startWatching(classId: classId)
        guard storeObserverToken == nil else { return }
        storeObserverToken = GroupClassStore.shared.observe { [weak self] event in
            self?.handleStoreEvent(event)
        }
    }

    private func unsubscribeFromRealtime() {
        GroupClassStore.shared.removeObserver(storeObserverToken)
        storeObserverToken = nil
        guard classId > 0 else { return }
        GroupClassStore.shared.stopWatching(classId: classId)
    }

    /// The open spot(s) this screen is racing the user to claim can be taken
    /// by someone else while they're deciding - live count keeps the number
    /// honest instead of letting them tap Confirm on a stale "1 slot open"
    /// that's actually already gone (handleClaimResponse()'s SPOT_TAKEN
    /// branch already covers that outcome gracefully, but showing the real
    /// number is better than relying on it).
    private func handleStoreEvent(_ event: GroupClassStoreEvent) {
        switch event {
        case .seatsChanged(let eventClassId, let eventScheduleId),
             .waitlistChanged(let eventClassId, let eventScheduleId):
            // Both numbers on this screen are live: the open-slot count is the
            // spot being raced for, and the queue length is the urgency
            // ("N people are waiting in queue. Book before they do.") - a
            // queue that empties out while the member hesitates should stop
            // pressuring them, and one that grows should.
            guard eventClassId == classId, eventScheduleId == Int(scheduleId) else { return }
            let live = GroupClassStore.shared.liveState(classId: classId, scheduleId: Int(scheduleId))
            // Only ever re-render the count itself. This used to swap the
            // headline out for a "this spot has been claimed" message once the
            // count hit zero, which read as the member's OWN action having
            // failed (or already been confirmed) when all it meant was that the
            // live number moved. handleClaimResponse()'s SPOT_TAKEN branch is
            // what actually tells them the race was lost.
            if let remaining = live.remainingSeats, remaining > 0 {
                headlineLabel.text = "\(remaining) \(remaining == 1 ? "slot" : "slots") \(remaining == 1 ? "is" : "are") open!"
            }
            if let waitlistCount = live.waitlistCount {
                let memberWord = waitlistCount == 1 ? "member" : "members"
                subtitleLabel.text = "This spot is available to the next \(waitlistCount) \(memberWord) on the waitlist"
                urgencySubtitleLabel.text = "\(waitlistCount) people are waiting in queue. Book before they do."
            }

        case .accessChanged(let eventClassId), .classStatusChanged(let eventClassId):
            // This screen is only valid while the spot is still claimable by
            // THIS member for free: `fetchClassDetail()` holds that gate and
            // redirects to the detail screen when it isn't (a paid/mixed
            // class a non-member can't claim would otherwise leave them
            // tapping "Confirm This Spot" for a guaranteed PAYMENT_REQUIRED).
            // An admin flipping access - or cancelling/completing the class -
            // mid-countdown has to re-run that gate, and since free-for-this-
            // member resolves against the member's own subscription, only a
            // real fetch can answer it.
            guard eventClassId == classId else { return }
            fetchClassDetail()

        default:
            break
        }
    }

    // MARK: Populate

    private func populateUI() {
        applySlotCounts(remainingSeats: seedRemainingSeats ?? 1, waitlistCount: seedWaitlistCount ?? 5)

        classTitleLabel.text = classTitle
        classDateTimeLabel.text = classTime
        locationTitleLabel.text = classLocation

        let trimmedTrainer = trainerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTrainer.isEmpty {
            trainerTitleLabel.text = trimmedTrainer.hasPrefix("Trainer:") ? trimmedTrainer : "Trainer: \(trimmedTrainer)"
        }
    }

    /// Persisted per schedule so the countdown keeps running across
    /// re-entries (notification tap, back-and-forth navigation) instead of
    /// restarting at 10:00 every time this screen opens. Mirrors Android's
    /// `slot_open_timer_expiry_<scheduleId>` SharedPreferences key.
    private func startCountdown() {
        let defaults = UserDefaults.standard
        let expiryKey = "slot_open_timer_expiry_\(scheduleId)"
        let now = Date().timeIntervalSince1970
        var expiry = defaults.double(forKey: expiryKey)

        if expiry <= now {
            expiry = now + Double(totalCountdownSeconds)
            defaults.set(expiry, forKey: expiryKey)
        }

        remainingSeconds = max(0, Int(expiry - now))
        updateTimerDisplay()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            self.remainingSeconds -= 1
            if self.remainingSeconds <= 0 {
                self.remainingSeconds = 0
                self.updateTimerDisplay()
                timer.invalidate()
                return
            }
            self.updateTimerDisplay()
        }
    }

    private func updateTimerDisplay() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerLabel.text = String(format: "%02d:%02d mins", minutes, seconds)
        timerRing.progress = CGFloat(remainingSeconds) / CGFloat(totalCountdownSeconds)
    }

    // MARK: Networking

    private func fetchClassDetail() {
        guard !scheduleId.isEmpty else { return }
        let params: [String: String] = [
            "schdule_id": scheduleId,
            "lat": "\(latitude)",
            "long": "\(longitude)"
        ]
        UpcomingClassVM.classDetailsApi(inputParams: params, isShowLoader: false) { [weak self] result in
            guard let self = self, let detail = result?.data else { return }
            DispatchQueue.main.async {
                // This screen is reachable directly from the "spot available" push
                // notification (`AppDelegate.routeNotificationTap`). Double-booked
                // members (willSpecialWaitlist) used to redirect away to the detail
                // screen right here, before the member ever saw this countdown/
                // urgency screen the notification promised - now handled inline
                // instead (see claimSpotTapped()'s SPECIAL_WAITLIST_DEFERRED
                // branch), matching what tapping the push notification should
                // actually open.
                let waitlistType = (detail.waitlistType ?? "").lowercased()
                let isSpecialWaitlistType = waitlistType == "special" || waitlistType == "extra"

                let normalWaitlistCount = GroupClassCardFormatter.intValue(detail.normalWaitlistCount, defaultValue: -1)
                let specialWaitlistCount = GroupClassCardFormatter.intValue(detail.specialWaitlistCount, defaultValue: 0)
                let waitlistCountVal = GroupClassCardFormatter.intValue(detail.waitlistCount, defaultValue: 0)
                let onlyExtraBooking = detail.onlyExtraBooking ?? detail.onlySpecialWaitlist ?? detail.isOnlyExtraBooking ?? detail.isOnlySpecialWaitlist ?? (
                    (isSpecialWaitlistType && normalWaitlistCount <= 0) ||
                    (specialWaitlistCount > 0 && specialWaitlistCount >= waitlistCountVal) ||
                    (normalWaitlistCount == 0 && waitlistCountVal > 0)
                )

                let hasContestedNormalWaitlist = !onlyExtraBooking && (
                    normalWaitlistCount >= 0 ? normalWaitlistCount > 0 :
                    (specialWaitlistCount > 0 ? waitlistCountVal > specialWaitlistCount : waitlistCountVal > 0)
                )

                if onlyExtraBooking || !hasContestedNormalWaitlist {
                    self.redirectToDetailScreen(detail: detail)
                    return
                }

                // A paid (or mixed-and-not-covered) class gets this screen too -
                // the open spot and the queue racing for it are just as real
                // whether or not the seat costs money. There used to be a
                // redirect to the detail screen here on the grounds that
                // claim-open-spot always answers PAYMENT_REQUIRED for these
                // members, but handleClaimResponse() already handles exactly
                // that reply by routing to the payment page - so the redirect
                // only cost the member the countdown and the queue context, to
                // end up at the same place one extra tap later.

                if let newClassId = detail.classId, newClassId > 0 {
                    self.classId = newClassId
                    self.subscribeToRealtime()
                }

                if let name = detail.className, !name.isEmpty { self.classTitleLabel.text = name }
                if let time = detail.time, !time.isEmpty { self.classDateTimeLabel.text = time }
                if let location = detail.location, !location.isEmpty { self.locationTitleLabel.text = location }
                self.studioLat = detail.studioLat?.doubleValue ?? 0
                self.studioLng = detail.studioLng?.doubleValue ?? 0
                // Device location first, server-passed distance only as a
                // last-resort fallback - see
                // GroupClassCardFormatter.distanceText()'s doc comment.
                let resolvedDistance = GroupClassCardFormatter.distanceText(
                    userLat: nil, userLng: nil,
                    studioLat: self.studioLat, studioLng: self.studioLng,
                    fallback: detail.distance
                )
                if !resolvedDistance.isEmpty { self.locationDistanceLabel.text = resolvedDistance }
                // Also syncs the trainerName PROPERTY, not just the label -
                // a claim launched from just a scheduleId (e.g. a
                // notification tap) starts with trainerName empty, and
                // every downstream screen (SpotTaken/ClassPayment/
                // DoubleBookingSheet) forwards self.trainerName, not
                // whatever the label happens to say. Without this, the
                // label looks right here but the name is silently dropped
                // one screen later.
                if let trainer = detail.name, !trainer.isEmpty {
                    self.trainerTitleLabel.text = "Trainer: \(trainer)"
                    self.trainerName = trainer
                }
                if let category = detail.classType, !category.isEmpty { self.categoryPillLabel.text = category.uppercased() }

                let capacity = detail.capacity ?? 1
                let booked = GroupClassCardFormatter.intValue(detail.bookedCount, defaultValue: 0)
                let remainingSeats = max(1, capacity - booked)
                let waitlistCount = GroupClassCardFormatter.intValue(detail.waitlistCount, defaultValue: 5)
                self.applySlotCounts(remainingSeats: remainingSeats, waitlistCount: waitlistCount)

                if let price = detail.price?.value, !price.isEmpty { self.classPrice = price }
            }
        }
    }

    /// Replaces this screen in place in the navigation stack (not just a push on
    /// top) so there's no back-button path that returns to Slot Open either.
    private func redirectToDetailScreen(detail: ClassDetailsModel) {
        guard let navigationController = self.navigationController else { return }

        var tapThrough = GroupClassTapThroughData()
        tapThrough.scheduleId = scheduleId
        tapThrough.title = detail.className?.isEmpty == false ? (detail.className ?? classTitle) : classTitle
        tapThrough.time = detail.time?.isEmpty == false ? (detail.time ?? classTime) : classTime
        tapThrough.location = detail.location?.isEmpty == false ? (detail.location ?? classLocation) : classLocation
        tapThrough.userLat = latitude
        tapThrough.userLng = longitude

        let detailVC = GroupTrainingDetailViewController()
        detailVC.tapThrough = tapThrough
        detailVC.hidesBottomBarWhenPushed = true

        var stack = navigationController.viewControllers
        if let index = stack.firstIndex(of: self) {
            stack[index] = detailVC
        } else {
            stack.append(detailVC)
        }
        navigationController.setViewControllers(stack, animated: true)
    }

    private func applySlotCounts(remainingSeats: Int, waitlistCount: Int) {
        let slotWord = remainingSeats == 1 ? "slot" : "slots"
        let verb = remainingSeats == 1 ? "is" : "are"
        headlineLabel.text = "\(remainingSeats) \(slotWord) \(verb) open!"

        let memberWord = waitlistCount == 1 ? "member" : "members"
        subtitleLabel.text = "This spot is available to the next \(waitlistCount) \(memberWord) on the waitlist"
        urgencySubtitleLabel.text = "\(waitlistCount) people are waiting in queue. Book before they do."
    }

    // MARK: Actions

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func notNowTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func confirmTapped() {
        confirmSpot(confirmSpecialWaitlist: false)
    }

    private func confirmSpot(confirmSpecialWaitlist: Bool) {
        guard !scheduleId.isEmpty else { return }
        TapticEngine.selection.feedback()
        confirmButton.isEnabled = false

        UpcomingClassVM.claimOpenSpotApi(scheduleId: scheduleId, confirmSpecialWaitlist: confirmSpecialWaitlist) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.confirmButton.isEnabled = true
                self.handleClaimResponse(result)
            }
        }
    }

    private func handleClaimResponse(_ result: BookClassBaseModel?) {
        guard let result = result else {
            AlertHelper.shared.showCustomeAlert(title: "", message: "Could not claim this spot. Please try again.", actions: ["OK"], completion: nil)
            return
        }

        if result.status == true {
            let time = result.data?.timing ?? classDateTimeLabel.text ?? classTime
            let location = result.data?.location ?? locationTitleLabel.text ?? classLocation
            let trainer = result.data?.trainer?.name ?? trainerName
            onClaimed?(classTitleLabel.text ?? classTitle, time, location, trainer)
            return
        }

        if result.code == "SPECIAL_WAITLIST_CONFIRM_REQUIRED" {
            // Nothing created yet - the backend only replies this without
            // confirmSpecialWaitlist set. Show the sheet as a real choice;
            // only its own "Join Waitlist" tap re-calls
            // confirmSpot(confirmSpecialWaitlist: true), which is the sole
            // path that actually creates the row. Any other dismissal
            // (X/swipe/tap outside) sends nothing at all.
            var input = DoubleBookingSheetInput()
            input.classTitle = classTitleLabel.text ?? classTitle
            input.classTime = classDateTimeLabel.text ?? classTime
            input.classLocation = locationTitleLabel.text ?? classLocation
            input.trainerName = trainerName
            input.distance = locationDistanceLabel.text ?? ""
            input.studioLat = studioLat
            input.studioLng = studioLng
            input.notifyHours = result.specialWaitlist?.notificationWindowHours?.intValue ?? 3
            DoubleBookingSheetViewController.present(from: self, input: input) { [weak self] in
                self?.confirmSpot(confirmSpecialWaitlist: true)
            }
            return
        }

        if result.code == "SPECIAL_WAITLIST_DEFERRED" {
            // Reached only after confirmSpecialWaitlist: true was sent - the
            // row is genuinely committed now, with real consent already
            // given via the sheet tap that triggered this call. Post-hoc
            // display here, matching the already-confirmed path elsewhere.
            var input = DoubleBookingSheetInput()
            input.classTitle = classTitleLabel.text ?? classTitle
            input.classTime = classDateTimeLabel.text ?? classTime
            input.classLocation = locationTitleLabel.text ?? classLocation
            input.trainerName = trainerName
            input.distance = locationDistanceLabel.text ?? ""
            input.studioLat = studioLat
            input.studioLng = studioLng
            input.notifyHours = result.specialWaitlist?.notificationWindowHours?.intValue ?? 3
            DoubleBookingSheetViewController.present(from: self, input: input)
            return
        }

        if result.code == "SPOT_TAKEN" {
            // The backend guarantees this user is on the waitlist now (it adds
            // them if they weren't already) - a real status screen instead of
            // an alert + straight push to WaitlistConfirmedViewController.
            let controller = SpotTakenViewController()
            controller.classTitle = classTitleLabel.text ?? classTitle
            controller.classTime = classDateTimeLabel.text ?? classTime
            controller.classLocation = locationTitleLabel.text ?? classLocation
            controller.trainerName = trainerName
            controller.distance = locationDistanceLabel.text ?? ""
            controller.studioLat = studioLat
            controller.studioLng = studioLng
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
            return
        }

        if result.code == "BLACKLISTED" {
            let controller = BookingPausedViewController()
            controller.reason = result.blacklistDetail?.reason ?? "2 consecutive no-shows for group classes"
            controller.resumesOn = result.blacklistDetail?.resumesOn ?? "12 August 2026, 6:00 PM"
            controller.hoursRemaining = result.blacklistDetail?.hoursRemaining?.value ?? "24"
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
            return
        }

        if result.code == "PAYMENT_REQUIRED" {
            // This open spot is on a paid/mixed class this member isn't covered
            // for free - route to payment instead of leaving them stuck on a
            // claim screen that can never succeed for them.
            AlertHelper.shared.showCustomeAlert(title: "", message: result.msg ?? "This class requires payment.", actions: ["OK"]) { [weak self] _ in
                guard let self = self else { return }
                let controller = ClassPaymentViewController()
                controller.scheduleId = self.scheduleId
                controller.classTitle = self.classTitleLabel.text ?? self.classTitle
                controller.classTime = self.classDateTimeLabel.text ?? self.classTime
                controller.classLocation = self.locationTitleLabel.text ?? self.classLocation
                controller.trainerName = self.trainerName
                controller.classPrice = (!self.classPrice.isEmpty && self.classPrice != "0") ? self.classPrice : "50.00"
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return
        }

        AlertHelper.shared.showCustomeAlert(title: "", message: result.msg ?? "Something went wrong. Please try again.", actions: ["OK"], completion: nil)
    }
}

// MARK: - Layout

private extension SlotOpenViewController {

    func buildLayout() {
        buildFooter()
        buildScrollView()
    }

    func buildFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = .clear
        view.addSubview(footerView)

        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.bandThickness = 2
        confirmButton.configure(title: Copy.confirmCTA,
                                font: AppFont.semibold.size(16.0, familyName: familyFunnelSans),
                                titleColor: Palette.ctaInk)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        footerView.addSubview(confirmButton)

        notNowButton.translatesAutoresizingMaskIntoConstraints = false
        notNowButton.backgroundColor = Palette.notNowFill
        notNowButton.layer.cornerRadius = 8
        notNowButton.layer.borderWidth = 1
        notNowButton.layer.borderColor = Palette.notNowStroke.cgColor
        notNowButton.setTitle(Copy.notNowCTA, for: .normal)
        notNowButton.setTitleColor(Palette.notNowText, for: .normal)
        notNowButton.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        notNowButton.addTarget(self, action: #selector(notNowTapped), for: .touchUpInside)
        footerView.addSubview(notNowButton)

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            confirmButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 12),
            confirmButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: Metric.horizontalInset),
            confirmButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -Metric.horizontalInset),
            confirmButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight),

            notNowButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 8),
            notNowButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: Metric.horizontalInset),
            notNowButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -Metric.horizontalInset),
            notNowButton.heightAnchor.constraint(equalToConstant: Metric.notNowHeight),
            notNowButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    func buildScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        // No bounce/rubber-band overscroll - Android's equivalent fix was
        // disabling the stretch-glow effect, which otherwise briefly reveals
        // the hero image's raw rectangular bounds past its blended edge.
        scrollView.bounces = false
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

        let closeRow = makeCloseButtonRow()
        contentStack.addArrangedSubview(closeRow)
        contentStack.setCustomSpacing(12, after: closeRow)

        let heroBlock = makeHeroBlock()
        contentStack.addArrangedSubview(heroBlock)
        contentStack.setCustomSpacing(20, after: heroBlock)

        let urgencyCard = makeUrgencyCard()
        contentStack.addArrangedSubview(urgencyCard)
        contentStack.setCustomSpacing(16, after: urgencyCard)

        contentStack.addArrangedSubview(makeDetailsCard())
    }

    // MARK: Close button

    func makeCloseButtonRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Same glass container the class detail screen's share icon uses -
        // `GlassCircularIconButton` reproduces `circle_action_btn_bg` exactly.
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.configure(icon: SlotOpenViewController.closeIcon(), diameter: Metric.closeButtonDiameter)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        container.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: container.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            closeButton.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: Metric.closeButtonDiameter),
            closeButton.heightAnchor.constraint(equalToConstant: Metric.closeButtonDiameter)
        ])
        return container
    }

    /// Draws the X directly (two diagonal strokes) rather than shipping a new
    /// asset, matching the spec's inline SVG.
    static func closeIcon() -> UIImage? {
        let size = CGSize(width: 24, height: 24)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 7, y: 17))
            path.addLine(to: CGPoint(x: 17, y: 7))
            path.move(to: CGPoint(x: 17, y: 17))
            path.addLine(to: CGPoint(x: 7, y: 7))
            path.lineWidth = 2
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            UIColor.white.setStroke()
            path.stroke()
            context.cgContext.setLineWidth(2)
        }
    }

    /// Draws the clock glyph directly (circle + hands), matching the spec's
    /// inline SVG, rather than shipping a new asset.
    static func clockIcon() -> UIImage? {
        let size = CGSize(width: 16, height: 16)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let gold = GroupClassColor.gold.color
            gold.setStroke()

            let circle = UIBezierPath(arcCenter: CGPoint(x: 8, y: 8), radius: 6.67, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            circle.lineWidth = 1
            circle.stroke()

            let hands = UIBezierPath()
            hands.move(to: CGPoint(x: 10.47, y: 10.12))
            hands.addLine(to: CGPoint(x: 8.41, y: 8.89))
            hands.addCurve(to: CGPoint(x: 7.75, y: 7.74), controlPoint1: CGPoint(x: 8.05, y: 8.67), controlPoint2: CGPoint(x: 7.75, y: 8.16))
            hands.addLine(to: CGPoint(x: 7.75, y: 5.01))
            hands.lineWidth = 1
            hands.lineCapStyle = .round
            hands.lineJoinStyle = .round
            hands.stroke()
        }
    }

    // MARK: Hero image + overlapping headline

    /// Hero photo blended into the screen background via `lightenBlendMode`,
    /// same effect as CSS `mix-blend-mode: lighten` - the photo's own
    /// near-black background merges seamlessly into the screen background
    /// instead of showing a rectangle edge. Headline + subtitle move as one
    /// block, 50pt up from the image's bottom edge - grouping them together
    /// (rather than letting the subtitle follow in normal flow after the
    /// image) keeps the gap between them a fixed 8pt regardless of image
    /// height.
    func makeHeroBlock() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.image = UIImage(named: "waitlist-spot-open-hero")
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.backgroundColor = .clear
        // `isOpaque` defaults to true on an image-backed layer, which lets Core
        // Animation skip blending against whatever is already drawn beneath it -
        // the exact case `compositingFilter` needs to do its work. Android's
        // equivalent (`applyLightenBlend`) has the same requirement: it forces
        // `LAYER_TYPE_HARDWARE` before applying the `PorterDuff.Mode.LIGHTEN`
        // paint, for the same reason - the blend can't happen against a layer
        // that's being drawn as a flat opaque bitmap.
        heroImageView.layer.isOpaque = false
        heroImageView.layer.compositingFilter = "lightenBlendMode"
        container.addSubview(heroImageView)

        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        headlineLabel.textColor = Palette.headline
        headlineLabel.textAlignment = .center
        headlineLabel.numberOfLines = 1

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        subtitleLabel.textColor = Palette.subtext
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [headlineLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 8
        container.addSubview(textStack)

        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: container.topAnchor),
            heroImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            heroImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            heroImageView.widthAnchor.constraint(equalToConstant: Metric.heroWidth),
            heroImageView.heightAnchor.constraint(equalToConstant: Metric.heroHeight),

            textStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textStack.bottomAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: -Metric.headlineBottomInset)
        ])
        return container
    }

    // MARK: Urgency card

    func makeUrgencyCard() -> UIView {
        let card = GlassCardView(cornerRadius: 12)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.urgencyCardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.urgencyCardStroke
        card.strokeAlpha = 1.0
        card.showsSheen = false

        let clockIcon = UIImageView(image: SlotOpenViewController.clockIcon())
        clockIcon.translatesAutoresizingMaskIntoConstraints = false
        clockIcon.contentMode = .scaleAspectFit

        urgencyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        urgencyTitleLabel.font = AppFont.medium.size(15.0, familyName: familyClashDisplay)
        urgencyTitleLabel.textColor = Palette.urgencyTitle
        urgencyTitleLabel.numberOfLines = 0
        urgencyTitleLabel.text = Copy.urgencyTitle
        urgencyTitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        urgencySubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        urgencySubtitleLabel.font = AppFont.regular.size(12.5, familyName: familyFunnelSans)
        urgencySubtitleLabel.textColor = Palette.urgencySubtitle
        urgencySubtitleLabel.numberOfLines = 0
        urgencySubtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        urgencySubtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Title gets its own full-width row (icon + title, nothing else
        // competing for space); the timer pill drops to the row below and
        // shares that row with the subtitle only - matches Android's
        // two-row urgency card.
        let titleRow = UIStackView(arrangedSubviews: [clockIcon, urgencyTitleLabel])
        titleRow.translatesAutoresizingMaskIntoConstraints = false
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 12

        let timerPillView = makeTimerPill()

        let subtitleRow = UIStackView(arrangedSubviews: [urgencySubtitleLabel, timerPillView])
        subtitleRow.translatesAutoresizingMaskIntoConstraints = false
        subtitleRow.axis = .horizontal
        subtitleRow.alignment = .center
        subtitleRow.spacing = 12

        // Indented to align under the title text, not the icon - same 28pt
        // (16pt icon + 12pt spacing) Android's own marginStart uses.
        let subtitleContainer = UIView()
        subtitleContainer.translatesAutoresizingMaskIntoConstraints = false
        subtitleContainer.addSubview(subtitleRow)
        NSLayoutConstraint.activate([
            subtitleRow.topAnchor.constraint(equalTo: subtitleContainer.topAnchor),
            subtitleRow.bottomAnchor.constraint(equalTo: subtitleContainer.bottomAnchor),
            subtitleRow.leadingAnchor.constraint(equalTo: subtitleContainer.leadingAnchor, constant: 28),
            subtitleRow.trailingAnchor.constraint(equalTo: subtitleContainer.trailingAnchor)
        ])

        let column = UIStackView(arrangedSubviews: [titleRow, subtitleContainer])
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 6

        card.addSubview(column)
        NSLayoutConstraint.activate([
            clockIcon.widthAnchor.constraint(equalToConstant: 16),
            clockIcon.heightAnchor.constraint(equalToConstant: 16),

            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 88),
            column.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            column.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            column.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            column.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    /// Solid fill + a ring drawn on top that shrinks around the pill's own
    /// outline as time runs out.
    func makeTimerPill() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let fill = GlassCardView(cornerRadius: Metric.timerPillHeight / 2)
        fill.translatesAutoresizingMaskIntoConstraints = false
        fill.fillColor = GroupClassColor.cardStroke.color
        fill.fillAlpha = 0.10
        fill.strokeAlpha = 0
        fill.showsSheen = false
        container.addSubview(fill)

        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
        timerLabel.textColor = Palette.timerText
        timerLabel.textAlignment = .center
        timerLabel.text = "10:00 mins"
        fill.addSubview(timerLabel)

        timerRing.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(timerRing)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: Metric.timerPillWidth),
            container.heightAnchor.constraint(equalToConstant: Metric.timerPillHeight),

            fill.topAnchor.constraint(equalTo: container.topAnchor),
            fill.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            fill.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            fill.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            timerLabel.centerXAnchor.constraint(equalTo: fill.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: fill.centerYAnchor),

            timerRing.topAnchor.constraint(equalTo: container.topAnchor),
            timerRing.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            timerRing.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            timerRing.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    // MARK: Class detail card (identical pattern to Slot/Waitlist Confirmed)

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
        locationTitleLabel.numberOfLines = 2
        locationTitleLabel.lineBreakMode = .byWordWrapping

        locationDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        locationDistanceLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        locationDistanceLabel.textColor = Palette.rowSubtitle
        locationDistanceLabel.numberOfLines = 1
        locationDistanceLabel.lineBreakMode = .byTruncatingTail
        locationDistanceLabel.text = Copy.distancePlaceholder

        let locationRow = makeDetailRow(icon: SlotOpenViewController.icon(["ic_location_pin_small"], systemFallback: "mappin.and.ellipse"),
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

        let trainerRow = makeDetailRow(icon: SlotOpenViewController.icon(["ic_trainer_running_18"], systemFallback: "figure.run"),
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
}

// MARK: - Icon resolution

private extension SlotOpenViewController {
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
