//
//  NotificationRowCell.swift
//  MyPT
//
//  Android reference: item_notification_row.xml + the bind() logic in
//  NotificationsAdapter.kt's ItemHolder - same icon/tile/card rules.
//

import UIKit

final class NotificationRowCell: UITableViewCell {

    static let reuseIdentifier = "NotificationRowCell"

    var onTapped: (() -> Void)?

    private let card = GlassCardView(cornerRadius: 12)
    private let iconTile = GlassCardView(cornerRadius: 12)
    private var iconGlyph: UIView?
    private let titleLabel = UILabel()
    private let subtextLabel = UILabel()
    private let timeLabel = UILabel()
    private let dotView = UIView()
    private let chevron = NotifIcon.chevronRight()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconGlyph?.removeFromSuperview()
        iconGlyph = nil
        onTapped = nil
    }

    typealias Palette = (unreadFill: UIColor, unreadStroke: UIColor, readFill: UIColor, readStroke: UIColor,
                         tileReadFill: UIColor, tileReadStroke: UIColor, subtext: UIColor, time: UIColor,
                         dotUnread: UIColor, dotRead: UIColor)

    func configure(entry: NotificationEntry, palette: Palette) {
        titleLabel.text = entry.title
        subtextLabel.text = entry.message
        timeLabel.text = NotificationRowCell.relativeTime(from: entry.createdAt)
        timeLabel.textColor = palette.time
        subtextLabel.textColor = palette.subtext

        let style = NotifStyleBridge.forType(entry.notificationType)

        iconGlyph?.removeFromSuperview()
        let glyph = NotificationRowCell.makeGlyph(for: style)
        glyph.translatesAutoresizingMaskIntoConstraints = false
        iconTile.addSubview(glyph)
        NSLayoutConstraint.activate([
            glyph.centerXAnchor.constraint(equalTo: iconTile.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: iconTile.centerYAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 18),
            glyph.heightAnchor.constraint(equalToConstant: 18),
        ])
        iconGlyph = glyph

        if entry.isRead {
            card.fillColor = palette.readFill
            card.strokeColor = palette.readStroke
            iconTile.fillColor = palette.tileReadFill
            iconTile.strokeColor = palette.tileReadStroke
            dotView.backgroundColor = palette.dotRead
        } else {
            card.fillColor = palette.unreadFill
            card.strokeColor = palette.unreadStroke
            iconTile.fillColor = style.tileFill
            iconTile.strokeColor = style.tileStroke
            dotView.backgroundColor = palette.dotUnread
        }
        card.fillAlpha = 1.0
        card.strokeAlpha = 1.0
        iconTile.fillAlpha = 1.0
        iconTile.strokeAlpha = 1.0
    }

    private static func makeGlyph(for style: NotifStyleBridge) -> UIView {
        switch style {
        case .gold: return NotifIcon.timer()
        case .red: return NotifIcon.close()
        case .green: return NotifIcon.bell()
        case .neutral:
            let imageView = UIImageView(image: UIImage(named: "ic_trainer_running_18")?.withRenderingMode(.alwaysTemplate))
            imageView.tintColor = .white
            imageView.contentMode = .scaleAspectFit
            return imageView
        }
    }

    private static func relativeTime(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        let minutes = Int(seconds / 60)
        let hours = Int(seconds / 3600)
        let days = Int(seconds / 86400)
        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes) min ago" }
        if hours < 24 { return "\(hours) \(hours == 1 ? "hour" : "hours") ago" }
        return "\(days) \(days == 1 ? "day" : "days") ago"
    }

    @objc private func handleTap() { onTapped?() }
}

// MARK: - Layout

private extension NotificationRowCell {

    func buildLayout() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        // radial-gradient(41.31% 50% at 50% -10.17%, rgba(255,255,255,0.08) 0%,
        // transparent 100%) from the design spec - same technique
        // card_details_bg.xml already uses on Android, just expressed via
        // GlassCardView's own sheen layer here instead of a second drawable.
        card.translatesAutoresizingMaskIntoConstraints = false
        card.sheenOrigin = .topCenter
        card.sheenAlpha = 0.08
        card.isUserInteractionEnabled = true
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        contentView.addSubview(card)

        iconTile.translatesAutoresizingMaskIntoConstraints = false
        iconTile.sheenOrigin = .topCenter
        iconTile.sheenAlpha = 0.08
        card.addSubview(iconTile)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        card.addSubview(titleLabel)

        subtextLabel.translatesAutoresizingMaskIntoConstraints = false
        subtextLabel.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        subtextLabel.numberOfLines = 2
        card.addSubview(subtextLabel)

        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.layer.cornerRadius = 4
        dotView.clipsToBounds = true
        card.addSubview(dotView)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = AppFont.regular.size(10.0, familyName: familyFunnelSans)
        card.addSubview(timeLabel)

        chevron.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chevron)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 84),

            // Top-aligned with the title (and, by extension, the dot - both
            // sit on the same card.top+12 line) rather than centered in the
            // card's full height, which grows with a 2-line subtext.
            iconTile.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            iconTile.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            iconTile.widthAnchor.constraint(equalToConstant: 38),
            iconTile.heightAnchor.constraint(equalToConstant: 38),

            dotView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            dotView.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -6),
            dotView.widthAnchor.constraint(equalToConstant: 8),
            dotView.heightAnchor.constraint(equalToConstant: 8),
            dotView.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),

            timeLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -11),
            chevron.centerYAnchor.constraint(equalTo: subtextLabel.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 18),
            chevron.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconTile.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: dotView.leadingAnchor, constant: -8),

            subtextLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtextLabel.leadingAnchor.constraint(equalTo: iconTile.trailingAnchor, constant: 12),
            // Against the chevron's own leading edge, not a guessed fixed
            // margin - the chevron only needs ~29pt (11 inset + 18 width),
            // a flat -48 was leaving space on the table unnecessarily.
            subtextLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            // Drives the card's actual height when the subtext wraps to two
            // lines - the >= 84 floor above only covers the short-text case.
            card.bottomAnchor.constraint(greaterThanOrEqualTo: subtextLabel.bottomAnchor, constant: 12),
        ])
    }
}

// MARK: - notification_type -> icon/colour category

enum NotifStyleBridge {
    case gold, red, green, neutral

    static func forType(_ type: String) -> NotifStyleBridge {
        switch type {
        case "class_waitlist_spot_available", "class_waitlist_joined":
            return .gold
        case "gx_booking_cancelled_ban", "gx_waitlist_removed_ban", "gx_blacklisted",
             "class_cancelled_by_mypt", "class_booking_cancelled_by_member",
             "class_waitlist_invitation_expired", "membership_expired":
            return .red
        case "gx_blacklist_removed", "class_booking_confirmed":
            return .green
        default:
            return .neutral
        }
    }

    var tileFill: UIColor {
        switch self {
        case .gold: return UIColor(hex: "#FFCC33").withAlphaComponent(0.10)
        case .red: return UIColor(hex: "#EE4D37").withAlphaComponent(0.10)
        case .green: return UIColor(hex: "#E0FE08").withAlphaComponent(0.10)
        case .neutral: return UIColor.white.withAlphaComponent(0.10)
        }
    }

    var tileStroke: UIColor {
        switch self {
        case .gold: return UIColor(hex: "#FFCC33").withAlphaComponent(0.50)
        case .red: return UIColor(hex: "#EE4D37").withAlphaComponent(0.50)
        case .green: return UIColor(hex: "#E0FE08").withAlphaComponent(0.50)
        case .neutral: return UIColor.white.withAlphaComponent(0.30)
        }
    }
}
