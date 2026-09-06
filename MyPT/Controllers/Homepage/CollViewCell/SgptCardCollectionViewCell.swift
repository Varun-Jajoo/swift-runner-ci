//
//  SgptCardCollectionViewCell.swift
//  MyPT
//

import UIKit
import SDWebImage

final class SgptCardCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "SgptCardCollectionViewCell"

    static let nativeImageSize = CGSize(width: 192, height: 256)

    private static let imageToTitleGap: CGFloat = 15
    private static let titleHeight: CGFloat = 26
    private static let titleToSubtitleGap: CGFloat = 4
    private static let subtitleHeight: CGFloat = 14

    static let cardSize = CGSize(
        width: SgptCardCollectionViewCell.nativeImageSize.width,
        height: SgptCardCollectionViewCell.nativeImageSize.height
            + SgptCardCollectionViewCell.imageToTitleGap
            + SgptCardCollectionViewCell.titleHeight
            + SgptCardCollectionViewCell.titleToSubtitleGap
            + SgptCardCollectionViewCell.subtitleHeight
    )

    private static let cardCornerRadius: CGFloat = 21.406

    /// Key the pulsing "spotlight" shadow animation is added/removed under -
    /// see `setGlowing(_:)`.
    private static let glowAnimationKey = "sgptSpotlightGlow"

    @IBOutlet weak var cardView: GlassCardView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        cardView.cornerRadius = SgptCardCollectionViewCell.cardCornerRadius
        cardView.showsSheen = false

        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true

        titleLabel.font = AppFont.medium.size(15.7, familyName: familyClashDisplay)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1

        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 1
        subtitleLabel.lineBreakMode = .byTruncatingTail
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // The glow's shadowPath was baked once, from whatever bounds the cell
        // had when it became centered. The carousel then resizes/scales the
        // cell and the stale path stayed behind as a dark shape sticking out
        // under the card. Re-cut it whenever the geometry changes.
        guard contentView.layer.shadowOpacity > 0 else { return }
        contentView.layer.shadowPath = UIBezierPath(
            roundedRect: cardView.frame,
            cornerRadius: SgptCardCollectionViewCell.cardCornerRadius
        ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.attributedText = nil
        setGlowing(false)
    }

    // MARK: Configure

    func configure(with item: SgptSessionModel) {
        titleLabel.text = SgptCardCollectionViewCell.titleText(for: item)
        subtitleLabel.attributedText = SgptCardCollectionViewCell.subtitleText(for: item)

        // Same fallback asset + sd_setImage call GroupClassCardCollectionViewCell
        // uses for its own cover photo.
        let fallback = UIImage(named: "class-card-placeholder")
        if let imageURL = item.image, !imageURL.isEmpty, let url = URL(string: imageURL) {
            coverImageView.sd_setImage(with: url, placeholderImage: fallback)
        } else {
            coverImageView.image = fallback
        }
    }

    // MARK: - Spotlight glow (pulsing shadow on the centered card)
    //
    // Approximates the Figma spec's pulsing box-shadow on the focused card
    // (5s infinite loop between a soft/spread shadow and a tight one) - the
    // visual signature of the "spotlight" now that off-center cards are
    // scaled down/dimmed instead. Not pixel-exact (no cubic-bezier keyframe
    // curve, iOS shadowRadius/shadowOffset stand in for the CSS blur/spread
    // pair), but cheap and self-contained: one CAAnimationGroup, added to
    // whichever cell is currently centered and removed from it on reuse /
    // when it stops being centered.
    func setGlowing(_ glowing: Bool) {
        if glowing {
            applyGlow()
        } else {
            contentView.layer.removeAnimation(forKey: SgptCardCollectionViewCell.glowAnimationKey)
            contentView.layer.shadowOpacity = 0
        }
    }

    private func applyGlow() {
        let layer = contentView.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(roundedRect: cardView.frame,
                                        cornerRadius: SgptCardCollectionViewCell.cardCornerRadius).cgPath
        layer.shadowOpacity = 0.28

        // 0px 10px 28px -4px rgba(0,0,0,.28)  <->  0px 2px 8px -4px rgba(0,0,0,.28)
        // CSS blur/spread don't map 1:1 onto shadowRadius/shadowOffset, so
        // these are an approximation: bigger vertical offset + wider radius
        // for the "spread" state, smaller/tighter for the other - opacity
        // stays fixed at .28 the whole time, only offset/radius pulse.
        let offset = CABasicAnimation(keyPath: "shadowOffset.height")
        offset.fromValue = 10
        offset.toValue = 2
        let radius = CABasicAnimation(keyPath: "shadowRadius")
        radius.fromValue = 14
        radius.toValue = 4

        let group = CAAnimationGroup()
        group.animations = [offset, radius]
        group.duration = 2.5 // + autoreverses -> 5s full cycle, matching the spec
        group.autoreverses = true
        group.repeatCount = .infinity
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(group, forKey: SgptCardCollectionViewCell.glowAnimationKey)
    }

    // MARK: - Text formatting

    static func titleText(for item: SgptSessionModel) -> String {
        if let name = item.sessionName, !name.isEmpty {
            return name
        }
        return "Small Group PT"
    }

    static func scheduleText(for item: SgptSessionModel) -> String {
        formattedSchedule(dateStr: item.date, timeStr: item.time)
    }

    /// Single-line "<EEE, d MMM, h:mm a> · <studio>" subtitle, matching what
    /// Android's `SgptHomeAdapter.formatSubtext` renders on the same card.
    /// `chipLabel` IS reused as-is for the studio part since it's already
    /// generic over a raw name string.
    static func subtitleText(for item: SgptSessionModel) -> NSAttributedString {
        let schedule = scheduleText(for: item)
        let studio = GroupClassCardFormatter.chipLabel(item.studioName)
        let text = studio.isEmpty ? schedule : "\(schedule) · \(studio)"

        // Design spec calls for a fixed ~12.2pt line height on a 9.5pt face;
        // `minimumLineHeight`/`maximumLineHeight` pin it exactly, same
        // NSAttributedString + NSMutableParagraphStyle technique
        // ConfirmSlotSheetViewController already uses for custom line
        // spacing elsewhere in the app (that call site uses `lineSpacing`,
        // an extra-space value, since it wasn't targeting an absolute
        // total line height - this one needs the absolute value instead).
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.minimumLineHeight = 12.2
        paragraph.maximumLineHeight = 12.2

        return NSAttributedString(string: text, attributes: [
            .font: AppFont.semibold.size(9.5, familyName: familyFunnelSans),
            .foregroundColor: UIColor.white.withAlphaComponent(0.55),
            .paragraphStyle: paragraph
        ])
    }

    /// Expects `date` as "yyyy-MM-dd" and `time` as "HH:mm:ss", rendered as
    /// "EEE, d MMM, h:mm a" - Android's own shape for this card.
    private static func formattedSchedule(dateStr: String?, timeStr: String?) -> String {
        guard let dateStr = dateStr, !dateStr.isEmpty, let timeStr = timeStr, !timeStr.isEmpty else {
            return GroupClassCardFormatter.defaultTime
        }

        let combinedFormatter = DateFormatter()
        combinedFormatter.locale = Locale(identifier: "en_US_POSIX")
        combinedFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let start = combinedFormatter.date(from: "\(dateStr) \(timeStr)") else {
            return GroupClassCardFormatter.defaultTime
        }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        displayFormatter.dateFormat = "EEE, d MMM, h:mm a"
        return displayFormatter.string(from: start)
    }
}
