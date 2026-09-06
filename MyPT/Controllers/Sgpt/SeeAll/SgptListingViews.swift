//
//  SgptListingViews.swift
//  MyPT
//

import UIKit
import SDWebImage

enum SgptListingMetrics {
    static let trendingSideCardWidth: CGFloat = 260
    static let trendingSideImageHeight: CGFloat = 360
    static let trendingFocusScale: CGFloat = 306.0 / 260.0
    static let trainerCardWidth: CGFloat = 81
    static let trainerImageHeight: CGFloat = 100
}

enum SgptListingColor {
    static let violet500 = UIColor(hex: "#1A062D")
    static let violet200 = UIColor(hex: "#B172EB")
    static let violetBorder = UIColor(hex: "#764C9C")
    static let gold1000 = UIColor(hex: "#201200")
    static let gold100 = UIColor(hex: "#FFF2C0")
    static let neutral200 = UIColor(hex: "#F0F0F0")
    static let surfaceLow = UIColor(hex: "#131416")
    static let gridCardBg = UIColor(hex: "#0D1918")
    static let limeGreen = UIColor(hex: "#E0FE08")
    static let quoteText = UIColor(hex: "#959595")
    static let quoteAuthor = UIColor(hex: "#606060")
    static let text55 = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
    static let text20 = UIColor(hex: "#FAFAFA").withAlphaComponent(0.2)
    static let stroke10 = UIColor.white.withAlphaComponent(0.1)
    static let backgroundTop = UIColor(hex: "#0E0B14")
    static let backgroundBottom = UIColor(hex: "#000A04")
}

final class SgptCarouselPagerView: UIView {

    private static let dotSize: CGFloat = 4
    private static let trackWidth: CGFloat = 32
    private static let fillWidth: CGFloat = 14

    private let container = UIStackView()
    private let track = UIView()
    private let fill = UIView()
    private var leadingDots: [UIView] = []
    private var trailingDots: [UIView] = []
    private var fillLeadingConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = SgptListingColor.surfaceLow
        layer.masksToBounds = true

        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 4
        addSubview(container)

        leadingDots = (0..<2).map { _ in makeDot() }
        trailingDots = (0..<2).map { _ in makeDot() }

        track.translatesAutoresizingMaskIntoConstraints = false
        track.backgroundColor = SgptListingColor.text20
        track.layer.cornerRadius = SgptCarouselPagerView.dotSize / 2
        track.layer.masksToBounds = true

        fill.translatesAutoresizingMaskIntoConstraints = false
        fill.backgroundColor = SgptListingColor.neutral200
        fill.layer.cornerRadius = SgptCarouselPagerView.dotSize / 2
        track.addSubview(fill)

        let fillLeading = fill.leadingAnchor.constraint(equalTo: track.leadingAnchor)
        fillLeadingConstraint = fillLeading

        leadingDots.forEach { container.addArrangedSubview($0) }
        container.addArrangedSubview(track)
        trailingDots.forEach { container.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),

            track.widthAnchor.constraint(equalToConstant: SgptCarouselPagerView.trackWidth),
            track.heightAnchor.constraint(equalToConstant: SgptCarouselPagerView.dotSize),

            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalToConstant: SgptCarouselPagerView.fillWidth),
            fillLeading
        ])
    }

    private func makeDot() -> UIView {
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = SgptListingColor.text20
        dot.layer.cornerRadius = SgptCarouselPagerView.dotSize / 2
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: SgptCarouselPagerView.dotSize),
            dot.heightAnchor.constraint(equalToConstant: SgptCarouselPagerView.dotSize)
        ])
        return dot
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    func update(page: Int, pageCount: Int) {
        guard pageCount > 1 else {
            fillLeadingConstraint?.constant = 0
            return
        }
        let clamped = min(max(page, 0), pageCount - 1)
        let travel = SgptCarouselPagerView.trackWidth - SgptCarouselPagerView.fillWidth
        fillLeadingConstraint?.constant = travel * CGFloat(clamped) / CGFloat(pageCount - 1)
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 14)
    }
}

