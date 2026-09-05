//
//  SgptCheckoutSheetViewController.swift
//  MyPT
//
//  "Confirm Booking" checkout sheet for Small Group PT — the credit-funded
//  path shown when the member already holds SGPT credits, instead of pushing
//  SgptPricingViewController.
//
//  Figma: "Checkout summary" (node 11211:21310).
//  Android counterpart (same copy, same order, same values):
//    app/src/main/res/layout/bottom_sheet_sgpt_checkout.xml
//    app/src/main/java/co/com/mypt/UpComingClasses/SgptCheckoutBottomSheet.kt
//
//  Presented as a real modal sheet rather than an overlay, matching
//  ConfirmSlotSheetViewController's approach for the Group Classes flow.
//

import UIKit
import SDWebImage

struct SgptCheckoutInput {
    var session: SgptSessionModel
    /// Credits this booking consumes — one per session.
    var creditsUsed: Int = 1
    /// Balance the member holds *before* this booking.
    var creditsBalance: Int = 0
    /// Size of the wallet the balance is a share of - the bar's denominator.
    /// Falls back to the balance when the API doesn't send one.
    var creditsTotal: Int = 0
    var expiresInDays: Int?
}

final class SgptCheckoutSheetViewController: UIViewController {

    private enum Metric {
        static let sheetCornerRadius: CGFloat = 20
        static let horizontalInset: CGFloat = 20
        static let creditSegments = 8
    }

    @IBOutlet weak var handleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var sessionWhenLabel: UILabel!
    @IBOutlet weak var sessionWhereLabel: UILabel!
    @IBOutlet weak var durationChip: PillChipView!

    @IBOutlet weak var creditsCard: UIView!
    @IBOutlet weak var creditsUsedTitleLabel: UILabel!
    @IBOutlet weak var creditsUsedLabel: UILabel!
    @IBOutlet weak var creditsDividerView: UIView!
    @IBOutlet weak var creditsRemainingTitleLabel: UILabel!
    @IBOutlet weak var creditsRemainingLabel: UILabel!
    @IBOutlet weak var creditsExpiryLabel: UILabel!
    @IBOutlet weak var creditsBar: SgptCreditsBarView!
    @IBOutlet weak var walletTileView: UIView!

    @IBOutlet weak var trainerCard: GlassCardView!
    @IBOutlet weak var trainerImageView: UIImageView!
    @IBOutlet weak var trainerNameLabel: UILabel!
    @IBOutlet weak var trainerExpLabel: UILabel!
    @IBOutlet weak var viewProfileButton: UIButton!

    @IBOutlet weak var policyLabel: UILabel!
    @IBOutlet weak var confirmButton: GradientCTAButton!

    /// Set before presenting; `present(from:input:)` does it for you.
    var input = SgptCheckoutInput(session: SgptSessionModel())

