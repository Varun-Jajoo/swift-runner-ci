//
//  GroupClassCardCollectionViewCell.swift
//  MyPT
//
//  180×240pt Group Class card used by the home carousel.
//  Android reference: `res/layout/item_group_class_card.xml` +
//  `adapter/GroupClassesHomeAdapter.kt`.
//

import UIKit

// MARK: - GradientFadeView

/// Bottom-of-image scrim. Backed directly by a `CAGradientLayer` so it resizes
/// with Auto Layout instead of needing manual frame bookkeeping in `layoutSubviews`.
final class GradientFadeView: UIView {

    override class var layerClass: AnyClass { return CAGradientLayer.self }

    var gradientLayer: CAGradientLayer {
        // Safe: `layerClass` above guarantees the backing layer's type.
        return layer as! CAGradientLayer
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
        isUserInteractionEnabled = false
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }

    /// Three-stop vertical fade (transparent → half → solid), matching Android's
    /// `card_cover_bottom_gradient` start/center/end colours.
    func setColors(_ colors: [UIColor], locations: [NSNumber]? = nil) {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
    }
}

// MARK: - GroupClassCardCollectionViewCell

final class GroupClassCardCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "GroupClassCardCollectionViewCell"
    static let cardSize = CGSize(width: 180, height: 240)

    /// Android's `#0D1918` card fill. Not promoted to a colorset because it is
    /// local to this card — every other surface in the module uses `groupClassBg*`.
    private static let cardFillColor = UIColor(hex: "#0D1918")

    /// Android's `spot_progress_bar_gold` fill (`#FFCC33 → #586400`).
    /// The shared `SpotAvailabilityState.gold` uses the module's *badge* gold
    /// (`#EBD463 → #DB812E`), which is a different ramp; rather than repoint the
    /// Phase-2 component — other screens consume that enum — the card overrides the
    /// fill through `SpotProgressBarView.setFillColors(_:)`. Green and red already
    /// match Android exactly and are left on the enum.
    private static let goldProgressFillColors = [UIColor(hex: "#FFCC33"),
                                                 UIColor(hex: "#586400")]

    private let cardView = GlassCardView(cornerRadius: 16)
    private let coverImageView = UIImageView()
    private let coverFadeView = GradientFadeView()
    private let badgeView = PremiumBadgeView()

    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let locationIconView = UIImageView()
    private let locationLabel = UILabel()
    private let spotLabel = UILabel()
    private let progressBar = SpotProgressBarView(barHeight: 2)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: Setup

    private func setupViews() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        // Card shell — solid fill (not glass). The gold hairline is paid-only
        // (Android toggles `MaterialCardView.strokeColor`/`strokeWidth` per row
        // in `onBindViewHolder`); `applyBadgeStyle(isPaid:)` sets the alpha.
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.showsSheen = false
        cardView.fillColor = GroupClassCardCollectionViewCell.cardFillColor
        cardView.fillAlpha = 1.0
        cardView.strokeColor = GroupClassColor.cardStroke.color
        cardView.strokeAlpha = 0.0
        cardView.strokeWidth = 0.8
        contentView.addSubview(cardView)

        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.backgroundColor = GroupClassCardCollectionViewCell.cardFillColor
        cardView.addSubview(coverImageView)

        coverFadeView.translatesAutoresizingMaskIntoConstraints = false
        coverFadeView.setColors([GroupClassCardCollectionViewCell.cardFillColor.withAlphaComponent(0.0),
                                 GroupClassCardCollectionViewCell.cardFillColor.withAlphaComponent(0.5),
                                 GroupClassCardCollectionViewCell.cardFillColor.withAlphaComponent(1.0)],
                                locations: [0.0, 0.5, 1.0])
        cardView.addSubview(coverFadeView)

        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.cornerRadius = 8
        badgeView.contentInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        cardView.addSubview(badgeView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        // Host Grotesk Medium on Android; substituted with Funnel Sans Medium per
        // the approved plan (Host Grotesk is not bundled in the iOS app).
        titleLabel.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        timeLabel.textColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        timeLabel.numberOfLines = 1
        timeLabel.lineBreakMode = .byTruncatingTail

        locationIconView.translatesAutoresizingMaskIntoConstraints = false
        locationIconView.contentMode = .scaleAspectFit
        // Reuses the existing outline pin asset, tinted to the card's ink colour.
        locationIconView.image = UIImage(named: "greenLocation")?.withRenderingMode(.alwaysTemplate)
        locationIconView.tintColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
        locationIconView.setContentHuggingPriority(.required, for: .horizontal)
        locationIconView.setContentCompressionResistancePriority(.required, for: .horizontal)

        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        locationLabel.textColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.75)
        locationLabel.numberOfLines = 1
        locationLabel.lineBreakMode = .byTruncatingTail
        // The location is the only element allowed to shrink, so the spots block
        // on its right can never be pushed out of the card.
        locationLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        spotLabel.translatesAutoresizingMaskIntoConstraints = false
        spotLabel.font = AppFont.medium.size(9.0, familyName: familyFunnelSans)
        spotLabel.textColor = UIColor(hex: "#F0F0F0")
        spotLabel.numberOfLines = 1
        spotLabel.textAlignment = .right
        spotLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        progressBar.translatesAutoresizingMaskIntoConstraints = false

        let spotStack = UIStackView(arrangedSubviews: [spotLabel, progressBar])
        spotStack.translatesAutoresizingMaskIntoConstraints = false
        spotStack.axis = .vertical
        spotStack.alignment = .trailing
        spotStack.spacing = 3
        spotStack.setContentHuggingPriority(.required, for: .horizontal)
        spotStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        let locationStack = UIStackView(arrangedSubviews: [locationIconView, locationLabel])
        locationStack.translatesAutoresizingMaskIntoConstraints = false
        locationStack.axis = .horizontal
        locationStack.alignment = .center
        locationStack.spacing = 3

        let bottomRow = UIStackView(arrangedSubviews: [locationStack, spotStack])
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.spacing = 6

        let contentStack = UIStackView(arrangedSubviews: [titleLabel, timeLabel, bottomRow])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 3
        contentStack.setCustomSpacing(6, after: timeLabel)
        cardView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            coverImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 165),

            coverFadeView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            coverFadeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            coverFadeView.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor),
            coverFadeView.heightAnchor.constraint(equalToConstant: 90),

            badgeView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            badgeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            badgeView.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),

            locationIconView.widthAnchor.constraint(equalToConstant: 14),
            locationIconView.heightAnchor.constraint(equalToConstant: 14),

            progressBar.widthAnchor.constraint(equalToConstant: 59),
            progressBar.heightAnchor.constraint(equalToConstant: 4),

            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        titleLabel.text = nil
        timeLabel.text = nil
        locationLabel.text = nil
        spotLabel.text = nil
        progressBar.setProgress(0, state: .green)
    }

    // MARK: Configure

    func configure(with item: UpcomingClassModel) {

        titleLabel.text = GroupClassCardFormatter.title(for: item)

        let rawTime = (item.time?.isEmpty == false) ? item.time : item.start_end
        timeLabel.text = GroupClassCardFormatter.formatTimeForUI(rawTime)

        locationLabel.text = GroupClassCardFormatter.locationText(for: item)

        // PREMIUM for paid (and mixed-but-not-a-member) classes, FREE otherwise.
        let isPaid = GroupClassCardFormatter.isPaid(access: item.access,
                                                    isMember: item.isMember ?? false)
        applyBadgeStyle(isPaid: isPaid)

        let availability = GroupClassCardFormatter.availability(
            bookedCount: GroupClassCardFormatter.intValue(item.bookedCount, defaultValue: 0),
            totalCapacity: GroupClassCardFormatter.intValue(item.totalCapacity, defaultValue: 20),
            remainingSeats: GroupClassCardFormatter.intValue(item.remainingSeats, defaultValue: 20)
        )
        spotLabel.text = availability.text
        apply(availability: availability)

        // Android's Glide call uses `img.png` as both `.placeholder()` and
        // `.error()` — every failure path (blank URL, load failure) converges on
        // the same fallback photo. `loadImage(urlString:placeholder:)` already
        // applies its `placeholder` argument on both the initial call and the
        // catch branch, so passing the bundled fallback here is a straight port.
        let fallback = UIImage(named: "class-card-placeholder")
        if let imageURL = GroupClassCardFormatter.absoluteImageURL(item.image) {
            coverImageView.loadImage(urlString: imageURL, placeholder: fallback)
        } else {
            coverImageView.image = fallback
        }
    }

    /// Order matters: `setProgress(_:state:)` reapplies the state's own gradient on
    /// every call, so the gold override has to land after it (and is undone for the
    /// green/red states by that same reapply, including on reuse).
    private func apply(availability: GroupClassCardFormatter.SpotAvailability) {
        progressBar.setProgress(availability.progress, state: availability.state)
        if case .gold = availability.state {
            progressBar.setFillColors(GroupClassCardCollectionViewCell.goldProgressFillColors)
        }
    }

    private func applyBadgeStyle(isPaid: Bool) {
        // Gold hairline is paid-only (`MaterialCardView.strokeColor`/`strokeWidth`
        // toggled per row on Android, transparent for a free/studio card).
        cardView.strokeAlpha = isPaid ? 1.0 : 0.0

        if isPaid {
            badgeView.isHorizontalGradient = false
            badgeView.startColor = GroupClassColor.premiumStart.color
            badgeView.endColor = GroupClassColor.premiumEnd.color
            badgeView.strokeColor = GroupClassColor.premiumStroke.color
            badgeView.configure(text: "PREMIUM",
                                font: AppFont.bold.size(12.0, familyName: familyFunnelSans),
                                textColor: UIColor(hex: "#141514"))
        } else {
            // Android's `studio_badge_bg`: left-to-right translucent black wash,
            // hairline white stroke.
            badgeView.isHorizontalGradient = true
            badgeView.startColor = UIColor.black.withAlphaComponent(0.6)
            badgeView.endColor = UIColor.black.withAlphaComponent(0.0)
            badgeView.strokeColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.2)
            badgeView.configure(text: "FREE",
                                font: AppFont.bold.size(12.0, familyName: familyFunnelSans),
                                textColor: UIColor(hex: "#F0F0F0"))
        }
    }
}
