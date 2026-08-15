//
//  NotificationBellInstaller.swift
//  MyPT
//
//  The Home top bar (HomepageVC.swift / ActiveHomepageVCViewController.swift)
//  is built in Homepage.storyboard, not in code - adding a new button there
//  safely means hand-editing Interface Builder's XML with no way to visually
//  verify the result, real risk of corrupting a storyboard several other
//  scenes also live in. Anchoring a new, purely-programmatic button off the
//  EXISTING `btnNameInitial` IBOutlet (both host controllers already have
//  it) avoids touching the storyboard at all. Android equivalent: the
//  `notificationBell` RelativeLayout added directly into
//  fragment_active_user_home_new.xml (that screen IS built in plain XML, so
//  no such constraint applied there).
//

import UIKit

enum NotificationBellInstaller {

    /// Adds the bell + unread dot to the left of `avatarButton`, wires its
    /// tap to push NotificationsViewController, and does an initial
    /// unread-count fetch. Call once from viewDidLoad(). Returns the dot
    /// view so the caller can also refresh it from viewWillAppear.
    @discardableResult
    static func install(leftOf avatarButton: UIButton, in hostViewController: UIViewController) -> UIView? {
        guard let container = avatarButton.superview else { return nil }

        let bellButton = UIButton(type: .custom)
        bellButton.translatesAutoresizingMaskIntoConstraints = false
        bellButton.backgroundColor = UIColor(red: 28/255, green: 31/255, blue: 33/255, alpha: 0.40)
        bellButton.layer.cornerRadius = 12
        container.addSubview(bellButton)

        let icon = NotifIcon.bell()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.isUserInteractionEnabled = false
        bellButton.addSubview(icon)

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = UIColor(hex: "#EE4D37")
        dot.layer.cornerRadius = 4
        dot.layer.borderWidth = 1
        dot.layer.borderColor = UIColor(hex: "#EE4D37").withAlphaComponent(0.50).cgColor
        dot.isHidden = true
        bellButton.addSubview(dot)

        NSLayoutConstraint.activate([
            bellButton.trailingAnchor.constraint(equalTo: avatarButton.leadingAnchor, constant: -12),
            bellButton.centerYAnchor.constraint(equalTo: avatarButton.centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 40),
            bellButton.heightAnchor.constraint(equalToConstant: 40),

            icon.centerXAnchor.constraint(equalTo: bellButton.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: bellButton.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),

            dot.topAnchor.constraint(equalTo: bellButton.topAnchor, constant: 6),
            dot.trailingAnchor.constraint(equalTo: bellButton.trailingAnchor, constant: -6),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),
        ])

        bellButton.addAction(UIAction { [weak hostViewController] _ in
            guard let hostViewController = hostViewController else { return }
            let controller = NotificationsViewController()
            controller.hidesBottomBarWhenPushed = true
            hostViewController.navigationController?.pushViewController(controller, animated: true)
        }, for: .touchUpInside)

        refreshUnreadBadge(dot)
        return dot
    }

    /// Cheap enough (one COUNT query) to just re-check every time Home
    /// appears - same reasoning as Android's own onResume refresh.
    static func refreshUnreadBadge(_ dot: UIView?) {
        guard let dot = dot else { return }
        NetworkManager.shared.genericAPICall(serviceEndPoint: .notifications_unread_count,
                                             method: .get,
                                             isShowLoading: false) { responseData, _ in
            guard let data = responseData,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let payload = json["data"] as? [String: Any],
                  let count = payload["unread_count"] as? Int else { return }
            DispatchQueue.main.async {
                dot.isHidden = count <= 0
            }
        }
    }
}