enum SgptTrainerTier {
    case none
    case premium
    case elite

    var title: String? {
        switch self {
        case .none: return nil
        case .premium: return "PREMIUM"
        case .elite: return "ELITE"
        }
    }

    var borderColor: UIColor {
        switch self {
        case .none: return SgptListingColor.violetBorder
        case .premium: return SgptListingColor.violet500
        case .elite: return SgptListingColor.gold1000
        }
    }

    var ribbonFill: UIColor {
        switch self {
        case .elite: return SgptListingColor.gold1000
        default: return SgptListingColor.violet500
        }
    }

    var ribbonStroke: UIColor {
        switch self {
        case .elite: return SgptListingColor.gold100
        default: return SgptListingColor.violet200
        }
    }
}

struct SgptTrainerItem {
    let name: String
    let imageURL: String?
    let tier: SgptTrainerTier
}

final class SgptTrainerCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "SgptTrainerCollectionViewCell"
    static let cardSize = CGSize(width: SgptListingMetrics.trainerCardWidth, height: 126)

    private let imageContainer = UIView()
    private let imageView = UIImageView()
    private let scrimLayer = CAGradientLayer()
    private let ribbonView = UIView()
    private let ribbonLabel = UILabel()
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildLayout()
    }

    private func buildLayout() {
        contentView.backgroundColor = .clear

        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.backgroundColor = UIColor(hex: "#101113")
        imageContainer.layer.cornerRadius = 16
        imageContainer.layer.masksToBounds = true
        imageContainer.layer.borderWidth = 2
        contentView.addSubview(imageContainer)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageContainer.addSubview(imageView)

        scrimLayer.colors = [
            UIColor.clear.cgColor,
            UIColor(hex: "#101113").cgColor
        ]
        scrimLayer.locations = [0.465, 0.999]
        imageContainer.layer.addSublayer(scrimLayer)

        ribbonView.translatesAutoresizingMaskIntoConstraints = false
        ribbonView.layer.borderWidth = 0.637
        ribbonView.layer.cornerRadius = 15.29
        ribbonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        ribbonView.layer.masksToBounds = true
        imageContainer.addSubview(ribbonView)

        ribbonLabel.translatesAutoresizingMaskIntoConstraints = false
        ribbonLabel.font = AppFont.medium.size(11.0, familyName: familyClashDisplay)
        ribbonLabel.textColor = .white
        ribbonLabel.textAlignment = .center
        ribbonView.addSubview(ribbonLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            imageContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageContainer.heightAnchor.constraint(equalToConstant: SgptListingMetrics.trainerImageHeight),

            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),

            ribbonView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            ribbonView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            ribbonView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            ribbonView.heightAnchor.constraint(equalToConstant: 21.661),

            ribbonLabel.centerXAnchor.constraint(equalTo: ribbonView.centerXAnchor),
            ribbonLabel.centerYAnchor.constraint(equalTo: ribbonView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -5)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        scrimLayer.frame = imageContainer.bounds
        CATransaction.commit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        nameLabel.text = nil
    }

    func configure(with item: SgptTrainerItem) {
        nameLabel.text = item.name
        imageContainer.layer.borderColor = item.tier.borderColor.cgColor

        if let tierTitle = item.tier.title {
            ribbonView.isHidden = false
            ribbonView.backgroundColor = item.tier.ribbonFill
            ribbonView.layer.borderColor = item.tier.ribbonStroke.cgColor
            ribbonLabel.text = tierTitle
        } else {
            ribbonView.isHidden = true
        }

        let fallback = UIImage(named: "class-card-placeholder")
        if let urlString = item.imageURL, !urlString.isEmpty, let url = URL(string: urlString) {
            imageView.sd_setImage(with: url, placeholderImage: fallback)
        } else {
            imageView.image = fallback
        }
    }
}

