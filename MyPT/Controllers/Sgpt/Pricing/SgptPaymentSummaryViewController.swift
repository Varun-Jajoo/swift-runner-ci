//
//  SgptPaymentSummaryViewController.swift
//  MyPT
//
//  SGPT credit purchase checkout — "Payment Summary" (Figma node 11226:22250).
//  Reached from SgptPricingViewController once a credit pack is chosen.
//
//  Android reference (ground truth for layout, copy and logic):
//    app/src/main/java/co/com/mypt/UpComingClasses/SgptPaymentSummaryActivity.kt
//    app/src/main/res/layout/activity_sgpt_payment_summary.xml
//
//  Built programmatically (no storyboard scene) rather than in Sgpt.storyboard —
//  this screen shares no cells/carousel with the storyboard-based SeeAll/Pricing
//  scenes, and this module already has a proven all-code pattern for an almost
//  identical payment-options screen: GroupClasses/Payment/ClassPaymentViewController.
//  Reusing that pattern (GlassCardView, PillChipView, GradientCTAButton) avoids
//  hand-authoring new Interface Builder XML with no way to compile-check it here.
//
//  Payment provider wiring (Tabby / Tamara / card) does not exist for SGPT yet —
//  CONFIRM & PAY stubs out the same way Android's does; everything above it is
//  real, driven by the pack passed in.
//

import UIKit

final class SgptPaymentSummaryViewController: CommonViewController {

    // MARK: - Input
    //
    // Mirrors the Intent extras SgptPaymentSummaryActivity.start(...) reads.
    // Session details are optional — reachable without a session in context
    // (a plain top-up), in which case the booking-note card simply doesn't
    // reference one, same as Android.

    var credits: Int = 0
    var price: Int = 0
    var fee: Int = 0
    var vatPercent: Int = 5
    var savings: Int = 0
    var sessionName: String = ""
    var trainerName: String = ""
    var sessionDate: String = ""
    var sessionTime: String = ""
    var sessionImageURL: String = ""

    /// Package tier being bought, plus the club and (optionally) the session to
    /// book in the same step. Needed by api/sgpt-purchase.
    var tierId: String = ""
    var studioId: String = ""
    /// Club shown on the Training Location row. Changing it re-prices the same
    /// bundle against the newly chosen club.
    var studioName: String = ""
    var sessionId: String = ""
    var session: SgptSessionModel?

    // MARK: - Payment selection state

    private enum PayOption {
        case tabby, tamara, card
    }

    private weak var trainingLocationLabel: UILabel?

    private var selectedOption: PayOption = .card {
        didSet { applySelectionUI() }
    }

    // MARK: - Palette / copy

    private enum Palette {
        static let bg = UIColor(hex: "#000A04")
        static let glow = UIColor(hex: "#E0FE08")
        static let sectionLabel = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
        static let cardFill = UIColor(hex: "#131416")
        static let cardStroke = UIColor(hex: "#29292A")
        static let noteFill = UIColor(hex: "#2B2B2C")
        static let sessionTitle = UIColor(hex: "#F0F0F0")
        static let sessionMeta = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let dotSeparator = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let payRowFill = UIColor(hex: "#1E1E1F")
        static let payRowStroke = UIColor.white.withAlphaComponent(0.10)
        static let payTitle = UIColor.white
        static let paySubtitle = UIColor(hex: "#B3B3B3")
        static let chipFill = UIColor.white.withAlphaComponent(0.10)
        static let chipStroke = UIColor(hex: "#FAFAFA").withAlphaComponent(0.20)
        static let chipText = UIColor(hex: "#F0F0F0")
        static let radioOffStroke = UIColor.white.withAlphaComponent(0.70)
        static let radioOnStroke = UIColor(hex: "#9AD600").withAlphaComponent(0.70)
        static let radioOnFill = UIColor(hex: "#9AD600")
        static let summaryLabel = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let summaryValue = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
        static let totalValue = UIColor(hex: "#FAFAFA")
        static let divider = UIColor.white.withAlphaComponent(0.10)
        static let savingsFill = UIColor(red: 117 / 255.0, green: 197 / 255.0, blue: 102 / 255.0, alpha: 0.10)
        static let savingsStroke = UIColor(hex: "#20413E")
        static let savingsText = UIColor(hex: "#89C5C0")
        static let noteText = UIColor.white
        static let noteSubtext = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let ctaInk = UIColor(hex: "#141514")
        static let footerFill = UIColor(hex: "#131416")
        static let footerAccent = UIColor(hex: "#2A8DFF")
        static let imageTileTop = UIColor(hex: "#1A0A3D")
        static let imageTileBottom = UIColor(hex: "#0A0520")
    }

