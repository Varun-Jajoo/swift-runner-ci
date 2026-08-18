//
//  ClassPaymentViewController.swift
//  MyPT
//
//  "Review your training plan" — the paid-class payment screen reached from
//  Group Training Detail's "PROCEED TO PAYMENT" CTA.
//
//  Android reference (ground truth for layout, copy and logic):
//    app/src/main/java/co/com/mypt/UpComingClasses/ClassPaymentScreenActivity.kt
//    app/src/main/res/layout/activity_class_payment_screen.xml
//
//  Payment paths:
//    · Tabby — wired LIVE this phase, following the exact existing app-wide
//      pattern in PaymentMethodsViewController.swift (TabbySDK / TabbyCheckout /
//      TabbyCheckoutPayload). On `.authorized`, POSTs book-class the same way
//      Phase 5's ConfirmSlotSheetViewController does, then pushes
//      SlotConfirmedViewController (Phase 6).
//    · Card — selectable this phase (matches Android's default-selected radio),
//      but its action is a clearly-marked TEMPORARY STUB; the real CCAvenue web
//      flow lands in Phase 8.
//
//  Entry point: GroupTrainingDetailViewController's "PROCEED TO PAYMENT" CTA
//  (`!isFreeForUser` branch), which pushes this screen directly, bypassing the
//  Confirm Slot sheet — matching Android exactly.
//

import UIKit
import SwiftUI
import Tabby

final class ClassPaymentViewController: CommonViewController {

    // MARK: - Input
    //
    // Mirrors the intent extras `ClassPaymentScreenActivity` reads: title / time /
    // location / trained_by / distance / total_price, plus schedule_id (needed
    // here, not read by Android's own onCreate block but required by both the
    // Tabby and — later — the Card payment POST).

    var scheduleId: String = ""
    var classTitle: String = "Morning Flow Yoga"
    var classTime: String = "Wed, 9 Jul • 7-8 AM"
    var classLocation: String = "Silicon Oasis"
    var trainerName: String = ""
    var distance: String = ""
    /// Raw price string, e.g. `"179"` or `"179 AED"` — cleaned the same way
    /// Android's `rawPrice.replace("AED","").replace(" ","").trim()` does.
    var classPrice: String = ""

    // MARK: - Payment selection state

    private enum PaymentOption {
        case tabby
        case card
    }

    /// Android starts with Card ("debit") selected by default and never actually
    /// reaches its own "please select a payment method" toast, since a default is
    /// always set in `onCreate` before the user can tap anything — reproduced here
    /// as a non-optional default rather than modelling dead code.
    private var selectedPaymentOption: PaymentOption = .card {
        didSet { applySelectionUI() }
    }

    // MARK: - Tabby session state (mirrors PaymentMethodsViewController.swift)

    private var tabbySessionId: String?
    private var tabbyPaymentId: String?
    private var isTabbyInstallmentsAvailable = false
    /// Bumped on every `configureTabbySession()` call; a completion checks
    /// its captured token against the current one before writing session
    /// state, so a stale reply (e.g. from the `.expired` reconfigure path)
    /// can't clobber a newer in-flight session.
    private var tabbyConfigToken = 0

