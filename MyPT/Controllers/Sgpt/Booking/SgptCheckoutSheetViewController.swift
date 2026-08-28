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
    var expiresInDays: Int?
}

final class SgptCheckoutSheetViewController: UIViewController {

    private enum Metric {
        static let sheetCornerRadius: CGFloat = 20
        static let horizontalInset: CGFloat = 20
        static let creditSegments = 8
    }

    private let input: SgptCheckoutInput

    var onConfirm: (() -> Void)?
    var onViewProfile: (() -> Void)?

    private let handleView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    private let sessionImageView = UIImageView()
    private let sessionNameLabel = UILabel()
    private let sessionWhenLabel = UILabel()
    private let sessionWhereLabel = UILabel()
    private let durationChip = UILabel()

    private let creditsCard = UIView()
    private let creditsUsedLabel = UILabel()
    private let creditsRemainingLabel = UILabel()
    private let creditsExpiryLabel = UILabel()
    private let segmentsStack = UIStackView()

    private let trainerCard = UIView()
    private let trainerImageView = UIImageView()
    private let trainerNameLabel = UILabel()
    private let trainerExpLabel = UILabel()
    private let viewProfileButton = UIButton(type: .system)

    private let policyLabel = UILabel()
    private let confirmButton = GradientCTAButton()