    private enum Copy {
        static let headerTitle = "SGPT Credits"
        static let bookingLabel = "Booking this session after purchase"
        static let fallbackSessionName = "Small Group PT"
        static let trainingLocationLabel = "Training Location"
        static let paymentOptionLabel = "Payment Option"
        static let cancelPolicy = "Cancel > 6 hours before credit refunded. Freeze anytime. Top-up anytime."
        static let orderSummaryLabel = "Order Summary"
        static let serviceFee = "Service fee"
        static let vatFormat = "VAT (%d%%)"
        static let total = "Total"
        static let ctaTitle = "CONFIRM & PAY"
        static let comingSoon = "Paying for Small Group PT credits from the app isn't available yet."

        static let tabbyTitle = "Tabby"
        static let tabbyChip = "EASY INSTALMENTS"
        static let tamaraTitle = "Tamara"
        static let tamaraChip = "ZERO - INTEREST"
        static let tamaraSubtitle = "Split into 3 payments"
        static let cardTitle = "Card"
        static let cardChip = "ONE-TIME SECURE PAYMENT"
        static let cardSubtitle = "Pay full amount now"
    }

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let cardCornerRadius: CGFloat = 12
        static let cardPadding: CGFloat = 20
        static let noteOverlap: CGFloat = 16
        static let payRowHeight: CGFloat = 62
        static let radioSide: CGFloat = 20
        // 48, matching ClassPaymentViewController and the SGPT pricing screen's
        // own "PURCHASE n CREDITS" button - 56 made this CTA visibly taller than
        // the button the user just came from.
        static let ctaHeight: CGFloat = 48
    }

    // MARK: - Views

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerSurfaceView: GlassCardView!
    @IBOutlet weak var ctaButton: GradientCTAButton!
    @IBOutlet weak var ambientGlowView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!

    private let contentStack = UIStackView()

    private let sessionTitleLabel = UILabel()
    private let sessionMetaLabel = UILabel()
    private let sessionImageView = UIImageView()

    private var optionRows: [PayOption: (row: UIView, radio: RadioIndicatorView)] = [:]

    private let creditsValueLabel = UILabel()
    private let feeValueLabel = UILabel()
    private let vatLabel = UILabel()
    private let vatValueLabel = UILabel()
    private let totalValueLabel = UILabel()
    private let savingsChipLabel = UILabel()
    private let savingsChipWrapper = UIView()
    private let autoBookNoteLabel = UILabel()


    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bg
        buildLayout()
        populateSession()
        populateOrderSummary()
        applySelectionUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Populate

    private func populateSession() {
        sessionTitleLabel.text = sessionName.isEmpty ? Copy.fallbackSessionName : sessionName
        sessionMetaLabel.text = [trainerName, sessionDate, sessionTime]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "  \u{00B7}  ")

        if let url = URL(string: sessionImageURL), !sessionImageURL.isEmpty {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self, let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async { self.sessionImageView.image = image }
            }.resume()
        }
    }

    private func populateOrderSummary() {
        let vat = Double(price + fee) * Double(vatPercent) / 100.0
        let total = Double(price + fee) + vat

        creditsValueLabel.text = currency(Double(price))
        feeValueLabel.text = currency(Double(fee))
        vatLabel.text = String(format: Copy.vatFormat, vatPercent)
        vatValueLabel.text = currency(vat)
        totalValueLabel.text = currency(total)

        if savings > 0 {
            let freeSessions = savings / 50
            savingsChipWrapper.isHidden = false
            savingsChipLabel.text = freeSessions > 0
                ? "SAVE \(currency(Double(savings))) - THAT'S \(freeSessions) FREE SESSIONS"
                : "SAVE \(currency(Double(savings)))"
        } else {
            savingsChipWrapper.isHidden = true
        }

        let remaining = max(credits - 1, 0)
        let name = sessionName.isEmpty ? "this session" : sessionName
        let head = "This session will be auto-booked after purchase"
        let tail = ". 1 credit used for \(name) \u{2014} \(remaining) credits saved for future sessions."
        // NSAttributedString ignores the label's own .font for any run that
        // doesn't specify one - has to be set explicitly here too, not just
        // .foregroundColor, or this renders in the system default font.
        let noteFont = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        let full = NSMutableAttributedString(
            string: head,
            attributes: [.foregroundColor: Palette.noteText, .font: noteFont]
        )
        full.append(NSAttributedString(string: tail, attributes: [.foregroundColor: Palette.noteSubtext, .font: noteFont]))
        autoBookNoteLabel.attributedText = full
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormat()
        return "AED \(formatter.string(value))"
    }

    /// Minimal Int/1-2dp formatter — this screen never needs a full
    /// NumberFormatter locale dance, just "1,000" vs "1,000.50".
    private struct NumberFormat {
        func string(_ value: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = value.truncatingRemainder(dividingBy: 1.0) == 0 ? 0 : 2
            formatter.minimumFractionDigits = 0
            return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
    }

    // MARK: - Selection

    private func applySelectionUI() {
        for (option, pair) in optionRows {
            pair.radio.isSelected = (option == selectedOption)
        }
    }

    @objc private func tabbyRowTapped() { TapticEngine.selection.feedback(); selectedOption = .tabby }
    @objc private func tamaraRowTapped() { TapticEngine.selection.feedback(); selectedOption = .tamara }
    @objc private func cardRowTapped() { TapticEngine.selection.feedback(); selectedOption = .card }

    @IBAction func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func confirmTapped() {
        ctaButton.isEnabled = false
        SgptVM.sgptPurchaseApi(tierId: tierId,
                               credits: credits,
                               studioId: studioId,
                               sessionId: sessionId) { [weak self] result, errorMessage in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.ctaButton.isEnabled = true

                guard let result = result else {
                    let message = errorMessage ?? "Could not complete the purchase. Please try again."
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }

                var input = SgptBookingSuccessInput(session: self.session ?? SgptSessionModel())
                input.mode = .purchasedAndBooked
                input.packCredits = result.creditsPurchased ?? self.credits
                input.creditsUsed = (result.booked ?? false) ? 1 : 0
                input.creditsRemaining = result.remainingCredits ?? 0
                input.expiresInDays = result.expiresInDays
                input.packPrice = result.price ?? Double(self.price)
                input.vatPercent = self.vatPercent
                SgptBookingSuccessViewController.start(from: self, input: input)
            }
        }
    }

    // MARK: - Entry point

    static func start(from controller: UIViewController,
                      credits: Int,
                      price: Int,
                      fee: Int = 0,
                      vatPercent: Int = 5,
                      savings: Int = 0,
                      sessionName: String = "",
                      trainerName: String = "",
                      date: String = "",
                      time: String = "",
                      image: String = "",
                      tierId: String = "",
                      studioId: String = "",
                      studioName: String = "",
                      sessionId: String = "",
                      session: SgptSessionModel? = nil) {
        let screen: SgptPaymentSummaryViewController = .instantiate(appStoryboard: .sgpt)
        screen.tierId = tierId
        screen.studioId = studioId
        screen.studioName = studioName
        screen.sessionId = sessionId
        screen.session = session
        screen.credits = credits
        screen.price = price
        screen.fee = fee
        screen.vatPercent = vatPercent
        screen.savings = savings
        screen.sessionName = sessionName
        screen.trainerName = trainerName
        screen.sessionDate = date
        screen.sessionTime = time
        screen.sessionImageURL = image
        screen.hidesBottomBarWhenPushed = true
        controller.navigationController?.pushViewController(screen, animated: true)
    }
}

