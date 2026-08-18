//
//  CancelBookingSheetViewController.swift
//  MyPT
//
//  "Cancel this booking?" bottom sheet — the group-class cancel confirmation,
//  built to match the same visual shell as `ConfirmSlotSheetViewController`
//  (Android: `dialog_confirm_slot_bottom_sheet.xml` / `showConfirmSlotBottomSheet`)
//  rather than a plain system alert, per explicit design direction: this
//  should look like the app's own confirm-booking sheet, not `UIAlertController`.
//
//  Android reference (ground truth for layout, copy and logic):
//    app/src/main/res/layout/dialog_cancel_booking_bottom_sheet.xml
//    app/src/main/java/co/com/mypt/UpComingClasses/SlotConfirmedActivity.kt
//        · showCancelBookingBottomSheet(bookingId, title, time, location, distance)
//        · sendCancelBookingRequest(bookingId, title, time)
//
//  Only shown from `SlotConfirmedViewController` in its read-only mode
//  (`canCancelBooking`), for the Bookings tab's Upcoming sub-tab.
//

import UIKit

// MARK: - CancelBookingSheetInput

struct CancelBookingSheetInput {
    /// Already stripped of the "wl-" prefix when `isWaitlist` is true - the
    /// raw numeric id `leave-waitlist` expects.
    var bookingId: String = ""
    /// A waitlist entry (GcWaitlist) is a different row from a confirmed
    /// booking (UserClassBooking) - needs `leave-waitlist`, not
    /// `cancel-class-booking`, or the API call fails with "booking not found".
    var isWaitlist: Bool = false
    var title: String = ""
    var time: String = ""
    var location: String = ""
    var distance: String = ""
    /// Blank/zero means free - the sheet then shows the plain cancellation
    /// policy instead of an amount + refund note.
    var price: String = ""
}

// MARK: - CancelBookingSheetViewController

final class CancelBookingSheetViewController: CommonViewController {

    // MARK: Input / output

    var input = CancelBookingSheetInput()

    /// Fires after a successful `cancel-class-booking` call and the sheet has
    /// finished dismissing. The presenter (`SlotConfirmedViewController`) uses
    /// this to push `BookingCancelledViewController`.
    var onCancelled: (() -> Void)?