    // MARK: - Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let backButtonDiameter: CGFloat = 40
        static let sectionCardCornerRadius: CGFloat = 16
        static let sectionCardPadding: CGFloat = 20
        static let couponCardPadding: CGFloat = 16
        static let iconTileSide: CGFloat = 38
        static let couponIconSide: CGFloat = 18
        static let paymentOptionCardPadding: CGFloat = 16
        static let paymentOptionRowPadding: CGFloat = 14
        static let paymentOptionRowInset: CGFloat = 12
        static let paymentLogoWidth: CGFloat = 52
        static let paymentLogoHeight: CGFloat = 29
        static let checkboxSide: CGFloat = 20
        static let ctaHeight: CGFloat = 48
    }

    private enum Palette {
        static let sectionLabel = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75) // #BFFAFAFA
        static let cardFill = UIColor(hex: "#18191C")
        static let cardStroke = UIColor(hex: "#232323")
        static let tileFill = UIColor(hex: "#101113")
        static let divider = UIColor.white.withAlphaComponent(0.10)               // #1AFFFFFF
        static let rowTitle = UIColor(hex: "#FAFAFA")
        static let rowSubtitle = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)  // #8CFAFAFA
        static let chipText = UIColor(hex: "#F0F0F0")
        static let couponTitle = UIColor(hex: "#F0F0F0")
        static let paymentTitle = UIColor.white
        static let paymentSubtitle = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let termsText = UIColor.white
        // This screen's `tvPaymentPrice` is `#000000`, not the `#131416` every
        // other CTA in the module uses.
        static let ctaInk = UIColor(hex: "#000000")
        static let headerTitle = UIColor.white
        static let paymentRowFill = UIColor(hex: "#212122")
        static let paymentRowStroke = UIColor.white.withAlphaComponent(0.10)
        static let applyButtonFill = UIColor(hex: "#1D1E1D")
        static let discountTileFill = GroupClassColor.lime.color.withAlphaComponent(0.10)
    }

    private enum Copy {
        static let headerTitle = "Review your training plan"
        static let savingsSectionTitle = "Savings corners"
        static let classDetailsSectionTitle = "Class Details"
        static let paymentSectionTitle = "Choose how you\u{2019}d like to pay"
        static let couponTitleFormat = "Save AED 35 with \u{2018}GYM20\u{2019}"
        static let viewAllCoupons = "View all coupons"
        static let applyButton = "APPLY"
        static let durationChip = "60 MINS"
        static let trainerSubtitle = "Certified MyPT Trainer"
        static let priceSubtitle = "Group Class Cost"
        static let tabbyTitle = "Tabby"
        static let tabbyBadge = "EASY INSTALMENTS"
        static let tabbyFallbackSubtext = "4 easy payments"
        static let cardTitle = "Card"
        static let cardBadge = "SECURE PAYMENT"
        static let cardSubtext = "Pay full amount now"
        static let termsText = "I have read and agree to the MyPT Personal Training Terms & Conditions"
        static let ctaTitle = "CONFIRM AND PAY"
        static let selectPaymentMethodAlert = "Please select a payment method"
        static let tabbyMinimumAlert = "Tabby requires a minimum order amount of 10 AED. Please select Card payment."
    }

    // MARK: - Views

    /// Android's root has a full-bleed `ImageView` (`@drawable/bg_image`, a
    /// soft dark-green top-centre glow) layered over `#000A04` — this screen
    /// previously had only the flat colour, no image.
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let footerView = UIView()
    private let ctaButton = GradientCTAButton()

    private let classTitleLabel = UILabel()
    private let classDateTimeLabel = UILabel()
    private let locationLabel = UILabel()
    private let distanceLabel = UILabel()
    private let trainerLabel = UILabel()
    private let priceLabel = UILabel()
    private let couponTitleLabel = UILabel()

    private let tabbySubtextLabel = UILabel()
    private let tabbyCheckbox = GroupClassCheckboxView()
    private let cardCheckbox = GroupClassCheckboxView()
    private var tabbyRow: UIView?
    private var cardRow: UIView?

    private let termsCheckbox = GroupClassCheckboxView()
    /// Android's `checkTerms` starts selected and toggles on tap, but never
    /// gates the CTA — replicated exactly, cosmetic-only per the real Kotlin.
    private var isTermsChecked = true {
        didSet { termsCheckbox.isChecked = isTermsChecked }
    }

    /// Set once in `buildHeader()`, consumed by `buildScrollView()` — both run
    /// inside the same `buildLayout()` call.
    private var headerBottomAnchor: NSLayoutYAxisAnchor?

    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = GroupClassColor.bg.color
        buildLayout()
        populateUI()
        applySelectionUI()
        // Tabby commented out for now.