// MARK: - Layout

private extension SgptPaymentSummaryViewController {

    func buildLayout() {
        buildAmbientGlow()
        styleFooter()
        styleHeader()
        buildScrollView()
    }

    /// Figma "Ellipse 3597": a 193pt-radius #E0FE08 circle at 10% opacity,
    /// heavily gaussian-blurred — approximated as a soft radial fade since
    /// UIKit has no blur-filter layer type. Same treatment as the Android fix
    /// (bg_sgpt_ambient_glow.xml).
    func buildAmbientGlow() {
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [Palette.glow.withAlphaComponent(0.10).cgColor,
                           Palette.glow.withAlphaComponent(0.0).cgColor]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        ambientGlowView.layer.addSublayer(gradient)

        DispatchQueue.main.async { [weak ambientGlowView] in
            gradient.frame = ambientGlowView?.bounds ?? .zero
        }
    }

    // MARK: Header

    func styleHeader() {
        headerTitleLabel.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
        headerTitleLabel.textColor = .white
        headerTitleLabel.text = Copy.headerTitle

        if let backButton = headerView.subviews.compactMap({ $0 as? GlassCircularIconButton }).first {
            backButton.configure(icon: SgptPaymentSummaryViewController.icon(["ic_chevron_left_24"], systemFallback: "chevron.left"),
                                 diameter: 40)
        }
    }