    init(input: SgptCheckoutInput) {
        self.input = input
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SgptListingColor.surfaceLow
        buildLayout()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 15.0, *), let sheet = sheetPresentationController {
            sheet.preferredCornerRadius = Metric.sheetCornerRadius
            sheet.prefersGrabberVisible = false
            if #available(iOS 16.0, *) {
                let height = view.systemLayoutSizeFitting(
                    CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
                ).height
                sheet.detents = [.custom { _ in height }]
            } else {
                sheet.detents = [.medium(), .large()]
            }
        }
    }

    private func buildLayout() {
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.backgroundColor = UIColor(hex: "#393C43")
        handleView.layer.cornerRadius = 2
        view.addSubview(handleView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        titleLabel.textColor = SgptListingColor.neutral200
        titleLabel.text = "Confirm Booking"
        view.addSubview(titleLabel)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        closeButton.tintColor = SgptListingColor.neutral200
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        sessionImageView.translatesAutoresizingMaskIntoConstraints = false
        sessionImageView.contentMode = .scaleAspectFill
        sessionImageView.clipsToBounds = true
        sessionImageView.layer.cornerRadius = 12
        sessionImageView.backgroundColor = UIColor(hex: "#1A0A3D")
        view.addSubview(sessionImageView)

        sessionNameLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionNameLabel.font = AppFont.semibold.size(16.0, familyName: familyClashDisplay)
        sessionNameLabel.textColor = .white
        view.addSubview(sessionNameLabel)

        sessionWhenLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionWhenLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        sessionWhenLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        view.addSubview(sessionWhenLabel)

        sessionWhereLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionWhereLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        sessionWhereLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        view.addSubview(sessionWhereLabel)

        durationChip.translatesAutoresizingMaskIntoConstraints = false
        durationChip.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        durationChip.textColor = SgptListingColor.neutral200
        durationChip.textAlignment = .center
        durationChip.layer.cornerRadius = 8
        durationChip.layer.borderWidth = 1
        durationChip.layer.borderColor = SgptListingColor.text20.cgColor
        durationChip.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        durationChip.clipsToBounds = true
        view.addSubview(durationChip)

        buildCreditsCard()
        buildTrainerCard()

        policyLabel.translatesAutoresizingMaskIntoConstraints = false
        policyLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        policyLabel.textAlignment = .center
        policyLabel.numberOfLines = 0
        view.addSubview(policyLabel)

        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.bandThickness = 2
        confirmButton.horizontalContentInset = 16
        confirmButton.configure(title: "CONFIRM YOUR SLOT",
                                font: AppFont.medium.size(14.0, familyName: familyFunnelSans),
                                titleColor: .black)
        confirmButton.setTrailingIcon(UIImage(named: "sgpt-ic-chevron-right"), tint: .black)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        view.addSubview(confirmButton)

        let inset = Metric.horizontalInset

        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 4),

            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),

            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),

            sessionImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            sessionImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            sessionImageView.widthAnchor.constraint(equalToConstant: 64),
            sessionImageView.heightAnchor.constraint(equalToConstant: 64),

            sessionNameLabel.topAnchor.constraint(equalTo: sessionImageView.topAnchor),
            sessionNameLabel.leadingAnchor.constraint(equalTo: sessionImageView.trailingAnchor, constant: 12),
            sessionNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: durationChip.leadingAnchor, constant: -8),

            sessionWhenLabel.topAnchor.constraint(equalTo: sessionNameLabel.bottomAnchor, constant: 4),
            sessionWhenLabel.leadingAnchor.constraint(equalTo: sessionNameLabel.leadingAnchor),
            sessionWhenLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -inset),

            sessionWhereLabel.topAnchor.constraint(equalTo: sessionWhenLabel.bottomAnchor, constant: 2),
            sessionWhereLabel.leadingAnchor.constraint(equalTo: sessionNameLabel.leadingAnchor),
            sessionWhereLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -inset),

            durationChip.topAnchor.constraint(equalTo: sessionImageView.topAnchor, constant: 4),
            durationChip.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            durationChip.heightAnchor.constraint(equalToConstant: 24),
            durationChip.widthAnchor.constraint(greaterThanOrEqualToConstant: 74),

            creditsCard.topAnchor.constraint(equalTo: sessionImageView.bottomAnchor, constant: 20),
            creditsCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            creditsCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),

            trainerCard.topAnchor.constraint(equalTo: creditsCard.bottomAnchor, constant: 20),
            trainerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            trainerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            trainerCard.heightAnchor.constraint(equalToConstant: 66),

            policyLabel.topAnchor.constraint(equalTo: trainerCard.bottomAnchor, constant: 20),
            policyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            policyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),

            confirmButton.topAnchor.constraint(equalTo: policyLabel.bottomAnchor, constant: 16),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            confirmButton.heightAnchor.constraint(equalToConstant: 48),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func buildCreditsCard() {
        creditsCard.translatesAutoresizingMaskIntoConstraints = false
        creditsCard.backgroundColor = UIColor(hex: "#241040")
        creditsCard.layer.cornerRadius = 12
        creditsCard.layer.borderWidth = 1
        creditsCard.layer.borderColor = SgptListingColor.violet500.cgColor
        creditsCard.clipsToBounds = true
        view.addSubview(creditsCard)

        let usedTitle = UILabel()
        usedTitle.translatesAutoresizingMaskIntoConstraints = false
        usedTitle.text = "Credits use for this session"
        usedTitle.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        usedTitle.textColor = .white
        creditsCard.addSubview(usedTitle)

        creditsUsedLabel.translatesAutoresizingMaskIntoConstraints = false
        creditsUsedLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        creditsUsedLabel.textColor = .white
        creditsCard.addSubview(creditsUsedLabel)

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = SgptListingColor.stroke10
        creditsCard.addSubview(divider)

        let remainingTitle = UILabel()
        remainingTitle.translatesAutoresizingMaskIntoConstraints = false
        remainingTitle.text = "Credits remaining after"
        remainingTitle.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        remainingTitle.textColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
        creditsCard.addSubview(remainingTitle)

        creditsRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
        creditsRemainingLabel.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
        creditsRemainingLabel.textColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
        creditsCard.addSubview(creditsRemainingLabel)

        segmentsStack.translatesAutoresizingMaskIntoConstraints = false
        segmentsStack.axis = .horizontal
        segmentsStack.spacing = 4
        segmentsStack.distribution = .fillEqually
        creditsCard.addSubview(segmentsStack)

        let walletTile = UIView()
        walletTile.translatesAutoresizingMaskIntoConstraints = false
        walletTile.backgroundColor = UIColor(hex: "#8A2BE1").withAlphaComponent(0.5)
        walletTile.layer.cornerRadius = 6.316
        creditsCard.addSubview(walletTile)

        let walletIcon = UIImageView()
        walletIcon.translatesAutoresizingMaskIntoConstraints = false
        walletIcon.image = UIImage(systemName: "wallet.pass")
        walletIcon.tintColor = .white
        walletIcon.contentMode = .scaleAspectFit
        walletTile.addSubview(walletIcon)

        creditsExpiryLabel.translatesAutoresizingMaskIntoConstraints = false
        creditsExpiryLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        creditsCard.addSubview(creditsExpiryLabel)

        NSLayoutConstraint.activate([
            usedTitle.topAnchor.constraint(equalTo: creditsCard.topAnchor, constant: 12),
            usedTitle.leadingAnchor.constraint(equalTo: creditsCard.leadingAnchor, constant: 15),

            creditsUsedLabel.centerYAnchor.constraint(equalTo: usedTitle.centerYAnchor),
            creditsUsedLabel.trailingAnchor.constraint(equalTo: creditsCard.trailingAnchor, constant: -15),

            divider.topAnchor.constraint(equalTo: usedTitle.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: creditsCard.leadingAnchor, constant: 15),
            divider.trailingAnchor.constraint(equalTo: creditsCard.trailingAnchor, constant: -15),
            divider.heightAnchor.constraint(equalToConstant: 1),

            remainingTitle.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            remainingTitle.leadingAnchor.constraint(equalTo: creditsCard.leadingAnchor, constant: 15),

            creditsRemainingLabel.centerYAnchor.constraint(equalTo: remainingTitle.centerYAnchor),
            creditsRemainingLabel.trailingAnchor.constraint(equalTo: creditsCard.trailingAnchor, constant: -15),

            segmentsStack.topAnchor.constraint(equalTo: remainingTitle.bottomAnchor, constant: 12),
            segmentsStack.leadingAnchor.constraint(equalTo: creditsCard.leadingAnchor, constant: 15),
            segmentsStack.trailingAnchor.constraint(equalTo: creditsCard.trailingAnchor, constant: -15),
            segmentsStack.heightAnchor.constraint(equalToConstant: 14),

            walletTile.topAnchor.constraint(equalTo: segmentsStack.bottomAnchor, constant: 12),
            walletTile.leadingAnchor.constraint(equalTo: creditsCard.leadingAnchor, constant: 15),
            walletTile.widthAnchor.constraint(equalToConstant: 20),
            walletTile.heightAnchor.constraint(equalToConstant: 20),
            walletTile.bottomAnchor.constraint(equalTo: creditsCard.bottomAnchor, constant: -12),

            walletIcon.centerXAnchor.constraint(equalTo: walletTile.centerXAnchor),
            walletIcon.centerYAnchor.constraint(equalTo: walletTile.centerYAnchor),
            walletIcon.widthAnchor.constraint(equalToConstant: 10),
            walletIcon.heightAnchor.constraint(equalToConstant: 10),

            creditsExpiryLabel.centerYAnchor.constraint(equalTo: walletTile.centerYAnchor),
            creditsExpiryLabel.leadingAnchor.constraint(equalTo: walletTile.trailingAnchor, constant: 8),
            creditsExpiryLabel.trailingAnchor.constraint(lessThanOrEqualTo: creditsCard.trailingAnchor, constant: -15)
        ])
    }

    private func buildTrainerCard() {
        trainerCard.translatesAutoresizingMaskIntoConstraints = false
        trainerCard.backgroundColor = UIColor(hex: "#1E1E1F")
        trainerCard.layer.cornerRadius = 12
        trainerCard.layer.borderWidth = 1
        trainerCard.layer.borderColor = UIColor(hex: "#29292A").cgColor
        view.addSubview(trainerCard)

        trainerImageView.translatesAutoresizingMaskIntoConstraints = false
        trainerImageView.contentMode = .scaleAspectFill
        trainerImageView.clipsToBounds = true
        trainerImageView.layer.cornerRadius = 9.188
        trainerImageView.backgroundColor = UIColor(hex: "#1A1A1A")
        trainerCard.addSubview(trainerImageView)

        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerNameLabel.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        trainerNameLabel.textColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
        trainerCard.addSubview(trainerNameLabel)

        trainerExpLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerExpLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        trainerExpLabel.textColor = SgptListingColor.text55
        trainerCard.addSubview(trainerExpLabel)

        viewProfileButton.translatesAutoresizingMaskIntoConstraints = false
        viewProfileButton.setTitle("VIEW PROFILE", for: .normal)
        viewProfileButton.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        viewProfileButton.setTitleColor(.white, for: .normal)
        viewProfileButton.backgroundColor = UIColor(hex: "#1D1E1D")
        viewProfileButton.layer.cornerRadius = 8
        viewProfileButton.layer.borderWidth = 1
        viewProfileButton.layer.borderColor = SgptListingColor.stroke10.cgColor
        viewProfileButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        viewProfileButton.addTarget(self, action: #selector(viewProfileTapped), for: .touchUpInside)
        trainerCard.addSubview(viewProfileButton)

        NSLayoutConstraint.activate([
            trainerImageView.leadingAnchor.constraint(equalTo: trainerCard.leadingAnchor, constant: 12),
            trainerImageView.centerYAnchor.constraint(equalTo: trainerCard.centerYAnchor),
            trainerImageView.widthAnchor.constraint(equalToConstant: 42),
            trainerImageView.heightAnchor.constraint(equalToConstant: 42),

            trainerNameLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 12),
            trainerNameLabel.bottomAnchor.constraint(equalTo: trainerCard.centerYAnchor, constant: 1),
            trainerNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: viewProfileButton.leadingAnchor, constant: -8),

            trainerExpLabel.leadingAnchor.constraint(equalTo: trainerNameLabel.leadingAnchor),
            trainerExpLabel.topAnchor.constraint(equalTo: trainerNameLabel.bottomAnchor, constant: 2),

            viewProfileButton.trailingAnchor.constraint(equalTo: trainerCard.trailingAnchor, constant: -12),
            viewProfileButton.centerYAnchor.constraint(equalTo: trainerCard.centerYAnchor),
            viewProfileButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func bind() {
        let session = input.session

        sessionNameLabel.text = SgptCardCollectionViewCell.titleText(for: session)
        sessionWhenLabel.attributedText = SgptCardCollectionViewCell.subtitleText(for: session)
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

        buildSegments(filled: remainingAfter)
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

    /// Two capsule tracks of four segments each, matching the Figma credits
    /// meter: segments fill left-to-right for the credits left after this
    /// booking, the rest sit dimmed.
    private func buildSegments(filled: Int) {
        segmentsStack.arrangedSubviews.forEach {
            segmentsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let filledCount = min(max(filled, 0), Metric.creditSegments)

        for track in 0..<2 {
            let trackView = UIStackView()
            trackView.axis = .horizontal
            trackView.spacing = 2
            trackView.distribution = .fillEqually
            trackView.isLayoutMarginsRelativeArrangement = true
            trackView.layoutMargins = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            trackView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
            trackView.layer.cornerRadius = 7
            trackView.clipsToBounds = true

            for index in 0..<4 {
                let segment = UIView()
                segment.backgroundColor = (track * 4 + index) < filledCount
                    ? .white
                    : UIColor.white.withAlphaComponent(0.2)
                segment.layer.cornerRadius = 2.5
                trackView.addArrangedSubview(segment)
            }
            segmentsStack.addArrangedSubview(trackView)
        }
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func confirmTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirm?()
        }
    }

    @objc private func viewProfileTapped() {
        onViewProfile?()
    }
}
