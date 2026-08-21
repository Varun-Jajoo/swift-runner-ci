//
//  SgptGridCardCollectionViewCell.swift
//  MyPT
//
//  Self-contained SGPT card for the See All grid - title/subtitle overlaid
//  directly on the cover photo behind a bottom scrim, unlike the home
//  carousel's `SgptCardCollectionViewCell`, which stacks its title/subtitle
//  below the cover photo instead - see that type's own doc comment.
//
//  A vertically-scrolling grid showing many cards at once has no single
//  "spotlight" card to hang shared labels off of, so each card needs to
//  carry its own info exactly like it used to - this is a deliberate split
//  into two cell types, not an oversight. Same relationship as Group
//  Classes' `GroupClassCardCollectionViewCell` (home carousel) vs.
//  `SeeAllGridCollectionViewCell` (See All grid): two different cell types
//  for two different presentation contexts that happen to share a data model.
//
//  Code-based (no xib), matching `SeeAllGridCollectionViewCell`'s own
//  construction style for this exact "See All" screen family.
//

import UIKit
import SDWebImage

final class SgptGridCardCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "SgptGridCardCollectionViewCell"

    /// Reference aspect ratio for the grid's responsive sizing
    /// (`SeeAllSgptViewController.sizeForItemAt` scales this to the actual
    /// per-column width) - the original SGPT card proportions, unrelated to
    /// the home carousel's own (since-revised) card sizes.
    static let cardSize = CGSize(width: 230, height: 426)

    private static let cardCornerRadius: CGFloat = 21.406

    /// Matches `GroupClassCardCollectionViewCell`'s own card fill, for visual
    /// consistency with the Group Classes grid living in the same app.
    private static let scrimColor = UIColor(hex: "#0D1918")

    private let cardView = GlassCardView(cornerRadius: SgptGridCardCollectionViewCell.cardCornerRadius)
    private let coverImageView = UIImageView()
    private let coverFadeView = GradientFadeView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

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
        // Full-bleed cover photo sits in front of it, so the sheen highlight
        // (drawn behind every subview) would never actually be visible.
        cardView.showsSheen = false
        contentView.addSubview(cardView)

        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        cardView.addSubview(coverImageView)

        coverFadeView.translatesAutoresizingMaskIntoConstraints = false
        coverFadeView.setColors([SgptGridCardCollectionViewCell.scrimColor.withAlphaComponent(0.0),
                                 SgptGridCardCollectionViewCell.scrimColor.withAlphaComponent(0.55),
                                 SgptGridCardCollectionViewCell.scrimColor.withAlphaComponent(0.92)],
                                locations: [0.0, 0.45, 1.0])
        cardView.addSubview(coverFadeView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        cardView.addSubview(stack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            coverImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            coverFadeView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            coverFadeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            coverFadeView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            coverFadeView.heightAnchor.constraint(equalToConstant: 170),

            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.attributedText = nil
    }

    // MARK: Configure

    func configure(with item: SgptSessionModel) {
        titleLabel.text = SgptCardCollectionViewCell.titleText(for: item)
        subtitleLabel.attributedText = SgptCardCollectionViewCell.subtitleText(for: item)

        let fallback = UIImage(named: "class-card-placeholder")
        if let imageURL = item.image, !imageURL.isEmpty, let url = URL(string: imageURL) {
            coverImageView.sd_setImage(with: url, placeholderImage: fallback)
        } else {
            coverImageView.image = fallback
        }
    }
}
