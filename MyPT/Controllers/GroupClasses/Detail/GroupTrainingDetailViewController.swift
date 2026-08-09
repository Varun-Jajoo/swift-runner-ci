//
//  GroupTrainingDetailViewController.swift
//  MyPT
//
//  Group Training Detail — the core screen of the Group Classes module.
//
//  Android reference (ground truth for every rule in here):
//    app/src/main/java/co/com/mypt/UpComingClasses/GroupTrainingDetailActivity.kt
//    app/src/main/res/layout/activity_group_training_detail.xml
//
//  The screen paints itself instantly from the tap-through payload the home
//  carousel hands over (`GroupClassTapThroughData`, Phase 3) and *then* refreshes
//  from `GET api/class-detail` — the same two-stage population Android performs
//  with its intent extras.
//
//  CTA state machine (ported 1:1 from `GroupTrainingDetailActivity`):
//    1. `isAlreadyBooked`   -> "BOOKED"            -> Slot Confirmed, read-only (Phase 6, LIVE)
//    2. `isWaitlistMode`    -> "JOIN WAITLIST"     -> join-waitlist flow    (Phase 9)
//    3. `!isFreeForUser`    -> "PROCEED TO PAYMENT"-> Class Payment screen  (Phase 7)
//    4. otherwise           -> "BOOK SLOT"         -> Confirm Slot sheet    (Phase 5, LIVE)
//  States 1 and 4 are wired to their real destinations; states 2-3 each carry an
//  explicit, clearly-marked stub below (never a silently wrong navigation).
//

import UIKit

final class GroupTrainingDetailViewController: CommonViewController {

    // MARK: - Input

    /// Payload handed over by `GroupClassNavigator.pushDetail(from:data:)`.
    /// Set before the screen is pushed; everything below reads from it until the
    /// `class-detail` refresh lands.
    var tapThrough = GroupClassTapThroughData()

    // MARK: - Mutable class state
    //
    // Field-for-field mirror of `GroupTrainingDetailActivity`'s properties so the
    // ported logic stays readable next to the Kotlin.

    private var scheduleId: String = ""
    /// Skips the redundant re-fetch on the first viewWillAppear right after
    /// viewDidLoad already fetched. Set true once that first fetch fires.
    private var hasFetchedOnce: Bool = false
    private var classTitle: String = ""
    private var classTime: String = ""
    private var classLocation: String = ""
    private var classImage: String = ""
    private var trainerName: String = ""
    private var trainerImage: String = ""
    private var classPrice: String = ""
    private var classAccess: String = "mixed"
    private var bookedCount: Int = 0
    private var totalCapacity: Int = 20
    private var startEnd: String = ""
    private var lat: Double = GroupClassCardFormatter.fallbackLatitude
    private var lng: Double = GroupClassCardFormatter.fallbackLongitude
    private var studioLat: Double = 0
    private var studioLng: Double = 0
    private var isAlreadyBooked: Bool = false
    private var isAlreadyWaitlisted: Bool = false
    private var isWaitlistMode: Bool = false
    private var isFreeForUser: Bool = false
    /// Set from `class-detail`'s response — the backend can report a user as
    /// blacklisted before any booking attempt is made, and the CTA has to catch
    /// that up front rather than only reacting to a failed `book-class` POST.
    private var isUserBlacklisted: Bool = false
    private var blacklistReason: String = "2 consecutive no-shows for group classes"
    private var blacklistResumesOn: String = ""
    private var blacklistDaysRemaining: String = ""
    /// A spot open with people still waiting auto-redirects to Slot Open at
    /// most once per visit to this screen, so tapping "Not Now" there doesn't
    /// loop straight back here. Mirrors Android's `checkedSlotOpenRedirect`.
    private var checkedSlotOpenRedirect: Bool = false
    /// Live values from the class-detail API, kept at class scope (not just
    /// local to `updateProgressAndWaitlistState`/the fetch handler) so
    /// `ctaTapped()` can also route to Slot Open instead of the booking sheet
    /// when a spot is open but people are already waiting on it.
    private var remainingSeats: Int = 0
    private var waitlistCount: Int = 0
    /// From class-detail's `will_special_waitlist` - true means tapping Book
    /// Slot / Join Waitlist will trigger the free-booking spam guard, so the
    /// double-booking sheet must show BEFORE any booking-confirm UI, not after.
    private var willSpecialWaitlist: Bool = false
    /// From class-detail's `special_waitlist_notify_hours` - used to pre-show
    /// the double-booking sheet before the real book/join API call.
    private var specialWaitlistNotifyHours: Int = 3
    /// The full last-fetched class-detail response, kept around so
    /// `ctaTapped()` can read fields (waitlist_type, normal/special waitlist
    /// counts, only-extra-booking flags) that aren't already mirrored into
    /// their own dedicated stored properties above.
    private var detail: ClassDetailsModel?
    /// Distance without the trailing " away" — the value Android forwards to the
    /// downstream booking screens.
    private var currentDistance: String = ""

    // MARK: - Layout constants

    private enum Metric {
        static let heroHeight: CGFloat = 364
        static let heroFadeHeight: CGFloat = 218
        static let horizontalInset: CGFloat = 16
        static let navButtonDiameter: CGFloat = 40
        static let iconTileSide: CGFloat = 38
        static let progressBarWidth: CGFloat = 59
        static let whyCardWidth: CGFloat = 190
        static let galleryCardSize = CGSize(width: 180, height: 250)
        static let ctaHeight: CGFloat = 48
        static let ctaMinWidth: CGFloat = 140
    }

    /// Hex values taken straight from `activity_group_training_detail.xml`; only
    /// the module-wide slots (backgrounds, progress ramps, badge golds) live in
    /// `GroupClassColor` — these are local to this screen.
    private enum Palette {
        static let hairline = UIColor.white.withAlphaComponent(0.07)      // #12FFFFFF
        static let moreHairline = UIColor.white.withAlphaComponent(0.10)  // #1AFFFFFF
        static let dateTime = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let spotsText = UIColor(hex: "#F0F0F0")
        static let rowTitle = UIColor(hex: "#F0F0F0")
        static let distance = UIColor.white.withAlphaComponent(0.4)       // #66FFFFFF
        static let doorsNote = UIColor(hex: "#9B9B9C")
        static let cardSurface = UIColor(hex: "#131416")
        static let cardStroke = UIColor(hex: "#101113")
        static let cardBody = UIColor(hex: "#898384")
        static let aboutText = UIColor.white.withAlphaComponent(0.6)      // #99FFFFFF
        static let aboutFade = UIColor(hex: "#0C0C0C")
        static let readMoreFill = UIColor(hex: "#1D1E1D")
        static let pillStroke = UIColor(hex: "#FAFAFA").withAlphaComponent(0.2) // #33FAFAFA
        static let pillText = UIColor(hex: "#F0F0F0")
        static let bottomBarTopBorder = UIColor(hex: "#2A8DFF")
        static let perSession = UIColor.white.withAlphaComponent(0.4)     // #66FFFFFF
        static let ctaInk = UIColor(hex: "#141514")
        static let waitlistBannerFill = UIColor(hex: "#FFF8DF")
        static let waitlistBannerInk = UIColor(hex: "#663800")
        /// `spot_progress_bar_gold` (`#FFCC33 -> #586400`) differs from the module
        /// badge gold that `SpotAvailabilityState.gold` carries, so the gold state
        /// is overridden through `SpotProgressBarView.setFillColors(_:)` — exactly
        /// what `GroupClassCardCollectionViewCell` does for the same reason.
        static let goldProgressFill = [UIColor(hex: "#FFCC33"), UIColor(hex: "#586400")]
    }

    /// Copy that is hard-coded in the Android layout (no API backing).
    private enum Copy {
        static let aboutFallback = "What to Expect (this will be displayed as about this class in the app if not use current default)"
        static let aboutPlaceholder = "Start your day with intention. This 60-minute vinyasa flow builds core strength, improves flexibility, and clears the mind before the day begins. Suitable for all levels — modifications provided."
        static let readMore = "READ MORE ABOUT THE CLASS"
        static let showLess = "SHOW LESS ABOUT THE CLASS"
        static let trainerSubtitle = "Certified Trainer · MyPT"
        static let waitlistBanner = "We'll notify you as soon as a spot becomes available"
        static let perSession = "PER SESSION"
        static let defaultPillType = "GROUP CLASS"
    }

    // MARK: - Views

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let heroContainer = UIView()
    private let heroImageView = UIImageView()
    private let heroFadeView = GradientFadeView()
    private let backButton = GlassCircularIconButton()
    private let favouriteButton = GlassCircularIconButton()
    private let shareButton = GlassCircularIconButton()
    private var heroNavTopConstraint: NSLayoutConstraint?

    private let categoryPill = PillChipView()
    private let locationPill = PillChipView()
    private let typePill = PillChipView()

    private let titleLabel = UILabel()
    private let dateTimeLabel = UILabel()
    private let spotsLabel = UILabel()
    private let progressBar = SpotProgressBarView(barHeight: 2)
    private var detailProgressBarWidthConstraint: NSLayoutConstraint?

    private let locationRow = UIView()
    private let locationTitleLabel = UILabel()
    private let locationDistanceLabel = UILabel()
    private let doorsOpenLabel = UILabel()

    private let whyScrollView = UIScrollView()
    private let whyDotsView = GroupClassCarouselDotsView()
    private let whyDotsPill = UIView()

    private let aboutLabel = UILabel()
    private let aboutContainerView = UIView()
    private var contentStackView: UIStackView?
    /// Rows for these two + the gallery cards below are built once in
    /// buildScrollView() (called from viewDidLoad, before fetchClassDetail()
    /// resolves) using whatever `detail` is at that moment - nil, since the
    /// network call hasn't returned yet. Unlike titleLabel/heroImageView etc.
    /// (single persistent views apply(detail:) can just re-set .text/.image
    /// on), these are collections of rows/cards with no stored reference, so
    /// without one apply(detail:) has nothing to repopulate and the real API
    /// data never reaches the screen. Stored here so refreshWhatToBring() /
    /// refreshThingsToKnow() / refreshMediaGallery() can clear + rebuild them
    /// once the real data actually arrives.
    private let whatToBringStack = UIStackView()
    private let thingsToKnowStack = UIStackView()
    /// Header + scrollview wrapped in one vertical stack rather than added to
    /// `column` as two separate arranged subviews toggled via `.isHidden` -
    /// UIStackView's custom-spacing-after-a-hidden-view behavior is
    /// unreliable (the surrounding gap can collapse to zero), which is
    /// exactly what happened here. refreshMediaGallery() inserts/removes
    /// this single wrapper as one unit instead, which has no such quirk.
    private let mediaGallerySectionView = UIStackView()
    private let mediaGalleryScrollView = UIScrollView()
    private let mediaGalleryCardsStack = UIStackView()
    /// Bottom scrim over the collapsed About copy. Hidden while expanded, and
    /// hidden entirely when the copy is short enough not to need truncating.
    private let aboutFadeView = GradientFadeView()
    private let readMoreButton = UIButton(type: .system)
    private var isAboutExpanded = false
    /// Lines shown while collapsed. Anything longer gets the scrim + READ MORE.
    private static let aboutCollapsedLineLimit = 5

    private let trainerAvatarView = UIImageView()
    private let trainerNameLabel = UILabel()

    private let waitlistBanner = UIView()
    private let bottomBar = UIView()
    /// Android's `tvPriceLabel` — normally the static "PER SESSION" caption above
    /// `priceLabel`, repurposed by `applyPostBookingCta()` to show dynamic
    /// "See you on..." / "We'll notify you..." copy once booked/waitlisted.
    private let perSessionLabel = UILabel()
    private let priceLabel = UILabel()
    private let ctaButton = GradientCTAButton()

    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = GroupClassColor.bg.color
        readTapThroughData()
        buildLayout()
        populateUI()
        setupWhyCarouselIndicator()

