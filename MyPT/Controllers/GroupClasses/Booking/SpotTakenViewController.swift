//
//  SpotTakenViewController.swift
//  MyPT
//
//  Shown when claimOpenSpotApi() comes back SPOT_TAKEN - someone else
//  confirmed the race before this member did. The backend already
//  guarantees this member is on the (normal) waitlist by the time this
//  response lands, same as before this screen existed - this only replaces
//  the old alert + straight push to WaitlistConfirmedViewController with a
//  real status screen.
//
//  Android reference: SpotTakenActivity.kt / activity_spot_taken.xml, itself
//  a trimmed copy of SlotOpenActivity's own chrome (close button, class
//  details card) - the countdown/urgency card and CONFIRM/NOT NOW pair are
//  gone (nothing left to race for), replaced by a single status card and a
//  single CTA.
//

import UIKit

final class SpotTakenViewController: CommonViewController {

    // MARK: - Input

    var classTitle: String = "Morning Flow Yoga"
    var classTime: String = "Wed, 9 Jul • 7-8 AM"
    var classLocation: String = "Silicon Oasis"
    var trainerName: String = ""
    var distance: String = ""
    var studioLat: Double = 0
    var studioLng: Double = 0

    // MARK: - Layout constants

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let closeButtonDiameter: CGFloat = 40
        static let heroHeight: CGFloat = 220
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let iconTileSide: CGFloat = 38
        static let ctaHeight: CGFloat = 48
    }

    private enum Palette {
        static let headline = UIColor(hex: "#FAFAFA")
        static let subtext = UIColor(hex: "#959595")
        static let divider = UIColor.white.withAlphaComponent(0.10)
        static let cardFill = UIColor(hex: "#18191C")
        static let cardStroke = UIColor(hex: "#232323")
        static let tileFill = UIColor(hex: "#101113")
        static let pillStroke = UIColor(hex: "#FAFAFA")
        static let pillText = UIColor(hex: "#F0F0F0")
        static let rowTitle = UIColor.white
        static let rowSubtitle = UIColor.white.withAlphaComponent(0.4)
        // rgba(8, 101, 254, ...) - the same blue token
        // WaitlistConfirmedViewController's own notify card uses.
        static let statusCardStroke = GroupClassColor.blue.color.withAlphaComponent(0.30)
        static let statusCardFill = GroupClassColor.blue.color.withAlphaComponent(0.10)
        static let statusText = UIColor(hex: "#ADCCFF")
        static let statusSubtext = UIColor(hex: "#FFFFFF")
        static let ctaInk = UIColor(hex: "#131416")
    }

    private enum Copy {
        static let headline = "Oops! That spot's taken"
        static let subtext = "Another member confirmed the booking before you"
        static let statusTitle = "You're still on the waitlist"
        static let statusSubtext = "We'll notify you if another spot becomes available for this class."
        static let categoryPill = "GROUP CLASS"
        static let exploreCTA = "EXPLORE OTHER CLASSES"
        static let trainerSubtitle = "Certified MyPT Trainer"
    }

    // MARK: Views

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let closeButton = GlassCircularIconButton()
    private let heroImageView = UIImageView()

    private let classTitleLabel = UILabel()
    private let dateTimeLabel = UILabel()
    private let locationTitleLabel = UILabel()
    private let locationDistanceLabel = UILabel()
    private let trainerNameLabel = UILabel()
    private let trainerSubtitleLabel = UILabel()

    private let footerView = UIView()
    private let exploreButton = GradientCTAButton()

    // MARK: Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GroupClassColor.bg.color
        buildLayout()
        populateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    private func populateUI() {
        classTitleLabel.text = classTitle
        dateTimeLabel.text = classTime
        locationTitleLabel.text = GroupClassCardFormatter.cleanStudioName(classLocation)

        let resolvedDistance = GroupClassCardFormatter.distanceText(
            userLat: nil, userLng: nil,
            studioLat: studioLat, studioLng: studioLng,
            fallback: distance
        )
        if !resolvedDistance.isEmpty {
            locationDistanceLabel.text = resolvedDistance
        }

        let trimmedTrainer = trainerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTrainer.isEmpty {
            trainerNameLabel.text = trimmedTrainer.hasPrefix("Trainer:") ? trimmedTrainer : "Trainer: \(trimmedTrainer)"
        }
    }

    // MARK: Actions

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }

    /// Same target ClassCancelledByAdminViewController's own "Explore
    /// Classes" CTA uses - the full Group Activity listing, not just back to
    /// Home.
    @objc private func exploreTapped() {
        let controller = SeeAllGroupClassesViewController()
        if studioLat != 0 { controller.initialLat = studioLat }
        if studioLng != 0 { controller.initialLng = studioLng }
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    private static func icon(_ names: [String], systemFallback: String? = nil) -> UIImage? {
        for name in names {
            if let image = UIImage(named: name) { return image }
        }
        if let systemFallback = systemFallback {
            return UIImage(systemName: systemFallback)
        }
        return nil
    }
}

