//
//  CancellationPolicySheetViewController.swift
//  MyPT
//
//  "Cancellation Policy" bottom sheet for group (GX) classes — a checklist of
//  icon+title+description rows, admin-editable via the backend's Legal
//  Documents page (`type: gx_cancellation_policy`, structured as JSON in
//  `content_json_en` rather than the usual Summernote HTML, since this is a
//  checklist, not prose).
//
//  Android reference: `GroupTrainingDetailActivity.showCancellationPolicyBottomSheet()`
//  / `dialog_cancellation_policy_bottom_sheet.xml` / `item_cancellation_policy_row.xml`.
//
//  Same content-sized custom-detent bottom-sheet recipe as
//  `DoubleBookingSheetViewController` / `ConfirmSlotSheetViewController` — see
//  those files for why the iOS-15/16 availability guards are load-bearing.
//

import UIKit

// MARK: - Response models

private struct GxCancellationPolicyItem: Decodable {
    let icon: String?
    let title: String?
    let description: String?
}

private struct LegalDocumentContentJson: Decodable {
    let items: [GxCancellationPolicyItem]?
    let footerText: String?

    enum CodingKeys: String, CodingKey {
        case items
        case footerText = "footer_text"
    }
}

private struct LegalDocumentData: Decodable {
    let titleEn: String?
    let contentJsonEn: LegalDocumentContentJson?

    enum CodingKeys: String, CodingKey {
        case titleEn = "title_en"
        case contentJsonEn = "content_json_en"
    }
}

private struct LegalDocumentBaseModel: Decodable {
    let status: Bool?
    let data: LegalDocumentData?
}

// MARK: - CancellationPolicySheetViewController

final class CancellationPolicySheetViewController: CommonViewController {