//        configureTabbySession()
        refreshLatestPrice()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Populate

    private func populateUI() {
        classTitleLabel.text = classTitle
        classDateTimeLabel.text = classTime
        locationLabel.text = classLocation

        let trimmedTrainer = trainerName.trimmingCharacters(in: .whitespacesAndNewlines)
        trainerLabel.text = trimmedTrainer.isEmpty
            ? "Trainer: Sara K."
            : (trimmedTrainer.hasPrefix("Trainer:") ? trimmedTrainer : "Trainer: \(trimmedTrainer)")

        let trimmedDistance = distance.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedDistance.isEmpty {
            distanceLabel.text = trimmedDistance.contains("away") ? trimmedDistance : "\(trimmedDistance) away"
        }

        priceLabel.text = "\(cleanedPrice()) AED"
        couponTitleLabel.text = Copy.couponTitleFormat

        // Tabby commented out for now.
//        applyTabbySubtext()
    }

    /// The price shown here was carried forward from whatever screen pushed
    /// this one (detail/slot-open), which is itself just a snapshot from
    /// whenever THAT screen last loaded - if the admin edits the class price
    /// in between, the payment screen (and the amount actually charged, since
    /// cleanedPrice() reads straight off classPrice) silently kept using the
    /// old number. Refetches class-detail here so the price - and whatever
    /// gets charged - reflects what the backend has right now, not a stale
    /// carried-forward value. "Populate instantly, then refresh" - same
    /// pattern GroupTrainingDetailViewController already uses.
    private func refreshLatestPrice() {
        guard !scheduleId.isEmpty else { return }

        let stored = appUserDefaults.getLatLong()?.components(separatedBy: ",")
        let lat = Double(stored?.first ?? "") ?? GroupClassCardFormatter.fallbackLatitude
        let lng = Double(stored?.last ?? "") ?? GroupClassCardFormatter.fallbackLongitude
        let params: [String: String] = ["lat": "\(lat)", "long": "\(lng)", "schdule_id": scheduleId]

        UpcomingClassVM.classDetailsApi(inputParams: params, isShowLoader: false) { [weak self] result in
            guard let self = self,
                  result?.status == true,
                  let detail = result?.data,
                  let freshPrice = detail.price?.value,
                  !freshPrice.isEmpty else { return }

            DispatchQueue.main.async {
                self.classPrice = freshPrice
                self.priceLabel.text = "\(self.cleanedPrice()) AED"
            }
        }
    }

    /// Android: `rawPrice.replace("AED","").replace(" ","").trim()`.
    private func cleanedPrice() -> String {
        return classPrice
            .replacingOccurrences(of: "AED", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func priceValue() -> Double {
        return Double(cleanedPrice()) ?? 0
    }

    /// Port of the dynamic "4 payments of AED X" subtext.
    private func applyTabbySubtext() {
        let value = priceValue()
        guard value > 0 else {
            tabbySubtextLabel.text = Copy.tabbyFallbackSubtext
            return
        }
        let installment = value / 4.0
        let formatted = installment.truncatingRemainder(dividingBy: 1.0) == 0
            ? String(format: "%.0f", installment)
            : String(format: "%.2f", installment)
        tabbySubtextLabel.text = "4 payments of AED \(formatted)"
    }

    // MARK: - Selection

    private func applySelectionUI() {
        tabbyCheckbox.isChecked = (selectedPaymentOption == .tabby)
        cardCheckbox.isChecked = (selectedPaymentOption == .card)
    }

    @objc private func tabbyRowTapped() {
        TapticEngine.selection.feedback()
        selectedPaymentOption = .tabby
    }

    @objc private func cardRowTapped() {
        TapticEngine.selection.feedback()
        selectedPaymentOption = .card
    }

    @objc private func termsTapped() {
        isTermsChecked.toggle()
    }

    /// This screen is unreachable for a free booking (paid classes route here
    /// directly; free ones go through `ConfirmSlotSheetViewController` instead),
    /// so the paid variant is deterministically the only correct one - same
    /// reasoning as Android's identical call site.
    @objc private func showTermsSheetTapped() {
        TermsAndConditionsSheetViewController.present(from: self, isFree: false)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - CTA

    @objc private func confirmAndPayTapped() {
        TapticEngine.selection.feedback()

        switch selectedPaymentOption {
        case .card:
            pushCCAvenuePayment()
        case .tabby:
            startTabbyCheckout()
        }
    }

    /// Port of Android's `linearPay` "debit" branch: pushes the CCAvenue
    /// WebView with the same extras `CCavenueWebCLassActivity` reads.
    private func pushCCAvenuePayment() {
        let controller = CCAvenueClassPaymentViewController()
        controller.scheduleId = scheduleId
        controller.classTitle = classTitle
        controller.classTime = classTime
        controller.classLocation = classLocation
        controller.trainerName = trainerName
        controller.distance = distance
        controller.price = cleanedPrice()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Network — POST api/book-class (Tabby success path)

    private func completeTabbyBooking(transactionId: String) {
        UpcomingClassVM.bookGroupClassApi(scheduleId: scheduleId,
                                          transactionId: transactionId,
                                          paymentType: "tabby") { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleBookingResponse(result)
            }
        }
    }

    /// Port of the `data`-shape branch in `ClassBookingResponseModel`'s decode —
    /// same handling as `ConfirmSlotSheetViewController.handleBookingResponse`.
    private func handleBookingResponse(_ result: BookClassBaseModel?) {
        guard let result = result else {
            AlertHelper.shared.showCustomeAlert(title: "", message: "Booking failed. Please try again.", actions: ["OK"], completion: nil)
            return
        }

        if result.status == true {
            pushSlotConfirmed()
            return
        }

        if isBlacklisted(result) {
            let controller = BookingPausedViewController()
            controller.reason = result.blacklistDetail?.reason ?? "2 consecutive no-shows for group classes"
            controller.resumesOn = result.blacklistDetail?.resumesOn ?? "12 August 2026, 6:00 PM"
            controller.hoursRemaining = result.blacklistDetail?.hoursRemaining?.value ?? "24"
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
            return
        }

        let trimmedMessage = (result.msg ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let message = trimmedMessage.isEmpty ? "Booking failed. Please try again." : trimmedMessage
        AlertHelper.shared.showCustomeAlert(title: "", message: message, actions: ["OK"], completion: nil)
    }

    private func isBlacklisted(_ model: BookClassBaseModel) -> Bool {
        if model.isBlacklisted == true { return true }
        if model.code == "BLACKLISTED" { return true }
        let lowered = (model.msg ?? "").lowercased()
        return lowered.contains("blacklisted") || lowered.contains("paused")
    }

    private func pushSlotConfirmed() {
        let controller = SlotConfirmedViewController()
        controller.classTitle = classTitle
        controller.classTime = classTime
        controller.classLocation = classLocation
        controller.trainerName = trainerName
        controller.distance = distance
        controller.classPrice = classPrice
        // scheduleId intentionally left blank: this screen has already POSTed
        // book-class by the time Slot Confirmed appears, matching the Confirm
        // Slot sheet's free-booking path (Phase 5) and avoiding a duplicate POST.
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - Tabby (mirrors PaymentMethodsViewController.swift's existing pattern)

private extension ClassPaymentViewController {

    func configureTabbySession() {
        let min: UInt64 = 1_000_000_000
        let max: UInt64 = 9_999_999_999
        let randomNumber = UInt64.random(in: min...max)

        let payAmt = Float(cleanedPrice()) ?? 0.0
        let todayDateStr = DateFormatterHelper.shared.getTodayDate(fromFormat: "yyyy-MM-dd HH:mm:ss zzz")

        let customerPayment = Payment(
            amount: "\(payAmt)",
            currency: .AED,
            description: "Group Class Booking",
            buyer: Buyer(
                email: "otp.success@tabby.ai",
                phone: "+971500000001",
                name: "",
                dob: nil
            ),
            buyer_history: BuyerHistory(
                registered_since: todayDateStr,
                loyalty_level: 0
            ),
            order: Order(
                reference_id: "#\(randomNumber)",
                items: [
                    OrderItem(
                        description: "",
                        product_url: "https://tabby.store/p/SKU123",
                        quantity: 1,
                        reference_id: "SKU123",
                        title: classTitle,
                        unit_price: "\(payAmt)",
                        category: ""
                    )
                ],
                shipping_amount: "",
                tax_amount: ""
            ),
            order_history: [
                OrderHistory(
                    purchased_at: todayDateStr,
                    amount: "",
                    status: .new,
                    shipping_address: ShippingAddress(address: "", city: "", zip: "")
                )
            ],
            shipping_address: ShippingAddress(address: "", city: "", zip: "")
        )

        let checkoutPayload = TabbyCheckoutPayload(
            merchant_code: "ae",
            lang: .en,
            payment: customerPayment
        )

        tabbyConfigToken += 1
        let requestToken = tabbyConfigToken

        TabbySDK.shared.setup(withApiKey: AppConstant.tabby_key)
        TabbySDK.shared.configure(forPayment: checkoutPayload) { [weak self] result in
            guard let self = self, self.tabbyConfigToken == requestToken else { return }
            switch result {
            case .success(let sessionInfo):
                self.tabbySessionId = sessionInfo.sessionId
                self.tabbyPaymentId = sessionInfo.paymentId
                self.isTabbyInstallmentsAvailable = sessionInfo.tabbyProductTypes.contains(.installments)
            case .failure(let error):
                debugPrint("[ClassPayment] Tabby configure failed: \(error.localizedDescription)")
                self.isTabbyInstallmentsAvailable = false
            }
        }
    }

    /// Android's own minimum-order guard, checked at CTA-tap time (the payment
    /// option can be *selected* below 10 AED, it just can't be *confirmed*).
    func startTabbyCheckout() {
        guard priceValue() >= 10.0 else {
            AlertHelper.shared.showCustomeAlert(title: "", message: Copy.tabbyMinimumAlert, actions: ["OK"], completion: nil)
            return
        }

        guard isTabbyInstallmentsAvailable, tabbySessionId != nil else {
            debugPrint("[ClassPayment] Tabby installments not available or session missing.")
            AlertHelper.shared.showCustomeAlert(title: "", message: "Tabby is not available right now. Please try Card instead.", actions: ["OK"], completion: nil)
            return
        }

        if #available(iOS 14.0, *) {
            let tabbyCheckoutView = TabbyCheckout(productType: .installments) { [weak self] result in
                guard let self = self else { return }
                self.dismiss(animated: true) {
                    switch result {
                    case .authorized:
                        self.completeTabbyBooking(transactionId: self.tabbyPaymentId ?? "")
                    case .rejected:
                        AlertHelper.shared.showCustomeAlert(title: "", message: "Payment Rejected", actions: ["OK"], completion: nil)
                    case .close:
                        break
                    case .expired:
                        self.configureTabbySession()
                    @unknown default:
                        break
                    }
                }
            }
            let hostingController = UIHostingController(rootView: tabbyCheckoutView)
            present(hostingController, animated: true)
        } else {
            let alert = UIAlertController(title: "Unsupported iOS Version",
                                          message: "Tabby checkout requires iOS 14 or later.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - Layout

private extension ClassPaymentViewController {

    func buildLayout() {
        buildBackgroundImage()
        buildHeader()
        buildFooter()
        buildScrollView()
    }

    func buildBackgroundImage() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: "class-payment-bg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.insertSubview(backgroundImageView, at: 0)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: Header (fixed, above the scroll view — matches Android's separate headerLayout)

    func buildHeader() {
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .clear
        view.addSubview(header)

        let backButton = GlassCircularIconButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.configure(icon: ClassPaymentViewController.icon(["ic_chevron_left_24"], systemFallback: "chevron.left"),
                             diameter: Metric.backButtonDiameter)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        header.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
        titleLabel.textColor = Palette.headerTitle
        titleLabel.numberOfLines = 1
        titleLabel.text = Copy.headerTitle
        header.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metric.horizontalInset),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metric.horizontalInset),

            backButton.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            backButton.topAnchor.constraint(equalTo: header.topAnchor),
            backButton.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -12),
            backButton.widthAnchor.constraint(equalToConstant: Metric.backButtonDiameter),
            backButton.heightAnchor.constraint(equalToConstant: Metric.backButtonDiameter),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: header.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])

        headerBottomAnchor = header.bottomAnchor
    }

    // MARK: Footer CTA

    func buildFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = GroupClassColor.bg2.color
        view.addSubview(footerView)

        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.bandThickness = 2
        ctaButton.configure(title: Copy.ctaTitle,
                            font: AppFont.medium.size(14.0, familyName: familyFunnelSans),
                            titleColor: Palette.ctaInk)
        // Text + 8pt + 16pt chevron, centred together — the shared component owns
        // that layout (`setTrailingIcon`), matching Android's centred CTA row.
        ctaButton.horizontalContentInset = 12
        ctaButton.setTrailingIcon(
            ClassPaymentViewController.icon(["ic_chevron_right_16_dark", "chevron-right"],
                                            systemFallback: "chevron.right"),
            tint: Palette.ctaInk)
        ctaButton.addTarget(self, action: #selector(confirmAndPayTapped), for: .touchUpInside)
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

    // MARK: Scroll container

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
        contentStack.layoutMargins = UIEdgeInsets(top: 0, left: Metric.horizontalInset, bottom: 30, right: Metric.horizontalInset)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerBottomAnchor ?? view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Savings corner section commented out per design update
        let classDetailsLabel = makeSectionLabel(Copy.classDetailsSectionTitle, topMargin: 20)
        let classDetailsCard = makeClassDetailsCard()
        let paymentLabel = makeSectionLabel(Copy.paymentSectionTitle)
        let paymentCard = makePaymentOptionsCard()
        let termsRow = makeTermsRow()

        contentStack.addArrangedSubview(classDetailsLabel)
        contentStack.setCustomSpacing(12, after: classDetailsLabel)
        contentStack.addArrangedSubview(classDetailsCard)
        contentStack.setCustomSpacing(35, after: classDetailsCard)

        contentStack.addArrangedSubview(paymentLabel)
        contentStack.setCustomSpacing(12, after: paymentLabel)
        contentStack.addArrangedSubview(paymentCard)
        contentStack.setCustomSpacing(20, after: paymentCard)

        contentStack.addArrangedSubview(termsRow)
    }

    func makeSectionLabel(_ text: String, topMargin: CGFloat = 0) -> UIView {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        label.textColor = Palette.sectionLabel
        label.numberOfLines = 1
        label.text = text
        if topMargin > 0 {
            let wrapper = UIView()
            wrapper.translatesAutoresizingMaskIntoConstraints = false
            wrapper.addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: topMargin),
                label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
                label.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
            ])
            return wrapper
        }
        return label
    }

    // MARK: Coupon teaser (cosmetic only — Android's own APPLY button has no listener)

    func makeCouponCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.sectionCardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        // `card_details_bg`: flat fill/stroke plus a top-centre radial sheen —
        // every one of this screen's three cards has it, not just Confirmed's.
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        // `discount_icon_bg`: lime-tinted 8dp tile, distinct from the generic
        // dark `location_icon_bg` recipe every other row on this screen uses.
        let iconTile = makeDiscountIconTile(image: ClassPaymentViewController.icon(["ic_discount_percent_18", "discount-percent"]),
                                            iconSide: Metric.couponIconSide)

        couponTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        couponTitleLabel.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        couponTitleLabel.textColor = Palette.couponTitle
        couponTitleLabel.numberOfLines = 2

        let viewAllLabel = UILabel()
        viewAllLabel.translatesAutoresizingMaskIntoConstraints = false
        viewAllLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        viewAllLabel.textColor = Palette.rowSubtitle
        viewAllLabel.text = Copy.viewAllCoupons

        let viewAllChevron = UIImageView(image: ClassPaymentViewController.icon(["ic_chevron_right_16", "chevron-right", "ic_arrow_right"])?
            .withRenderingMode(.alwaysTemplate))
        viewAllChevron.tintColor = Palette.rowSubtitle
        viewAllChevron.translatesAutoresizingMaskIntoConstraints = false
        viewAllChevron.contentMode = .scaleAspectFit

        let viewAllRow = UIStackView(arrangedSubviews: [viewAllLabel, viewAllChevron])
        viewAllRow.translatesAutoresizingMaskIntoConstraints = false
        viewAllRow.axis = .horizontal
        viewAllRow.alignment = .center
        viewAllRow.spacing = 4

        let textStack = UIStackView(arrangedSubviews: [couponTitleLabel, viewAllRow])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 2

        let applyLabel = UILabel()
        applyLabel.translatesAutoresizingMaskIntoConstraints = false
        applyLabel.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        applyLabel.textColor = .white
        applyLabel.text = Copy.applyButton

        let applyChevron = UIImageView(image: ClassPaymentViewController.icon(["ic_chevron_right_16", "chevron-right", "ic_arrow_right"])?
            .withRenderingMode(.alwaysTemplate))
        applyChevron.tintColor = .white
        applyChevron.translatesAutoresizingMaskIntoConstraints = false
        applyChevron.contentMode = .scaleAspectFit

        let applyButton = UIStackView(arrangedSubviews: [applyLabel, applyChevron])
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.axis = .horizontal
        applyButton.alignment = .center
        applyButton.spacing = 4
        applyButton.isLayoutMarginsRelativeArrangement = true
        applyButton.layoutMargins = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        // `btn_apply_bg`: 8dp radius, solid `#1D1E1D` fill, 1dp `#1AFFFFFF`
        // stroke — not a translucent capsule.
        applyButton.backgroundColor = Palette.applyButtonFill
        applyButton.layer.cornerRadius = 8
        applyButton.layer.masksToBounds = true
        applyButton.layer.borderWidth = 1
        applyButton.layer.borderColor = Palette.divider.cgColor
        // Android's `btnApplyCoupon` is drawn but has no `OnClickListener` — left
        // non-interactive here too, rather than inventing a coupon flow.

        card.addSubview(iconTile)
        card.addSubview(textStack)
        card.addSubview(applyButton)

        NSLayoutConstraint.activate([
            iconTile.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Metric.couponCardPadding),
            iconTile.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconTile.widthAnchor.constraint(equalToConstant: Metric.iconTileSide),
            iconTile.heightAnchor.constraint(equalToConstant: Metric.iconTileSide),

            applyButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Metric.couponCardPadding),
            applyButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            applyButton.heightAnchor.constraint(equalToConstant: 36),

            textStack.leadingAnchor.constraint(equalTo: iconTile.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: applyButton.leadingAnchor, constant: -8),
            textStack.topAnchor.constraint(equalTo: card.topAnchor, constant: Metric.couponCardPadding),
            textStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Metric.couponCardPadding),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        return card
    }

    // MARK: Class Details card

    func makeClassDetailsCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.sectionCardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        classTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        classTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        classTitleLabel.textColor = Palette.rowTitle
        classTitleLabel.numberOfLines = 1

        classDateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        classDateTimeLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        classDateTimeLabel.textColor = Palette.rowSubtitle
        classDateTimeLabel.numberOfLines = 1

        let durationChip = PillChipView(text: Copy.durationChip)
        durationChip.translatesAutoresizingMaskIntoConstraints = false
        durationChip.configure(text: Copy.durationChip,
                               font: AppFont.medium.size(12.0, familyName: familyFunnelSans),
                               textColor: Palette.chipText)
        // `chip_60_mins_bg`: `#33FFFFFF -> #00FFFFFF` fill, `#33FAFAFA`
        // (~20% alpha) stroke, `paddingHorizontal=12dp paddingVertical=4dp`.
        durationChip.fillColor = UIColor.white.withAlphaComponent(0.08)
        durationChip.strokeColor = UIColor.white.withAlphaComponent(0.2)
        durationChip.contentInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)

        let classRow = makeDetailRow(icon: ClassPaymentViewController.icon(["ic_yoga_18"], systemFallback: "figure.yoga"),
                                     titleLabel: classTitleLabel,
                                     subtitleLabel: classDateTimeLabel,
                                     accessory: durationChip)

        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        locationLabel.textColor = Palette.rowTitle
        locationLabel.numberOfLines = 1

        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        distanceLabel.textColor = Palette.rowSubtitle
        distanceLabel.numberOfLines = 1
        distanceLabel.text = "2.1 km away"

        let locationRow = makeDetailRow(icon: ClassPaymentViewController.icon(["ic_location_pin_small"], systemFallback: "mappin.and.ellipse"),
                                        titleLabel: locationLabel,
                                        subtitleLabel: distanceLabel)

        trainerLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        trainerLabel.textColor = Palette.rowTitle
        trainerLabel.numberOfLines = 1

        let trainerSubtitleLabel = UILabel()
        trainerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerSubtitleLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        trainerSubtitleLabel.textColor = Palette.rowSubtitle
        trainerSubtitleLabel.numberOfLines = 1
        trainerSubtitleLabel.text = Copy.trainerSubtitle

        let trainerRow = makeDetailRow(icon: ClassPaymentViewController.icon(["ic_trainer_running_18"], systemFallback: "figure.run"),
                                       titleLabel: trainerLabel,
                                       subtitleLabel: trainerSubtitleLabel)

        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        priceLabel.textColor = Palette.rowTitle
        priceLabel.numberOfLines = 1

        let priceSubtitleLabel = UILabel()
        priceSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceSubtitleLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        priceSubtitleLabel.textColor = Palette.rowSubtitle
        priceSubtitleLabel.numberOfLines = 1
        priceSubtitleLabel.text = Copy.priceSubtitle

        // dirham-currency ships its own solid-white glyph with the AED cutout
        // baked in — do not tint it, matching how the Slot Confirmed price row
        // treats the same asset.
        let priceRow = makeDetailRow(icon: ClassPaymentViewController.icon(["ic_dirham_icon", "dirham-currency", "ic_aed"]),
                                     titleLabel: priceLabel,
                                     subtitleLabel: priceSubtitleLabel,
                                     tintIcon: false)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 0

        let rows: [UIView] = [classRow, makeDivider(), locationRow, makeDivider(), trainerRow, makeDivider(), priceRow]
        for (index, row) in rows.enumerated() {
            stack.addArrangedSubview(row)
            if index < rows.count - 1 {
                stack.setCustomSpacing(15, after: row)
            }
        }

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: Metric.sectionCardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Metric.sectionCardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Metric.sectionCardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Metric.sectionCardPadding)
        ])
        return card
    }

    func makeIconTile(image: UIImage?, iconSide: CGFloat, tint: UIColor? = .white) -> UIView {
        let tile = GlassCardView(cornerRadius: 12)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = Palette.tileFill
        tile.fillAlpha = 1.0
        tile.strokeColor = UIColor(hex: "#101113")
        tile.strokeAlpha = 1.0
        tile.sheenOrigin = .topCenter
        tile.sheenAlpha = 0.08

        let iconView = UIImageView(image: tint == nil ? image : image?.withRenderingMode(.alwaysTemplate))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        if let tint = tint { iconView.tintColor = tint }
        iconView.contentMode = .scaleAspectFit
        tile.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: iconSide),
            iconView.heightAnchor.constraint(equalToConstant: iconSide)
        ])
        return tile
    }

    /// `discount_icon_bg`: 8dp radius, lime-tinted `#1AE0FE08` fill, `#1AFFFFFF`
    /// stroke, plus a top-centre radial white highlight — distinct from every
    /// other icon tile on this screen, which uses the dark `location_icon_bg`
    /// recipe via `makeIconTile`.
    func makeDiscountIconTile(image: UIImage?, iconSide: CGFloat) -> UIView {
        let tile = GlassCardView(cornerRadius: 8)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = Palette.discountTileFill
        tile.fillAlpha = 1.0
        tile.strokeColor = Palette.divider
        tile.strokeAlpha = 1.0
        tile.sheenOrigin = .topCenter
        tile.sheenAlpha = 0.08

        let iconView = UIImageView(image: image)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        tile.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: iconSide),
            iconView.heightAnchor.constraint(equalToConstant: iconSide)
        ])
        return tile
    }

    func makeDetailRow(icon: UIImage?,
                       titleLabel: UILabel,
                       subtitleLabel: UILabel,
                       accessory: UIView? = nil,
                       tintIcon: Bool = true) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let iconTile = makeIconTile(image: icon, iconSide: 18, tint: tintIcon ? .white : nil)
        iconTile.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 2

        row.addSubview(iconTile)
        row.addSubview(textStack)

        var constraints = [
            iconTile.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            iconTile.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconTile.widthAnchor.constraint(equalToConstant: Metric.iconTileSide),
            iconTile.heightAnchor.constraint(equalToConstant: Metric.iconTileSide),
            iconTile.topAnchor.constraint(equalTo: row.topAnchor),
            iconTile.bottomAnchor.constraint(equalTo: row.bottomAnchor),

            textStack.leadingAnchor.constraint(equalTo: iconTile.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ]

        if let accessory = accessory {
            accessory.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(accessory)
            constraints += [
                textStack.trailingAnchor.constraint(lessThanOrEqualTo: accessory.leadingAnchor, constant: -8),
                accessory.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                accessory.centerYAnchor.constraint(equalTo: row.centerYAnchor)
            ]
        } else {
            constraints.append(textStack.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor))
        }

        NSLayoutConstraint.activate(constraints)
        return row
    }

    func makeDivider() -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = Palette.divider
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    // MARK: Payment options card

    func makePaymentOptionsCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.sectionCardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        // Tabby commented out for now - see tapped()'s matching comment.