    // MARK: Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let bottomInset: CGFloat = 0
        static let handleSize = CGSize(width: 64, height: 5)
        static let closeButtonSide: CGFloat = 24
        static let cardPadding: CGFloat = 20
        static let cardCornerRadius: CGFloat = 16
        static let iconTileSide: CGFloat = 38
        static let rowIconSide: CGFloat = 18
        static let ctaHeight: CGFloat = 48
        static let sheetCornerRadius: CGFloat = 20
    }

    private enum Palette {
        static let sheetBg = UIColor(hex: "#121315")
        static let handle = UIColor(hex: "#393C43")
        static let title = UIColor(hex: "#F0F0F0")
        static let subtext = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let cardFill = UIColor(hex: "#18191C")
        static let cardStroke = UIColor(hex: "#232323")
        static let tileFill = UIColor(hex: "#101113")
        static let rowTitle = UIColor(hex: "#FAFAFA")
        static let rowSubtitle = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55) // #8CFAFAFA
        static let divider = UIColor.white.withAlphaComponent(0.10)             // #1AFFFFFF
        static let ctaInk = UIColor.white
        static let dangerStart = UIColor(hex: "#FF4444")
        static let dangerEnd = UIColor(hex: "#FF4444")
        static let dangerBand = UIColor(hex: "#2B1512")
        static let supportCardBg = UIColor(hex: "#0954A9")
        static let supportSubtitle = UIColor(hex: "#8CFAFAFA")
    }

    private enum Copy {
        static let title = "Don't let this class go to waste!"
        static let subtitle = "You're one step closer to your goals."
        static let supportTitle = "Dedicated Support"
        static let supportSubtitle = "For assistance with on-training issues or any escalations"
        static let cancelCTA = "CANCEL BOOKING"
        static let leaveWaitlistCTA = "LEAVE WAITLIST"
        static let keepCTA = "KEEP BOOKING"
        static let cancelFailed = "Could not cancel booking. Please try again."
        static let refundEligible = "Eligible for refund"
        static let refundPolicyHeading = "REFUND POLICY"
        static let refundPolicyBody = "Your payment will be refunded to your original payment method."
        static let cancellationPolicyHeading = "CANCELLATION POLICY"
        static let cancellationPolicyBody = "This is a free booking - cancelling won't charge you anything."
        static let waitlistPolicyHeading = "WAITLIST"
        static let waitlistPolicyBody = "You'll lose your spot in line - you can rejoin the waitlist anytime before the class fills up again."
    }

    /// Mirrors Android's `isFreeOrZero` check in `SlotConfirmedActivity`/
    /// `SlotConfirmedViewController.applyPrice()` - blank, "free", or <= 0 all
    /// mean nothing to refund.
    private var isFree: Bool {
        let raw = input.price.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.isEmpty { return true }
        let clean = raw.replacingOccurrences(of: "AED", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: " ", with: "")
        if clean.caseInsensitiveCompare("free") == .orderedSame { return true }
        return (Double(clean) ?? 0.0) <= 0.0
    }

    // MARK: Views

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let closeButton = UIButton(type: .system)

    private let amountTitleLabel = UILabel()

    private let ctaButton = GradientCTAButton()
    private let keepBookingButton = UIButton(type: .system)

    private var resolvedSheetHeight: CGFloat = 0

    // MARK: Init

    init(input: CancelBookingSheetInput) {
        self.input = input
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        self.input = CancelBookingSheetInput()
        super.init(coder: coder)
        modalPresentationStyle = .pageSheet
    }

    // MARK: Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Palette.sheetBg
        buildLayout()
        populateUI()
        configureSheetPresentation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateResolvedSheetHeight()
    }

    // MARK: Sheet presentation

    private func configureSheetPresentation() {
        if #available(iOS 15.0, *) {
            guard let sheet = sheetPresentationController else { return }

            sheet.preferredCornerRadius = Metric.sheetCornerRadius
            sheet.prefersGrabberVisible = false

            if #available(iOS 16.0, *) {
                let detent = UISheetPresentationController.Detent.custom(
                    identifier: UISheetPresentationController.Detent.Identifier("cancelBookingContent")
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

    // MARK: Populate

    private func populateUI() {
        let clean = input.price.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "AED", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: " ", with: "")
        amountTitleLabel.text = "\(clean) AED"
    }

    // MARK: Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func keepBookingTapped() {
        dismiss(animated: true)
    }

    @objc private func confirmCancelTapped() {
        TapticEngine.selection.feedback()
        guard !input.bookingId.isEmpty else { return }

        let endpoint: ApiEndPoint = input.isWaitlist ? .leave_waitlist : .cancel_class_booking
        let params: [String: Any] = input.isWaitlist
            ? ["waitlist_id": input.bookingId]
            : ["booking_id": input.bookingId]
        NetworkManager.shared.genericAPICall(serviceEndPoint: endpoint,
                                             method: .post,
                                             parameters: params,
                                             isShowLoading: true) { [weak self] responseData, _ in
            guard let self = self else { return }
            let succeeded = responseData
                .flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
                .flatMap { $0["status"] as? Bool } ?? false

            DispatchQueue.main.async {
                if succeeded {
                    self.dismiss(animated: true) { [weak self] in
                        self?.onCancelled?()
                    }
                } else {
                    AlertHelper.shared.showCustomeAlert(title: "", message: Copy.cancelFailed, actions: ["OK"], completion: nil)
                }
            }
        }
    }
}

// MARK: - Presentation helper

extension CancelBookingSheetViewController {

    @discardableResult
    static func present(from presenter: UIViewController,
                        input: CancelBookingSheetInput,
                        onCancelled: (() -> Void)? = nil) -> CancelBookingSheetViewController {
        let controller = CancelBookingSheetViewController(input: input)
        controller.onCancelled = onCancelled
        presenter.present(controller, animated: true)
        return controller
    }
}

// MARK: - Layout

private extension CancelBookingSheetViewController {

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
        contentStack.layoutMargins = UIEdgeInsets(top: 8,
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
        contentStack.setCustomSpacing(12, after: handleRow)

        let headerRow = makeHeaderRow()
        contentStack.addArrangedSubview(headerRow)
        contentStack.setCustomSpacing(20, after: headerRow)

        // Decorative nudge card - matches the app's existing
        // cancel_booking_bottom_sheet_dialog.xml content pattern (no tap
        // destination there either).
        let supportCard = makeSupportCard()
        contentStack.addArrangedSubview(supportCard)
        contentStack.setCustomSpacing(20, after: supportCard)

        // Amount-paid card - paid bookings only; a free booking has nothing
        // new to show here beyond the support card and policy note below.
        if !isFree {
            let detailsCard = makeDetailsCard()
            contentStack.addArrangedSubview(detailsCard)
            contentStack.setCustomSpacing(16, after: detailsCard)
        }

        // Refund/cancellation policy - real, non-duplicate content instead of
        // re-stating what the details screen behind this sheet already shows.
        let policyBox = makePolicyNoteBox()
        contentStack.addArrangedSubview(policyBox)
        contentStack.setCustomSpacing(20, after: policyBox)

        contentStack.addArrangedSubview(makeCancelCTA())
        contentStack.setCustomSpacing(12, after: contentStack.arrangedSubviews.last!)

        contentStack.addArrangedSubview(makeKeepBookingButton())
    }

