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
        // gx_booking_cancelled_ban shares the same deep-link target as an
        // admin cancellation ("this class has been cancelled" is equally
        // true from the member's side either way) - previously bucketed
        // under my_bookings (tab-only), now routed the same as the type it
        // shares a screen with so the two can't drift apart.
        case "class_cancelled_by_mypt", "gx_booking_cancelled_ban": return "class_cancelled_by_admin"
        // class_attended/class_no_show_warning both carry schedule_id and
        // are about a specific class, same as a booking confirmation - reuse
        // the same deep-link target rather than a new screen.
        case "class_booking_confirmed", "class_updated", "class_attended", "class_no_show_warning": return "group_class_detail"
        case "class_booking_cancelled_by_member": return "my_bookings"
        // Own push type (not folded into my_profile) so routeNotificationTap()
        // can open the ban screen directly instead of just landing on the
        // Menu tab. Deliberately does NOT forward hours_blocked/resumes_on
        // below - that'd be this ban's state as of whenever it was imposed,
        // not now, and pushBanScreen() always re-checks live instead.
        case "gx_blacklisted": return "gx_blacklisted"
        case "membership_expired", "gx_blacklist_removed", "gx_waitlist_removed_ban": return "my_profile"
        default: return ""
        }
    }

    static func route(notificationType: String, data: [String: String]) {
        let type = pushType(forNotificationType: notificationType)
        guard !type.isEmpty else { return }
        var userInfo: [AnyHashable: Any] = ["type": type]
        if let scheduleId = data["schedule_id"] { userInfo["schedule_id"] = scheduleId }
        if let blacklistId = data["blacklist_id"] { userInfo["blacklist_id"] = blacklistId }
        AppDelegate.routeNotificationTap(userInfo: userInfo)
    }
}