    // MARK: Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let handleSize = CGSize(width: 64, height: 5)
        static let closeButtonSide: CGFloat = 24
        static let iconTileSide: CGFloat = 40
        static let itemCornerRadius: CGFloat = 12
        static let iconTileCornerRadius: CGFloat = 10
        static let ctaHeight: CGFloat = 48
        static let sheetCornerRadius: CGFloat = 20
    }

    private enum Palette {
        static let sheetBg = UIColor(hex: "#131416")
        static let handle = UIColor(hex: "#393C43")
        static let title = UIColor(hex: "#F0F0F0")
        static let itemCardFill = UIColor(hex: "#1A1B1D")
        static let iconTileFill = UIColor(hex: "#232426")
        static let itemTitle = UIColor.white
        static let itemDescription = UIColor(hex: "#B3B3B3")
        static let footerText = UIColor(hex: "#666666")
        static let ctaFill = UIColor.white
        static let ctaInk = UIColor.black
    }

    private enum Copy {
        static let fallbackTitle = "Cancellation Policy"
        static let ctaTitle = "OK, GOT IT"
        static let defaultFooter = "Effective January 2025 · MyPT LLC"
    }

    /// The exact content seeded on the backend for `gx_cancellation_policy_free`/
    /// `_paid` - shown immediately on open, before the live fetch resolves.
    private static let defaultItems: [GxCancellationPolicyItem] = [
        GxCancellationPolicyItem(icon: "check", title: "Free cancellation", description: "Cancel up to 24 hours before the class for a full refund to your original payment method."),
        GxCancellationPolicyItem(icon: "cross", title: "No refund", description: "Cancel up to 24 hours before the class for a full refund to your original payment method."),
        GxCancellationPolicyItem(icon: "refresh", title: "MyPT cancels", description: "If MyPT cancels for any reason, you receive a full refund or 90-day credits."),
        GxCancellationPolicyItem(icon: "refresh", title: "4th Point", description: "If MyPT cancels for any reason, you receive a full refund or 90-day credits.")
    ]

    // MARK: Views

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    private let itemsStack = UIStackView()
    private let footerLabel = UILabel()
    private let ctaButton = UIButton(type: .system)

    private var resolvedSheetHeight: CGFloat = 0

    /// Which doc variant to fetch - a class free-for-this-member and one
    /// booked/paid-for show DIFFERENT policy text. Set by `present(from:isFree:)`
    /// before `viewDidLoad` ever runs, so `fetchPolicy()` always sees the right
    /// value. Defaults `true` only so a stray call site without it fails safe
    /// toward the more permissive copy rather than crashing.
    private var isFree: Bool = true

    // MARK: Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.sheetBg
        modalPresentationStyle = .pageSheet
        buildLayout()
        configureSheetPresentation()
        // Populated immediately with the exact content seeded on the backend,
        // rather than staying empty until the network call resolves - a slow
        // or failing request (e.g. not yet deployed) previously meant this
        // sheet opened and just sat there with nothing in it. Live data
        // replaces this in `populate(...)` if the call succeeds.
        populate(title: nil, items: CancellationPolicySheetViewController.defaultItems, footerText: Copy.defaultFooter)
        fetchPolicy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateResolvedSheetHeight()
    }

    // MARK: Presentation helper

    @discardableResult
    static func present(from presenter: UIViewController, isFree: Bool) -> CancellationPolicySheetViewController {
        let controller = CancellationPolicySheetViewController()
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
                    identifier: UISheetPresentationController.Detent.Identifier("cancellationPolicyContent")
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

        let total = ceil(contentHeight + 16)
        guard total > 0, abs(total - resolvedSheetHeight) > 0.5 else { return }

        resolvedSheetHeight = total
        if #available(iOS 16.0, *) {
            sheetPresentationController?.invalidateDetents()
        }
    }

    // MARK: Networking

    private func fetchPolicy() {
        let endpoint: ApiEndPoint = isFree ? .get_gx_cancellation_policy_free : .get_gx_cancellation_policy_paid
        NetworkManager.shared.genericAPICall(serviceEndPoint: endpoint,
                                             method: .get,
                                             isShowLoading: false) { [weak self] responseData, _ in
            guard let self = self, let responseData = responseData else { return }
            guard let result = try? JSONDecoder().decode(LegalDocumentBaseModel.self, from: responseData),
                  result.status == true, let data = result.data else { return }

            DispatchQueue.main.async {
                self.populate(title: data.titleEn,
                             items: data.contentJsonEn?.items ?? [],
                             footerText: data.contentJsonEn?.footerText)
            }
        }
    }

    private func populate(title: String?, items: [GxCancellationPolicyItem], footerText: String?) {
        if let title = title, !title.isEmpty {
            titleLabel.text = title
        }

        itemsStack.arrangedSubviews.forEach {
            itemsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for item in items {
            itemsStack.addArrangedSubview(makeItemRow(item))
        }

        if let footerText = footerText, !footerText.isEmpty {
            footerLabel.text = footerText
            footerLabel.isHidden = false
        } else {
            footerLabel.isHidden = true
        }

        updateResolvedSheetHeight()
    }

    // MARK: Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func gotItTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Layout

private extension CancellationPolicySheetViewController {

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
        contentStack.setCustomSpacing(16, after: handleRow)

        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        itemsStack.axis = .vertical
        itemsStack.alignment = .fill
        itemsStack.spacing = 12
        contentStack.addArrangedSubview(itemsStack)
        contentStack.setCustomSpacing(16, after: headerRow)

        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        footerLabel.textColor = Palette.footerText
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        footerLabel.isHidden = true
        contentStack.addArrangedSubview(footerLabel)
        contentStack.setCustomSpacing(16, after: itemsStack)

        let cta = makeCTA()
        contentStack.addArrangedSubview(cta)
        contentStack.setCustomSpacing(16, after: footerLabel)
    }

    /// Same 64×5 `#393C43` pill used by every other bottom sheet in the group
    /// class flow (`DoubleBookingSheetViewController`, `ConfirmSlotSheetViewController`)
    /// — the exact asset the design spec called out, already established here.
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

    /// One checklist row: a rounded-square icon tile on the left, title +
    /// wrapped description stacked on the right, both sitting inside a
    /// slightly-lighter-than-sheet card (`#1A1B1D` on `#131416`).
    func makeItemRow(_ item: GxCancellationPolicyItem) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Palette.itemCardFill
        card.layer.cornerRadius = Metric.itemCornerRadius
        card.layer.masksToBounds = true

        let iconTile = UIView()
        iconTile.translatesAutoresizingMaskIntoConstraints = false
        iconTile.backgroundColor = Palette.iconTileFill
        iconTile.layer.cornerRadius = Metric.iconTileCornerRadius
        iconTile.layer.masksToBounds = true

        let iconView = UIImageView(image: iconImage(for: item.icon))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        iconTile.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
        titleLabel.textColor = Palette.itemTitle
        titleLabel.numberOfLines = 1
        titleLabel.text = item.title ?? ""

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        descriptionLabel.textColor = Palette.itemDescription
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = item.description ?? ""

        let textStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 4

        card.addSubview(iconTile)
        card.addSubview(textStack)

        NSLayoutConstraint.activate([
            iconTile.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            iconTile.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconTile.widthAnchor.constraint(equalToConstant: Metric.iconTileSide),
            iconTile.heightAnchor.constraint(equalToConstant: Metric.iconTileSide),

            iconView.centerXAnchor.constraint(equalTo: iconTile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconTile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            textStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            textStack.leadingAnchor.constraint(equalTo: iconTile.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
        ])
        return card
    }

    /// Backend sends a plain string key (`check`/`cross`/`refresh`) rather than
    /// an asset name, so the icon choice stays backend-editable without an app
    /// release - matches Android's `when (item.optString("icon"))` switch.
    func iconImage(for key: String?) -> UIImage? {
        switch key {
        case "check": return UIImage(systemName: "checkmark")
        case "cross": return UIImage(systemName: "xmark")
        case "refresh": return UIImage(systemName: "arrow.triangle.2.circlepath")
        default: return UIImage(systemName: "checkmark")
        }
    }

    func makeCTA() -> UIView {
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.backgroundColor = Palette.ctaFill
        ctaButton.layer.cornerRadius = 8
        ctaButton.setTitleColor(Palette.ctaInk, for: .normal)
        ctaButton.titleLabel?.font = AppFont.semibold.size(13.0, familyName: familyFunnelSans)
        ctaButton.setTitle(Copy.ctaTitle, for: .normal)
        ctaButton.tintColor = Palette.ctaInk
        ctaButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        ctaButton.semanticContentAttribute = .forceRightToLeft
        ctaButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        ctaButton.addTarget(self, action: #selector(gotItTapped), for: .touchUpInside)
        ctaButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight).isActive = true
        return ctaButton
    }
}