        // Android: `if (scheduleId.isNotBlank()) fetchClassDetail()`.
        if !scheduleId.isEmpty {
            hasFetchedOnce = true
            fetchClassDetail()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true

        // willSpecialWaitlist/isAlreadyBooked/isAlreadyWaitlisted are snapshotted
        // once per fetch and read again at CTA-tap time. Without a re-fetch here,
        // booking/waitlisting a DIFFERENT class on another screen and coming back
        // to this still-alive screen leaves those flags stale - the normal confirm
        // sheet can show when the server would now say "special", since nothing
        // ever told this screen its own snapshot is out of date. Skips the very
        // first appearance since viewDidLoad already just fetched.
        if hasFetchedOnce && !scheduleId.isEmpty {
            fetchClassDetail()
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // The nav row lives inside the hero (so it scrolls away with it, matching
        // Android's `layout_marginTop="40dp"` inside the hero FrameLayout), which
        // means it cannot use the safe-area guide directly.
        heroNavTopConstraint?.constant = view.safeAreaInsets.top + 12
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Needs the label's resolved width, so it can only run after layout.
        updateAboutOverflowState()
    }

    // MARK: - Tap-through ingestion

    /// Port of the `intent.getStringExtra(...)` block in `onCreate`.
    private func readTapThroughData() {
        scheduleId = tapThrough.scheduleId
        classTitle = tapThrough.title.isEmpty ? GroupClassCardFormatter.defaultTitle : tapThrough.title
        classTime = tapThrough.time
        classLocation = tapThrough.location
        classImage = tapThrough.image
        trainerName = tapThrough.trainedBy
        trainerImage = tapThrough.trainerImage
        classPrice = tapThrough.price
        classAccess = GroupClassCardFormatter.resolvedAccess(tapThrough.access)

        // Android: free -> true, paid -> false, anything else (mixed) -> is_member.
        isFreeForUser = resolveIsFreeForUser(access: classAccess, isMember: tapThrough.isMember)

        bookedCount = tapThrough.bookedCount
        totalCapacity = tapThrough.totalCapacity
        // Seeded from whatever the launching card already knew, so the CTA
        // doesn't flash "Book Slot" before flipping to "BOOKED" / "ON
        // WAITLIST" once fetchClassDetail() confirms it a moment later.
        isAlreadyBooked = tapThrough.isBooked
        isAlreadyWaitlisted = tapThrough.isWaitlisted
        startEnd = tapThrough.startEnd
        lat = tapThrough.userLat == 0 ? GroupClassCardFormatter.fallbackLatitude : tapThrough.userLat
        lng = tapThrough.userLng == 0 ? GroupClassCardFormatter.fallbackLongitude : tapThrough.userLng
        studioLat = tapThrough.studioLat
        studioLng = tapThrough.studioLng
    }

    /// `access == "free"` -> free, `access == "paid"` -> paid, `mixed` (or an
    /// unknown value) -> free only for active members.
    private func resolveIsFreeForUser(access: String, isMember: Bool) -> Bool {
        let access = access.lowercased()
        if access == "free" { return true }
        if access == "paid" { return false }
        return isMember
    }

    // MARK: - Populate (instant, from tap-through data)

    /// Port of `populateUI()`.
    private func populateUI() {
        titleLabel.text = classTitle

        let rawTime = (classTime.contains("•") || classTime.contains("-") || classTime.rangeOfCharacter(from: .letters) != nil) ? classTime : (startEnd.isEmpty ? classTime : startEnd)
        dateTimeLabel.text = GroupClassCardFormatter.formatTimeForUI(rawTime)

        locationTitleLabel.text = classLocation
        if !classLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            locationPill.text = GroupClassCardFormatter.cleanStudioName(classLocation).uppercased()
        }
        adjustGlassPillsOverflow()

        doorsOpenLabel.attributedText = doorsOpenText(for: rawTime)

        applyHeroImage(classImage)

        if !trainerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            trainerNameLabel.text = trainerName
        }
        applyTrainerImage(trainerImage)

        // Android recomputes the distance from the studio coordinates and only
        // falls back to the string it was handed.
        updateDetailDistance(studioLat: studioLat, studioLng: studioLng, fallback: tapThrough.distance)

        applyInitialPriceLabel()

        updateProgressAndWaitlistState(booked: bookedCount, totalCapacity: totalCapacity)