// MARK: - Layout

private extension SpotTakenViewController {

    func buildLayout() {
        buildFooter()
        buildScrollView()
    }

    func buildFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = .clear
        view.addSubview(footerView)

        exploreButton.translatesAutoresizingMaskIntoConstraints = false
        exploreButton.bandThickness = 2
        exploreButton.configure(title: Copy.exploreCTA,
                                font: AppFont.semibold.size(16.0, familyName: familyFunnelSans),
                                titleColor: Palette.ctaInk)
        exploreButton.addTarget(self, action: #selector(exploreTapped), for: .touchUpInside)
        footerView.addSubview(exploreButton)

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            exploreButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 12),
            exploreButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: Metric.horizontalInset),
            exploreButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -Metric.horizontalInset),
            exploreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            exploreButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight)
        ])
    }

    func buildScrollView() {
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
        contentStack.layoutMargins = UIEdgeInsets(top: 20, left: Metric.horizontalInset, bottom: 24, right: Metric.horizontalInset)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        let closeRow = makeCloseButtonRow()
        contentStack.addArrangedSubview(closeRow)
        contentStack.setCustomSpacing(28, after: closeRow)

        let heroRow = makeHeroRow()
        contentStack.addArrangedSubview(heroRow)
        contentStack.setCustomSpacing(0, after: heroRow)

        let headlineLabel = makeHeadlineLabel()
        contentStack.addArrangedSubview(headlineLabel)
        contentStack.setCustomSpacing(8, after: headlineLabel)

        let subtextLabel = makeSubtextLabel()
        contentStack.addArrangedSubview(subtextLabel)
        contentStack.setCustomSpacing(20, after: subtextLabel)

        let statusCard = makeStatusCard()
        contentStack.addArrangedSubview(statusCard)
        contentStack.setCustomSpacing(16, after: statusCard)

        contentStack.addArrangedSubview(makeDetailsCard())
    }

    // MARK: Close button

    func makeCloseButtonRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.configure(icon: SpotTakenViewController.icon(["ic_close_24"], systemFallback: "xmark"),
                              diameter: Metric.closeButtonDiameter)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        container.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: container.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            closeButton.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: Metric.closeButtonDiameter),
            closeButton.heightAnchor.constraint(equalToConstant: Metric.closeButtonDiameter)
        ])
        return container
    }

    // MARK: Hero + headline

    /// In normal flow, not overlaid with text like Slot Open's own hero -
    /// this illustration has no bottom fade built in for text to sit on.
    /// Headline + subtext follow directly below it instead.
    func makeHeroRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.image = UIImage(named: "spot-taken-hero")
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.backgroundColor = .clear
        // Same LIGHTEN compositing as every other hero image in this module -
        // merges the illustration's near-black background into the screen
        // background instead of showing a rectangle edge.
        heroImageView.layer.isOpaque = false
        heroImageView.layer.compositingFilter = "lightenBlendMode"
        container.addSubview(heroImageView)

        // Belt-and-suspenders on top of the LIGHTEN blend above: a thin edge
        // blend into the screen background, reliable regardless of
        // device/compositing quirks. Kept short deliberately - a tall fade
        // here is itself what reads as dead space between the image and
        // the headline below it.
        let fade = GradientFadeView()
        fade.translatesAutoresizingMaskIntoConstraints = false
        fade.setColors([GroupClassColor.bg.color.withAlphaComponent(0), GroupClassColor.bg.color])
        heroImageView.addSubview(fade)

        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: container.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            heroImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: Metric.heroHeight),

            fade.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor),
            fade.trailingAnchor.constraint(equalTo: heroImageView.trailingAnchor),
            fade.bottomAnchor.constraint(equalTo: heroImageView.bottomAnchor),
            fade.heightAnchor.constraint(equalToConstant: 32)
        ])
        return container
    }

    func makeHeadlineLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
        label.textColor = Palette.headline
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = Copy.headline
        return label
    }

    func makeSubtextLabel() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = NSAttributedString(
            string: Copy.subtext,
            attributes: [
                .font: AppFont.regular.size(15.0, familyName: familyFunnelSans),
                .foregroundColor: Palette.subtext,
                .paragraphStyle: SpotTakenViewController.paragraphStyle(lineSpacing: 4, alignment: .center)
            ]
        )
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        return container
    }

    // MARK: Status card (replaces the urgency/countdown card - nothing left
    // to race, this is a plain status readout)

    func makeStatusCard() -> UIView {
        let card = GlassCardView(cornerRadius: 12)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.statusCardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.statusCardStroke
        card.strokeAlpha = 1.0
        card.showsSheen = false

        let icon = UIImageView(image: SpotTakenViewController
            .icon(["ic_info_hexagon_18", "info-hexagon"], systemFallback: "info.circle")?
            .withRenderingMode(.alwaysTemplate))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = Palette.statusText
        icon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        titleLabel.textColor = Palette.statusText
        titleLabel.numberOfLines = 1
        titleLabel.text = Copy.statusTitle

        let titleRow = UIStackView(arrangedSubviews: [icon, titleLabel])
        titleRow.translatesAutoresizingMaskIntoConstraints = false
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 6

        let subtextLabel = UILabel()
        subtextLabel.translatesAutoresizingMaskIntoConstraints = false
        subtextLabel.numberOfLines = 0
        subtextLabel.textAlignment = .left
        subtextLabel.attributedText = NSAttributedString(
            string: Copy.statusSubtext,
            attributes: [
                .font: AppFont.regular.size(12.0, familyName: familyFunnelSans),
                .foregroundColor: Palette.statusSubtext,
                .paragraphStyle: SpotTakenViewController.paragraphStyle(lineSpacing: 4, alignment: .left)
            ]
        )

        let stack = UIStackView(arrangedSubviews: [titleRow, subtextLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 3

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    // MARK: Details card - identical shape to WaitlistConfirmedViewController's own

    func makeDetailsCard() -> UIView {
        let card = GlassCardView(cornerRadius: Metric.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.fillColor = Palette.cardFill
        card.fillAlpha = 1.0
        card.strokeColor = Palette.cardStroke
        card.strokeAlpha = 1.0
        card.showsSheen = false

        let pillRow = makeCategoryPillRow()

        classTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        classTitleLabel.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        classTitleLabel.textColor = .white
        classTitleLabel.numberOfLines = 0

        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        dateTimeLabel.textColor = UIColor(hex: "#8CFAFAFA")
        dateTimeLabel.numberOfLines = 1
        dateTimeLabel.lineBreakMode = .byTruncatingTail

        locationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        locationTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        locationTitleLabel.textColor = Palette.rowTitle
        locationTitleLabel.numberOfLines = 1
        locationTitleLabel.lineBreakMode = .byTruncatingTail

        locationDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        locationDistanceLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        locationDistanceLabel.textColor = Palette.rowSubtitle
        locationDistanceLabel.numberOfLines = 1
        locationDistanceLabel.lineBreakMode = .byTruncatingTail

        let locationRow = makeDetailRow(icon: SpotTakenViewController.icon(["ic_location_pin_small"], systemFallback: "mappin.and.ellipse"),
                                        iconSide: 14,
                                        titleLabel: locationTitleLabel,
                                        subtitleLabel: locationDistanceLabel)

        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerNameLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        trainerNameLabel.textColor = Palette.rowTitle
        trainerNameLabel.numberOfLines = 1
        trainerNameLabel.lineBreakMode = .byTruncatingTail

        // Matches Android's activity_spot_taken.xml (tvTrainerSub) and this
        // module's own SlotOpenViewController - both show this caption under
        // the trainer name; this screen was missing it entirely.
        trainerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trainerSubtitleLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        trainerSubtitleLabel.textColor = Palette.rowSubtitle
        trainerSubtitleLabel.numberOfLines = 1
        trainerSubtitleLabel.lineBreakMode = .byTruncatingTail
        trainerSubtitleLabel.text = Copy.trainerSubtitle

        let trainerRow = makeDetailRow(icon: SpotTakenViewController.icon(["ic_trainer_running_18"], systemFallback: "figure.run"),
                                       iconSide: 16,
                                       titleLabel: trainerNameLabel,
                                       subtitleLabel: trainerSubtitleLabel)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 0

        let divider1 = makeDivider()
        let divider2 = makeDivider()

        stack.addArrangedSubview(pillRow)
        stack.setCustomSpacing(12, after: pillRow)
        stack.addArrangedSubview(classTitleLabel)
        stack.setCustomSpacing(4, after: classTitleLabel)
        stack.addArrangedSubview(dateTimeLabel)
        stack.setCustomSpacing(12, after: dateTimeLabel)
        stack.addArrangedSubview(divider1)
        stack.setCustomSpacing(12, after: divider1)
        stack.addArrangedSubview(locationRow)
        stack.setCustomSpacing(12, after: locationRow)
        stack.addArrangedSubview(divider2)
        stack.setCustomSpacing(12, after: divider2)
        stack.addArrangedSubview(trainerRow)

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: Metric.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Metric.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Metric.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Metric.cardPadding)
        ])
        return card
    }

    func makeCategoryPillRow() -> UIView {
        let pill = GlassCardView(cornerRadius: 8)
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.fillColor = .white
        pill.fillAlpha = 0.0
        pill.strokeColor = Palette.pillStroke
        pill.strokeAlpha = 0.2
        pill.sheenColor = .white
        pill.sheenAlpha = 0.2
        pill.sheenOrigin = .topCenter
        pill.sheenEdge = .bottomRight

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        label.textColor = Palette.pillText
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = Copy.categoryPill
        pill.addSubview(label)

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(pill)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: pill.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12),

            pill.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            pill.topAnchor.constraint(equalTo: wrapper.topAnchor),
            pill.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            pill.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            pill.trailingAnchor.constraint(lessThanOrEqualTo: wrapper.trailingAnchor)
        ])
        return wrapper
    }

    func makeDetailRow(icon: UIImage?, iconSide: CGFloat, titleLabel: UILabel, subtitleLabel: UILabel) -> UIStackView {
        let iconTile = makeIconTile(image: icon, iconSide: iconSide)

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

    func makeIconTile(image: UIImage?, iconSide: CGFloat) -> UIView {
        let tile = GlassCardView(cornerRadius: 12)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.fillColor = Palette.tileFill
        tile.fillAlpha = 1.0
        tile.strokeColor = Palette.tileFill
        tile.strokeAlpha = 1.0
        tile.sheenOrigin = .topCenter
        tile.sheenAlpha = 0.08

        let iconView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
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

    func makeDivider() -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = Palette.divider
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }
}

// MARK: - Attributed copy

private extension SpotTakenViewController {
    static func paragraphStyle(lineSpacing: CGFloat, alignment: NSTextAlignment) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.alignment = alignment
        return style
    }
}