    // MARK: Footer CTA

    func styleFooter() {
        footerView.backgroundColor = UIColor(hex: "#01368F")
        footerView.layer.cornerRadius = 16
        footerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        footerView.clipsToBounds = true

        footerSurfaceView.cornerRadius = 16
        footerSurfaceView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        footerSurfaceView.fillColor = Palette.footerFill
        footerSurfaceView.fillAlpha = 1.0
        footerSurfaceView.showsSheen = true
        footerSurfaceView.sheenOrigin = .topCenter
        footerSurfaceView.sheenAlpha = 0.08

        ctaButton.bandThickness = 3
        ctaButton.configure(title: Copy.ctaTitle,
                            font: AppFont.medium.size(14.0, familyName: familyFunnelSans),
                            titleColor: Palette.ctaInk,
                            cornerRadius: 12)
        ctaButton.setTrailingIcon(UIImage(named: "sgpt-ic-chevron-right")
                                  ?? UIImage(systemName: "chevron.right"),
                                  tint: Palette.ctaInk)
    }

    func buildScrollView() {
        scrollView.backgroundColor = .clear

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 0
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: Metric.horizontalInset, bottom: 24, right: Metric.horizontalInset)
        contentContainer.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])

        let bookingLabel = makeSectionLabel(Copy.bookingLabel)
        let sessionCard = makeSessionCard()
        let paymentLabel = makeSectionLabel(Copy.paymentOptionLabel)
        let paymentBlock = makeOverlappingBlock(panel: makePaymentOptionsCard(), note: makeNote(icon: "timeSlotClock", systemFallback: "clock", text: Copy.cancelPolicy))
        let summaryLabel = makeSectionLabel(Copy.orderSummaryLabel)
        // Wired to the stored autoBookNoteLabel property itself (not a copy of
        // its text) - populateOrderSummary() runs after buildLayout() and sets
        // that label's attributedText later, so the note has to hold the live
        // instance to pick that up rather than an empty snapshot taken now.
        autoBookNoteLabel.numberOfLines = 0
        let autoBookNote = buildNote(icon: nil, systemFallback: "figure.strengthtraining.traditional", contentLabel: autoBookNoteLabel)
        let summaryBlock = makeOverlappingBlock(panel: makeOrderSummaryCard(), note: autoBookNote)

        contentStack.addArrangedSubview(bookingLabel)
        contentStack.setCustomSpacing(12, after: bookingLabel)
        contentStack.addArrangedSubview(sessionCard)
        contentStack.setCustomSpacing(24, after: sessionCard)

        let locationLabel = makeSectionLabel(Copy.trainingLocationLabel)
        let locationCard = makeTrainingLocationCard()
        contentStack.addArrangedSubview(locationLabel)
        contentStack.setCustomSpacing(12, after: locationLabel)
        contentStack.addArrangedSubview(locationCard)
        contentStack.setCustomSpacing(24, after: locationCard)

        contentStack.addArrangedSubview(paymentLabel)
        contentStack.setCustomSpacing(12, after: paymentLabel)
        contentStack.addArrangedSubview(paymentBlock)
        contentStack.setCustomSpacing(24, after: paymentBlock)

        contentStack.addArrangedSubview(summaryLabel)
        contentStack.setCustomSpacing(12, after: summaryLabel)
        contentStack.addArrangedSubview(summaryBlock)
    }

    func makeSectionLabel(_ text: String) -> UIView {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        label.textColor = Palette.sectionLabel
        label.text = text
        return label
    }

    /// A `GlassCardView` matching Figma's near-flat panel fill plus its
    /// barely-visible top-centre radial sheen (`opacity: 0.08` in the spec).
    func makePanelCard() -> GlassCardView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08
        return card
    }

    // MARK: Session card

    /// Training Location, ported from PurchaseReviewPackageVC's row - with the
    /// difference that here it is tappable: the gym flow locks the club once a
    /// studio_id is set, but an SGPT bundle is priced per club, so switching
    /// clubs is the whole point of the row.
    func makeTrainingLocationCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Palette.cardFill
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = Palette.cardStroke.cgColor

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 0
        nameLabel.text = studioName.isEmpty ? "Select a gym" : studioName
        trainingLocationLabel = nameLabel

        let chevron = UIImageView(image: UIImage(named: "sgpt-ic-chevron-right")
                                  ?? UIImage(systemName: "chevron.right"))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.contentMode = .scaleAspectFit
        chevron.tintColor = .white.withAlphaComponent(0.55)

        card.addSubview(nameLabel)
        card.addSubview(chevron)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            nameLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            chevron.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 8),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14)
        ])

        card.isUserInteractionEnabled = true
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trainingLocationTapped)))
        return card
    }

    /// Opens the existing gym list in picker mode, then re-prices this bundle
    /// against whichever club comes back.
    @objc func trainingLocationTapped() {
        let vc: GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
        vc.inputType = "gym"
        // The listing sorts by proximity and prints a distance per gym; without
        // these it would query from 0,0 and show nonsense distances. Same
        // fallback the SGPT listing screens use.
        vc.inputLat = GroupClassCardFormatter.fallbackLatitude
        vc.inputLong = GroupClassCardFormatter.fallbackLongitude
        vc.flowGymwork = .bookTrainerGymWorkout
        vc.onStudioPicked = { [weak self] pickedId, pickedName in
            guard let self = self else { return }
            self.studioId = pickedId
            self.studioName = pickedName
            self.trainingLocationLabel?.text = pickedName
            self.repriceForSelectedStudio()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    /// The same bundle costs a different amount per club, and tier ids are
    /// per-club too, so the pack is re-matched on credits rather than id.
    private func repriceForSelectedStudio() {
        SgptVM.sgptPackagesApi(studioId: studioId, isShowLoader: true) { [weak self] packs in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let match = packs?.first(where: { $0.credits == self.credits }) else {
                    AlertHelper.shared.showCustomeAlert(message: "This package isn't available at that gym.")
                    return
                }
                self.tierId = match.id?.value ?? ""
                self.price = Int(match.price ?? Double(self.price))
                self.populateOrderSummary()
            }
        }
    }

    func makeSessionCard() -> UIView {
        let card = makePanelCard()

        let imageTile = UIView()
        imageTile.translatesAutoresizingMaskIntoConstraints = false
        imageTile.layer.cornerRadius = 11.5
        imageTile.layer.masksToBounds = true
        let tileGradient = CAGradientLayer()
        tileGradient.colors = [Palette.imageTileTop.cgColor, Palette.imageTileBottom.cgColor]
        tileGradient.startPoint = CGPoint(x: 0, y: 0)
        tileGradient.endPoint = CGPoint(x: 1, y: 1)
        imageTile.layer.addSublayer(tileGradient)

        sessionImageView.translatesAutoresizingMaskIntoConstraints = false
        sessionImageView.contentMode = .scaleAspectFill
        sessionImageView.clipsToBounds = true
        imageTile.addSubview(sessionImageView)

        sessionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionTitleLabel.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        sessionTitleLabel.textColor = Palette.sessionTitle
        sessionTitleLabel.numberOfLines = 1

        sessionMetaLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionMetaLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        sessionMetaLabel.textColor = Palette.sessionMeta
        sessionMetaLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [sessionTitleLabel, sessionMetaLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 6

        card.addSubview(imageTile)
        card.addSubview(textStack)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 77),

            imageTile.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 7.5),
            imageTile.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            imageTile.widthAnchor.constraint(equalToConstant: 60),
            imageTile.heightAnchor.constraint(equalToConstant: 60),

            sessionImageView.topAnchor.constraint(equalTo: imageTile.topAnchor),
            sessionImageView.leadingAnchor.constraint(equalTo: imageTile.leadingAnchor),
            sessionImageView.trailingAnchor.constraint(equalTo: imageTile.trailingAnchor),
            sessionImageView.bottomAnchor.constraint(equalTo: imageTile.bottomAnchor),

            textStack.leadingAnchor.constraint(equalTo: imageTile.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        DispatchQueue.main.async { tileGradient.frame = imageTile.bounds }
        return card
    }

    // MARK: Payment options card

    func makePaymentOptionsCard() -> UIView {
        let card = makePanelCard()

        let tabbyRow = makePaymentRow(logo: SgptPaymentSummaryViewController.icon(["ic_tabby_icon"]),
                                      title: Copy.tabbyTitle,
                                      chip: Copy.tabbyChip,
                                      subtitle: installmentSubtitle(),
                                      option: .tabby,
                                      action: #selector(tabbyRowTapped))

        let tamaraRow = makePaymentRow(logo: SgptPaymentSummaryViewController.icon(["ic_tamara_icon"]),
                                       title: Copy.tamaraTitle,
                                       chip: Copy.tamaraChip,
                                       subtitle: Copy.tamaraSubtitle,
                                       option: .tamara,
                                       action: #selector(tamaraRowTapped))

        let cardRow = makePaymentRow(logo: SgptPaymentSummaryViewController.icon(["ic_masterCard_icon"]),
                                     title: Copy.cardTitle,
                                     chip: Copy.cardChip,
                                     subtitle: Copy.cardSubtitle,
                                     option: .card,
                                     action: #selector(cardRowTapped))

        let stack = UIStackView(arrangedSubviews: [tabbyRow, tamaraRow, cardRow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
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

    func installmentSubtitle() -> String {
        guard price > 0 else { return "4 easy payments" }
        return "4 payments of \(currency(Double(price) / 4.0))"
    }

    // Explicitly `private`, not just relying on the enclosing `private
    // extension` - that only grants members fileprivate-level access, which
    // is wider than the `private enum PayOption` this takes as a parameter,
    // and Swift requires a function to be no more accessible than its own
    // signature.
    private func makePaymentRow(logo: UIImage?, title: String, chip: String, subtitle: String,
                                option: PayOption, action: Selector) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.backgroundColor = Palette.payRowFill
        row.layer.cornerRadius = 16
        row.layer.masksToBounds = true
        row.layer.borderWidth = 1
        row.layer.borderColor = Palette.payRowStroke.cgColor

        let tap = UITapGestureRecognizer(target: self, action: action)
        row.addGestureRecognizer(tap)
        row.isUserInteractionEnabled = true

        let logoView = UIImageView(image: logo)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.contentMode = .scaleAspectFit
        logoView.layer.cornerRadius = 3
        logoView.layer.masksToBounds = true
        logoView.layer.borderWidth = 1
        logoView.layer.borderColor = UIColor(hex: "#393939").cgColor

        let titleLabel = UILabel()
        titleLabel.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        titleLabel.textColor = Palette.payTitle
        titleLabel.text = title

        let chipView = PillChipView(text: chip)
        chipView.configure(text: chip, font: AppFont.semibold.size(9.5, familyName: familyFunnelSans), textColor: Palette.chipText)
        chipView.fillColor = Palette.chipFill
        chipView.strokeColor = Palette.chipStroke
        chipView.contentInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, chipView])
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 8

        let subtitleLabel = UILabel()
        subtitleLabel.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        subtitleLabel.textColor = Palette.paySubtitle
        subtitleLabel.text = subtitle
        subtitleLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [titleRow, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4

        let radio = RadioIndicatorView()
        radio.translatesAutoresizingMaskIntoConstraints = false
        optionRows[option] = (row, radio)

        row.addSubview(logoView)
        row.addSubview(textStack)
        row.addSubview(radio)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: Metric.payRowHeight),

            logoView.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            logoView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            logoView.widthAnchor.constraint(equalToConstant: 36),
            logoView.heightAnchor.constraint(equalToConstant: 28),

            textStack.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 8),
            textStack.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: radio.leadingAnchor, constant: -8),

            radio.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            radio.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            radio.widthAnchor.constraint(equalToConstant: Metric.radioSide),
            radio.heightAnchor.constraint(equalToConstant: Metric.radioSide)
        ])
        return row
    }

    // MARK: Order summary card

    func makeOrderSummaryCard() -> UIView {
        let card = makePanelCard()

        let creditsRow = makeSummaryRow(label: "\(credits) SGPT credits", valueLabel: creditsValueLabel)
        let feeRow = makeSummaryRow(label: Copy.serviceFee, valueLabel: feeValueLabel)
        let vatRow = makeSummaryRow(labelLabel: vatLabel, valueLabel: vatValueLabel)

        let divider = UIView()
        divider.backgroundColor = Palette.divider
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let totalLabel = UILabel()
        totalLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        totalLabel.textColor = Palette.summaryLabel
        totalLabel.text = Copy.total

        totalValueLabel.font = AppFont.medium.size(20.0, familyName: familyFunnelSans)
        totalValueLabel.textColor = Palette.totalValue

        let totalRow = UIStackView(arrangedSubviews: [totalLabel, UIView(), totalValueLabel])
        totalRow.axis = .horizontal
        totalRow.alignment = .center

        savingsChipLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        savingsChipLabel.textColor = Palette.savingsText
        savingsChipLabel.textAlignment = .center
        savingsChipLabel.numberOfLines = 1
        savingsChipLabel.adjustsFontSizeToFitWidth = true
        savingsChipLabel.minimumScaleFactor = 0.8

        savingsChipWrapper.translatesAutoresizingMaskIntoConstraints = false
        savingsChipWrapper.backgroundColor = Palette.savingsFill
        savingsChipWrapper.layer.cornerRadius = 8
        savingsChipWrapper.layer.masksToBounds = true
        savingsChipWrapper.layer.borderWidth = 1
        savingsChipWrapper.layer.borderColor = Palette.savingsStroke.cgColor
        savingsChipLabel.translatesAutoresizingMaskIntoConstraints = false
        savingsChipWrapper.addSubview(savingsChipLabel)
        NSLayoutConstraint.activate([
            savingsChipWrapper.heightAnchor.constraint(equalToConstant: 30),
            savingsChipLabel.leadingAnchor.constraint(equalTo: savingsChipWrapper.leadingAnchor, constant: 12),
            savingsChipLabel.trailingAnchor.constraint(equalTo: savingsChipWrapper.trailingAnchor, constant: -12),
            savingsChipLabel.centerYAnchor.constraint(equalTo: savingsChipWrapper.centerYAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [creditsRow, feeRow, vatRow, divider, totalRow, savingsChipWrapper])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 15
        stack.setCustomSpacing(20, after: totalRow)

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: Metric.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Metric.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Metric.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Metric.cardPadding)
        ])
        return card
    }

    func makeSummaryRow(label: String, valueLabel: UILabel) -> UIView {
        let labelView = UILabel()
        labelView.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        labelView.textColor = Palette.summaryLabel
        labelView.text = label
        return makeSummaryRow(labelLabel: labelView, valueLabel: valueLabel)
    }

    func makeSummaryRow(labelLabel: UILabel, valueLabel: UILabel) -> UIView {
        labelLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        labelLabel.textColor = Palette.summaryLabel
        valueLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        valueLabel.textColor = Palette.summaryValue
        valueLabel.textAlignment = .right
        let row = UIStackView(arrangedSubviews: [labelLabel, valueLabel])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    // MARK: Peeking note (drawn behind the panel above it, matching Figma exactly)

    func makeNote(icon: String?, systemFallback: String, text: String) -> UIView {
        let label = UILabel()
        label.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        label.textColor = Palette.noteText
        label.numberOfLines = 0
        label.text = text
        return buildNote(icon: icon, systemFallback: systemFallback, contentLabel: label)
    }

    func buildNote(icon: String?, systemFallback: String, contentLabel: UILabel) -> UIView {
        let note = UIView()
        note.translatesAutoresizingMaskIntoConstraints = false
        note.backgroundColor = Palette.noteFill
        note.layer.cornerRadius = 16
        // Square top corners - the panel above covers them anyway, and a
        // rounded top edge peeking out at the sides of the overlap reads as a
        // seam. Matches the equivalent Android fix.
        note.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        note.layer.masksToBounds = true

        let iconNames = icon.map { [$0] } ?? []
        let iconView = UIImageView(image: SgptPaymentSummaryViewController.icon(iconNames, systemFallback: systemFallback))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        note.addSubview(iconView)
        note.addSubview(contentLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: note.leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: note.topAnchor, constant: Metric.noteOverlap + 12),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            contentLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            contentLabel.trailingAnchor.constraint(equalTo: note.trailingAnchor, constant: -16),
            contentLabel.topAnchor.constraint(equalTo: iconView.topAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: note.bottomAnchor, constant: -12)
        ])
        return note
    }

    /// Panel drawn on top of note (added second = higher z, matching Figma's
    /// own source order); note's top anchors to the panel's bottom minus a
    /// small overlap so only its lower edge peeks out below the panel.
    func makeOverlappingBlock(panel: UIView, note: UIView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(note)
        container.addSubview(panel)

        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: container.topAnchor),
            panel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            note.topAnchor.constraint(equalTo: panel.bottomAnchor, constant: -Metric.noteOverlap),
            note.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            note.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            note.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }
}