        // Seeded booked/waitlisted state takes priority over the generic
        // capacity-based CTA above - same override the live fetch applies
        // once it confirms this from the server.
        if isAlreadyBooked {
            applyPostBookingCta(booked: true)
        } else if isAlreadyWaitlisted {
            applyPostBookingCta(booked: false)
        }
    }

    /// Android's initial (intent-driven) price branch — note it is *not* the same
    /// ladder the API branch uses (that one also treats plain `is_member` as free).
    private func applyInitialPriceLabel() {
        let cleanInitialPrice = cleanedPrice(classPrice)
        if isFreeForUser {
            priceLabel.text = "Free for members"
        } else if classAccess.lowercased() == "free" {
            priceLabel.text = "FREE"
        } else if !cleanInitialPrice.isEmpty, cleanInitialPrice != "0", cleanInitialPrice != "0.00" {
            priceLabel.text = "AED \(cleanInitialPrice)"
        } else {
            priceLabel.text = ""
        }
    }

    private func cleanedPrice(_ raw: String) -> String {
        return raw.replacingOccurrences(of: "AED", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func applyHeroImage(_ path: String) {
        // The app bundles no group-class cover placeholder (the home card cell has
        // the same gap); the hero's solid fill is the empty state.
        if let url = GroupClassCardFormatter.absoluteImageURL(path) {
            heroImageView.loadImage(urlString: url, placeholder: nil)
        } else {
            heroImageView.image = nil
        }
    }

    private func applyTrainerImage(_ path: String) {
        // Android hands the raw value straight to Glide; `absoluteImageURL` passes
        // absolute URLs through untouched and additionally resolves bare storage
        // paths, so it is a strict superset of that behaviour.
        if let url = GroupClassCardFormatter.absoluteImageURL(path) {
            trainerAvatarView.loadImage(urlString: url, placeholder: nil)
        }
    }

    // MARK: - Capacity -> progress bar + CTA label

    /// Port of `updateProgressAndWaitlistState(booked, totalCap)`.
    ///
    /// Android derives `remaining` from `capacity - booked` here (it deliberately
    /// does **not** read the list model's `remaining_seats`), so that derived value
    /// is what gets fed to the shared threshold helper. The thresholds themselves —
    /// `>= 100% or remaining <= 0` red + waitlist, `> 80%` red, `> 40%` gold, else
    /// green — already live in `GroupClassCardFormatter.availability`.
    private func updateProgressAndWaitlistState(booked: Int, totalCapacity: Int) {
        let remaining = totalCapacity - booked
        // Was previously only a local, so ctaTapped() and the slot-open
        // redirect check both read a stale/default value instead of what
        // this API call just fetched.
        remainingSeats = remaining
        let percentage = totalCapacity > 0 ? (Double(booked) / Double(totalCapacity)) * 100.0 : 0.0

        let availability = GroupClassCardFormatter.availability(bookedCount: booked,
                                                               totalCapacity: totalCapacity,
                                                               remainingSeats: remaining)
        spotsLabel.text = availability.text
        progressBar.setProgress(availability.progress, state: availability.state)
        if case .gold = availability.state {
            progressBar.setFillColors(Palette.goldProgressFill)
        }
        let textWidth = spotsLabel.intrinsicContentSize.width
        detailProgressBarWidthConstraint?.constant = max(Metric.progressBarWidth, ceil(textWidth))

        // Android's default label flips purely on `isFreeForUser`.
        let defaultBookingText = isFreeForUser ? "BOOK SLOT" : "PROCEED TO PAYMENT"

        if percentage >= 100 || remaining <= 0 {
            isWaitlistMode = true
            waitlistBanner.isHidden = false
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 56, right: 0)
            setCTATitle("JOIN WAITLIST")
        } else {
            isWaitlistMode = false
            waitlistBanner.isHidden = true
            scrollView.contentInset = .zero
            setCTATitle(defaultBookingText)
        }

        // GroupClassCardCollectionViewCell replaces the capacity bar with a
        // "BOOKED"/"ON WAITLIST" badge for classes this user already
        // booked/waitlisted - this screen never did, leaving the bar showing
        // a capacity color unrelated to this user's own status. Applied
        // after the capacity branch above so isWaitlistMode/waitlistBanner/
        // the CTA title it sets (genuinely about the class's own capacity,
        // not this user) stay untouched.
        if isAlreadyBooked {
            progressBar.isHidden = true
            spotsLabel.text = "BOOKED"
            spotsLabel.font = AppFont.bold.size(10.0, familyName: familyFunnelSans)
            spotsLabel.textColor = UIColor(hex: "#32AE5C")
        } else if isAlreadyWaitlisted {
            progressBar.isHidden = true
            spotsLabel.text = "ON WAITLIST"
            spotsLabel.font = AppFont.bold.size(10.0, familyName: familyFunnelSans)
            spotsLabel.textColor = UIColor(hex: "#FFCC33")
        } else {
            progressBar.isHidden = false
            spotsLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            spotsLabel.textColor = Palette.spotsText
        }
    }

    /// Re-measures the button's `wrap_content`+`minWidth` width on every title
    /// change. Without an explicit relayout pass here the button only ever grows
    /// (e.g. "BOOK SLOT" -> "PROCEED TO PAYMENT" after the detail refresh lands)
    /// and never visibly shrinks back down for a shorter title, since nothing
    /// else on screen forces `bottomBar` to re-run layout in between.
    private func setCTATitle(_ title: String) {
        resetCTAStyle()
        ctaButton.configure(title: title,
                            font: AppFont.medium.size(14.0, familyName: familyFunnelSans),
                            titleColor: Palette.ctaInk)
        UIView.animate(withDuration: 0.2) {
            self.bottomBar.layoutIfNeeded()
        }
    }

    /// `tvPriceLabel` keeps the same font/color/kerning whether it's showing the
    /// static "PER SESSION" caption or `applyPostBookingCta()`'s dynamic copy -
    /// Android applies `letterSpacing="0.06"` in the XML itself, so it's not lost
    /// when the Kotlin code swaps `.text` at runtime, and neither should this be.
    private func setPerSessionLabelText(_ text: String) {
        perSessionLabel.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: AppFont.regular.size(10.0, familyName: familyFunnelSans),
                .foregroundColor: Palette.perSession,
                .kern: 0.6
            ]
        )
    }

    /// Undoes `applyPostBookingCta()`'s dark "VIEW" re-skin. Called at the top of
    /// `setCTATitle()` so every OTHER path (paid/waitlist/default booking) always
    /// starts from the normal white-gradient look, regardless of what state the
    /// button was left in before.
    private func resetCTAStyle() {
        ctaButton.bandThickness = 2
        ctaButton.bodyStartColor = UIColor(hex: "#FFFFFF")
        ctaButton.bodyEndColor = UIColor(hex: "#F0F0F0")
        ctaButton.layer.borderWidth = 0
        ctaButton.setTrailingIcon(
            GroupTrainingDetailViewController.icon(["ic_chevron_right_16_dark", "chevron-right"], systemFallback: "chevron.right"),
            tint: Palette.ctaInk)
    }

    /// Port of `applyPostBookingCta(booked)`: swaps the bottom bar's price
    /// section + CTA from the bookable state to the post-action "VIEW" state -
    /// same button whether fully booked or just on the waitlist, only the two
    /// text lines above it differ.
    ///
    /// NOTE (matches Android's actual current behaviour, not a bug introduced
    /// here): `fetchClassDetail()`'s generic price refresh runs AFTER this and
    /// unconditionally overwrites `priceLabel` (Android's `tvPriceMember`) back
    /// to the plain price/"Free for members" text - only `perSessionLabel`
    /// (Android's `tvPriceLabel`) durably keeps the "See you on..."/"We'll
    /// notify you..." copy. Ported as-is for parity.
    private func applyPostBookingCta(booked: Bool) {
        setPerSessionLabelText(booked ? buildSeeYouOnText() : "We'll notify you if a slot opens")
        priceLabel.text = booked ? "Your class is booked" : "You're on the waitlist"

        if booked {
            waitlistBanner.isHidden = true
        }

        ctaButton.bandThickness = 0
        // `bg_btn_not_now`'s fill (#1D1E1D) - same flat dark already used for
        // the About section's "SHOW LESS" pill (`Palette.readMoreFill`).
        ctaButton.bodyStartColor = Palette.readMoreFill
        ctaButton.bodyEndColor = Palette.readMoreFill
        ctaButton.layer.cornerRadius = ctaButton.cornerRadius
        ctaButton.layer.borderWidth = 1
        ctaButton.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor
        ctaButton.configure(title: "VIEW",
                            font: AppFont.medium.size(14.0, familyName: familyFunnelSans),
                            titleColor: .white)
        ctaButton.setTrailingIcon(
            GroupTrainingDetailViewController.icon(["ic_chevron_right_16", "chevron-right"], systemFallback: "chevron.right"),
            tint: UIColor.white.withAlphaComponent(0.4))
        UIView.animate(withDuration: 0.2) {
            self.bottomBar.layoutIfNeeded()
        }
    }

    /// "Thu, 27 Aug • 7-8 AM" -> "See you on 27 Aug at 7:00 AM!"
    private func buildSeeYouOnText() -> String {
        let formatted = dateTimeLabel.text ?? ""
        guard !formatted.isEmpty else { return "See you soon!" }

        let parts = formatted.components(separatedBy: "•").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard parts.count == 2 else { return "See you soon!" }

        let datePart = parts[0].components(separatedBy: ",").dropFirst().joined(separator: ",").trimmingCharacters(in: .whitespacesAndNewlines)
        let timePart = parts[1]
        let startHour = timePart.components(separatedBy: "-").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let amPm = String(timePart.trimmingCharacters(in: .whitespacesAndNewlines).suffix(2))

        guard !datePart.isEmpty, !startHour.isEmpty else { return "See you soon!" }
        return "See you on \(datePart) at \(startHour):00 \(amPm)!"
    }

    // MARK: - Distance

    /// Port of `updateDetailDistance(sLat, sLng, fallback)`. Same fix as
    /// Android: pass nil here instead of `lat`/`lng` so `distanceText`
    /// always checks the device's real last-known location first - `lat`/
    /// `lng` are just whatever the caller (e.g. the home banner) forwarded,
    /// defaulting to a fixed Dubai coordinate when it forwarded none, which
    /// used to silently win over the real device location for every screen
    /// that didn't pass real coordinates through. `lat`/`lng` stay as-is for
    /// the classDetail API request and the onward booking-screen handoff
    /// below - only this distance display should prefer live location.
    private func updateDetailDistance(studioLat: Double, studioLng: Double, fallback: String) {
        let text = GroupClassCardFormatter.distanceText(userLat: nil,
                                                        userLng: nil,
                                                        studioLat: studioLat,
                                                        studioLng: studioLng,
                                                        fallback: fallback)
        locationDistanceLabel.text = text
        currentDistance = text.replacingOccurrences(of: " away", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Doors open (class start − 10 minutes, computed client-side)

    /// Port of `getDynamicDoorsOpenHtml(timeStr)`. The HTML Android renders is
    /// `Doors open at <b><font color='#FFFFFF'>hh:mm a</font></b> — arrive 10 min early`.
    private func doorsOpenText(for timeStr: String) -> NSAttributedString {
        let time = doorsOpenTime(for: timeStr)

        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.semibold.size(14.0, familyName: familyFunnelSans),
            .foregroundColor: Palette.doorsNote
        ]
        let emphasisAttributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.bold.size(14.0, familyName: familyFunnelSans),
            .foregroundColor: UIColor.white
        ]

        let result = NSMutableAttributedString(string: "Doors open at ", attributes: baseAttributes)
        result.append(NSAttributedString(string: time, attributes: emphasisAttributes))
        result.append(NSAttributedString(string: " — arrive 10 min early", attributes: baseAttributes))
        return result
    }

    /// Extracts the class start hour from the display string and subtracts 10
    /// minutes, wrapping across midnight exactly like the Kotlin
    /// `(hr * 60 + min - 10 + 1440) % 1440`.
    private func doorsOpenTime(for timeStr: String) -> String {
        let trimmed = timeStr.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "06:50 AM" }

        // `Wed, 9 Jul • 7-8 AM` -> `7-8 AM`; a bullet-less string is used as-is.
        let timePart: String
        if let bullet = trimmed.range(of: "•") {
            timePart = String(trimmed[bullet.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            timePart = trimmed
        }

        let isPm = timePart.range(of: "PM", options: .caseInsensitive) != nil

        // Kotlin's `substringBefore("-")` yields the whole string when absent.
        let beforeDash: String
        if let dash = timePart.range(of: "-") {
            beforeDash = String(timePart[..<dash.lowerBound])
        } else {
            beforeDash = timePart
        }

        // Equivalent of `replace("[^0-9:]".toRegex(), "")`.
        let startPart = String(beforeDash.filter { $0.isNumber || $0 == ":" })
            .trimmingCharacters(in: .whitespacesAndNewlines)

        var hour = 7
        var minute = 0
        if startPart.contains(":") {
            let parts = startPart.split(separator: ":", omittingEmptySubsequences: false)
            hour = Int(parts[0]) ?? 7
            minute = parts.count > 1 ? (Int(parts[1]) ?? 0) : 0
        } else {
            hour = Int(startPart) ?? 7
        }

        if isPm && hour < 12 { hour += 12 }
        if !isPm && hour == 12 { hour = 0 }

        let totalMinutes = (hour * 60 + minute - 10 + 1440) % 1440
        let doorsHour = totalMinutes / 60
        let doorsMinute = totalMinutes % 60
        let amPm = doorsHour >= 12 ? "PM" : "AM"
        let hour12 = (doorsHour % 12 == 0) ? 12 : (doorsHour % 12)

        return String(format: "%02d:%02d %@", hour12, doorsMinute, amPm)
    }

    // MARK: - Network

    /// `GET api/class-detail?lat=&long=&schdule_id=` — the exact query trio Android
    /// builds, issued through the app's existing `UpcomingClassVM` wrapper.
    func fetchClassDetail() {
        let params: [String: String] = [
            "lat": "\(lat)",
            "long": "\(lng)",
            "schdule_id": scheduleId
        ]

        UpcomingClassVM.classDetailsApi(inputParams: params, isShowLoader: false) { [weak self] result in
            guard let self = self,
                  result?.status == true,
                  let detail = result?.data else { return }

            DispatchQueue.main.async {
                self.apply(detail: detail, topLevelCode: result?.code, topLevelMsg: result?.msg, topLevelIsBlacklisted: result?.isBlacklisted)
            }
        }
    }

    /// Port of the `runOnUiThread { ... }` body inside `fetchClassDetail()`.
    /// Ordering matters: capacity is folded in first, then the booked/waitlisted
    /// overrides, then price/access — and only then is the capacity-driven label
    /// recomputed with the freshly-resolved `isFreeForUser`.
    private func apply(detail: ClassDetailsModel, topLevelCode: String?, topLevelMsg: String?, topLevelIsBlacklisted: Bool?) {
        self.detail = detail
        // buildScrollView() (viewDidLoad, before this ever fires) built these
        // three sections against a nil `detail`, so they need an explicit
        // refresh now that the real data is in - see the note above
        // whatToBringStack's declaration.
        refreshWhatToBring()
        refreshThingsToKnow()
        refreshMediaGallery()

        // Port of the 5-way OR Android checks in `fetchClassDetail()`'s success
        // branch: `detail.is_blacklisted` (nested) OR the same key at the
        // response's top level OR `code == "BLACKLISTED"` OR "blacklisted"/"paused"
        // appearing in the top-level `msg`.
        let topLevelMessage = (topLevelMsg ?? "").lowercased()
        let isBlacklisted = (detail.isBlacklisted == true)
            || (topLevelIsBlacklisted == true)
            || (topLevelCode == "BLACKLISTED")
            || topLevelMessage.contains("blacklisted")
            || topLevelMessage.contains("paused")
        if isBlacklisted {
            isUserBlacklisted = true
            blacklistReason = detail.reason ?? "2 consecutive no-shows for group classes"
            blacklistResumesOn = detail.resumesOn ?? ""
            blacklistDaysRemaining = detail.daysRemaining?.value ?? ""
        }

        let name = (detail.className ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !name.isEmpty {
            classTitle = name
            titleLabel.text = name
        }

        let apiTime = (detail.time ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let apiDate = (detail.date ?? detail.startDate ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedTime: String
        if classTime.contains("•") && !apiTime.contains("-") {
            resolvedTime = classTime
        } else if !apiTime.isEmpty {
            resolvedTime = GroupClassCardFormatter.formatTimeForUI(apiTime, dateStr: apiDate)
        } else if !classTime.isEmpty {
            resolvedTime = GroupClassCardFormatter.formatTimeForUI(classTime, dateStr: apiDate)
        } else {
            resolvedTime = GroupClassCardFormatter.formatTimeForUI(startEnd, dateStr: apiDate)
        }
        if !resolvedTime.isEmpty {
            dateTimeLabel.text = resolvedTime
        }
        // Deliberately NOT resolvedTime: that one is display-formatted (may
        // early-return a "Fri, 14 Aug • 7-8 AM" string via formatTimeForUI's
        // "•" shortcut), whereas doorsOpenText()/pushSlotOpen need a raw,
        // parseable time string - reusing resolvedTime here would silently
        // break the doors-open display.
        let effectiveTime = apiTime.isEmpty ? (startEnd.isEmpty ? classTime : startEnd) : apiTime

        let apiTrainerName = (detail.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !apiTrainerName.isEmpty {
            trainerName = apiTrainerName
            trainerNameLabel.text = apiTrainerName
        }

        let apiTrainerImage = (detail.profile ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !apiTrainerImage.isEmpty {
            trainerImage = apiTrainerImage
            applyTrainerImage(apiTrainerImage)
        }

        let apiImage = (detail.classProfile ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !apiImage.isEmpty {
            classImage = apiImage
            applyHeroImage(apiImage)
        } else {
            heroImageView.image = nil
        }

        let description = (detail.classDescription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        aboutLabel.text = description.isEmpty ? Copy.aboutFallback : description

        let apiCategory = (detail.classCategory ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !apiCategory.isEmpty {
            categoryPill.text = apiCategory.uppercased()
        }

        let apiLocation = (detail.location ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !apiLocation.isEmpty {
            classLocation = apiLocation
            locationTitleLabel.text = apiLocation
            locationPill.text = GroupClassCardFormatter.cleanStudioName(apiLocation).uppercased()
        }

        // Android: `optString("class_type", "GROUP CLASS")` — the default applies
        // when the key is missing, and the value is skipped when it is blank.
        let apiClassType = (detail.classType ?? Copy.defaultPillType).trimmingCharacters(in: .whitespacesAndNewlines)
        if !apiClassType.isEmpty {
            typePill.text = apiClassType.uppercased()
        }
        adjustGlassPillsOverflow()

        let apiStudioLat = GroupClassCardFormatter.doubleValue(detail.studioLat, defaultValue: studioLat)
        let apiStudioLng = GroupClassCardFormatter.doubleValue(detail.studioLng, defaultValue: studioLng)
        studioLat = apiStudioLat
        studioLng = apiStudioLng
        let apiDistance = (detail.distance ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let effectiveDistance: String
        if !currentDistance.isEmpty && !currentDistance.hasPrefix("0.0") && currentDistance.lowercased() != "away" {
            effectiveDistance = currentDistance
        } else if !apiDistance.isEmpty && !apiDistance.hasPrefix("0.0") && apiDistance.lowercased() != "away" {
            effectiveDistance = apiDistance
        } else if !tapThrough.distance.isEmpty && !tapThrough.distance.hasPrefix("0.0") {
            effectiveDistance = tapThrough.distance
        } else {
            effectiveDistance = currentDistance
        }
        updateDetailDistance(studioLat: apiStudioLat,
                             studioLng: apiStudioLng,
                             fallback: effectiveDistance)

        let apiCapacity = detail.capacity ?? totalCapacity
        let apiBookedCount = GroupClassCardFormatter.intValue(detail.bookedCount, defaultValue: bookedCount)
        if apiCapacity > 0 {
            totalCapacity = apiCapacity
            bookedCount = apiBookedCount
            updateProgressAndWaitlistState(booked: apiBookedCount, totalCapacity: apiCapacity)
        }

        isAlreadyBooked = detail.isBooked ?? false
        isAlreadyWaitlisted = detail.isWaitlisted ?? false

        // A spot is open with people still waiting - show the priority claim
        // screen instead of the normal detail page, both for a waitlisted
        // member whose turn it is and for a brand-new user walking in on an
        // open spot. Only auto-redirect once per visit.
        waitlistCount = GroupClassCardFormatter.intValue(detail.waitlistCount, defaultValue: 0)
        let waitlistType = (detail.waitlistType ?? "").lowercased()
        let isSpecialWaitlistType = waitlistType == "special" || waitlistType == "extra"

        let normalWaitlistCount = GroupClassCardFormatter.intValue(detail.normalWaitlistCount, defaultValue: -1)
        let specialWaitlistCount = GroupClassCardFormatter.intValue(detail.specialWaitlistCount, defaultValue: 0)
        let onlyExtraBooking = detail.onlyExtraBooking ?? detail.onlySpecialWaitlist ?? detail.isOnlyExtraBooking ?? detail.isOnlySpecialWaitlist ?? (
            (isSpecialWaitlistType && normalWaitlistCount <= 0) ||
            (specialWaitlistCount > 0 && specialWaitlistCount >= waitlistCount) ||
            (normalWaitlistCount == 0 && waitlistCount > 0)
        )
        let hasContestedNormalWaitlist = !onlyExtraBooking && (
            normalWaitlistCount >= 0 ? normalWaitlistCount > 0 :
            (specialWaitlistCount > 0 ? waitlistCount > specialWaitlistCount : waitlistCount > 0)
        )

        willSpecialWaitlist = detail.willSpecialWaitlist ?? false
        specialWaitlistNotifyHours = GroupClassCardFormatter.intValue(detail.specialWaitlistNotifyHours, defaultValue: 3)
        // Computed fresh here (not from `isFreeForUser`, which isn't recomputed
        // from this response until further below) - the claim-open-spot screen
        // only ever succeeds for a member this class is actually free for.
        // Routing a paid/mixed-non-member user there anyway meant every tap on
        // its Confirm button came back PAYMENT_REQUIRED - always a popup +
        // redirect to payment, never a successful claim.
        let freshIsFreeForUser = resolveIsFreeForUser(access: (detail.access ?? classAccess), isMember: detail.isMember ?? false)
        if !checkedSlotOpenRedirect {
            checkedSlotOpenRedirect = true
            // For a NON double booking user (!willSpecialWaitlist), do NOT
            // show the open slot screen if the waitlist has ONLY extra booking
            // members (onlyExtraBooking) - instead, they get the normal booking flow.
            if !isAlreadyBooked && remainingSeats > 0 && hasContestedNormalWaitlist && !willSpecialWaitlist && freshIsFreeForUser && !onlyExtraBooking {
                pushSlotOpen(time: effectiveTime)
            }
        }

        if isAlreadyBooked {
            applyPostBookingCta(booked: true)
        } else if isAlreadyWaitlisted {
            applyPostBookingCta(booked: false)
        } else {
            // A booking may have been removed server-side; recompute from capacity.
            updateProgressAndWaitlistState(booked: bookedCount, totalCapacity: totalCapacity)
        }

        doorsOpenLabel.attributedText = doorsOpenText(for: effectiveTime)

        let isMember = detail.isMember ?? false
        let access = (detail.access ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedAccess = access.isEmpty ? (classAccess.isEmpty ? "mixed" : classAccess) : access
        classAccess = resolvedAccess

        let price = (detail.price ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !price.isEmpty { classPrice = price }
        let cleanPrice = cleanedPrice(classPrice)

        isFreeForUser = resolveIsFreeForUser(access: resolvedAccess, isMember: isMember)

        // Guarded: this used to run unconditionally AFTER applyPostBookingCta()
        // above, silently overwriting "Your class is booked"/"You're on the
        // waitlist" back to "Free for members"/price on every single class-detail
        // refresh (matches an identical bug just fixed in Android's
        // GroupTrainingDetailActivity.kt - populateUI()'s seeded path never had
        // it, since there the price text is set BEFORE applyPostBookingCta()
        // runs, so only whichever booking hadn't finished its live refresh yet
        // ever showed the correct CTA).
        if !isAlreadyBooked && !isAlreadyWaitlisted {
            if isFreeForUser {
                priceLabel.text = "Free for members"
            } else if resolvedAccess.lowercased() == "free" {
                priceLabel.text = "FREE"
            } else if !cleanPrice.isEmpty, cleanPrice != "0", cleanPrice != "0.00" {
                priceLabel.text = "AED \(cleanPrice)"
            } else {
                priceLabel.text = ""
            }

            updateProgressAndWaitlistState(booked: bookedCount, totalCapacity: totalCapacity)
        }
    }

    // MARK: - Login gate

    /// The app's existing auth check: a missing/blank access token means the user
    /// is browsing as a guest (same token read `NetworkManager`'s request adapter
    /// and `CCAvenuePaymentViewController` perform).
    private var isAuthenticated: Bool {
        let token = (appUserDefaults.getAccessToken() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return !token.isEmpty && token != "-1"
    }

    /// Routes a guest to the app's existing login entry point (`MainViewController`,
    /// the phone-number screen — the iOS counterpart of Android's
    /// `PhoneNumberScreenActivity`). This is the same idiom the rest of the app
    /// uses for a guest-gated action, e.g. `ClassDetailsViewController`'s
    /// `.guestUser` branch.
    ///
    /// - Returns: `true` when the caller may proceed, `false` when the user was
    ///            sent to login.
    @discardableResult
    private func requireLogin() -> Bool {
        guard !isAuthenticated else { return true }
        AlertHelper.shared.showCustomeAlert(title: "", message: "Please log in to proceed", actions: ["OK"]) { _ in
            if appUserDefaults.clearUserDefault() {
                appSceneDelegate?.goToMainView()
            }
        }
        return false
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func favouriteTapped() {
        // Android's `btnHeart` has no click listener — the control is decorative
        // there too. Left as an explicit no-op rather than inventing behaviour.
        debugPrint("[GroupTrainingDetail] Favourite tapped — no destination defined on Android either.")
    }

    @objc private func shareTapped() {
        let rawTime = startEnd.isEmpty ? classTime : startEnd
        let formattedTime = GroupClassCardFormatter.formatTimeForUI(rawTime)
        var shareText = "Check out \(classTitle) on MyPT!\n"
        if !formattedTime.isEmpty {
            shareText += "Time: \(formattedTime)\n"
        }
        if !classLocation.isEmpty {
            shareText += "Location: \(classLocation)"
        }

        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        present(activityVC, animated: true)
    }

    @objc private func locationTapped() {
        openMapsDirections()
    }

    /// Port of `openGoogleMapsDirections()`, using the app's existing Google-Maps
    /// URL scheme + web-fallback pattern (see `GymDetailsViewController`).
    private func openMapsDirections() {
        guard studioLat != 0, studioLng != 0 else {
            AlertHelper.shared.showCustomeAlert(title: "", message: "Location not available", actions: ["OK"], completion: nil)
            return
        }

        let schemeURLString = "comgooglemaps://?daddr=\(studioLat),\(studioLng)&directionsmode=driving"
        if let url = URL(string: schemeURLString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }

        let webURLString = "https://www.google.com/maps/dir/?api=1&destination=\(studioLat),\(studioLng)"
        if let webURL = URL(string: webURLString) {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }

    /// The 4-state CTA. Branch order is Android's, verbatim — the blacklist
    /// check now runs first, ahead of every other branch (`btnBookSlot`'s
    /// listener checks `isUserBlacklisted` before `isAlreadyBooked`).
    @objc private func ctaTapped() {
        TapticEngine.selection.feedback()

        if isUserBlacklisted {
            pushBookingPaused()
            return
        }

        if isAlreadyBooked {
            pushSlotConfirmedReadOnly()
            return
        }

        let waitlistType = (detail?.waitlistType ?? "").lowercased()
        let isSpecialWaitlistType = waitlistType == "special" || waitlistType == "extra"

        let normalWaitlistCount = GroupClassCardFormatter.intValue(detail?.normalWaitlistCount, defaultValue: -1)
        let specialWaitlistCount = GroupClassCardFormatter.intValue(detail?.specialWaitlistCount, defaultValue: 0)
        let onlyExtraBooking = detail?.onlyExtraBooking ?? detail?.onlySpecialWaitlist ?? detail?.isOnlyExtraBooking ?? detail?.isOnlySpecialWaitlist ?? (
            (isSpecialWaitlistType && normalWaitlistCount <= 0) ||
            (specialWaitlistCount > 0 && specialWaitlistCount >= waitlistCount) ||
            (normalWaitlistCount == 0 && waitlistCount > 0)
        )
        let hasContestedNormalWaitlist = !onlyExtraBooking && (
            normalWaitlistCount >= 0 ? normalWaitlistCount > 0 :
            (specialWaitlistCount > 0 ? waitlistCount > specialWaitlistCount : waitlistCount > 0)
        )

        if remainingSeats > 0 && hasContestedNormalWaitlist && !willSpecialWaitlist && isFreeForUser && !onlyExtraBooking {
            // A spot is open with real normal waitlisted members waiting in line -
            // show the priority claim race screen. If the waitlist contains ONLY
            // extra booking members (onlyExtraBooking), non-double-booking users
            // proceed directly with the standard normal booking flow.
            pushSlotOpen(time: dateTimeLabel.text ?? classTime)
            return
        }

        if isAlreadyWaitlisted {
            let controller: UIViewController = willSpecialWaitlist ? DoubleBookingWaitlistConfirmedViewController() : WaitlistConfirmedViewController()
            if let dbVc = controller as? DoubleBookingWaitlistConfirmedViewController {
                dbVc.classTitle = classTitle
                dbVc.classTime = dateTimeLabel.text ?? ""
                dbVc.classLocation = classLocation
                dbVc.trainerName = trainerName
                dbVc.distance = locationDistanceLabel.text ?? currentDistance
                dbVc.hidesBottomBarWhenPushed = true
            } else if let wVc = controller as? WaitlistConfirmedViewController {
                wVc.classTitle = classTitle
                wVc.classTime = dateTimeLabel.text ?? ""
                wVc.classLocation = classLocation
                wVc.trainerName = trainerName
                wVc.distance = locationDistanceLabel.text ?? currentDistance
                wVc.hidesBottomBarWhenPushed = true
            }
            navigationController?.pushViewController(controller, animated: true)
            return
        }

        if isWaitlistMode {
            // Android performs the token check inside `joinWaitlistDirectly` before
            // anything else, so the gate stays on this path.
            guard requireLogin() else { return }

            if willSpecialWaitlist {
                // class-detail already told us this tap will trigger the spam
                // guard - show the double-booking sheet FIRST and only actually
                // join if the member explicitly confirms inside it, instead of
                // creating the special-waitlist row eagerly on this outer tap.
                presentDoubleBookingSheet(preCheck: true)
                return
            }
            presentConfirmWaitlistJoinSheet()
            return
        }

        if !isFreeForUser {
            guard requireLogin() else { return }
            pushClassPayment()
            return
        }

        if willSpecialWaitlist {
            // class-detail already told us this tap will trigger the spam
            // guard - show the double-booking sheet FIRST, same as the
            // isWaitlistMode branch above, and only actually book if the
            // member explicitly confirms inside it. (Previously booked
            // eagerly on this outer tap - matching Android's own prior bug -
            // so the sheet showed afterward as a no-op confirmation with
            // nothing left to confirm, i.e. opening the sheet was what
            // booked them, not tapping its confirm button.)
            guard requireLogin() else { return }
            presentDoubleBookingSheet(preCheck: true) { [weak self] in
                self?.performFreeBooking(skipSpecialSheetCheck: true)
            }
            return
        }

        // Android does *not* gate this branch here: the login check lives inside the
        // Confirm Slot bottom sheet's confirm button (`ConfirmSlotSheetViewController`).
        presentConfirmSlotSheet()
    }

    /// Shared by the auto-redirect (page load) and `ctaTapped()` (Book Slot
    /// tap) - both routes to this screen need the identical construction and
    /// the identical onClaimed -> Slot Confirmed hookup.
    private func pushSlotOpen(time: String) {
        let controller = SlotOpenViewController()
        controller.scheduleId = scheduleId
        controller.classTitle = classTitle
        controller.classTime = time
        controller.classLocation = classLocation
        controller.trainerName = trainerName
        controller.seedRemainingSeats = remainingSeats
        controller.seedWaitlistCount = waitlistCount
        controller.latitude = lat
        controller.longitude = lng
        controller.onClaimed = { [weak self] claimedTitle, claimedTime, location, trainer in
            guard let self = self else { return }
            let confirmed = SlotConfirmedViewController()
            confirmed.classTitle = claimedTitle
            confirmed.classTime = claimedTime
            confirmed.classLocation = location
            confirmed.trainerName = trainer
            confirmed.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(confirmed, animated: true)
        }
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    /// Port of the `isUserBlacklisted` branch of `btnBookSlot.setOnClickListener`.
    private func pushBookingPaused() {
        let controller = BookingPausedViewController()
        controller.reason = blacklistReason
        controller.resumesOn = blacklistResumesOn.isEmpty ? "12 August 2026" : blacklistResumesOn
        controller.daysRemaining = blacklistDaysRemaining.isEmpty ? "6" : blacklistDaysRemaining
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    /// Port of the `isFreeForUser == false` branch of `btnBookSlot.setOnClickListener`:
    /// Android pushes `ClassPaymentScreenActivity` directly for a paid class,
    /// bypassing the Confirm Slot sheet entirely.
    private func pushClassPayment() {
        let controller = ClassPaymentViewController()
        controller.scheduleId = scheduleId
        controller.classTitle = classTitle
        controller.classTime = dateTimeLabel.text ?? ""
        controller.classLocation = classLocation
        controller.trainerName = trainerName
        controller.classPrice = classPrice
        controller.distance = locationDistanceLabel.text ?? currentDistance
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    /// Port of `joinWaitlistDirectly`: `POST join-waitlist` with schedule_id /
    /// transaction_id="" / price, then either refresh + push Waitlist Confirmed
    /// (success), stub to Phase 10 (blacklisted), or surface the server message.
    ///
    /// `skipSpecialSheetCheck` is `true` only when the double-booking sheet was
    /// already shown BEFORE this call (the pre-check path) - the member already
    /// confirmed, so the response's `waitlist_type` is ignored and this always
    /// finishes as a plain success, exactly like Android's
    /// `joinWaitlistDirectly(..., skipSpecialSheetCheck = true)`.
    private func joinWaitlist(skipSpecialSheetCheck: Bool = false) {
        UpcomingClassVM.joinWaitlistApi(scheduleId: scheduleId,
                                        transactionId: "",
                                        price: classPrice) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleWaitlistResponse(result, skipSpecialSheetCheck: skipSpecialSheetCheck)
            }
        }
    }

    private func handleWaitlistResponse(_ result: BookClassBaseModel?, skipSpecialSheetCheck: Bool = false) {
        guard let result = result else {
            AlertHelper.shared.showCustomeAlert(title: "", message: "Could not join waitlist. Please try again.", actions: ["OK"], completion: nil)
            return
        }

        if result.status == true {
            // Android calls fetchClassDetail() before navigating so this screen
            // reflects the new waitlist state when the user comes back.
            fetchClassDetail()

            // Post-hoc fallback: class-detail's `will_special_waitlist` said this
            // wouldn't trigger the guard (or this is the un-gated plain path), but
            // the server disagrees - show the sheet now instead of silently
            // treating a special-waitlist join as a plain one.
            if !skipSpecialSheetCheck, result.specialWaitlist?.isSpecial == true {
                presentDoubleBookingSheet(preCheck: false,
                                          notifyHours: result.specialWaitlist?.notificationWindowHours?.intValue)
                return
            }

            // Port of Android's `isSpecialWaitlist = skipSpecialSheetCheck ||
            // waitlist_type == "special"` in `joinWaitlistDirectly()` - missing
            // here meant a pre-confirmed double-booking join (skipSpecialSheetCheck
            // true, sheet already shown) always landed on the PLAIN waitlist
            // confirmed screen instead of the overlapping-waitlist one, even
            // though the row that actually got created server-side was special.
            let isSpecialWaitlist = skipSpecialSheetCheck || result.specialWaitlist?.isSpecial == true
            if isSpecialWaitlist {
                pushDoubleBookingWaitlistConfirmed()
            } else {
                let controller = WaitlistConfirmedViewController()
                controller.classTitle = classTitle
                controller.classTime = dateTimeLabel.text ?? ""
                controller.classLocation = classLocation
                controller.trainerName = trainerName
                controller.distance = currentDistance
                controller.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(controller, animated: true)
            }
            return
        }

        if isWaitlistBlacklisted(result) {
            let controller = BookingPausedViewController()
            controller.reason = result.blacklistDetail?.reason ?? "2 consecutive no-shows for group classes"
            controller.resumesOn = result.blacklistDetail?.resumesOn ?? "12 August 2026"
            controller.daysRemaining = result.blacklistDetail?.daysRemaining?.value ?? "6"
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
            return
        }

        let trimmedMessage = (result.msg ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let message = trimmedMessage.isEmpty ? "Could not join waitlist. Please try again." : trimmedMessage
        AlertHelper.shared.showCustomeAlert(title: "", message: message, actions: ["OK"], completion: nil)
    }

    private func isWaitlistBlacklisted(_ model: BookClassBaseModel) -> Bool {
        if model.isBlacklisted == true { return true }
        if model.code == "BLACKLISTED" { return true }
        let lowered = (model.msg ?? "").lowercased()
        return lowered.contains("blacklisted") || lowered.contains("paused")
    }

    /// Port of Android's extracted `performFreeBooking()`: the free-for-member
    /// `POST book-class` call, shared by the willSpecialWaitlist bypass here and
    /// (separately) `ConfirmSlotSheetViewController`'s own confirm button.
    ///
    /// `skipSpecialSheetCheck` mirrors `joinWaitlist(skipSpecialSheetCheck:)`:
    /// pass `true` when this call is itself firing from inside the
    /// double-booking sheet's own confirm tap (the pre-check path) - the user
    /// already saw and confirmed that sheet, so a response that (correctly,
    /// expectedly) reports `specialWaitlist.isSpecial == true` must NOT
    /// re-trigger it, or the sheet visibly closes and reopens on every tap.
    private func performFreeBooking(skipSpecialSheetCheck: Bool = false) {
        guard !scheduleId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            pushSlotConfirmedFresh()
            return
        }

        UpcomingClassVM.bookGroupClassApi(scheduleId: scheduleId,
                                          transactionId: "",
                                          paymentType: "free") { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleFreeBookingResponse(result, skipSpecialSheetCheck: skipSpecialSheetCheck)
            }
        }
    }

    private func handleFreeBookingResponse(_ result: BookClassBaseModel?, skipSpecialSheetCheck: Bool = false) {
        guard let result = result else {
            AlertHelper.shared.showCustomeAlert(title: "", message: "Booking failed. Please try again.", actions: ["OK"], completion: nil)
            return
        }

        if result.status == true {
            fetchClassDetail()

            if !skipSpecialSheetCheck, result.specialWaitlist?.isSpecial == true {
                presentDoubleBookingSheet(preCheck: false,
                                          notifyHours: result.specialWaitlist?.notificationWindowHours?.intValue)
                return
            }

            // Port of Android's `isSpecialWaitlist = skipSpecialSheetCheck ||
            // waitlist_type == "special"` in `performFreeBooking()` - missing
            // here meant a pre-confirmed double-booking (skipSpecialSheetCheck
            // true, sheet already shown) always landed on "Your slot is
            // confirmed" even though the backend diverted this booking into a
            // special-waitlist row instead of an actual booking.
            let isSpecialWaitlist = skipSpecialSheetCheck || result.specialWaitlist?.isSpecial == true
            if isSpecialWaitlist {
                pushDoubleBookingWaitlistConfirmed()
            } else {
                pushSlotConfirmedFresh()
            }
            return
        }

        if isWaitlistBlacklisted(result) {
            let controller = BookingPausedViewController()
            controller.reason = result.blacklistDetail?.reason ?? "2 consecutive no-shows for group classes"
            controller.resumesOn = result.blacklistDetail?.resumesOn ?? "12 August 2026"
            controller.daysRemaining = result.blacklistDetail?.daysRemaining?.value ?? "6"
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
            return
        }

        let trimmedMessage = (result.msg ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let message = trimmedMessage.isEmpty ? "Booking failed. Please try again." : trimmedMessage
        AlertHelper.shared.showCustomeAlert(title: "", message: message, actions: ["OK"], completion: nil)
    }

    /// Mirrors `ConfirmSlotSheetViewController.navigateToSlotConfirmed()`'s fresh
    /// (non-read-only) success screen: no `schedule_id` forwarded (the booking
    /// already exists) and no price (this is the free-for-member path).
    private func pushSlotConfirmedFresh() {
        let controller = SlotConfirmedViewController()
        controller.classTitle = classTitle
        controller.classTime = dateTimeLabel.text ?? ""
        controller.classLocation = classLocation
        controller.trainerName = trainerName
        controller.distance = locationDistanceLabel.text ?? currentDistance
        controller.classPrice = ""
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    /// Shared destination for any post-hoc "this join/booking turned out to
    /// already be special" outcome - a pre-confirmed double-booking sheet
    /// (`skipSpecialSheetCheck == true`) means the row is guaranteed special
    /// server-side regardless of what this specific response's own
    /// `specialWaitlist.isSpecial` says.
    private func pushDoubleBookingWaitlistConfirmed() {
        let controller = DoubleBookingWaitlistConfirmedViewController()
        controller.classTitle = classTitle
        controller.classTime = dateTimeLabel.text ?? ""
        controller.classLocation = classLocation
        controller.trainerName = trainerName
        controller.distance = locationDistanceLabel.text ?? currentDistance
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    /// Port of `showDoubleBookingBottomSheet(notifyHours, onJoinConfirmed)`.
    /// `preCheck == true` -> pre-check mode: no entry exists yet, the sheet's own
    /// Join button fires `joinWaitlist(skipSpecialSheetCheck: true)`.
    /// `preCheck == false` -> post-hoc mode: entry already exists server-side,
    /// the sheet's Join button just confirms and pushes Waitlist Confirmed.
    private func presentDoubleBookingSheet(preCheck: Bool, notifyHours: Int? = nil, onConfirm: (() -> Void)? = nil) {
        var input = DoubleBookingSheetInput()
        input.classTitle = classTitle
        input.classTime = dateTimeLabel.text ?? classTime
        input.classLocation = classLocation
        input.trainerName = trainerName
        input.distance = locationDistanceLabel.text ?? currentDistance
        input.notifyHours = notifyHours ?? specialWaitlistNotifyHours

        if preCheck {
            DoubleBookingSheetViewController.present(from: self, input: input) { [weak self] in
                if let onConfirm = onConfirm {
                    onConfirm()
                } else {
                    self?.joinWaitlist(skipSpecialSheetCheck: true)
                }
            }
        } else {
            DoubleBookingSheetViewController.present(from: self, input: input)
        }
    }

    /// Port of the `isAlreadyBooked` branch of `btnBookSlot.setOnClickListener`.
    ///
    /// Android starts `SlotConfirmedActivity` with exactly these six extras —
    /// `title`, `time` (the *label* text, already formatted), `location`,
    /// `trainer_name`, `distance` (`tvLocationDistance`'s text, falling back to
    /// `currentDistance` only if the view is missing) and `price` — and pointedly
    /// omits `schedule_id`, so the success screen does not re-POST `book-class` for
    /// a booking that already exists.
    ///
    /// `isReadOnly` is the iOS-side belt to that braces: it hard-disables the POST
    /// regardless of `scheduleId`, and makes Slot Confirmed's glass back button
    /// return *here* instead of unwinding the whole stack to the tab root (which is
    /// what the fresh-booking flow does, mirroring Android's `FLAG_ACTIVITY_CLEAR_TOP`).
    private func pushSlotConfirmedReadOnly() {
        let controller = SlotConfirmedViewController()
        controller.classTitle = classTitle
        controller.classTime = dateTimeLabel.text ?? ""
        controller.classLocation = classLocation
        controller.trainerName = trainerName
        controller.distance = locationDistanceLabel.text ?? currentDistance
        controller.classPrice = isFreeForUser ? "" : classPrice
        controller.isReadOnly = true
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    /// Port of `showConfirmSlotBottomSheet(classTitle, tvClassDateTime.text, classLocation)`.
    ///
    /// Android passes those three explicitly and lets the sheet body read the rest
    /// off the Activity, so the same fields are forwarded here. `distance` is the
    /// *label* text (which still carries the trailing " away") rather than the
    /// stripped `currentDistance` — Android's
    /// `findViewById(R.id.tvLocationDistance)?.text ?: currentDistance` only falls
    /// back when the view itself is missing.
    private func presentConfirmSlotSheet() {
        var input = ConfirmSlotSheetInput()
        input.scheduleId = scheduleId
        input.title = classTitle
        input.time = dateTimeLabel.text ?? ""
        input.location = classLocation
        input.distance = locationDistanceLabel.text ?? currentDistance
        input.trainerName = trainerName
        input.price = classPrice
        input.isFreeForUser = isFreeForUser

        ConfirmSlotSheetViewController.present(from: self, input: input, onBookingSucceeded: { [weak self] in
            // Android calls `fetchClassDetail()` right before it leaves for Slot
            // Confirmed, so this screen shows "BOOKED" when the user comes back.
            self?.fetchClassDetail()
        }, onSpecialWaitlistTriggered: { [weak self] notifyHours in
            // will_special_waitlist read false when this sheet was shown, but the
            // booking response disagreed - show the double-booking sheet now
            // instead of silently letting the normal confirm sheet's own success
            // path treat this as an ordinary booking.
            self?.presentDoubleBookingSheet(preCheck: false, notifyHours: notifyHours)
        })
    }

    /// Was previously missing entirely: the `isWaitlistMode && !willSpecialWaitlist`
    /// branch above called `joinWaitlist()` straight from the outer CTA tap with no
    /// confirmation step at all, unlike every other path on this screen (booking,
    /// special-waitlist), which always confirms first. Mirrors Android's fix -
    /// `showConfirmSlotBottomSheet(..., isWaitlistJoin = true)`.
    private func presentConfirmWaitlistJoinSheet() {
        var input = ConfirmSlotSheetInput()
        input.scheduleId = scheduleId
        input.title = classTitle
        input.time = dateTimeLabel.text ?? ""
        input.location = classLocation
        input.distance = locationDistanceLabel.text ?? currentDistance
        input.trainerName = trainerName
        input.price = classPrice
        input.isFreeForUser = isFreeForUser
        input.isWaitlistJoin = true

        ConfirmSlotSheetViewController.present(from: self, input: input, onWaitlistJoinConfirmed: { [weak self] in
            self?.joinWaitlist()
        })
    }

    /// Expands / collapses the About copy. Expanding drops the line cap and takes
    /// the scrim away; collapsing puts both back. Android leaves its own
    /// `btnReadMore` inert — this is the iOS-side behaviour that was asked for.
    @objc private func readMoreTapped() {
        TapticEngine.selection.feedback()
        isAboutExpanded.toggle()
        readMoreButton.setTitle(isAboutExpanded ? Copy.showLess : Copy.readMore, for: .normal)
        aboutLabel.numberOfLines = isAboutExpanded ? 0 : GroupTrainingDetailViewController.aboutCollapsedLineLimit
        aboutFadeView.isHidden = isAboutExpanded

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    /// Hides the scrim *and* the READ MORE button when the copy already fits
    /// inside `aboutCollapsedLineLimit` lines — there is nothing to reveal, so
    /// neither affordance should be on screen. Re-evaluated on every layout pass
    /// because the answer depends on the label's resolved width.
    private func updateAboutOverflowState() {
        let availableWidth = aboutLabel.bounds.width
        guard availableWidth > 0, let font = aboutLabel.font else { return }

        let text = aboutLabel.text ?? ""
        let fullHeight = (text as NSString).boundingRect(
            with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        ).height

        let collapsedLimit = font.lineHeight * CGFloat(GroupTrainingDetailViewController.aboutCollapsedLineLimit)
        // 1pt of slack absorbs the rounding difference between the measured
        // bounding box and the label's own line-fragment layout.
        let overflows = fullHeight > collapsedLimit + 1

        readMoreButton.isHidden = !overflows
        aboutFadeView.isHidden = !overflows || isAboutExpanded

        // When Read More is hidden, its own `setCustomSpacing(24, after:)` never
        // renders - UIKit drops spacing tied to a hidden arranged subview - so
        // the standard 24pt gap into "What to bring" has to be carried by
        // `aboutContainerView` itself instead, or the next section jams
        // straight up against the (now-invisible) button with no gap at all.
        contentStackView?.setCustomSpacing(overflows ? 8 : 24, after: aboutContainerView)

        // A paragraph that no longer overflows (shorter copy arrived from the API
        // while expanded) must not stay stuck in the expanded state.
        if !overflows && isAboutExpanded {
            isAboutExpanded = false
            readMoreButton.setTitle(Copy.readMore, for: .normal)
            aboutLabel.numberOfLines = GroupTrainingDetailViewController.aboutCollapsedLineLimit
        }
    }

    // MARK: - Why-this-class-stands-out carousel indicator

    /// Port of `setupCarouselIndicator()`: two pages, switching at the 50% scroll mark.
    private func setupWhyCarouselIndicator() {
        whyDotsView.setPageCount(2)
        whyDotsView.setSelectedPage(0)
    }
}

// MARK: - UIScrollViewDelegate

extension GroupTrainingDetailViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === whyScrollView else { return }
        let maxScroll = max(scrollView.contentSize.width - scrollView.bounds.width, 1)
        let ratio = min(max(scrollView.contentOffset.x / maxScroll, 0), 1)
        whyDotsView.setSelectedPage(ratio > 0.5 ? 1 : 0)
    }
}

// MARK: - Layout

private extension GroupTrainingDetailViewController {

    func buildLayout() {
        buildBottomBar()
        buildWaitlistBanner()
        buildScrollView()
    }

    // MARK: Scroll container

    func buildScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.insertSubview(scrollView, at: 0)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 0
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        contentStack.addArrangedSubview(makeHeroSection())
        contentStack.addArrangedSubview(makeContentColumn())
    }

    // MARK: Hero

    func makeHeroSection() -> UIView {
        heroContainer.translatesAutoresizingMaskIntoConstraints = false
        heroContainer.backgroundColor = GroupClassColor.bg.color
        heroContainer.clipsToBounds = true

        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.backgroundColor = UIColor(hex: "#32615C")
        heroContainer.addSubview(heroImageView)

        heroFadeView.translatesAutoresizingMaskIntoConstraints = false
        heroFadeView.setColors([GroupClassColor.bg.color.withAlphaComponent(0.0),
                                GroupClassColor.bg.color])
        heroContainer.addSubview(heroFadeView)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.configure(icon: GroupTrainingDetailViewController.icon(["ic_back_chevron_20"], systemFallback: "chevron.left"),
                             diameter: Metric.navButtonDiameter)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
        favouriteButton.configure(icon: GroupTrainingDetailViewController.icon(["ic_heart_20"], systemFallback: "heart"),
                                  diameter: Metric.navButtonDiameter)
        favouriteButton.addTarget(self, action: #selector(favouriteTapped), for: .touchUpInside)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.configure(icon: GroupTrainingDetailViewController.icon(["ic_share_20"], systemFallback: "square.and.arrow.up"),
                              diameter: Metric.navButtonDiameter)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)

        heroContainer.addSubview(backButton)
        heroContainer.addSubview(favouriteButton)
        heroContainer.addSubview(shareButton)

        let navTop = backButton.topAnchor.constraint(equalTo: heroContainer.topAnchor, constant: 52)
        heroNavTopConstraint = navTop

        NSLayoutConstraint.activate([
            heroContainer.heightAnchor.constraint(equalToConstant: Metric.heroHeight),

            heroImageView.topAnchor.constraint(equalTo: heroContainer.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: heroContainer.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: heroContainer.trailingAnchor),
            heroImageView.bottomAnchor.constraint(equalTo: heroContainer.bottomAnchor),

            heroFadeView.leadingAnchor.constraint(equalTo: heroContainer.leadingAnchor),
            heroFadeView.trailingAnchor.constraint(equalTo: heroContainer.trailingAnchor),
            heroFadeView.bottomAnchor.constraint(equalTo: heroContainer.bottomAnchor),
            heroFadeView.heightAnchor.constraint(equalToConstant: Metric.heroFadeHeight),

            navTop,
            backButton.leadingAnchor.constraint(equalTo: heroContainer.leadingAnchor,
                                                constant: Metric.horizontalInset),
            backButton.widthAnchor.constraint(equalToConstant: Metric.navButtonDiameter),
            backButton.heightAnchor.constraint(equalToConstant: Metric.navButtonDiameter),

            shareButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: heroContainer.trailingAnchor,
                                                  constant: -Metric.horizontalInset),
            shareButton.widthAnchor.constraint(equalToConstant: Metric.navButtonDiameter),
            shareButton.heightAnchor.constraint(equalToConstant: Metric.navButtonDiameter),

            favouriteButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            favouriteButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -8),
            favouriteButton.widthAnchor.constraint(equalToConstant: Metric.navButtonDiameter),
            favouriteButton.heightAnchor.constraint(equalToConstant: Metric.navButtonDiameter)
        ])

        return heroContainer
    }

    // MARK: Content column

    func makeContentColumn() -> UIView {
        let column = UIStackView()
        contentStackView = column
        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 0
        column.isLayoutMarginsRelativeArrangement = true
        column.layoutMargins = UIEdgeInsets(top: 0,
                                            left: Metric.horizontalInset,
                                            bottom: 32,
                                            right: Metric.horizontalInset)

        // 1 — three glass pills
        let pillsRow = makePillsRow()
        column.addArrangedSubview(pillsRow)
        column.setCustomSpacing(8, after: pillsRow)

        // 2 — class title
        titleLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        column.addArrangedSubview(titleLabel)
        column.setCustomSpacing(16, after: titleLabel)

        // 3 — date/time + spots progress
        let dateSpotsRow = makeDateAndSpotsRow()
        column.addArrangedSubview(dateSpotsRow)
        column.setCustomSpacing(16, after: dateSpotsRow)

        // 4 — location row (tap -> Maps)
        let locationRowView = makeLocationRow()
        column.addArrangedSubview(locationRowView)

        let locationDivider = makeHairline(color: Palette.hairline)
        column.addArrangedSubview(locationDivider)
        column.setCustomSpacing(4, after: locationDivider)

        // 5 — doors-open row
        let doorsRow = makeDoorsOpenRow()
        column.addArrangedSubview(doorsRow)
        let doorsDivider = makeHairline(color: Palette.hairline)
        column.addArrangedSubview(doorsDivider)
        column.setCustomSpacing(24, after: doorsDivider)

        // 6 — why this class stands out
        let whyTitle = makeSectionTitle("Why this class stands out")
        column.setCustomSpacing(24, after: column.arrangedSubviews[column.arrangedSubviews.count - 1])
        column.addArrangedSubview(whyTitle)
        column.setCustomSpacing(8, after: whyTitle)

        let whyCarousel = makeWhyCarousel()
        column.addArrangedSubview(whyCarousel)
        column.setCustomSpacing(12, after: whyCarousel)

        let dotsRow = makeWhyDotsRow()
        column.addArrangedSubview(dotsRow)
        column.setCustomSpacing(24, after: dotsRow)

        // 7 — about the class
        let aboutTitle = makeSectionTitle("About the class")
        column.addArrangedSubview(aboutTitle)
        column.setCustomSpacing(12, after: aboutTitle)

        let aboutBlock = makeAboutBlock()
        column.addArrangedSubview(aboutBlock)
        column.setCustomSpacing(8, after: aboutBlock)

        let readMoreButton = makeReadMoreButton()
        column.addArrangedSubview(readMoreButton)
        column.setCustomSpacing(24, after: readMoreButton)

        // 8 — what to bring
        // Rows go into a dedicated nested stack (not `column` directly) so
        // refreshWhatToBring() can clear + rebuild just this section once
        // fetchClassDetail() actually resolves - see the note above
        // whatToBringStack's declaration for why that matters.
        let bringTitle = makeSectionTitle("What to bring")
        column.addArrangedSubview(bringTitle)
        column.setCustomSpacing(12, after: bringTitle)
        whatToBringStack.axis = .vertical
        whatToBringStack.alignment = .fill
        whatToBringStack.spacing = 0
        column.addArrangedSubview(whatToBringStack)
        appendInfoRows(GroupTrainingDetailViewController.checklistRows(from: detail?.whatToBring, fallback: GroupTrainingDetailViewController.whatToBringRows), to: whatToBringStack)

        // 9 — things to know
        let knowTitle = makeSectionTitle("Things to know")
        column.setCustomSpacing(24, after: column.arrangedSubviews[column.arrangedSubviews.count - 1])
        column.addArrangedSubview(knowTitle)
        column.setCustomSpacing(8, after: knowTitle)
        thingsToKnowStack.axis = .vertical
        thingsToKnowStack.alignment = .fill
        thingsToKnowStack.spacing = 0
        column.addArrangedSubview(thingsToKnowStack)
        appendInfoRows(GroupTrainingDetailViewController.checklistRows(from: detail?.thingsToKnow, fallback: GroupTrainingDetailViewController.thingsToKnowRows), to: thingsToKnowStack)
        // Standard gap to whatever comes next - set once here so it holds
        // regardless of whether the media gallery section below ends up
        // inserted or not (refreshMediaGallery() only inserts/removes the
        // gallery wrapper itself, it never touches this value).
        column.setCustomSpacing(24, after: thingsToKnowStack)

        // 10 — media gallery, from the class detail API's media_gallery array
        // (already-resolved URLs, either the class's own uploaded gallery or
        // the trainer's media as a fallback). Built but NOT added to `column`
        // here - refreshMediaGallery() inserts it right after
        // thingsToKnowStack once fetchClassDetail() resolves with real URLs,
        // and removes it again if there are none, so there's never a
        // hidden-but-present arranged subview to confuse the stack's spacing.
        mediaGallerySectionView.axis = .vertical
        mediaGallerySectionView.alignment = .fill
        mediaGallerySectionView.spacing = 8
        let galleryHeader = makeGalleryHeader()
        mediaGallerySectionView.addArrangedSubview(galleryHeader)
        let gallery = makeMediaGallery()
        mediaGallerySectionView.addArrangedSubview(gallery)

        let initialGalleryUrls = (detail?.mediaGallery ?? []).filter { !$0.isEmpty }
        populateMediaGalleryCards(urls: initialGalleryUrls)
        if !initialGalleryUrls.isEmpty {
            column.addArrangedSubview(mediaGallerySectionView)
            column.setCustomSpacing(24, after: mediaGallerySectionView)
        }

        // 11 — trainer card
        let trainerTitle = makeSectionTitle("Your trainer")
        column.addArrangedSubview(trainerTitle)
        column.setCustomSpacing(8, after: trainerTitle)

        let trainerCard = makeTrainerCard()
        column.addArrangedSubview(trainerCard)
        column.setCustomSpacing(24, after: trainerCard)

        // 12 — policy rows
        let moreTitle = makeSectionTitle("More")
        column.addArrangedSubview(moreTitle)
        column.setCustomSpacing(8, after: moreTitle)

        let cancellationRow = makePolicyRow(icon: GroupTrainingDetailViewController.icon(["ic_person_age_18"], systemFallback: "person.fill"),
                                            title: "Cancellation policy",
                                            action: #selector(cancellationPolicyRowTapped))
        column.addArrangedSubview(cancellationRow)
        column.setCustomSpacing(8, after: cancellationRow)

        let termsRow = makePolicyRow(icon: GroupTrainingDetailViewController.icon(["ic_clock_18"], systemFallback: "clock.fill"),
                                     title: "Terms and conditions",
                                     action: #selector(termsAndConditionsRowTapped))
        column.addArrangedSubview(termsRow)

        return column
    }

    func makePillsRow() -> UIView {
        [categoryPill, locationPill, typePill].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.fillColor = .clear
            $0.strokeColor = Palette.pillStroke
            $0.contentInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
            $0.configure(text: nil,
                         font: AppFont.medium.size(12.0, familyName: familyFunnelSans),
                         textColor: Palette.pillText)
            // Three long API-driven labels can exceed the 16pt-inset column; let
            // them truncate rather than push each other off screen.
            $0.titleLabel.lineBreakMode = .byTruncatingTail
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
        }

        // Android ships literal placeholder text in the layout; the API refresh
        // overwrites all three.
        categoryPill.text = "YOGA"
        locationPill.text = "DSO CLUB"
        typePill.text = Copy.defaultPillType

        let pillStack = UIStackView(arrangedSubviews: [categoryPill, locationPill, typePill])
        pillStack.translatesAutoresizingMaskIntoConstraints = false
        pillStack.axis = .horizontal
        pillStack.alignment = .center
        pillStack.spacing = 6

        // Wrapper keeps the pills hugging the leading edge inside a .fill column.
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(pillStack)
        NSLayoutConstraint.activate([
            pillStack.topAnchor.constraint(equalTo: wrapper.topAnchor),
            pillStack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            pillStack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            pillStack.trailingAnchor.constraint(lessThanOrEqualTo: wrapper.trailingAnchor)
        ])
        return wrapper
    }

    /// The 3 glass pills (category, gym, "GROUP CLASS") already truncate
    /// individually, but a long category name can still leave the gym pill
    /// squeezed to near-nothing or push the row past the 16pt-inset column.
    /// Drop the gym pill entirely once the row would overflow - measured
    /// against each pill's actual rendered text width, not a hardcoded
    /// character count, so it adapts to any category/gym name length.
    private func adjustGlassPillsOverflow() {
        let availableWidth = view.safeAreaLayoutGuide.layoutFrame.width - 32 // 16pt leading + trailing
        guard availableWidth > 0 else { return }

        let spacing: CGFloat = 6

        func pillWidth(_ pill: PillChipView) -> CGFloat {
            let insets = pill.contentInsets
            return pill.titleLabel.intrinsicContentSize.width + insets.left + insets.right
        }

        let totalWidth = pillWidth(categoryPill) + spacing + pillWidth(locationPill) + spacing + pillWidth(typePill)
        locationPill.isHidden = totalWidth > availableWidth
    }

    func makeDateAndSpotsRow() -> UIView {
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        dateTimeLabel.textColor = Palette.dateTime
        dateTimeLabel.numberOfLines = 1
        dateTimeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        spotsLabel.translatesAutoresizingMaskIntoConstraints = false
        spotsLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        spotsLabel.textColor = Palette.spotsText
        spotsLabel.textAlignment = .right
        spotsLabel.numberOfLines = 1
        spotsLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        progressBar.translatesAutoresizingMaskIntoConstraints = false

        let spotStack = UIStackView(arrangedSubviews: [spotsLabel, progressBar])
        spotStack.translatesAutoresizingMaskIntoConstraints = false
        spotStack.axis = .vertical
        spotStack.alignment = .trailing
        spotStack.spacing = 4
        spotStack.setContentHuggingPriority(.required, for: .horizontal)
        spotStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [dateTimeLabel, spotStack])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        let barWidth = progressBar.widthAnchor.constraint(equalToConstant: Metric.progressBarWidth)
        detailProgressBarWidthConstraint = barWidth
        barWidth.isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 2).isActive = true
        return row
    }

    func makeLocationRow() -> UIView {
        locationRow.translatesAutoresizingMaskIntoConstraints = false

        // Android renders this pin at 14dp inside the 38dp tile (the clock row's
        // is 18dp — they are deliberately different sizes).
        let iconTile = makeIconTile(image: GroupTrainingDetailViewController.icon(["ic_location_pin_small", "ic_Location", "greenLocation"]),
                                    iconSide: 14)

        locationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        locationTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        locationTitleLabel.textColor = .white
        locationTitleLabel.numberOfLines = 2
        locationTitleLabel.lineBreakMode = .byWordWrapping

        locationDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        locationDistanceLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        locationDistanceLabel.textColor = Palette.distance
        locationDistanceLabel.numberOfLines = 1
        locationDistanceLabel.lineBreakMode = .byTruncatingTail

        let textStack = UIStackView(arrangedSubviews: [locationTitleLabel, locationDistanceLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 2
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let chevron = makeChevron()

        let row = UIStackView(arrangedSubviews: [iconTile, textStack, chevron])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        locationRow.addSubview(row)

        // `minHeight="54dp"` + `paddingVertical="12dp"` on `locationRowContainer`.
        NSLayoutConstraint.activate([
            locationRow.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
            row.leadingAnchor.constraint(equalTo: locationRow.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: locationRow.trailingAnchor),
            row.topAnchor.constraint(equalTo: locationRow.topAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: locationRow.bottomAnchor, constant: -12)
        ])

        locationRow.isUserInteractionEnabled = true
        locationRow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationTapped)))
        return locationRow
    }

    func makeDoorsOpenRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconTile = makeIconTile(image: GroupTrainingDetailViewController.icon(["ic_clock_18"], systemFallback: "clock.fill"),
                                    iconSide: 18)

        doorsOpenLabel.translatesAutoresizingMaskIntoConstraints = false
        doorsOpenLabel.numberOfLines = 0
        doorsOpenLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        doorsOpenLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [iconTile, doorsOpenLabel])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        container.addSubview(row)

        // `doorsOpenRowContainer`: `minHeight="54dp"`, `paddingVertical="12dp"` —
        // the same box metrics as the location row above it.
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        return container
    }

    func makeWhyCarousel() -> UIView {
        whyScrollView.translatesAutoresizingMaskIntoConstraints = false
        whyScrollView.showsHorizontalScrollIndicator = false
        whyScrollView.backgroundColor = .clear
        whyScrollView.delegate = self

        let card1 = makeWhyCard(icon: GroupTrainingDetailViewController.icon(["ic_expert_instructor_28"], systemFallback: "person.crop.circle.badge.checkmark"),
                                title: "Expert Instructor",
                                body: "Certified trainer with hundreds of delivered classes")
        let card2 = makeWhyCard(icon: GroupTrainingDetailViewController.icon(["ic_small_group_28"], systemFallback: "person.2.fill"),
                                title: "Small Group",
                                body: "Capped sessions — never a crowd")

        // A horizontal stack with `.fill` alignment gives both cards the height of
        // the tallest — Android's `measureWithLargestChild`.
        let stack = UIStackView(arrangedSubviews: [card1, card2])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 12
        whyScrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: whyScrollView.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: whyScrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: whyScrollView.contentLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: whyScrollView.contentLayoutGuide.bottomAnchor),
            whyScrollView.heightAnchor.constraint(equalTo: stack.heightAnchor),

            card1.widthAnchor.constraint(equalToConstant: Metric.whyCardWidth),
            card2.widthAnchor.constraint(equalToConstant: Metric.whyCardWidth)
        ])
        return whyScrollView
    }

    func makeWhyCard(icon: UIImage?, title: String, body: String) -> UIView {
        let card = GlassCardView(cornerRadius: 12)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardSurface
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        // Android's radial highlight is anchored at the top-centre of the card.
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.10

        let iconView = UIImageView(image: icon?.withRenderingMode(.alwaysTemplate))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        // The stack is `.fill` (so both labels get the card width and wrap), which
        // would also stretch a bare image view — hence the leading-aligned wrapper.
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)

        let cardTitleLabel = UILabel()
        cardTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardTitleLabel.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        cardTitleLabel.textColor = Palette.rowTitle
        cardTitleLabel.numberOfLines = 0
        cardTitleLabel.text = title

        let cardBodyLabel = UILabel()
        cardBodyLabel.translatesAutoresizingMaskIntoConstraints = false
        cardBodyLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        cardBodyLabel.textColor = Palette.cardBody
        cardBodyLabel.numberOfLines = 0
        cardBodyLabel.text = body

        let stack = UIStackView(arrangedSubviews: [iconContainer, cardTitleLabel, cardBodyLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 4
        stack.setCustomSpacing(8, after: iconContainer)
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            iconView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            iconView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
            iconView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            iconView.trailingAnchor.constraint(lessThanOrEqualTo: iconContainer.trailingAnchor),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }

    /// Same recipe as the Home carousel's dots pill (`GroupClassesCarouselView`):
    /// 5pt-tall `GroupClassCarouselDotsView` in a `bg3` pill, 4pt top/bottom and
    /// 12pt leading/trailing insets, corner radius = half the resulting pill
    /// height. This one previously forced the dots view to 10pt tall with a fixed
    /// 9pt radius, which is why it looked visibly chunkier than Home's.
    func makeWhyDotsRow() -> UIView {
        whyDotsPill.translatesAutoresizingMaskIntoConstraints = false
        whyDotsPill.backgroundColor = GroupClassColor.bg3.color
        whyDotsPill.layer.cornerRadius = 6.5
        whyDotsPill.layer.masksToBounds = true

        whyDotsView.translatesAutoresizingMaskIntoConstraints = false
        whyDotsPill.addSubview(whyDotsView)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(whyDotsPill)

        NSLayoutConstraint.activate([
            whyDotsView.topAnchor.constraint(equalTo: whyDotsPill.topAnchor, constant: 4),
            whyDotsView.bottomAnchor.constraint(equalTo: whyDotsPill.bottomAnchor, constant: -4),
            whyDotsView.leadingAnchor.constraint(equalTo: whyDotsPill.leadingAnchor, constant: 12),
            whyDotsView.trailingAnchor.constraint(equalTo: whyDotsPill.trailingAnchor, constant: -12),
            whyDotsView.heightAnchor.constraint(equalToConstant: 5),

            whyDotsPill.topAnchor.constraint(equalTo: container.topAnchor),
            whyDotsPill.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            whyDotsPill.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        return container
    }

    /// The About copy sits directly under its heading and is driven purely by
    /// `aboutLabel.numberOfLines` — collapsed to `aboutCollapsedLineLimit`, or 0
    /// (unbounded) once expanded. The container takes its height from the label
    /// rather than a hard-coded constant; the previous version pinned it to both
    /// `>= 110` *and* `== 93`, which is an unsatisfiable pair, and clipped the
    /// copy to a fixed box regardless of how long it actually was.
    func makeAboutBlock() -> UIView {
        aboutContainerView.translatesAutoresizingMaskIntoConstraints = false
        aboutContainerView.clipsToBounds = true

        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        aboutLabel.textColor = Palette.aboutText
        aboutLabel.numberOfLines = GroupTrainingDetailViewController.aboutCollapsedLineLimit
        aboutLabel.lineBreakMode = .byTruncatingTail
        aboutLabel.text = Copy.aboutPlaceholder
        aboutLabel.setContentHuggingPriority(.required, for: .vertical)
        aboutLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        aboutContainerView.addSubview(aboutLabel)

        aboutFadeView.translatesAutoresizingMaskIntoConstraints = false
        aboutFadeView.setColors([Palette.aboutFade.withAlphaComponent(0.0),
                                 Palette.aboutFade.withAlphaComponent(0.85),
                                 Palette.aboutFade],
                                locations: [0.0, 0.5, 1.0])
        aboutContainerView.addSubview(aboutFadeView)

        NSLayoutConstraint.activate([
            aboutLabel.topAnchor.constraint(equalTo: aboutContainerView.topAnchor),
            aboutLabel.leadingAnchor.constraint(equalTo: aboutContainerView.leadingAnchor),
            aboutLabel.trailingAnchor.constraint(equalTo: aboutContainerView.trailingAnchor),
            aboutLabel.bottomAnchor.constraint(equalTo: aboutContainerView.bottomAnchor),

            aboutFadeView.leadingAnchor.constraint(equalTo: aboutContainerView.leadingAnchor),
            aboutFadeView.trailingAnchor.constraint(equalTo: aboutContainerView.trailingAnchor),
            aboutFadeView.bottomAnchor.constraint(equalTo: aboutContainerView.bottomAnchor),
            aboutFadeView.heightAnchor.constraint(equalToConstant: 40)
        ])
        return aboutContainerView
    }

    func makeReadMoreButton() -> UIView {
        readMoreButton.translatesAutoresizingMaskIntoConstraints = false
        readMoreButton.setTitle(Copy.readMore, for: .normal)
        readMoreButton.setTitleColor(.white, for: .normal)
        readMoreButton.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        readMoreButton.backgroundColor = Palette.readMoreFill
        readMoreButton.layer.cornerRadius = 8
        readMoreButton.layer.borderWidth = 1
        readMoreButton.layer.borderColor = Palette.moreHairline.cgColor
        readMoreButton.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)
        readMoreButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        return readMoreButton
    }

    /// Called from apply(detail:) once the real API response arrives -
    /// buildScrollView() runs synchronously in viewDidLoad, before
    /// fetchClassDetail() has resolved, so the rows/cards it builds initially
    /// are always the fallback/empty state. These clear + rebuild just the
    /// affected nested stack so the real data actually reaches the screen.
    func refreshWhatToBring() {
        whatToBringStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        appendInfoRows(GroupTrainingDetailViewController.checklistRows(from: detail?.whatToBring, fallback: GroupTrainingDetailViewController.whatToBringRows), to: whatToBringStack)
    }

    func refreshThingsToKnow() {
        thingsToKnowStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        appendInfoRows(GroupTrainingDetailViewController.checklistRows(from: detail?.thingsToKnow, fallback: GroupTrainingDetailViewController.thingsToKnowRows), to: thingsToKnowStack)
    }

    func refreshMediaGallery() {
        let urls = (detail?.mediaGallery ?? []).filter { !$0.isEmpty }
        populateMediaGalleryCards(urls: urls)

        guard let column = contentStackView else { return }
        let isInColumn = mediaGallerySectionView.superview === column

        if urls.isEmpty {
            if isInColumn {
                column.removeArrangedSubview(mediaGallerySectionView)
                mediaGallerySectionView.removeFromSuperview()
            }
        } else if !isInColumn {
            guard let thingsToKnowIndex = column.arrangedSubviews.firstIndex(of: thingsToKnowStack) else { return }
            column.insertArrangedSubview(mediaGallerySectionView, at: thingsToKnowIndex + 1)
            column.setCustomSpacing(24, after: mediaGallerySectionView)
        }
    }

    func appendInfoRows(_ rows: [(icons: [String], system: String, text: String)], to column: UIStackView) {
        for (index, row) in rows.enumerated() {
            let icon = GroupTrainingDetailViewController.icon(row.icons, systemFallback: row.system)
            let view = makeInfoRow(icon: icon, text: row.text)
            column.addArrangedSubview(view)
            // Android: first row 12dp under the heading, subsequent rows 10dp apart.
            if index < rows.count - 1 {
                column.setCustomSpacing(10, after: view)
            }
        }
    }

    func makeInfoRow(icon: UIImage?, text: String) -> UIView {
        let iconTile = makeIconTile(image: icon, iconSide: 18)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        label.textColor = Palette.rowTitle
        label.numberOfLines = 0
        label.text = text
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // A centre-aligned stack keeps the row height correct whether the copy is
        // one line or wraps, without hand-rolled inequality constraints.
        let row = UIStackView(arrangedSubviews: [iconTile, label])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    func makeGalleryHeader() -> UIView {
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false

        let title = makeSectionTitle("Media Gallery")
        title.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(title)

        let chevron = makeChevron()
        header.addSubview(chevron)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            title.topAnchor.constraint(equalTo: header.topAnchor),
            title.bottomAnchor.constraint(equalTo: header.bottomAnchor),

            chevron.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            chevron.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            chevron.leadingAnchor.constraint(greaterThanOrEqualTo: title.trailingAnchor, constant: 12)
        ])
        // Android's chevron here has no click listener — the gallery is static.
        return header
    }

    /// Static placeholder gallery, exactly as Android ships it (the migration plan
    /// explicitly says NOT to wire this to `media_gallery` unless asked).
    func makeMediaGallery() -> UIView {
        mediaGalleryScrollView.translatesAutoresizingMaskIntoConstraints = false
        mediaGalleryScrollView.showsHorizontalScrollIndicator = false
        mediaGalleryScrollView.backgroundColor = .clear

        mediaGalleryCardsStack.translatesAutoresizingMaskIntoConstraints = false
        mediaGalleryCardsStack.axis = .horizontal
        mediaGalleryCardsStack.alignment = .fill
        mediaGalleryCardsStack.spacing = 12
        mediaGalleryScrollView.addSubview(mediaGalleryCardsStack)

        NSLayoutConstraint.activate([
            mediaGalleryCardsStack.topAnchor.constraint(equalTo: mediaGalleryScrollView.contentLayoutGuide.topAnchor),
            mediaGalleryCardsStack.leadingAnchor.constraint(equalTo: mediaGalleryScrollView.contentLayoutGuide.leadingAnchor),
            mediaGalleryCardsStack.trailingAnchor.constraint(equalTo: mediaGalleryScrollView.contentLayoutGuide.trailingAnchor),
            mediaGalleryCardsStack.bottomAnchor.constraint(equalTo: mediaGalleryScrollView.contentLayoutGuide.bottomAnchor),
            mediaGalleryScrollView.heightAnchor.constraint(equalToConstant: Metric.galleryCardSize.height)
        ])
        return mediaGalleryScrollView
    }

    func populateMediaGalleryCards(urls: [String]) {
        mediaGalleryCardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        urls.forEach { mediaGalleryCardsStack.addArrangedSubview(makeGalleryCard(urlString: $0)) }
    }

    func makeGalleryCard(urlString: String) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Palette.cardSurface
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = true

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        if let url = GroupClassCardFormatter.absoluteImageURL(urlString) {
            imageView.loadImage(urlString: url, placeholder: nil)
        }
        card.addSubview(imageView)

        NSLayoutConstraint.activate([
            card.widthAnchor.constraint(equalToConstant: Metric.galleryCardSize.width),
            card.heightAnchor.constraint(equalToConstant: Metric.galleryCardSize.height),
            imageView.topAnchor.constraint(equalTo: card.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        return card
    }

    func makeTrainerCard() -> UIView {
        let card = GlassCardView(cornerRadius: 20)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardSurface
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.10

        trainerAvatarView.translatesAutoresizingMaskIntoConstraints = false
        trainerAvatarView.contentMode = .scaleAspectFill
        trainerAvatarView.clipsToBounds = true
        trainerAvatarView.layer.cornerRadius = 16
        trainerAvatarView.backgroundColor = GroupClassColor.bg3.color
        trainerAvatarView.tintColor = .white.withAlphaComponent(0.4)
        trainerAvatarView.image = GroupTrainingDetailViewController.icon(["dummy_trainer"], systemFallback: "person.crop.circle.fill")?
            .withRenderingMode(.alwaysTemplate)
        card.addSubview(trainerAvatarView)

        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerNameLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        trainerNameLabel.textColor = .white
        trainerNameLabel.numberOfLines = 1
        trainerNameLabel.lineBreakMode = .byTruncatingTail
        trainerNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        subtitleLabel.textColor = Palette.cardBody
        subtitleLabel.numberOfLines = 1
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitleLabel.text = Copy.trainerSubtitle

        // `.fill`: the stack has a definite width here, so the labels must take it
        // and truncate rather than overflow the card.
        let textStack = UIStackView(arrangedSubviews: [trainerNameLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 4
        card.addSubview(textStack)

        NSLayoutConstraint.activate([
            trainerAvatarView.widthAnchor.constraint(equalToConstant: 64),
            trainerAvatarView.heightAnchor.constraint(equalToConstant: 64),
            trainerAvatarView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16.5),
            trainerAvatarView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            trainerAvatarView.topAnchor.constraint(greaterThanOrEqualTo: card.topAnchor, constant: 12),
            trainerAvatarView.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12),

            textStack.leadingAnchor.constraint(equalTo: trainerAvatarView.trailingAnchor, constant: 20),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16.5),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: card.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12),

            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 88)
        ])
        return card
    }

    /// "Cancellation policy" / "Terms and conditions": icon tile + title + chevron,
    /// with a hairline underneath. Previously had no destination on either
    /// platform - `action` now opens the matching bottom sheet.
    func makePolicyRow(icon: UIImage?, title: String, action: Selector) -> UIView {
        let container = UIStackView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .vertical
        container.alignment = .fill
        container.spacing = 0
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))

        let iconTile = makeIconTile(image: icon, iconSide: 18)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        label.textColor = .white
        label.numberOfLines = 0
        label.text = title
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let chevron = makeChevron()

        let row = UIStackView(arrangedSubviews: [iconTile, label, chevron])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)

        container.addArrangedSubview(row)
        container.addArrangedSubview(makeHairline(color: Palette.moreHairline))
        return container
    }

    /// `isFreeForUser` is the same free/paid resolution already driving this
    /// screen's button label and CTA routing - reused here to pick which doc
    /// variant to fetch (see `CancellationPolicySheetViewController.isFree`).
    @objc private func cancellationPolicyRowTapped() {
        CancellationPolicySheetViewController.present(from: self, isFree: isFreeForUser)
    }

    @objc private func termsAndConditionsRowTapped() {
        TermsAndConditionsSheetViewController.present(from: self, isFree: isFreeForUser)
    }

    // MARK: Waitlist banner + sticky bottom bar

    func buildWaitlistBanner() {
        waitlistBanner.translatesAutoresizingMaskIntoConstraints = false
        waitlistBanner.isHidden = true
        view.insertSubview(waitlistBanner, belowSubview: bottomBar)

        let bannerBg = GradientFadeView()
        bannerBg.translatesAutoresizingMaskIntoConstraints = false
        bannerBg.setColors([UIColor.white, UIColor(hex: "#EBD463")], locations: [0.0, 1.0])
        bannerBg.layer.cornerRadius = 16
        bannerBg.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bannerBg.layer.masksToBounds = true
        bannerBg.layer.borderWidth = 1
        bannerBg.layer.borderColor = UIColor(hex: "#FFEDA5").cgColor
        waitlistBanner.addSubview(bannerBg)

        let bellView = UIImageView(image: GroupTrainingDetailViewController.icon(["ic_bell_brown", "bell"])?
            .withRenderingMode(.alwaysTemplate))
        bellView.translatesAutoresizingMaskIntoConstraints = false
        bellView.tintColor = Palette.waitlistBannerInk
        bellView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        label.textColor = Palette.waitlistBannerInk
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = Copy.waitlistBanner

        let row = UIStackView(arrangedSubviews: [bellView, label])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        waitlistBanner.addSubview(row)

        NSLayoutConstraint.activate([
            bannerBg.topAnchor.constraint(equalTo: waitlistBanner.topAnchor),
            bannerBg.leadingAnchor.constraint(equalTo: waitlistBanner.leadingAnchor),
            bannerBg.trailingAnchor.constraint(equalTo: waitlistBanner.trailingAnchor),
            bannerBg.bottomAnchor.constraint(equalTo: waitlistBanner.bottomAnchor),

            bellView.widthAnchor.constraint(equalToConstant: 16),
            bellView.heightAnchor.constraint(equalToConstant: 16),

            row.topAnchor.constraint(equalTo: waitlistBanner.topAnchor, constant: 8),
            row.centerXAnchor.constraint(equalTo: waitlistBanner.centerXAnchor),
            row.leadingAnchor.constraint(greaterThanOrEqualTo: waitlistBanner.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(lessThanOrEqualTo: waitlistBanner.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: waitlistBanner.bottomAnchor, constant: -24),

            waitlistBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waitlistBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            waitlistBanner.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 16)
        ])
    }

    func buildBottomBar() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = Palette.bottomBarTopBorder
        bottomBar.layer.cornerRadius = 16
        bottomBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomBar.layer.masksToBounds = true
        view.addSubview(bottomBar)

        let surface = GlassCardView(cornerRadius: 16)
        surface.translatesAutoresizingMaskIntoConstraints = false
        surface.fillColor = Palette.cardSurface
        surface.fillAlpha = 1.0
        surface.strokeColor = .clear
        surface.sheenOrigin = .topCenter
        surface.sheenAlpha = 0.08
        bottomBar.addSubview(surface)

        perSessionLabel.translatesAutoresizingMaskIntoConstraints = false
        setPerSessionLabelText(Copy.perSession)

        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = AppFont.semibold.size(18.0, familyName: familyClashDisplay)
        priceLabel.textColor = .white
        priceLabel.numberOfLines = 1
        priceLabel.lineBreakMode = .byTruncatingTail

        let priceStack = UIStackView(arrangedSubviews: [perSessionLabel, priceLabel])
        priceStack.translatesAutoresizingMaskIntoConstraints = false
        priceStack.axis = .vertical
        priceStack.alignment = .leading
        priceStack.spacing = 2
        bottomBar.addSubview(priceStack)

        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.bandThickness = 2
        setCTATitle("BOOK SLOT")
        // Android's `btnBookSlot`: `paddingHorizontal="12dp"` with the text and a
        // 16dp chevron centred together, 8dp apart. `GradientCTAButton` owns that
        // layout now (see `setTrailingIcon`), so no per-screen chevron view or
        // manual `contentEdgeInsets` arithmetic is needed here.
        ctaButton.horizontalContentInset = 12
        ctaButton.setTrailingIcon(
            GroupTrainingDetailViewController.icon(["ic_chevron_right_16_dark", "chevron-right"],
                                                   systemFallback: "chevron.right"),
            tint: Palette.ctaInk)
        ctaButton.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)
        ctaButton.setContentHuggingPriority(.required, for: .horizontal)
        ctaButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        bottomBar.addSubview(ctaButton)

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            surface.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 2),
            surface.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            surface.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            surface.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),

            priceStack.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),
            priceStack.centerYAnchor.constraint(equalTo: ctaButton.centerYAnchor),
            priceStack.trailingAnchor.constraint(lessThanOrEqualTo: ctaButton.leadingAnchor, constant: -12),

            ctaButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            ctaButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 14),
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            ctaButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight),
            ctaButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Metric.ctaMinWidth)
        ])
    }

    // MARK: Small builders

    func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        label.textColor = .white
        label.numberOfLines = 0
        label.text = text
        return label
    }

    func makeHairline(color: UIColor) -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = color
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    func makeChevron() -> UIImageView {
        let chevron = UIImageView(image: GroupTrainingDetailViewController.icon(["ic_chevron_right_16", "chevron-right"], systemFallback: "chevron.right")?
            .withRenderingMode(.alwaysTemplate))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        // Current `ic_chevron_right_16`: `strokeColor="#66FFFFFF"` (40% white),
        // not opaque — this tint is already defined on the screen as `Palette.distance`.
        chevron.tintColor = Palette.distance
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            chevron.widthAnchor.constraint(equalToConstant: 16),
            chevron.heightAnchor.constraint(equalToConstant: 16)
        ])
        return chevron
    }

    /// Android's `location_icon_bg`: 38dp rounded square (12pt radius),
    /// 1px solid #101113 border, radial-gradient sheen + #131416 surface.
    func makeIconTile(image: UIImage?, iconSide: CGFloat) -> UIView {
        let tile = GlassCardView(cornerRadius: 12)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = Palette.cardSurface
        tile.fillAlpha = 1.0
        tile.strokeColor = Palette.cardStroke
        tile.strokeAlpha = 1.0
        tile.sheenOrigin = .topCenter
        tile.sheenAlpha = 0.08

        let iconView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
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
}

