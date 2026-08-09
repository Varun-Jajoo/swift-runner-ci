//
//  TermsAndConditionsSheetViewController.swift
//  MyPT
//
//  "Terms & Condition" bottom sheet for group (GX) classes — numbered
//  sections (bold title + gray paragraph) with "OKAY, GOT IT" action button.
//

import UIKit

// MARK: - Response models

private struct GxTermsItem: Decodable {
    let title: String?
    let description: String?
}

private struct TermsContentJson: Decodable {
    let items: [GxTermsItem]?
}

private struct TermsLegalDocumentData: Decodable {
    let titleEn: String?
    let contentJsonEn: TermsContentJson?

    enum CodingKeys: String, CodingKey {
        case titleEn = "title_en"
        case contentJsonEn = "content_json_en"
    }
}

private struct TermsLegalDocumentBaseModel: Decodable {
    let status: Bool?
    let data: TermsLegalDocumentData?
}

// MARK: - TermsAndConditionsSheetViewController

final class TermsAndConditionsSheetViewController: CommonViewController {

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let handleSize = CGSize(width: 64, height: 5)
        static let closeButtonSide: CGFloat = 24
        static let handleToTitle: CGFloat = 20
        static let titleToDivider: CGFloat = 16
        static let dividerToItems: CGFloat = 16
        static let itemSpacing: CGFloat = 16
        static let titleToBody: CGFloat = 4
        static let sheetCornerRadius: CGFloat = 20
        static let buttonHeight: CGFloat = 48
    }

    private enum Palette {
        static let sheetBg = UIColor(hex: "#131416")
        static let handle = UIColor(hex: "#393C43")
        static let title = UIColor(hex: "#F0F0F0")
        static let divider = UIColor.white.withAlphaComponent(0.10)
        static let itemTitle = UIColor.white
        static let itemDescription = UIColor(hex: "#AAAAAA")
        /// Matches CancellationPolicySheetViewController's ctaFill/ctaInk exactly —
        /// the two sheets are siblings reached from the same rows, so they use one
        /// button treatment. Was #F2EBC0 (cream), which read as yellow next to the
        /// white CTA on the cancellation sheet.
        static let btnBg = UIColor.white
        static let btnText = UIColor.black
    }

    private enum Copy {
        static let fallbackTitle = "Terms & Conditions"
        static let okayGotIt = "OKAY, GOT IT"
    }

    private static let defaultItems: [GxTermsItem] = [
        GxTermsItem(title: "1. Booking & Payment", description: "All bookings are confirmed only upon successful payment. Prices are inclusive of VAT where applicable. MyPT reserves the right to update pricing with 7 days notice."),
        GxTermsItem(title: "2. Class Participation", description: "Participants must be 16 years or older unless otherwise stated. Please inform your trainer of any injuries before the session begins.")
    ]

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    private let itemsStack = UIStackView()
    private let okayButton = UIButton(type: .system)

    private var resolvedSheetHeight: CGFloat = 0
    private var isFree: Bool = true

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.sheetBg
        modalPresentationStyle = .pageSheet
        buildLayout()
        configureSheetPresentation()
        populate(title: nil, items: TermsAndConditionsSheetViewController.defaultItems)
        fetchTerms()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateResolvedSheetHeight()
    }

    @discardableResult
    static func present(from presenter: UIViewController, isFree: Bool) -> TermsAndConditionsSheetViewController {
        let controller = TermsAndConditionsSheetViewController()
        controller.isFree = isFree
        presenter.present(controller, animated: true)
        return controller
    }

    // MARK: Sheet presentation

    private func configureSheetPresentation() {
        if #available(iOS 15.0, *) {
            guard let sheet = sheetPresentationController else { return }
            sheet.preferredCornerRadius = Metric.sheetCornerRadius
            sheet.prefersGrabberVisible = false

            if #available(iOS 16.0, *) {
                let detent = UISheetPresentationController.Detent.custom(
                    identifier: UISheetPresentationController.Detent.Identifier("termsConditionsContent")
                ) { [weak self] context in
                    guard let self = self, self.resolvedSheetHeight > 0 else {
                        return context.maximumDetentValue * 0.75
                    }
                    return min(self.resolvedSheetHeight, context.maximumDetentValue * 0.85)
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

    // MARK: Networking

    private func fetchTerms() {
        let endpoint: ApiEndPoint = isFree ? .get_gx_terms_free : .get_gx_terms_paid
        NetworkManager.shared.genericAPICall(serviceEndPoint: endpoint,
                                             method: .get,
                                             isShowLoading: false) { [weak self] responseData, _ in
            guard let self = self, let responseData = responseData else { return }
            guard let result = try? JSONDecoder().decode(TermsLegalDocumentBaseModel.self, from: responseData),
                  result.status == true, let data = result.data else { return }

            DispatchQueue.main.async {
                self.populate(title: data.titleEn, items: data.contentJsonEn?.items ?? [])
            }
        }
    }

    private func populate(title: String?, items: [GxTermsItem]) {
        if let title = title, !title.isEmpty {
            titleLabel.text = title
        }

        let displayItems = items.isEmpty ? TermsAndConditionsSheetViewController.defaultItems : items
        itemsStack.arrangedSubviews.forEach {
            itemsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for item in displayItems {
            itemsStack.addArrangedSubview(makeItemBlock(item))
        }

        updateResolvedSheetHeight()
    }

    // MARK: Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Layout

private extension TermsAndConditionsSheetViewController {

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

        let handleRow = makeHandleRow()
        contentStack.addArrangedSubview(handleRow)

        let headerRow = makeHeaderRow()
        contentStack.addArrangedSubview(headerRow)
        contentStack.setCustomSpacing(Metric.handleToTitle, after: handleRow)

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = Palette.divider
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentStack.addArrangedSubview(divider)
        contentStack.setCustomSpacing(Metric.titleToDivider, after: headerRow)

        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        itemsStack.axis = .vertical
        itemsStack.alignment = .fill
        itemsStack.spacing = Metric.itemSpacing
        contentStack.addArrangedSubview(itemsStack)
        contentStack.setCustomSpacing(Metric.dividerToItems, after: divider)

        let bottomDivider = UIView()
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false
        bottomDivider.backgroundColor = Palette.divider
        bottomDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        okayButton.translatesAutoresizingMaskIntoConstraints = false
        okayButton.setTitle(Copy.okayGotIt, for: .normal)
        okayButton.setTitleColor(Palette.btnText, for: .normal)
        // Same treatment as the cancellation sheet's CTA: semibold 13 with a
        // trailing chevron, so both sheets present an identical button.
        okayButton.titleLabel?.font = AppFont.semibold.size(13.0, familyName: familyFunnelSans)
        okayButton.backgroundColor = Palette.btnBg
        okayButton.tintColor = Palette.btnText
        okayButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        okayButton.semanticContentAttribute = .forceRightToLeft
        okayButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        okayButton.layer.cornerRadius = 8
        okayButton.layer.masksToBounds = true
        okayButton.heightAnchor.constraint(equalToConstant: Metric.buttonHeight).isActive = true
        okayButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        contentStack.setCustomSpacing(16, after: itemsStack)
        contentStack.addArrangedSubview(bottomDivider)
        contentStack.setCustomSpacing(16, after: bottomDivider)
        contentStack.addArrangedSubview(okayButton)
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

    func makeHeaderRow() -> UIView {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        titleLabel.textColor = Palette.title
        titleLabel.numberOfLines = 1
        titleLabel.text = Copy.fallbackTitle

        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = Palette.title
        closeButton.accessibilityLabel = "Close"
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(titleLabel)
        row.addSubview(closeButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: row.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor),

            closeButton.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: Metric.closeButtonSide),
            closeButton.heightAnchor.constraint(equalToConstant: Metric.closeButtonSide),
            closeButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
        return row
    }

    func makeItemBlock(_ item: GxTermsItem) -> UIView {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.bold.size(14.0, familyName: familyFunnelSans)
        titleLabel.textColor = Palette.itemTitle
        titleLabel.numberOfLines = 0
        titleLabel.text = item.title ?? ""

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        let bodyFont = AppFont.regular.size(13.0, familyName: familyFunnelSans)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        descriptionLabel.attributedText = NSAttributedString(
            string: item.description ?? "",
            attributes: [
                .font: bodyFont,
                .foregroundColor: Palette.itemDescription,
                .paragraphStyle: paragraph
            ]
        )

        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Metric.titleToBody
        return stack
    }
}