    // MARK: Handle

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

    // MARK: Header

    func makeHeaderRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        titleLabel.textColor = Palette.title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.text = Copy.title

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .left
        subtitleLabel.attributedText = NSAttributedString(
            string: Copy.subtitle,
            attributes: [
                .font: AppFont.regular.size(16.0, familyName: familyFunnelSans),
                .foregroundColor: Palette.subtext,
                .paragraphStyle: CancelBookingSheetViewController.paragraphStyle(lineSpacing: 4, alignment: .left)
            ]
        )

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 8
        container.addSubview(textStack)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(CancelBookingSheetViewController.icon(["ic_close_x_34"], systemFallback: "xmark")?
            .withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = Palette.title
        closeButton.accessibilityLabel = "Close"
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.contentHorizontalAlignment = .fill
        closeButton.contentVerticalAlignment = .fill
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        container.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: container.topAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: Metric.closeButtonSide),
            closeButton.heightAnchor.constraint(equalToConstant: Metric.closeButtonSide),

            textStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textStack.topAnchor.constraint(equalTo: container.topAnchor),
            textStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            textStack.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -12)
        ])
        return container
    }

    // MARK: Support nudge card

    func makeSupportCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Palette.supportCardBg
        card.layer.cornerRadius = 10
        card.layer.masksToBounds = true

        let iconView = UIImageView(image: CancelBookingSheetViewController.icon(["customer_support", "headphones"], systemFallback: "headphones"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.semibold.size(16.0, familyName: familyFunnelSans)
        titleLabel.textColor = Palette.rowTitle
        titleLabel.numberOfLines = 1
        titleLabel.text = Copy.supportTitle

        let chevron = UIImageView(image: CancelBookingSheetViewController.icon(["ic_chevron_right_16", "chevron-right"], systemFallback: "chevron.right")?
            .withRenderingMode(.alwaysTemplate))
        chevron.tintColor = .white
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.contentMode = .scaleAspectFit

        let topRow = UIStackView(arrangedSubviews: [iconView, titleLabel, chevron])
        topRow.translatesAutoresizingMaskIntoConstraints = false
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 10

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        subtitleLabel.textColor = Palette.supportSubtitle
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = Copy.supportSubtitle

        // Fixed-width spacer indents the subtitle under the title (not the
        // icon) without fighting the outer stack's own arranged-subview
        // constraints the way a second manual leading anchor would.
        let indentSpacer = UIView()
        indentSpacer.translatesAutoresizingMaskIntoConstraints = false
        indentSpacer.widthAnchor.constraint(equalToConstant: 34).isActive = true

        let subtitleRow = UIStackView(arrangedSubviews: [indentSpacer, subtitleLabel])
        subtitleRow.translatesAutoresizingMaskIntoConstraints = false
        subtitleRow.axis = .horizontal
        subtitleRow.alignment = .fill

        let stack = UIStackView(arrangedSubviews: [topRow, subtitleRow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 5
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            chevron.widthAnchor.constraint(equalToConstant: 20),
            chevron.heightAnchor.constraint(equalToConstant: 20),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    // MARK: Details card

    func makeDetailsCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08

        // Class name/time is already the whole screen behind this sheet, so
        // this card only ever shows the one thing that ISN'T already on
        // screen: the amount paid (only built at all for paid bookings).
        amountTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        amountTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        amountTitleLabel.textColor = Palette.rowTitle
        amountTitleLabel.numberOfLines = 1

        let amountSubtitleLabel = UILabel()
        amountSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        amountSubtitleLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        amountSubtitleLabel.textColor = Palette.rowSubtitle
        amountSubtitleLabel.numberOfLines = 1
        amountSubtitleLabel.text = Copy.refundEligible

        let amountRow = makeCardRow(icon: CancelBookingSheetViewController.icon(["ic_dirham_icon", "dirham-currency", "ic_aed"], systemFallback: "creditcard"),
                                    titleLabel: amountTitleLabel,
                                    subtitleLabel: amountSubtitleLabel)

        let stack = UIStackView(arrangedSubviews: [amountRow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
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

    func makeCardRow(icon: UIImage?, titleLabel: UILabel, subtitleLabel: UILabel) -> UIView {
        let iconTile = makeIconTile(image: icon)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 2
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [iconTile, textStack])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    func makeIconTile(image: UIImage?) -> UIView {
        let tile = GlassCardView(cornerRadius: 12)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = Palette.tileFill
        tile.fillAlpha = 1.0
        tile.strokeColor = UIColor(hex: "#101113")
        tile.strokeAlpha = 1.0
        tile.sheenOrigin = .topCenter
        tile.sheenAlpha = 0.08

        let iconView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        iconView.tintColor = .white
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        tile.addSubview(iconView)

        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: Metric.iconTileSide),
            tile.heightAnchor.constraint(equalToConstant: Metric.iconTileSide),
            iconView.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: Metric.rowIconSide),
            iconView.heightAnchor.constraint(equalToConstant: Metric.rowIconSide)
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

    // MARK: Policy note

    /// Matches `important_note_bg` styling used across the module - amber
    /// fill/stroke, warning-style box - reused here for whichever policy
    /// text actually applies instead of duplicating the class/location the
    /// user already sees on the screen behind this sheet.
    func makePolicyNoteBox() -> UIView {
        let box = UIView()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.backgroundColor = GroupClassColor.gold.color.withAlphaComponent(0.10)
        box.layer.cornerRadius = 12
        box.layer.masksToBounds = true
        box.layer.borderWidth = 1
        box.layer.borderColor = GroupClassColor.gold.color.withAlphaComponent(0.30).cgColor

        let warningIcon = UIImageView(image: CancelBookingSheetViewController.icon(["ic_warning_hex_16", "info-hexagon"], systemFallback: "exclamationmark.triangle.fill")?
            .withRenderingMode(.alwaysTemplate))
        warningIcon.translatesAutoresizingMaskIntoConstraints = false
        warningIcon.tintColor = GroupClassColor.gold.color
        warningIcon.contentMode = .scaleAspectFit

        let headingLabel = UILabel()
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        headingLabel.textColor = GroupClassColor.gold.color
        headingLabel.numberOfLines = 1
        headingLabel.text = input.isWaitlist ? Copy.waitlistPolicyHeading : (isFree ? Copy.cancellationPolicyHeading : Copy.refundPolicyHeading)

        let headingRow = UIStackView(arrangedSubviews: [warningIcon, headingLabel])
        headingRow.translatesAutoresizingMaskIntoConstraints = false
        headingRow.axis = .horizontal
        headingRow.alignment = .center
        headingRow.spacing = 8

        let indentSpacer = UIView()
        indentSpacer.translatesAutoresizingMaskIntoConstraints = false
        indentSpacer.widthAnchor.constraint(equalToConstant: 24).isActive = true

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.numberOfLines = 0
        bodyLabel.attributedText = NSAttributedString(
            string: input.isWaitlist ? Copy.waitlistPolicyBody : (isFree ? Copy.cancellationPolicyBody : Copy.refundPolicyBody),
            attributes: [
                .font: AppFont.regular.size(12.0, familyName: familyFunnelSans),
                .foregroundColor: UIColor.white,
                .paragraphStyle: CancelBookingSheetViewController.paragraphStyle(lineSpacing: 3, alignment: .left)
            ]
        )

        let bodyRow = UIStackView(arrangedSubviews: [indentSpacer, bodyLabel])
        bodyRow.translatesAutoresizingMaskIntoConstraints = false
        bodyRow.axis = .horizontal
        bodyRow.alignment = .fill

        let stack = UIStackView(arrangedSubviews: [headingRow, bodyRow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 5
        box.addSubview(stack)

        NSLayoutConstraint.activate([
            warningIcon.widthAnchor.constraint(equalToConstant: 16),
            warningIcon.heightAnchor.constraint(equalToConstant: 16),

            stack.topAnchor.constraint(equalTo: box.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -12)
        ])
        return box
    }

    // MARK: CTAs

    func makeCancelCTA() -> UIView {
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.bandThickness = 2
        ctaButton.bandColor = Palette.dangerBand
        ctaButton.bodyStartColor = Palette.dangerStart
        ctaButton.bodyEndColor = Palette.dangerEnd
        ctaButton.configure(title: input.isWaitlist ? Copy.leaveWaitlistCTA : Copy.cancelCTA,
                            font: AppFont.semibold.size(15.0, familyName: familyFunnelSans),
                            titleColor: Palette.ctaInk)
        ctaButton.addTarget(self, action: #selector(confirmCancelTapped), for: .touchUpInside)
        ctaButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight).isActive = true
        return ctaButton
    }

    func makeKeepBookingButton() -> UIView {
        keepBookingButton.translatesAutoresizingMaskIntoConstraints = false
        keepBookingButton.setTitle(Copy.keepCTA, for: .normal)
        keepBookingButton.setTitleColor(UIColor(hex: "#131416"), for: .normal)
        keepBookingButton.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        keepBookingButton.backgroundColor = .white
        keepBookingButton.layer.cornerRadius = 8
        keepBookingButton.layer.masksToBounds = true
        keepBookingButton.addTarget(self, action: #selector(keepBookingTapped), for: .touchUpInside)
        keepBookingButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return keepBookingButton
    }
}

// MARK: - Attributed copy + icon resolution

private extension CancelBookingSheetViewController {

    static func paragraphStyle(lineSpacing: CGFloat, alignment: NSTextAlignment) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.alignment = alignment
        return style
    }

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
