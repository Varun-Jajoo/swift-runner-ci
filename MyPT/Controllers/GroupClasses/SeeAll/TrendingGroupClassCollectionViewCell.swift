//
//  TrendingGroupClassCollectionViewCell.swift
//  MyPT
//
//  "Trending On MyPT" horizontal card: a class card with a giant translucent
//  rank number peeking out from behind its left edge.
//
//  Android reference: `res/layout/item_trending_group_class.xml` +
//  `adapter/TrendingGroupClassesAdapter.kt`. The rank glyphs there are
//  hand-drawn gradient vector paths (`ic_rank_number_1/2/3.xml`); reproduced
//  here as gradient-masked text since importing three bespoke vector assets
//  for a decorative background element isn't warranted.
//

import UIKit

// MARK: - GradientRankNumberView

/// Giant number rendered with the same silver top-to-bottom gradient Android's
/// rank vectors use (`#EEEEEE` -> `#52999999` -> `#80FFFFFF`), via a
/// `CATextLayer` mask rather than a bitmap/vector asset.
final class GradientRankNumberView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let textMaskLayer = CATextLayer()

    var number: Int = 1 {
        didSet { textMaskLayer.string = "\(number)" }
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
        backgroundColor = .clear
        isUserInteractionEnabled = false

        gradientLayer.colors = [
            UIColor(white: 0.93, alpha: 1.0).cgColor,
            UIColor(white: 0.6, alpha: 0.32).cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.65, y: 1.0)

        textMaskLayer.contentsScale = UIScreen.main.scale
        textMaskLayer.alignmentMode = .left
        textMaskLayer.isWrapped = false
        textMaskLayer.string = "\(number)"
        if let font = UIFont(name: "\(familyClashDisplay)-Bold", size: 100),
           let cgFont = CGFont(font.fontName as CFString) {
            textMaskLayer.font = cgFont
            textMaskLayer.fontSize = 100
        } else {
            textMaskLayer.fontSize = 100
        }

        gradientLayer.mask = textMaskLayer
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        textMaskLayer.frame = bounds
        CATransaction.commit()
    }
}

// MARK: - TrendingGroupClassCollectionViewCell

final class TrendingGroupClassCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "TrendingGroupClassCollectionViewCell"
    static let cardWidth: CGFloat = 160
    static let cardHeight: CGFloat = 190
    /// Rank #1's number vector is narrower, so a smaller leading margin still
    /// keeps the card flush against it; #2 and #3 are visually wider and need
    /// the larger margin to peek out cleanly (`TrendingGroupClassesAdapter`'s
    /// `marginStartDp` rule, ported verbatim).
    static let firstRankLeadingInset: CGFloat = 35
    static let otherRankLeadingInset: CGFloat = 48

    /// Total cell width including the peeking number, for `sizeForItemAt`.
    static func totalWidth(forRankIndex index: Int) -> CGFloat {
        let inset = index == 0 ? firstRankLeadingInset : otherRankLeadingInset
        return inset + cardWidth
    }

    private static let cardFillColor = UIColor(hex: "#101113")

    private let rankNumberView = GradientRankNumberView()
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

        rankNumberView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rankNumberView)

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
        coverImageView.backgroundColor = TrendingGroupClassCollectionViewCell.cardFillColor
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
        spotLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        progressBar.translatesAutoresizingMaskIntoConstraints = false

        let spotStack = UIStackView(arrangedSubviews: [spotLabel, progressBar])
        spotStack.translatesAutoresizingMaskIntoConstraints = false
        spotStack.axis = .vertical
        spotStack.alignment = .trailing
        spotStack.spacing = 2
        spotStack.setContentHuggingPriority(.required, for: .horizontal)
        spotStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        let locationStack = UIStackView(arrangedSubviews: [locationIconView, locationLabel])
        locationStack.translatesAutoresizingMaskIntoConstraints = false
        locationStack.axis = .horizontal
        locationStack.alignment = .center
        locationStack.spacing = 2

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
            constant: TrendingGroupClassCollectionViewCell.otherRankLeadingInset)

        NSLayoutConstraint.activate([
            rankNumberView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rankNumberView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            // Wider than the leading inset that reveals it (35/48pt) so the
            // glyph never gets clipped by its own bounds before the card's
            // edge does the actual "peeking" reveal.
            rankNumberView.widthAnchor.constraint(equalToConstant: 70),
            rankNumberView.heightAnchor.constraint(equalToConstant: 104),

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
            coverFadeView.heightAnchor.constraint(equalToConstant: 80),

            badgeView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            badgeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),

            locationIconView.widthAnchor.constraint(equalToConstant: 12),
            locationIconView.heightAnchor.constraint(equalToConstant: 12),

            progressBar.widthAnchor.constraint(equalToConstant: 48),

            contentStack.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 9),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor)
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

    func configure(with item: UpcomingClassModel, rankIndex: Int) {
        // Ranks 4+ reuse the "3" glyph — Android's own `TrendingGroupClassesAdapter`
        // does the same (`else -> R.drawable.ic_rank_number_3`), not an oversight.
        rankNumberView.number = min(rankIndex + 1, 3)
        cardLeadingConstraint.constant = rankIndex == 0
            ? TrendingGroupClassCollectionViewCell.firstRankLeadingInset
            : TrendingGroupClassCollectionViewCell.otherRankLeadingInset

        titleLabel.text = GroupClassCardFormatter.title(for: item)

        let rawTime = (item.time?.isEmpty == false) ? item.time : item.start_end
        timeLabel.text = GroupClassCardFormatter.formatTimeForUI(rawTime)

        locationLabel.text = GroupClassCardFormatter.locationText(for: item)

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
            badgeView.startColor = UIColor.black.withAlphaComponent(0.6)
            badgeView.endColor = UIColor.black.withAlphaComponent(0.0)
            badgeView.strokeColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.2)
            badgeView.configure(text: "FREE",
                                font: AppFont.bold.size(11.0, familyName: familyFunnelSans),
                                textColor: UIColor(hex: "#F0F0F0"))
            cardView.strokeAlpha = 0.0
        }

        let availability = GroupClassCardFormatter.availability(
            bookedCount: GroupClassCardFormatter.intValue(item.bookedCount, defaultValue: 0),
            totalCapacity: GroupClassCardFormatter.intValue(item.totalCapacity, defaultValue: 20),
            remainingSeats: GroupClassCardFormatter.intValue(item.remainingSeats, defaultValue: 20)
        )
        spotLabel.text = availability.text
        progressBar.setProgress(availability.progress, state: availability.state)
        if case .gold = availability.state {
            progressBar.setFillColors([UIColor(hex: "#FFCC33"), UIColor(hex: "#586400")])
        }

        let fallback = UIImage(named: "class-card-placeholder")
        if let imageURL = GroupClassCardFormatter.absoluteImageURL(item.image) {
            coverImageView.loadImage(urlString: imageURL, placeholder: fallback)
        } else {
            coverImageView.image = fallback
        }
    }
}
