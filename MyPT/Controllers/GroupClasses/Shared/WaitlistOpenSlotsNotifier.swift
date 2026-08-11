//
//  WaitlistOpenSlotsNotifier.swift
//  MyPT
//
//  Fires a local "N spots opened up" notification the next time the app
//  backgrounds right after a booking/waitlist-join completes, pointing at
//  the Bookings tab. Android counterpart: `WaitlistOpenSlotsNotifier.kt` /
//  `AppForegroundTracker.kt`. iOS doesn't need the Android tracker's
//  whole-app-vs-single-Activity debounce trick - `UIApplication.
//  didEnterBackgroundNotification` already only fires for a true background
//  transition, never for pushing/popping a view controller in-app.
//

import UIKit
import UserNotifications

struct WaitlistOpenSlot {
    let scheduleId: String
    let className: String
}

enum WaitlistOpenSlotsNotifier {

    private static var observer: NSObjectProtocol?

    /// Call from a confirmation screen's `viewDidLoad` right after a
    /// booking/waitlist-join succeeds - arms a one-shot check for the next
    /// time the app backgrounds. Re-arming (e.g. a second confirmation
    /// screen shown before the first background happens) replaces the
    /// previous arm rather than stacking observers.
    static func armOnNextBackground() {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            if let observer = WaitlistOpenSlotsNotifier.observer {
                NotificationCenter.default.removeObserver(observer)
            }
            WaitlistOpenSlotsNotifier.observer = nil
            WaitlistOpenSlotsNotifier.checkAndNotify()
        }
    }

    private static func checkAndNotify() {
        UpcomingClassVM.waitlistOpenSlotsCountApi { slots in
            guard !slots.isEmpty else { return }
            scheduleNotification(slots: slots)
        }
    }

    private static func scheduleNotification(slots: [WaitlistOpenSlot]) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }

            let content = UNMutableNotificationContent()
            content.title = "Spot Available 🔔"
            var userInfo: [AnyHashable: Any] = ["type": "waitlist_open_slots"]

            if slots.count == 1, let only = slots.first {
                // Exactly one open spot - name the class and deep link straight
                // to its claim screen (AppDelegate.routeNotificationTap(userInfo:)),
                // same idiom the server-pushed "waitlist_spot_available" type
                // already uses for a specific class.
                content.body = "A spot opened up in \(only.className) - confirm before another member does."
                userInfo["schedule_id"] = only.scheduleId
            } else {
                // Multiple matches - no single class to name or deep link to,
                // just a generic nudge toward the Bookings tab instead of
                // spelling out "N spots opened up".
                content.body = "A spot opened up in one of your waitlisted classes. Tap to view your bookings."
            }
            content.sound = .default
            content.userInfo = userInfo

            let request = UNNotificationRequest(
                identifier: "waitlist_open_slots",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            )
            UNUserNotificationCenter.current().add(request)
        }
    }
}
