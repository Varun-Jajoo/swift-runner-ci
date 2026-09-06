
import UIKit
import SDWebImage

final class SgptGridCardCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "SgptGridCardCollectionViewCell"

    static let cardSize = CGSize(width: 196.5, height: 322)

    private static let imageAspectRatio: CGFloat = 271.0 / 196.5

    private static let infoBlockHeight: CGFloat = 43
    private static let imageToInfoGap: CGFloat = 8

    static func heightForWidth(_ width: CGFloat) -> CGFloat {
        width * imageAspectRatio + imageToInfoGap + infoBlockHeight
    }

    private static let cornerRadius: CGFloat = 12

    private let imageContainer = UIView()
    private let coverImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()

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

        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.layer.cornerRadius = SgptGridCardCollectionViewCell.cornerRadius
        imageContainer.clipsToBounds = true
        imageContainer.backgroundColor = UIColor(red: 0.0505, green: 0.0995, blue: 0.0943, alpha: 1)
        contentView.addSubview(imageContainer)

        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        imageContainer.addSubview(coverImageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        dateLabel.textColor = .white.withAlphaComponent(0.55)
        dateLabel.textAlignment = .center
        dateLabel.numberOfLines = 1

        let infoStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.alignment = .center
        infoStack.spacing = 7
        contentView.addSubview(infoStack)

        NSLayoutConstraint.activate([
            imageContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            coverImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),

            infoStack.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 8),
            infoStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            infoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            infoStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])

        imageContainer.heightAnchor.constraint(
            equalTo: imageContainer.widthAnchor,
            multiplier: SgptGridCardCollectionViewCell.imageAspectRatio
        ).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
    }

    func configure(with item: SgptSessionModel) {
        titleLabel.text = Self.titleText(for: item)
        dateLabel.text = Self.dateText(for: item)

        let fallback = UIImage(named: "class-card-placeholder")
        if let imageURL = item.image, !imageURL.isEmpty, let url = URL(string: imageURL) {
            coverImageView.sd_setImage(with: url, placeholderImage: fallback)
        } else {
            coverImageView.image = fallback
        }
    }

    private static func titleText(for item: SgptSessionModel) -> String {
        if let name = item.sessionName, !name.isEmpty {
            return name
        }
        return "Small Group PT"
    }

    private static func dateText(for item: SgptSessionModel) -> String {
        let studio = GroupClassCardFormatter.chipLabel(item.studioName)

        guard let dateStr = item.date, !dateStr.isEmpty,
              let timeStr = item.time, !timeStr.isEmpty else {
            return studio
        }

        let combinedFormatter = DateFormatter()
        combinedFormatter.locale = Locale(identifier: "en_US_POSIX")
        combinedFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let start = combinedFormatter.date(from: "\(dateStr) \(timeStr)") else {
            return studio
        }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        displayFormatter.dateFormat = "EEE, d MMM, h:mm a"
        let schedule = displayFormatter.string(from: start)

        return studio.isEmpty ? schedule : "\(schedule) · \(studio)"
    }
}