// MARK: - Static content + icon resolution

private extension GroupTrainingDetailViewController {

    /// First bundled asset wins; a system symbol is the last resort.
    ///
    /// Every candidate list leads with the *Android* drawable name, so importing
    /// the real glyphs later under those exact names upgrades the screen with no
    /// code change. Deliberately does **not** fall through to unrelated
    /// already-bundled iOS assets (e.g. workout-library or booking icons designed
    /// for other screens) — that was rendering the wrong glyph rather than a
    /// missing one, which is what was actually reported. An SF Symbol is a closer
    /// visual match than a mismatched bitmap and needs no new asset.
    static func icon(_ names: [String], systemFallback: String? = nil) -> UIImage? {
        for name in names {
            if let image = UIImage(named: name) { return image }
        }
        if let systemFallback = systemFallback {
            return UIImage(systemName: systemFallback)
        }
        return nil
    }

    /// Maps a backend checklist icon key (see ClassEventController::
    /// APP_DETAIL_ICON_KEYS - always one of this fixed preset set, never raw
    /// emoji) to an asset name + SF Symbol fallback, mirroring Android's
    /// checklistIconFor() in GroupTrainingDetailActivity.kt.
    static func checklistIconAssets(for key: String?) -> (icons: [String], system: String) {
        switch key ?? "" {
        case "towel": return (["ic_towel_18"], "drop.fill")
        case "water": return (["ic_water_18"], "drop.fill")
        case "shoes": return (["ic_shoes_18"], "shoeprints.fill")
        case "clothes": return (["ic_clothes_18"], "tshirt.fill")
        case "rope": return (["ic_skipping_18"], "figure.walk")
        case "glove": return (["ic_glove_18"], "hand.raised.fill")
        case "yoga": return (["ic_yoga_18"], "figure.mind.and.body")
        case "dumbbell": return (["ic_dumbbell_18"], "dumbbell.fill")
        case "socks": return (["ic_clothes_18"], "tshirt.fill")
        case "clock": return (["ic_clock_18"], "clock.fill")
        case "age": return (["ic_person_age_18"], "person.fill")
        case "booking": return (["ic_booking_18"], "calendar")
        case "info": return (["info-hexagon"], "info.circle.fill")
        case "flame": return (["ic_flame_18"], "flame.fill")
        case "heart": return (["ic_heart_20"], "heart.fill")
        default: return (["info-hexagon"], "info.circle.fill")
        }
    }

