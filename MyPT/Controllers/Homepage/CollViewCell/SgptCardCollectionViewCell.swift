//
//  SgptCardCollectionViewCell.swift
//  MyPT
//
//  230x426pt Small Group PT (SGPT) card used by the home carousel's
//  `collectionSgpt`. Standard xib-backed cell (UINib(nibName:) + storyboard
//  UICollectionView), unlike the Group Classes carousel's hand-built
//  GroupClassesCarouselView.
//

import UIKit
import SDWebImage

final class SgptCardCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "SgptCardCollectionViewCell"
    static let cardSize = CGSize(width: 230, height: 426)

    /// Design-spec corner radius - not a round number, matches the token this
    /// card was built from.
    private static let cardCornerRadius: CGFloat = 21.406

    /// Bottom scrim colour. Matches `GroupClassCardCollectionViewCell`'s own
    /// card fill (`#0D1918`) for visual consistency with the Group Classes
    /// carousel living on the same home screen.
    private static let scrimColor = UIColor(hex: "#0D1918")

    @IBOutlet weak var cardView: GlassCardView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverFadeView: GradientFadeView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        cardView.cornerRadius = SgptCardCollectionViewCell.cardCornerRadius
        // Full-bleed cover photo already sits in front of it, so the sheen
        // highlight (drawn behind every subview) would never actually be
        // visible - same reasoning GroupClassCardCollectionViewCell applies.
        cardView.showsSheen = false

        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true

        // Three-stop vertical fade behind the title/subtitle stack, matching
        // GroupClassCardCollectionViewCell's coverFadeView recipe.
        coverFadeView.setColors([
            SgptCardCollectionViewCell.scrimColor.withAlphaComponent(0.0),
            SgptCardCollectionViewCell.scrimColor.withAlphaComponent(0.55),
            SgptCardCollectionViewCell.scrimColor.withAlphaComponent(0.92)
        ], locations: [0.0, 0.45, 1.0])

        titleLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1

        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.attributedText = nil
    }

    // MARK: Configure

    func configure(with item: SgptSessionModel) {
        titleLabel.text = (item.sessionName?.isEmpty == false) ? item.sessionName : "Small Group PT"
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

    /// Two-line "<EEE, d MMM • h-h a>\n<studio>" subtitle - the same
    /// "EEE, d MMM • h-h a" shape `GroupClassCardFormatter.formatTimeForUI`
    /// already produces for Group Classes, reimplemented locally (rather than
    /// called directly) because SGPT's `date`/`time`/`duration` arrive as
    /// three separate fields instead of one pre-formatted combined string
    /// that formatter expects. `chipLabel` IS reused as-is for the studio
    /// line since it's already generic over a raw name string.
    private static func subtitleText(for item: SgptSessionModel) -> NSAttributedString {
        let durationMinutes = GroupClassCardFormatter.intValue(item.duration, defaultValue: 60)
        let schedule = formattedSchedule(dateStr: item.date, timeStr: item.time, durationMinutes: durationMinutes)
        let studio = GroupClassCardFormatter.chipLabel(item.studioName)
        let text = studio.isEmpty ? schedule : "\(schedule)\n\(studio)"

        // Design spec calls for a fixed ~18pt line height on a 14pt face;
        // `minimumLineHeight`/`maximumLineHeight` pin it exactly, same
        // NSAttributedString + NSMutableParagraphStyle technique
        // ConfirmSlotSheetViewController already uses for custom line
        // spacing elsewhere in the app (that call site uses `lineSpacing`,
        // an extra-space value, since it wasn't targeting an absolute
        // total line height - this one needs the absolute value instead).
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.minimumLineHeight = 18
        paragraph.maximumLineHeight = 18

        return NSAttributedString(string: text, attributes: [
            .font: AppFont.semibold.size(14.0, familyName: familyFunnelSans),
            .foregroundColor: UIColor.white.withAlphaComponent(0.55),
            .paragraphStyle: paragraph
        ])
    }

    /// Expects `date` as "yyyy-MM-dd" and `time` as "HH:mm:ss", combines them
    /// with `duration` (minutes) to produce Group Classes' own
    /// "EEE, d MMM • h-h a" display shape.
    private static func formattedSchedule(dateStr: String?, timeStr: String?, durationMinutes: Int) -> String {
        guard let dateStr = dateStr, !dateStr.isEmpty, let timeStr = timeStr, !timeStr.isEmpty else {
            return GroupClassCardFormatter.defaultTime
        }

        let combinedFormatter = DateFormatter()
        combinedFormatter.locale = Locale(identifier: "en_US_POSIX")
        combinedFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let start = combinedFormatter.date(from: "\(dateStr) \(timeStr)") else {
            return GroupClassCardFormatter.defaultTime
        }

        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.dateFormat = "EEE, d MMM"
        let dayText = dayFormatter.string(from: start)

        let startHour = Calendar.current.component(.hour, from: start)
        let durationHours = max(1, Int((Double(durationMinutes) / 60.0).rounded()))
        let endHour = (startHour + durationHours) % 24
        let start12 = (startHour % 12 == 0) ? 12 : startHour % 12
        let end12 = (endHour % 12 == 0) ? 12 : endHour % 12
        let amPm = (endHour >= 12 && endHour != 24) ? "PM" : "AM"

        return "\(dayText) • \(start12)-\(end12) \(amPm)"
    }
}
