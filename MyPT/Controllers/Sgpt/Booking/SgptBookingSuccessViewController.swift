//
//  SgptBookingSuccessViewController.swift
//  MyPT
//
//  "Credits & Session Locked In!" — the success screen after an SGPT credit
//  pack is purchased and the session booked in the same flow.
//
//  Figma: MyPT UXUI Phase 1, node 11327:21771 (Success State).
//  Android twin: SgptBookingSuccessActivity / activity_sgpt_booking_success.xml
//
//  Scene: Sgpt.storyboard / "SgptBookingSuccessViewController". The scene owns
//  the backdrop, scroll view, footer buttons and the contentContainer; the body
//  sections are filled in here, same split as SgptPricingViewController.
//

import UIKit

// MARK: - Input

/// Which flow reached this screen.
enum SgptBookingSuccessMode {
    /// Bought a credit pack and booked in one go - shows the payment summary.
    /// Figma 11327:21771.
    case purchasedAndBooked
    /// Already held credits, booked from the checkout sheet - no payment taken,
    /// so no payment summary. Figma 11327:21694.
    case bookedWithExistingCredits
}

struct SgptBookingSuccessInput {
    var mode: SgptBookingSuccessMode = .purchasedAndBooked
    var session: SgptSessionModel
    var packName: String = "Starter Pack"
    var packCredits: Int = 8
    var creditsUsed: Int = 1
    var creditsRemaining: Int = 7
    /// Size of the wallet the remaining credits are a share of - the bar's
    /// denominator. Falls back to used + remaining when the API sends none.
    var creditsTotal: Int = 0
    var expiresInDays: Int?
    var packPrice: Double = 0
    var vatPercent: Int = 5
}

// MARK: - Success badge

/// Port of the Figma `Success Icon` (80×80): a 20%-alpha #1FC16B halo at r=20,
/// a solid disc at r=31.11, and the white tick path on top.
final class SgptSuccessBadgeView: UIView {

    private static let viewport: CGFloat = 80
    private static let green = UIColor(hex: "#1FC16B")

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
        haloLayer.fillColor = SgptSuccessBadgeView.green.withAlphaComponent(0.2).cgColor
        discLayer.fillColor = SgptSuccessBadgeView.green.cgColor
        tickLayer.fillColor = UIColor.white.cgColor
        layer.addSublayer(haloLayer)
        layer.addSublayer(discLayer)
        layer.addSublayer(tickLayer)
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: SgptSuccessBadgeView.viewport, height: SgptSuccessBadgeView.viewport)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }

        let scale = min(bounds.width, bounds.height) / SgptSuccessBadgeView.viewport
        let transform = CGAffineTransform(scaleX: scale, y: scale)

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        haloLayer.frame = bounds
        discLayer.frame = bounds
        tickLayer.frame = bounds

        let halo = UIBezierPath(arcCenter: CGPoint(x: 40, y: 40), radius: 20,
                                startAngle: 0, endAngle: .pi * 2, clockwise: true)
        halo.apply(transform)
        haloLayer.path = halo.cgPath

        let disc = UIBezierPath(arcCenter: CGPoint(x: 40, y: 40), radius: 31.1111,
                                startAngle: 0, endAngle: .pi * 2, clockwise: true)
        disc.apply(transform)
        discLayer.path = disc.cgPath

        let tick = SgptSuccessBadgeView.tickPath()
        tick.apply(transform)
        tickLayer.path = tick.cgPath

        CATransaction.commit()
    }

    private static func tickPath() -> UIBezierPath {
        let p = UIBezierPath()
        p.move(to: CGPoint(x: 36.5085, y: 51.4123))
        p.addCurve(to: CGPoint(x: 35.3457, y: 50.9417),
                   controlPoint1: CGPoint(x: 36.0655, y: 51.4123), controlPoint2: CGPoint(x: 35.6503, y: 51.2462))
        p.addLine(to: CGPoint(x: 28.0924, y: 43.4669))
        p.addCurve(to: CGPoint(x: 28.037, y: 41.0583),
                   controlPoint1: CGPoint(x: 27.4003, y: 42.8301), controlPoint2: CGPoint(x: 27.3726, y: 41.7504))
        p.addCurve(to: CGPoint(x: 30.4456, y: 41.003),
                   controlPoint1: CGPoint(x: 28.6738, y: 40.3662), controlPoint2: CGPoint(x: 29.7535, y: 40.3385))
        p.addLine(to: CGPoint(x: 35.761, y: 44.7957))
        p.addCurve(to: CGPoint(x: 36.7853, y: 44.685),
                   controlPoint1: CGPoint(x: 36.0655, y: 45.0726), controlPoint2: CGPoint(x: 36.5362, y: 45.0172))
        p.addLine(to: CGPoint(x: 49.3818, y: 29.1263))
        p.addCurve(to: CGPoint(x: 51.7626, y: 28.7941),
                   controlPoint1: CGPoint(x: 49.9355, y: 28.3788), controlPoint2: CGPoint(x: 51.0152, y: 28.2127))
        p.addCurve(to: CGPoint(x: 52.0948, y: 31.175),
                   controlPoint1: CGPoint(x: 52.5101, y: 29.3478), controlPoint2: CGPoint(x: 52.6762, y: 30.4275))
        p.addLine(to: CGPoint(x: 37.865, y: 50.7202))
        p.addCurve(to: CGPoint(x: 36.6469, y: 51.3846),
                   controlPoint1: CGPoint(x: 37.5605, y: 51.1078), controlPoint2: CGPoint(x: 37.1176, y: 51.3569))
        p.addCurve(to: CGPoint(x: 36.5085, y: 51.4123),
                   controlPoint1: CGPoint(x: 36.5915, y: 51.4123), controlPoint2: CGPoint(x: 36.5639, y: 51.4123))
        p.close()
        return p
    }
}