    /// Converts the API's `[{"text", "icon"}]` checklist array into the row
    /// tuples `appendInfoRows` expects, falling back to the static defaults
    /// below when the class has none set.
    static func checklistRows(from items: [ChecklistItemModel]?, fallback: [(icons: [String], system: String, text: String)]) -> [(icons: [String], system: String, text: String)] {
        guard let items = items, !items.isEmpty else { return fallback }
        return items.compactMap { item in
            guard let text = item.text, !text.isEmpty else { return nil }
            let assets = checklistIconAssets(for: item.icon)
            return (icons: assets.icons, system: assets.system, text: text)
        }
    }

    /// Static "What to bring" list — hard-coded in the Android layout.
    static var whatToBringRows: [(icons: [String], system: String, text: String)] {
        return [
            (["ic_towel_18"], "drop.fill", "Bring a towel — sweating is guaranteed"),
            (["ic_skipping_18"], "figure.walk", "Bring your skipping rope"),
            (["ic_shoes_18"], "shoeprints.fill", "Training shoes with lateral support"),
            (["ic_clothes_18"], "tshirt.fill", "Comfortable workout clothing")
        ]
    }

    /// Static "Things to know" list — hard-coded in the Android layout.
    static var thingsToKnowRows: [(icons: [String], system: String, text: String)] {
        return [
            (["ic_person_age_18"], "person.fill", "Ages 16 and above"),
            (["ic_clock_18"], "clock.fill", "Arrive 10 minutes early"),
            (["ic_booking_18"], "calendar", "Bookings non-refundable within 24 hours"),
            (["ic_glove_18"], "hand.raised.fill", "Gloves provided for boxing classes")
        ]
    }
}