// MARK: - Icon resolution

private extension SgptPaymentSummaryViewController {
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

// MARK: - RadioIndicatorView

/// Two-state radio circle matching Android's bg_sgpt_radio_on / _off exactly:
/// unselected — a plain 70%-white ring; selected — a lime ring plus a filled
/// lime dot inset from it.
private final class RadioIndicatorView: UIView {

    private let ringLayer = CAShapeLayer()
    private let dotLayer = CAShapeLayer()

    var isSelected: Bool = false {
        didSet { applyState() }
    }

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
        ringLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(ringLayer)
        dotLayer.fillColor = SgptPaymentSummaryViewControllerPalette.radioOnFill.cgColor
        layer.addSublayer(dotLayer)
        applyState()
    }

    private func applyState() {
        ringLayer.strokeColor = (isSelected
            ? SgptPaymentSummaryViewControllerPalette.radioOnStroke
            : SgptPaymentSummaryViewControllerPalette.radioOffStroke).cgColor
        ringLayer.lineWidth = isSelected ? 1.5 : 1.765
        dotLayer.isHidden = !isSelected
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let ringInset = ringLayer.lineWidth / 2
        ringLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: ringInset, dy: ringInset)).cgPath
        ringLayer.frame = bounds

        let dotInset: CGFloat = 4.3
        dotLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: dotInset, dy: dotInset)).cgPath
        dotLayer.frame = bounds

        CATransaction.commit()
    }
}

/// Standalone copy of the two radio colours — `RadioIndicatorView` is a
/// top-level file-private type so it can't see its owning controller's
/// nested `Palette` enum.
private enum SgptPaymentSummaryViewControllerPalette {
    static let radioOffStroke = UIColor.white.withAlphaComponent(0.70)
    static let radioOnStroke = UIColor(hex: "#9AD600").withAlphaComponent(0.70)
    static let radioOnFill = UIColor(hex: "#9AD600")
}
