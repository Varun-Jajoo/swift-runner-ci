//
//  NotificationRouting.swift
//  MyPT
//
//  Bridges the DB `notification_type` column (what NotificationsViewController's
//  list actually has) back to the push `type` values AppDelegate.routeNotificationTap()
//  already knows how to navigate for - the two taxonomies are deliberately
//  separate (see NotificationController's own doc comment on the backend for
//  why), so a list row needs this one translation step before reusing that
//  same routing function, rather than re-implementing the switch here.
//  Android equivalent: NotificationsActivity.pushTypeFor().
//

import Foundation

enum NotificationRouting {

    static func pushType(forNotificationType notificationType: String) -> String {
        switch notificationType {
        case "class_waitlist_spot_available": return "waitlist_spot_available"
        case "class_waitlist_joined": return "waitlist_joined"
        case "class_waitlist_not_converted": return "waitlist_not_converted"
        case "class_waitlist_invitation_expired": return "waitlist_invitation_expired"
        case "class_cancelled_by_mypt": return "class_cancelled_by_admin"
        case "class_booking_confirmed", "class_updated": return "group_class_detail"
        case "class_booking_cancelled_by_member", "gx_booking_cancelled_ban": return "my_bookings"
        case "membership_expired", "gx_blacklisted", "gx_blacklist_removed", "gx_waitlist_removed_ban": return "my_profile"
        default: return ""
        }
    }

    static func route(notificationType: String, data: [String: String]) {
        let type = pushType(forNotificationType: notificationType)
        guard !type.isEmpty else { return }
        var userInfo: [AnyHashable: Any] = ["type": type]
        if let scheduleId = data["schedule_id"] { userInfo["schedule_id"] = scheduleId }
        AppDelegate.routeNotificationTap(userInfo: userInfo)
    }
}