    var onConfirm: (() -> Void)?
    var onViewProfile: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SgptListingColor.surfaceLow
        styleScene()
        bind()
        configureSheetDetent()
    }

    /// Sized before the sheet animates in. Doing this in viewDidAppear meant it
    /// presented at the default full height and then snapped down to fit.
    private func configureSheetDetent() {
        guard #available(iOS 15.0, *), let sheet = sheetPresentationController else { return }
        sheet.preferredCornerRadius = Metric.sheetCornerRadius
        sheet.prefersGrabberVisible = false

        let width = UIScreen.main.bounds.width
        view.frame = CGRect(x: 0, y: 0, width: width, height: UIScreen.main.bounds.height)
        view.layoutIfNeeded()

        let height = view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        if #available(iOS 16.0, *) {
            sheet.detents = [.custom { _ in height }]
        } else {
            sheet.detents = [.medium()]
        }
    }

    /// The scene owns the hierarchy and constraints; this only applies the
    /// colours, fonts and corner radii Interface Builder can't express.
    private func styleScene() {
        handleView.backgroundColor = UIColor(hex: "#393C43")
        handleView.layer.cornerRadius = 2

        titleLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        titleLabel.textColor = SgptListingColor.neutral200

        closeButton.tintColor = SgptListingColor.neutral200

        sessionImageView.layer.cornerRadius = 12
        sessionImageView.backgroundColor = UIColor(hex: "#1A0A3D")

        sessionNameLabel.font = AppFont.semibold.size(16.0, familyName: familyClashDisplay)
        sessionNameLabel.textColor = .white

        sessionWhenLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        sessionWhenLabel.textColor = UIColor.white.withAlphaComponent(0.5)

        sessionWhereLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        sessionWhereLabel.textColor = UIColor.white.withAlphaComponent(0.4)

        durationChip.cornerRadius = 8
        durationChip.fillColor = UIColor.white.withAlphaComponent(0.15)
        durationChip.strokeColor = SgptListingColor.text20
        durationChip.sheenColor = .white
        durationChip.sheenAlpha = 0.20
        durationChip.titleLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        durationChip.titleLabel.textColor = SgptListingColor.neutral200

        creditsCard.backgroundColor = UIColor(hex: "#241040")
        creditsCard.layer.cornerRadius = 12
        creditsCard.layer.borderWidth = 1
        creditsCard.layer.borderColor = SgptListingColor.violet500.cgColor
        creditsCard.clipsToBounds = true

        creditsUsedTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        creditsUsedTitleLabel.textColor = .white
        creditsUsedLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        creditsUsedLabel.textColor = .white

        creditsDividerView.backgroundColor = SgptListingColor.stroke10

        creditsRemainingTitleLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        creditsRemainingTitleLabel.textColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
        creditsRemainingLabel.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
        creditsRemainingLabel.textColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)

        walletTileView.backgroundColor = UIColor(hex: "#8A2BE1").withAlphaComponent(0.5)
        walletTileView.layer.cornerRadius = 6.316

        creditsExpiryLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)

        trainerCard.cornerRadius = 12
        trainerCard.fillColor = UIColor(hex: "#1E1E1F")
        trainerCard.fillAlpha = 1.0
        trainerCard.strokeColor = UIColor(hex: "#29292A")
        trainerCard.strokeAlpha = 1.0
        trainerCard.showsSheen = true
        trainerCard.sheenOrigin = .topCenter
        trainerCard.sheenAlpha = 0.08

        trainerImageView.layer.cornerRadius = 9.188
        trainerImageView.backgroundColor = UIColor(hex: "#1A1A1A")

        trainerNameLabel.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        trainerNameLabel.textColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)

        trainerExpLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        trainerExpLabel.textColor = SgptListingColor.text55

        viewProfileButton.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        viewProfileButton.setTitleColor(.white, for: .normal)
        viewProfileButton.backgroundColor = UIColor(hex: "#1D1E1D")
        viewProfileButton.layer.cornerRadius = 8
        viewProfileButton.layer.borderWidth = 1
        viewProfileButton.layer.borderColor = SgptListingColor.stroke10.cgColor
        let chevron = UIImage(systemName: "chevron.right",
                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 9, weight: .semibold))
        if #available(iOS 15.0, *) {
            // Configuration places the image trailing natively. The old
            // semanticContentAttribute flip also mirrored the left/right insets,
            // which is what left more padding on one side than the other.
            var config = UIButton.Configuration.plain()
            config.image = chevron
            config.imagePlacement = .trailing
            config.imagePadding = 6
            config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            config.baseForegroundColor = .white
            config.preferredSymbolConfigurationForImage =
                UIImage.SymbolConfiguration(pointSize: 9, weight: .semibold)
            config.title = "VIEW PROFILE"
            // The transformer runs last, so the 12pt face survives the Dynamic
            // Type scaling Configuration otherwise applies to the title.
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
                return out
            }
            viewProfileButton.configuration = config
            viewProfileButton.titleLabel?.adjustsFontForContentSizeCategory = false
        } else {
            viewProfileButton.setImage(chevron, for: .normal)
            viewProfileButton.tintColor = .white
            viewProfileButton.semanticContentAttribute = .forceRightToLeft
            viewProfileButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            viewProfileButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        }
        viewProfileButton.imageView?.contentMode = .scaleAspectFit
        viewProfileButton.clipsToBounds = true

        policyLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)

        confirmButton.bandThickness = 2
        confirmButton.horizontalContentInset = 16
        confirmButton.configure(title: "CONFIRM YOUR SLOT",
                                font: AppFont.medium.size(14.0, familyName: familyFunnelSans),
                                titleColor: .black)
        confirmButton.setTrailingIcon(UIImage(named: "sgpt-ic-chevron-right"), tint: .black)
    }

    private func bind() {
        let session = input.session

        sessionNameLabel.text = SgptCardCollectionViewCell.titleText(for: session)
        if let when = SgptCardCollectionViewCell.subtitleText(for: session).mutableCopy() as? NSMutableAttributedString {
            when.addAttribute(.font,
                              value: AppFont.regular.size(12.0, familyName: familyFunnelSans),
                              range: NSRange(location: 0, length: when.length))
            sessionWhenLabel.attributedText = when
        }
        sessionWhereLabel.text = session.studioName ?? ""

        durationChip.text = "\(GroupClassCardFormatter.intValue(session.duration, defaultValue: 60)) MINS"

        let fallback = UIImage(named: "class-card-placeholder")
        if let raw = session.image, !raw.isEmpty, let url = URL(string: raw) {
            sessionImageView.sd_setImage(with: url, placeholderImage: fallback)
            trainerImageView.sd_setImage(with: url, placeholderImage: fallback)
        } else {
            sessionImageView.image = fallback
            trainerImageView.image = fallback
        }

        creditsUsedLabel.text = creditLabel(input.creditsUsed)
        let remainingAfter = max(0, input.creditsBalance - input.creditsUsed)
        creditsRemainingLabel.text = creditLabel(remainingAfter)

        creditsExpiryLabel.attributedText = input.expiresInDays.map {
            tinted(prefix: "Credits expires in ", highlight: "\($0) days", highlightColor: .white)
        } ?? NSAttributedString(
            string: "Credits do not expire",
            attributes: [.foregroundColor: SgptListingColor.text55]
        )

        policyLabel.attributedText = tinted(
            prefix: "By confirming, you agree to our ",
            highlight: "Cancellation Policy",
            highlightColor: SgptListingColor.limeGreen
        )

        trainerNameLabel.text = session.trainerName ?? ""
        trainerExpLabel.text = "MyPT Trainer"
        applyCreditsProgress()
    }

    private func creditLabel(_ value: Int) -> String {
        value == 1 ? "1 credit" : "\(value) credits"
    }

    private func tinted(prefix: String, highlight: String, highlightColor: UIColor) -> NSAttributedString {
        let result = NSMutableAttributedString(
            string: prefix,
            attributes: [.foregroundColor: SgptListingColor.text55]
        )
        result.append(NSAttributedString(
            string: highlight,
            attributes: [.foregroundColor: highlightColor]
        ))
        return result
    }

    /// Credits left after this booking as a share of the whole wallet, so the
    /// bar means the same thing here and on the success screen.
    private func applyCreditsProgress() {
        let total = max(input.creditsTotal > 0 ? input.creditsTotal : input.creditsBalance, 1)
        let after = max(input.creditsBalance - input.creditsUsed, 0)
        creditsBar.progress = CGFloat(min(after, total)) / CGFloat(total)
    }

    @IBAction func closeTapped() {
        dismiss(animated: true)
    }

    @IBAction func confirmTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirm?()
        }
    }

    @IBAction func viewProfileTapped() {
        onViewProfile?()
    }

    // MARK: Entry point

    static func present(from controller: UIViewController,
                        input: SgptCheckoutInput,
                        onConfirm: (() -> Void)? = nil,
                        onViewProfile: (() -> Void)? = nil) {
        let sheet: SgptCheckoutSheetViewController = .instantiate(appStoryboard: .sgpt)
        sheet.input = input
        sheet.onConfirm = onConfirm
        sheet.onViewProfile = onViewProfile
        sheet.modalPresentationStyle = .pageSheet
        controller.present(sheet, animated: true)
    }
}