//        let tabby = makePaymentOptionRow(logo: ClassPaymentViewController.icon(["tabby", "ic_tabby_icon"]),
//                                         title: Copy.tabbyTitle,
//                                         badgeText: Copy.tabbyBadge,
//                                         subtitleLabel: tabbySubtextLabel,
//                                         checkbox: tabbyCheckbox,
//                                         tapAction: #selector(tabbyRowTapped))
//        tabbyRow = tabby

        let card2 = makePaymentOptionRow(logo: ClassPaymentViewController.icon(["cards_im", "ic_masterCard_icon"]),
                                         title: Copy.cardTitle,
                                         badgeText: Copy.cardBadge,
                                         subtitleLabel: {
                                             let label = UILabel()
                                             label.text = Copy.cardSubtext
                                             return label
                                         }(),
                                         checkbox: cardCheckbox,
                                         tapAction: #selector(cardRowTapped))
        cardRow = card2

        let stack = UIStackView(arrangedSubviews: [card2])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: Metric.paymentOptionCardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Metric.paymentOptionCardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Metric.paymentOptionCardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Metric.paymentOptionCardPadding)
        ])
        return card
    }

    func makePaymentOptionRow(logo: UIImage?,
                              title: String,
                              badgeText: String,
                              subtitleLabel: UILabel,
                              checkbox: GroupClassCheckboxView,
                              tapAction: Selector) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        // `payment_option_card_bg`: 16dp radius, solid `#212122` fill, 1dp
        // `#1AFFFFFF` stroke — not a translucent 12dp glass tint.
        row.backgroundColor = Palette.paymentRowFill
        row.layer.cornerRadius = 16
        row.layer.masksToBounds = true
        row.layer.borderWidth = 1
        row.layer.borderColor = Palette.paymentRowStroke.cgColor

        let tap = UITapGestureRecognizer(target: self, action: tapAction)
        row.addGestureRecognizer(tap)
        row.isUserInteractionEnabled = true

        let logoView = UIImageView(image: logo)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        titleLabel.textColor = Palette.paymentTitle
        titleLabel.text = title

        let badge = PillChipView(text: badgeText)
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.configure(text: badgeText,
                       font: AppFont.medium.size(9.5, familyName: familyFunnelSans),
                       textColor: Palette.chipText)
        // Android's small badges: `paddingHorizontal=8dp paddingVertical=3dp`.
        badge.fillColor = UIColor.white.withAlphaComponent(0.08)
        badge.strokeColor = UIColor.white.withAlphaComponent(0.2)
        badge.contentInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, badge])
        titleRow.translatesAutoresizingMaskIntoConstraints = false
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 6

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        subtitleLabel.textColor = Palette.paymentSubtitle
        subtitleLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [titleRow, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 2

        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.isUserInteractionEnabled = false // the whole row is the tap target

        row.addSubview(logoView)
        row.addSubview(textStack)
        row.addSubview(checkbox)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 2 * Metric.paymentOptionRowPadding + Metric.paymentLogoHeight),

            logoView.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: Metric.paymentOptionRowInset),
            logoView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            logoView.widthAnchor.constraint(equalToConstant: Metric.paymentLogoWidth),
            logoView.heightAnchor.constraint(equalToConstant: Metric.paymentLogoHeight),

            textStack.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 8),
            textStack.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: checkbox.leadingAnchor, constant: -4),

            checkbox.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -Metric.paymentOptionRowInset),
            checkbox.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: Metric.checkboxSide),
            checkbox.heightAnchor.constraint(equalToConstant: Metric.checkboxSide)
        ])
        return row
    }

    // MARK: Terms & Conditions row

    func makeTermsRow() -> UIView {
        let row = GlassCardView(cornerRadius: 8)
        row.translatesAutoresizingMaskIntoConstraints = false
        row.fillColor = UIColor(hex: "#101113")
        row.fillAlpha = 1.0
        row.strokeColor = UIColor(hex: "#27282A")
        row.strokeAlpha = 1.0
        row.showsSheen = false

        termsCheckbox.translatesAutoresizingMaskIntoConstraints = false
        termsCheckbox.isChecked = isTermsChecked

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        label.textColor = Palette.termsText
        label.numberOfLines = 0
        label.text = Copy.termsText

        row.addSubview(termsCheckbox)
        row.addSubview(label)

        let tap = UITapGestureRecognizer(target: self, action: #selector(termsTapped))
        row.addGestureRecognizer(tap)
        row.isUserInteractionEnabled = true

        // The row's own tap only ever toggled the checkbox - the "Terms &
        // Conditions" text itself had no way to actually show the terms.
        // Giving the label its own gesture and making the row's require it to
        // fail first means tapping the text opens the sheet, tapping anywhere
        // else on the row (or the checkbox) still just toggles agreement.
        label.isUserInteractionEnabled = true
        let showTermsTap = UITapGestureRecognizer(target: self, action: #selector(showTermsSheetTapped))
        label.addGestureRecognizer(showTermsTap)
        tap.require(toFail: showTermsTap)

        NSLayoutConstraint.activate([
            termsCheckbox.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
            termsCheckbox.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            termsCheckbox.widthAnchor.constraint(equalToConstant: Metric.checkboxSide),
            termsCheckbox.heightAnchor.constraint(equalToConstant: Metric.checkboxSide),
            termsCheckbox.topAnchor.constraint(greaterThanOrEqualTo: row.topAnchor, constant: 12),
            termsCheckbox.bottomAnchor.constraint(lessThanOrEqualTo: row.bottomAnchor, constant: -12),

            label.leadingAnchor.constraint(equalTo: termsCheckbox.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: row.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -12)
        ])
        return row
    }
}

// MARK: - Icon resolution

private extension ClassPaymentViewController {

    /// First bundled asset wins — leads with the Android drawable name so real
    /// artwork can be dropped in later with no code change. Falls to a system
    /// symbol rather than an unrelated bundled icon designed for another screen.
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
