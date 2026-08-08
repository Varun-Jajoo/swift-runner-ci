//
//  TermsAndConditionsSheetViewController.swift
//  MyPT
//
//  "Terms & Condition" bottom sheet for group (GX) classes — numbered
//  sections (bold title + gray paragraph), no icon, unlike the Cancellation
//  Policy checklist sheet. Backed by the same `legal_documents` /
//  `content_json_en` mechanism (see `CancellationPolicySheetViewController`
//  for the shared rationale), under `type: gx_terms_free` / `gx_terms_paid`.
//
//  Layout spacing here is a direct port of the Figma redline given for this
//  screen (handle -> 31pt -> title -> 19.44pt -> divider -> 26.44pt -> section 1
//  -> 5pt -> body -> 26.45pt -> section 2 -> ...), not approximated like
//  Cancellation Policy's card colors were.
//
//  Android reference: `GroupTrainingDetailActivity.showTermsAndConditionsBottomSheet()`
//  / `dialog_terms_conditions_bottom_sheet.xml` / `item_terms_conditions_row.xml`.
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
        static let handleToTitle: CGFloat = 31
        static let titleToDivider: CGFloat = 19.44
        static let dividerToItems: CGFloat = 26.44
        static let itemSpacing: CGFloat = 26.44
        static let titleToBody: CGFloat = 5
        static let sheetCornerRadius: CGFloat = 20
    }

    private enum Palette {
        static let sheetBg = UIColor(hex: "#131416")
        static let handle = UIColor(hex: "#393C43")
        static let title = UIColor(hex: "#F0F0F0")
        static let divider = UIColor.white.withAlphaComponent(0.10)
        static let itemTitle = UIColor.white
        static let itemDescription = UIColor(hex: "#AAAAAA")
    }

    private enum Copy {
        static let fallbackTitle = "Terms & Condition"
    }

    /// The exact content seeded on the backend for `gx_terms_free`/`_paid` -
    /// shown immediately on open, before the live fetch resolves.
    private static let defaultItems: [GxTermsItem] = [
        GxTermsItem(title: "1. Booking & Payment", description: "All bookings are confirmed only upon successful payment. Prices are inclusive of VAT where applicable. MyPT reserves the right to update pricing with 7 days notice."),
        GxTermsItem(title: "2. Class Participation", description: "Participants must be 16 years or older unless otherwise stated. Please inform your trainer of any injuries before the session begins.")
    ]

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    private let itemsStack = UIStackView()

    private var resolvedSheetHeight: CGFloat = 0

    /// Same free/paid split as `CancellationPolicySheetViewController.isFree`.
    private var isFree: Bool = true

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.sheetBg
        modalPresentationStyle = .pageSheet
        buildLayout()
        configureSheetPresentation()
        // Same "show the seeded default immediately, replace with live data
        // if it arrives" fix as CancellationPolicySheetViewController.
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

    private func updateResolvedSheetHeight() {
        guard view.bounds.width > 0 else { return }

        let fitting = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let contentHeight = contentStack.systemLayoutSizeFitting(
            fitting,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        let total = ceil(contentHeight + view.safeAreaInsets.bottom)
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

        itemsStack.arrangedSubviews.forEach {
            itemsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for item in items {
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
                                                  bottom: 20,
                                                  right: Metric.horizontalInset)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

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

    /// One numbered section: bold white title (14pt/700), 5pt gap, then a
    /// gray (#AAAAAA) 13pt body at ~165% line height (21.45pt) via
    /// `NSMutableParagraphStyle.lineSpacing`, exactly as specced.
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
        paragraph.lineSpacing = 21.45 - bodyFont.lineHeight
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