// MARK: - Controller

final class SgptBookingSuccessViewController: UIViewController {

    private enum Palette {
        static let bg = UIColor(hex: "#000A04")
        static let creditsFill = UIColor(hex: "#241040")
        static let panelFill = UIColor(hex: "#131416")
        static let panelStroke = UIColor(hex: "#101113")
        static let detailFill = UIColor(hex: "#1E1E1F")
        static let detailStroke = UIColor(hex: "#232323")
        static let secondaryFill = UIColor(hex: "#1D1E1D")
        static let text55 = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let text75 = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
        static let stroke10 = UIColor.white.withAlphaComponent(0.10)
        static let stroke20 = UIColor.white.withAlphaComponent(0.20)
        static let ctaInk = UIColor(hex: "#141514")
        /// The colour the poster fades into so it blends with the page. It has
        /// to *be* the page colour - at #000805 against a #000A04 page it landed
        /// a shade off and the card's bottom read as an edge rather than a fade.
        static let blend = bg
    }

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let cardCorner: CGFloat = 12
        static let ctaHeight: CGFloat = 48
        static let creditSegments = 8
    }

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var backdropFadeView: GradientFadeView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var backToClassesButton: UIButton!
    @IBOutlet weak var viewBookingsButton: GradientCTAButton!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var posterCard: SgptBlendCardView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var posterScrim: GradientFadeView!
    @IBOutlet weak var durationChip: PillChipView!
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var sessionMetaLabel: UILabel!
    @IBOutlet weak var headerDividerView: UIView!
    @IBOutlet weak var creditsCard: UIView!
    @IBOutlet weak var creditsUsedTitleLabel: UILabel!
    @IBOutlet weak var creditsUsedLabel: UILabel!
    @IBOutlet weak var creditsDividerView: UIView!
    @IBOutlet weak var creditsRemainingTitleLabel: UILabel!
    @IBOutlet weak var creditsRemainingLabel: UILabel!
    @IBOutlet weak var creditsProgressBar: SgptCreditsBarView!
    @IBOutlet weak var backButton: GlassCircularIconButton!
    @IBOutlet weak var walletTileView: UIView!
    @IBOutlet weak var creditsExpiryLabel: UILabel!
    @IBOutlet weak var paymentSummaryTitleLabel: UILabel!
    @IBOutlet weak var paymentCard: UIView!
    @IBOutlet weak var packLineLabel: UILabel!
    @IBOutlet weak var packPriceLabel: UILabel!
    @IBOutlet weak var vatLabel: UILabel!
    @IBOutlet weak var vatValueLabel: UILabel!
    @IBOutlet weak var paymentDividerView: UIView!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var receiptStrip: UIView!
    @IBOutlet weak var receiptLogoView: UIImageView!
    @IBOutlet weak var receiptStatusLabel: UILabel!
    @IBOutlet weak var receiptDiamondView: SgptDiamondView!
    @IBOutlet weak var receiptNoteLabel: UILabel!
    @IBOutlet weak var paymentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var creditsBottomConstraint: NSLayoutConstraint!

    /// Set before pushing; `start(from:input:)` does it for you.
    var input = SgptBookingSuccessInput(session: SgptSessionModel())

    /// Tapped "VIEW MY BOOKINGS". Defaults to popping to root when unset.
    var onViewBookings: (() -> Void)?
    /// Tapped "BACK TO CLASSES".
    var onBackToClasses: (() -> Void)?

    private var creditsTargetProgress: CGFloat = 0
    private var hasRunCreditsDeduction = false


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bg
        navigationItem.hidesBackButton = true
        styleSceneChrome()
        styleContent()
        bindContent()
        applyMode()
        applyCreditsProgress()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runCreditsDeduction()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        mainScrollView.contentInset.top = view.safeAreaInsets.top
        mainScrollView.verticalScrollIndicatorInsets.top = view.safeAreaInsets.top
    }

    // MARK: Scene chrome

    private func styleSceneChrome() {
        backdropImageView.image = UIImage(named: "sgpt-success-bg")
        backdropFadeView.setColors([Palette.bg.withAlphaComponent(0), Palette.bg])

        footerView.backgroundColor = Palette.bg

        backButton.configure(icon: UIImage(named: "sgpt-ic-back-chevron")
                             ?? UIImage(systemName: "chevron.left"), diameter: 40)
        backButton.tintColor = .white

        backToClassesButton.backgroundColor = Palette.secondaryFill
        backToClassesButton.layer.cornerRadius = 8
        backToClassesButton.layer.borderWidth = 1
        backToClassesButton.layer.borderColor = Palette.stroke10.cgColor
        backToClassesButton.setTitleColor(.white, for: .normal)
        backToClassesButton.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)

        viewBookingsButton.setTitleColor(Palette.ctaInk, for: .normal)
        viewBookingsButton.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }

    private func styleContent() {
        titleLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        titleLabel.textColor = .white

        subtitleLabel.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        subtitleLabel.textColor = Palette.text55

        posterCard.cornerRadius = 20
        posterCard.borderWidth = 1
        posterCard.borderColor = Palette.stroke20
        // Ends on the page colour so the card's bottom edge dissolves rather
        // than stopping on a line.
        posterScrim.setColors([Palette.blend.withAlphaComponent(0),
                               Palette.blend.withAlphaComponent(0.85),
                               Palette.blend],
                              locations: [0, 0.55, 1])

        durationChip.fillColor = UIColor.white.withAlphaComponent(0.20)
        durationChip.strokeColor = Palette.text55.withAlphaComponent(0.20)
        durationChip.titleLabel.textColor = UIColor(hex: "#F0F0F0")
        durationChip.titleLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)

        sessionNameLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        sessionNameLabel.textColor = .white
        sessionMetaLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        sessionMetaLabel.textColor = UIColor.white.withAlphaComponent(0.75)

        headerDividerView.backgroundColor = Palette.stroke10

        // Same treatment as the checkout sheet's credits card: the violet fill
        // and rim were missing here, which is why the meter read flatter than
        // the sheet's even though the bar itself is the same control.
        creditsCard.backgroundColor = UIColor(hex: "#241040")
        creditsCard.layer.cornerRadius = Metric.cardCorner
        creditsCard.layer.borderWidth = 1
        creditsCard.layer.borderColor = SgptListingColor.violet500.cgColor
        creditsCard.clipsToBounds = true
        creditsUsedTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        creditsUsedTitleLabel.textColor = .white
        creditsUsedLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        creditsUsedLabel.textColor = .white
        creditsDividerView.backgroundColor = Palette.stroke10
        creditsRemainingTitleLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        creditsRemainingTitleLabel.textColor = Palette.text75
        creditsRemainingLabel.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
        creditsRemainingLabel.textColor = Palette.text75
        walletTileView.backgroundColor = UIColor(hex: "#8A2BE1").withAlphaComponent(0.5)
        walletTileView.layer.cornerRadius = 6.316
        creditsExpiryLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)

        paymentSummaryTitleLabel.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        paymentSummaryTitleLabel.textColor = Palette.text75

        paymentCard.backgroundColor = Palette.panelFill
        paymentCard.layer.cornerRadius = Metric.cardCorner
        paymentCard.layer.borderWidth = 1
        paymentCard.layer.borderColor = Palette.panelStroke.cgColor

        let dim = UIColor.white.withAlphaComponent(0.5)
        packLineLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        packLineLabel.textColor = dim
        packPriceLabel.font = AppFont.regular.size(13.0, familyName: familyFunnelSans)
        packPriceLabel.textColor = Palette.text55
        vatLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        vatLabel.textColor = dim
        vatValueLabel.font = AppFont.regular.size(13.0, familyName: familyFunnelSans)
        vatValueLabel.textColor = Palette.text55
        paymentDividerView.backgroundColor = Palette.stroke10
        totalTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        totalTitleLabel.textColor = .white
        totalValueLabel.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
        totalValueLabel.textColor = .white

        receiptStrip.backgroundColor = Palette.detailFill
        receiptStrip.layer.cornerRadius = 4
        receiptStrip.layer.borderWidth = 1
        receiptStrip.layer.borderColor = Palette.detailStroke.cgColor
        receiptLogoView.layer.cornerRadius = 3
        receiptLogoView.layer.borderWidth = 0.857
        receiptLogoView.layer.borderColor = UIColor(hex: "#393939").cgColor
        receiptLogoView.clipsToBounds = true
        receiptStatusLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        receiptStatusLabel.textColor = .white
        receiptDiamondView.diamondColor = UIColor(hex: "#DFD0EF")
        receiptNoteLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        receiptNoteLabel.textColor = Palette.text55
    }

    private func bindContent() {
        switch input.mode {
        case .purchasedAndBooked:
            titleLabel.text = "Credits & Session Locked In!"
            subtitleLabel.text = "\(input.packName) purchased · \(creditLabel(input.creditsUsed)) applied to this session"
        case .bookedWithExistingCredits:
            titleLabel.text = "Session Booked!"
            subtitleLabel.text = "\(creditLabel(input.creditsUsed)) used · \(input.creditsRemaining) remaining in your wallet"
        }

        let fallback = UIImage(named: "class-card-placeholder")
        if let raw = input.session.image, !raw.isEmpty, let url = URL(string: raw) {
            posterImageView.sd_setImage(with: url, placeholderImage: fallback)
        } else {
            posterImageView.image = fallback
        }

        durationChip.text = "\(GroupClassCardFormatter.intValue(input.session.duration, defaultValue: 60)) MINS"
        sessionNameLabel.text = SgptCardCollectionViewCell.titleText(for: input.session)
        sessionMetaLabel.attributedText = metaText(for: input.session)

        creditsUsedLabel.text = creditLabel(input.creditsUsed)
        creditsRemainingLabel.text = creditLabel(input.creditsRemaining)
        creditsExpiryLabel.attributedText = expiryText()

        let packCredits = input.packCredits < 10 ? String(format: "%02d", input.packCredits) : "\(input.packCredits)"
        let vat = input.packPrice * Double(input.vatPercent) / 100.0
        packLineLabel.text = "\(input.packName) · \(packCredits) credits"
        packPriceLabel.text = currency(input.packPrice)
        vatLabel.text = "VAT (\(input.vatPercent)%)"
        vatValueLabel.text = currency(vat)
        totalValueLabel.text = currency(input.packPrice + vat)
    }

    private func applyMode() {
        let showsPayment = input.mode == .purchasedAndBooked
        paymentSummaryTitleLabel.isHidden = !showsPayment
        paymentCard.isHidden = !showsPayment
        paymentBottomConstraint.isActive = showsPayment
        creditsBottomConstraint.isActive = !showsPayment
    }
    // MARK: Segments

    /// Remaining credits as a share of the whole wallet - the same denominator
    /// the checkout sheet uses. Starts at the pre-booking balance so the bar can
    /// run down to the post-booking figure on appear.
    private func applyCreditsProgress() {
        let before = input.creditsUsed + input.creditsRemaining
        let total = max(input.creditsTotal > 0 ? input.creditsTotal : before, 1)
        creditsProgressBar.progress = CGFloat(min(before, total)) / CGFloat(total)
        creditsTargetProgress = CGFloat(min(input.creditsRemaining, total)) / CGFloat(total)
    }

    private func runCreditsDeduction() {
        guard !hasRunCreditsDeduction else { return }
        hasRunCreditsDeduction = true
        creditsProgressBar.setProgress(creditsTargetProgress, animated: true)
    }

    // MARK: Helpers

    private func creditLabel(_ value: Int) -> String {
        value == 1 ? "1 credit" : "\(value) credits"
    }

    /// The card cell's subtitle carries a 9.5pt face and a chip-trimmed studio
    /// ("Mixed Gym"), both wrong on a full-width poster - schedule and the whole
    /// venue name, at the poster's own size, like the checkout sheet shows.
    private func metaText(for session: SgptSessionModel) -> NSAttributedString {
        let schedule = SgptCardCollectionViewCell.scheduleText(for: session)
        let studio = (session.studioName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let text = studio.isEmpty ? schedule : "\(schedule)\n\(studio)"

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 2

        return NSAttributedString(string: text, attributes: [
            .font: AppFont.semibold.size(14.0, familyName: familyFunnelSans),
            .foregroundColor: UIColor.white.withAlphaComponent(0.75),
            .paragraphStyle: paragraph
        ])
    }

    private func expiryText() -> NSAttributedString {
        let prefix = "Credits expires in "
        let days = input.expiresInDays.map { "\($0) days" } ?? "—"
        let text = NSMutableAttributedString(
            string: prefix,
            attributes: [.foregroundColor: Palette.text55]
        )
        text.append(NSAttributedString(string: days, attributes: [.foregroundColor: UIColor.white]))
        return text
    }

    private func currency(_ value: Double) -> String {
        String(format: "AED %.2f", value)
    }

    // MARK: Actions

    @IBAction func viewBookingsTapped() {
        TapticEngine.selection.feedback()
        if let handler = onViewBookings {
            handler()
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    @IBAction func backTapped() {
        TapticEngine.selection.feedback()
        navigationController?.popViewController(animated: true)
    }

    @IBAction func backToClassesTapped() {
        TapticEngine.selection.feedback()
        if let handler = onBackToClasses {
            handler()
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    // MARK: Entry point

    static func start(from controller: UIViewController, input: SgptBookingSuccessInput) {
        let screen: SgptBookingSuccessViewController = .instantiate(appStoryboard: .sgpt)
        screen.input = input
        screen.hidesBottomBarWhenPushed = true
        controller.navigationController?.pushViewController(screen, animated: true)
    }
}
