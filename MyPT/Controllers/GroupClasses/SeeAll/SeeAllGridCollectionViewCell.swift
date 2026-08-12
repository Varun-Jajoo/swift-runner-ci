//
//  SeeAllGridCollectionViewCell.swift
//  MyPT
//
//  "Upcoming Classes" grid card on the See All Group Classes screen.
//
//  Android reference: `res/layout/item_see_all_grid_class_card.xml` +
//  `adapter/SeeAllGridAdapter.kt`.
//

import UIKit
import SDWebImage

final class SeeAllGridCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "SeeAllGridCollectionViewCell"
    /// Fixed regardless of column count — only the width changes with the
    /// responsive span count (`app:cardCornerRadius="16dp"`, height `228dp`).
    static let cardHeight: CGFloat = 228

    /// Android's `#0D1918` card fill (`app:cardBackgroundColor`).
    private static let cardFillColor = UIColor(hex: "#0D1918")

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

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.showsSheen = false
        cardView.fillColor = SeeAllGridCollectionViewCell.cardFillColor
        cardView.fillAlpha = 1.0
        // Gold hairline is paid-only; transparent otherwise (Android toggles
        // `strokeColor`/`strokeWidth` per row, no FREE badge shown on this screen).
        cardView.strokeColor = GroupClassColor.cardStroke.color
        cardView.strokeAlpha = 0.0
        cardView.strokeWidth = 0.6
        contentView.addSubview(cardView)

        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.backgroundColor = SeeAllGridCollectionViewCell.cardFillColor
        cardView.addSubview(coverImageView)

        coverFadeView.translatesAutoresizingMaskIntoConstraints = false
        coverFadeView.setColors([SeeAllGridCollectionViewCell.cardFillColor.withAlphaComponent(0.0),
                                 SeeAllGridCollectionViewCell.cardFillColor.withAlphaComponent(0.5),
                                 SeeAllGridCollectionViewCell.cardFillColor.withAlphaComponent(1.0)],
                                locations: [0.0, 0.5, 1.0])
        cardView.addSubview(coverFadeView)

        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.cornerRadius = 6
        badgeView.contentInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        badgeView.isHorizontalGradient = false
        badgeView.startColor = GroupClassColor.premiumStart.color
        badgeView.endColor = GroupClassColor.premiumEnd.color
        badgeView.strokeColor = GroupClassColor.premiumStroke.color
        badgeView.isHidden = true
        cardView.addSubview(badgeView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        // Host Grotesk Bold on Android; substituted with Funnel Sans (module-wide
        // substitution, Host Grotesk is not bundled in the iOS app).
        titleLabel.font = AppFont.bold.size(13.0, familyName: familyFunnelSans)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = AppFont.medium.size(11.0, familyName: familyFunnelSans)
        timeLabel.textColor = UIColor(hex: "#8CFAFAFA")
        timeLabel.numberOfLines = 1
        timeLabel.lineBreakMode = .byTruncatingTail

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
        // own fixed width — a real conflict whenever the combined text didn't
        // quite fit, which UIKit can resolve by collapsing the view instead of
        // truncating it. `.defaultHigh` still wins over the location label
        // (which stays `.defaultLow`, so it's always the one that yields first)
        // without being able to deadlock against the row's own required width.
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
        // the label's own priority — matching it keeps this whole block first
        // to give, mirroring Android's `tvClassLocation`
        // (`layout_width="0dp" layout_weight="1"`).
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
        contentStack.setCustomSpacing(5, after: timeLabel)
        cardView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            coverImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 160),

            coverFadeView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            coverFadeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            coverFadeView.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor),
            coverFadeView.heightAnchor.constraint(equalToConstant: 35),

            badgeView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            badgeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),

            locationIconView.widthAnchor.constraint(equalToConstant: 12),
            locationIconView.heightAnchor.constraint(equalToConstant: 12),

            // Explicit height: the intrinsic height alone left the bar collapsed
            // inside the trailing-aligned vertical stack, which is why it was
            // missing from these cards. 2pt matches
            // `item_see_all_grid_class_card.xml`.
            progressBar.heightAnchor.constraint(equalToConstant: 2),

            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        ])

        let barWidth = progressBar.widthAnchor.constraint(equalToConstant: 48)
        barWidth.isActive = true
        progressBarWidthConstraint = barWidth
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Deliberately does *not* clear `coverImageView`: `configure` always
        // assigns either the cached/loaded photo or the fallback, and blanking it
        // here just guarantees a visible empty frame on every reuse.
        titleLabel.text = nil
        timeLabel.text = nil
        locationLabel.text = nil
        spotLabel.text = nil
        badgeView.isHidden = true
        progressBar.setProgress(0, state: .green)
    }

    func configure(with item: UpcomingClassModel) {
        titleLabel.text = GroupClassCardFormatter.title(for: item)

        let rawTime = (item.time?.isEmpty == false) ? item.time : item.start_end
        timeLabel.text = GroupClassCardFormatter.formatTimeForUI(rawTime)

        locationLabel.text = GroupClassCardFormatter.cardLocationText(for: item)

        // PREMIUM only, never FREE — this screen hides the badge entirely for
        // free/studio classes rather than showing a FREE pill.
        let isPaid = GroupClassCardFormatter.isPaid(access: item.access,
                                                    isMember: item.isMember ?? false)
        badgeView.isHidden = !isPaid
        if isPaid {
            badgeView.configure(text: "PREMIUM",
                                font: AppFont.bold.size(10.0, familyName: familyFunnelSans),
                                textColor: UIColor(hex: "#141514"))
        }
        cardView.strokeAlpha = isPaid ? 1.0 : 0.0

        if item.isBooked == true {
            progressBar.isHidden = true
            spotLabel.text = "BOOKED"
            spotLabel.font = AppFont.bold.size(8.5, familyName: familyFunnelSans)
            spotLabel.textColor = UIColor(hex: "#32AE5C")
        } else if item.isWaitlisted == true {
            progressBar.isHidden = true
            spotLabel.text = "ON WAITLIST"
            spotLabel.font = AppFont.bold.size(8.5, familyName: familyFunnelSans)
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
                progressBar.setFillColors([UIColor(hex: "#FFCC33"), UIColor(hex: "#586400")])
            }

            let textWidth = spotLabel.intrinsicContentSize.width
            progressBarWidthConstraint?.constant = max(48, ceil(textWidth))
        }

        // SDWebImage's own cache + per-imageView load cancellation - see
        // GroupClassCardCollectionViewCell's identical call for why that
        // cancellation matters for a reused collection view cell.
        let fallback = UIImage(named: "class-card-placeholder")
        if let imageURL = GroupClassCardFormatter.absoluteImageURL(item.image), let url = URL(string: imageURL) {
            coverImageView.sd_setImage(with: url, placeholderImage: fallback)
        } else {
            coverImageView.image = fallback
        }
    }
}
