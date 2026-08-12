//
//  TrendingGroupClassCollectionViewCell.swift
//  MyPT
//
//  "Trending On MyPT" horizontal card: a class card with a giant translucent
//  rank number peeking out from behind its left edge.
//
//  Android reference: `res/layout/item_trending_group_class.xml` +
//  `adapter/TrendingGroupClassesAdapter.kt`. The rank glyphs are real
//  gradient vector drawables (`ic_rank_number_1` through `_5`), now bundled
//  as SVG imagesets — loaded here directly rather than approximated.
//

import UIKit
import SDWebImage

// MARK: - TrendingGroupClassCollectionViewCell

final class TrendingGroupClassCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "TrendingGroupClassCollectionViewCell"
    static let cardWidth: CGFloat = 160
    static let cardHeight: CGFloat = 190
    /// Giant rank number's fixed render height (`layout_height="104dp"` on
    /// Android; width is `wrap_content` + `adjustViewBounds`, i.e. scaled to
    /// this height at the asset's own aspect ratio).
    static let rankImageHeight: CGFloat = 104

    /// `TrendingGroupClassesAdapter.marginStartDp`, ported verbatim — each
    /// rank's numeral vector has a different width/shape, so each needed its
    /// own hand-calibrated peeking offset (ranks 4/5 are visibly wider than
    /// 1-3 and need to sit further left to still read as "peeking").
    private static let leadingInsets: [CGFloat] = [35, 48, 48, 60, 58]
    private static let defaultLeadingInset: CGFloat = 48

    static func leadingInset(forRankIndex index: Int) -> CGFloat {
        return leadingInsets.indices.contains(index) ? leadingInsets[index] : defaultLeadingInset
    }

    /// Total cell width including the peeking number, for `sizeForItemAt`.
    static func totalWidth(forRankIndex index: Int) -> CGFloat {
        return leadingInset(forRankIndex: index) + cardWidth
    }

    private static let cardFillColor = UIColor(hex: "#101113")
    /// `imgClassCover`'s new `android:background="#32615C"` — shows while the
    /// remote cover image is still loading, instead of the plain card fill.
    private static let coverPlaceholderColor = UIColor(hex: "#32615C")
    /// Android's `spot_progress_bar_gold` fill (`#FFCC33 → #586400`), same
    /// constant `GroupClassCardCollectionViewCell` uses for the identical override.
    private static let goldProgressFillColors = [UIColor(hex: "#FFCC33"), UIColor(hex: "#586400")]

    private let rankImageView = UIImageView()
    private let cardView = GlassCardView(cornerRadius: 12)
    private let coverImageView = UIImageView()
    private let coverFadeView = GradientFadeView()
    private let badgeView = PremiumBadgeView()

    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let locationIconView = UIImageView()
    private let locationLabel = UILabel()
    private let spotLabel = UILabel()
    private let progressBar = SpotProgressBarView(barHeight: 2)

    private var cardLeadingConstraint: NSLayoutConstraint!
    /// Recreated per-configure since each rank glyph has its own aspect ratio
    /// (`adjustViewBounds` on Android — `wrap_content` width scaled to the
    /// fixed 104dp height).
    private var rankImageWidthConstraint: NSLayoutConstraint?
    /// Widened past 59pt when the "N/20 spot left" text itself is longer,
    /// exactly like `GroupClassCardCollectionViewCell` - Android re-measures
    /// this `.post{}` after every bind.
    private var progressBarWidthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        rankImageView.translatesAutoresizingMaskIntoConstraints = false
        rankImageView.contentMode = .scaleAspectFit
        rankImageView.isUserInteractionEnabled = false
        contentView.addSubview(rankImageView)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        // Android's `bg_card_gradient_black_without_border`: solid #101113 fill
        // plus an 8%-white radial sheen centred at the top edge.
        cardView.fillColor = TrendingGroupClassCollectionViewCell.cardFillColor
        cardView.fillAlpha = 1.0
        cardView.sheenOrigin = .topCenter
        cardView.sheenEdge = .bottomCenter
        cardView.sheenAlpha = 0.08
        cardView.strokeColor = GroupClassColor.cardStroke.color
        cardView.strokeAlpha = 0.0
        cardView.strokeWidth = 0.8
        contentView.addSubview(cardView)

        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.backgroundColor = TrendingGroupClassCollectionViewCell.coverPlaceholderColor
        cardView.addSubview(coverImageView)

        coverFadeView.translatesAutoresizingMaskIntoConstraints = false
        coverFadeView.setColors([TrendingGroupClassCollectionViewCell.cardFillColor.withAlphaComponent(0.0),
                                 TrendingGroupClassCollectionViewCell.cardFillColor.withAlphaComponent(0.5),
                                 TrendingGroupClassCollectionViewCell.cardFillColor.withAlphaComponent(1.0)],
                                locations: [0.0, 0.5, 1.0])
        cardView.addSubview(coverFadeView)

        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.cornerRadius = 6
        badgeView.contentInsets = UIEdgeInsets(top: 2, left: 7, bottom: 2, right: 7)
        cardView.addSubview(badgeView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.bold.size(14.0, familyName: familyFunnelSans)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        timeLabel.textColor = UIColor(hex: "#8CFAFAFA")
        timeLabel.numberOfLines = 1

        locationIconView.translatesAutoresizingMaskIntoConstraints = false
        locationIconView.contentMode = .scaleAspectFit
        locationIconView.image = UIImage(named: "greenLocation")?.withRenderingMode(.alwaysTemplate)
        locationIconView.tintColor = UIColor(hex: "#BFFAFAFA")
        locationIconView.setContentHuggingPriority(.required, for: .horizontal)
        locationIconView.setContentCompressionResistancePriority(.required, for: .horizontal)

        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = AppFont.semibold.size(11.0, familyName: familyFunnelSans)
        locationLabel.textColor = UIColor(hex: "#BFFAFAFA")
        locationLabel.numberOfLines = 1
        locationLabel.lineBreakMode = .byTruncatingTail
        locationLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        spotLabel.translatesAutoresizingMaskIntoConstraints = false
        spotLabel.font = AppFont.medium.size(9.0, familyName: familyFunnelSans)
        spotLabel.textColor = UIColor(hex: "#F0F0F0")
        spotLabel.numberOfLines = 1
        spotLabel.textAlignment = .right
        // `.required` here used to sit at the same priority tier as this row's
        // own fixed-width pin to the 160pt card — a real conflict whenever the
        // combined text ("Join Waitlist" + a studio name) didn't quite fit,
        // which UIKit can resolve by collapsing the view instead of truncating
        // it. `.defaultHigh` still wins over the location label below (which
        // stays `.defaultLow`, so it's always the one that yields first) without
        // being able to deadlock against the row's own required width.
        spotLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        progressBar.translatesAutoresizingMaskIntoConstraints = false

        let spotStack = UIStackView(arrangedSubviews: [spotLabel, progressBar])
        spotStack.translatesAutoresizingMaskIntoConstraints = false
        spotStack.axis = .vertical
        spotStack.alignment = .trailing
        spotStack.spacing = 2
        spotStack.setContentHuggingPriority(.required, for: .horizontal)
        spotStack.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        let locationStack = UIStackView(arrangedSubviews: [locationIconView, locationLabel])
        locationStack.translatesAutoresizingMaskIntoConstraints = false
        locationStack.axis = .horizontal
        locationStack.alignment = .center
        locationStack.spacing = 2
        // The stack's own compression resistance (a `UIView` property, distinct
        // from the label's) otherwise defaults to `.defaultHigh` regardless of
        // what priority the label inside it has — matching it to the label
        // keeps this whole block the first to give, exactly like Android's
        // `tvClassLocation` (`layout_width="0dp" layout_weight="1"`) always
        // absorbing whatever space the fixed-width spot column doesn't need.
        locationStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let bottomRow = UIStackView(arrangedSubviews: [locationStack, spotStack])
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.spacing = 4

        let contentStack = UIStackView(arrangedSubviews: [titleLabel, timeLabel, bottomRow])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 2
        contentStack.setCustomSpacing(3, after: timeLabel)
        contentView.addSubview(contentStack)

        cardLeadingConstraint = cardView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: TrendingGroupClassCollectionViewCell.defaultLeadingInset)

        let progressBarWidth = progressBar.widthAnchor.constraint(equalToConstant: 59)
        progressBarWidthConstraint = progressBarWidth

        NSLayoutConstraint.activate([
            rankImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rankImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            rankImageView.heightAnchor.constraint(equalToConstant: TrendingGroupClassCollectionViewCell.rankImageHeight),

            cardLeadingConstraint,
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.widthAnchor.constraint(equalToConstant: TrendingGroupClassCollectionViewCell.cardWidth),
            cardView.heightAnchor.constraint(equalToConstant: TrendingGroupClassCollectionViewCell.cardHeight),

            coverImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            coverFadeView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            coverFadeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            coverFadeView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            coverFadeView.heightAnchor.constraint(equalToConstant: 45),

            badgeView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            badgeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),

            locationIconView.widthAnchor.constraint(equalToConstant: 12),
            locationIconView.heightAnchor.constraint(equalToConstant: 12),

            // Explicit height: `SpotProgressBarView`'s intrinsic height alone left
            // the bar collapsed inside the trailing-aligned vertical stack, which
            // is why it was missing from these cards entirely. 2pt matches
            // `item_trending_group_class.xml`.
            progressBarWidth,
            progressBar.heightAnchor.constraint(equalToConstant: 2),

            contentStack.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 9),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Cover and rank images are both reassigned unconditionally in
        // `configure`, so clearing them here only adds a blank frame on reuse.
        titleLabel.text = nil
        timeLabel.text = nil
        locationLabel.text = nil
        spotLabel.text = nil
        progressBar.isHidden = false
        progressBar.setProgress(0, state: .green)
    }

    func configure(with item: UpcomingClassModel, rankIndex: Int) {
        applyRankImage(forRankIndex: rankIndex)
        cardLeadingConstraint.constant = TrendingGroupClassCollectionViewCell.leadingInset(forRankIndex: rankIndex)

        titleLabel.text = GroupClassCardFormatter.title(for: item)

        let rawTime = (item.time?.isEmpty == false) ? item.time : item.start_end
        timeLabel.text = GroupClassCardFormatter.formatTimeForUI(rawTime)

        locationLabel.text = GroupClassCardFormatter.cardLocationText(for: item)

        let isPaid = GroupClassCardFormatter.isPaid(access: item.access,
                                                    isMember: item.isMember ?? false)
        if isPaid {
            badgeView.isHorizontalGradient = false
            badgeView.startColor = GroupClassColor.premiumStart.color
            badgeView.endColor = GroupClassColor.premiumEnd.color
            badgeView.strokeColor = GroupClassColor.premiumStroke.color
            badgeView.configure(text: "PREMIUM",
                                font: AppFont.bold.size(11.0, familyName: familyFunnelSans),
                                textColor: UIColor(hex: "#141514"))
            cardView.strokeAlpha = 1.0
        } else {
            badgeView.isHorizontalGradient = true
            badgeView.startColor = UIColor(hex: "#1A1D1C")
            badgeView.endColor = UIColor(hex: "#1A1D1C")
            badgeView.strokeColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.3)
            badgeView.configure(text: "FREE",
                                font: AppFont.bold.size(11.0, familyName: familyFunnelSans),
                                textColor: UIColor(hex: "#F0F0F0"))
            cardView.strokeAlpha = 0.0
        }

        // EXACT SAME LOGIC & TEXT COLORS AS HOME CARDS (GroupClassCardCollectionViewCell).
        if item.isBooked == true {
            progressBar.isHidden = true
            spotLabel.text = "BOOKED"
            spotLabel.font = AppFont.bold.size(10.0, familyName: familyFunnelSans)
            spotLabel.textColor = UIColor(hex: "#32AE5C")
        } else if item.isWaitlisted == true {
            progressBar.isHidden = true
            spotLabel.text = "ON WAITLIST"
            spotLabel.font = AppFont.bold.size(10.0, familyName: familyFunnelSans)
            spotLabel.textColor = UIColor(hex: "#FFCC33")
        } else {
            progressBar.isHidden = false
            spotLabel.font = AppFont.medium.size(9.0, familyName: familyFunnelSans)
            spotLabel.textColor = UIColor(hex: "#F0F0F0")

            let availability = GroupClassCardFormatter.availability(
                bookedCount: GroupClassCardFormatter.intValue(item.bookedCount, defaultValue: 0),
                totalCapacity: GroupClassCardFormatter.intValue(item.totalCapacity, defaultValue: 20),
                remainingSeats: GroupClassCardFormatter.intValue(item.remainingSeats, defaultValue: 20)
            )
            spotLabel.text = availability.text
            progressBar.setProgress(availability.progress, state: availability.state)
            if case .gold = availability.state {
                progressBar.setFillColors(TrendingGroupClassCollectionViewCell.goldProgressFillColors)
            }
        }

        let textWidth = spotLabel.intrinsicContentSize.width
        progressBarWidthConstraint?.constant = max(59, ceil(textWidth))

        let fallback = UIImage(named: "class-card-placeholder")
        if let imageURL = GroupClassCardFormatter.absoluteImageURL(item.image), let url = URL(string: imageURL) {
            coverImageView.sd_setImage(with: url, placeholderImage: fallback)
        } else {
            coverImageView.image = fallback
        }
    }

    /// Loads the real rank glyph (`ic_rank_number_1` … `_5`; ranks beyond 5
    /// reuse `_5`, matching `TrendingGroupClassesAdapter`'s own `else` branch)
    /// and re-derives the width constraint from the asset's own aspect ratio —
    /// each numeral is a different shape/width at the fixed 104pt height.
    private func applyRankImage(forRankIndex rankIndex: Int) {
        let assetNumber = min(rankIndex + 1, 5)
        let image = UIImage(named: "ic_rank_number_\(assetNumber)")
        rankImageView.image = image

        rankImageWidthConstraint?.isActive = false
        guard let image = image, image.size.height > 0 else {
            rankImageWidthConstraint = nil
            return
        }
        let aspectRatio = image.size.width / image.size.height
        let widthConstraint = rankImageView.widthAnchor.constraint(
            equalTo: rankImageView.heightAnchor, multiplier: aspectRatio)
        widthConstraint.isActive = true
        rankImageWidthConstraint = widthConstraint
    }
}
