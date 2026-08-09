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
        UpcomingClassVM.waitlistOpenSlotsCountApi { emptySlots in
            guard emptySlots > 0 else { return }
            scheduleNotification(emptySlots: emptySlots)
        }
    }

    private static func scheduleNotification(emptySlots: Int) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }

            let content = UNMutableNotificationContent()
            content.title = "Spot available"
            content.body = emptySlots == 1
                ? "1 spot opened up in a class you're waitlisted for."
                : "\(emptySlots) spots opened up in classes you're waitlisted for."
            content.sound = .default
            // Routed by AppDelegate.routeNotificationTap(userInfo:) - jumps
            // straight to the Bookings tab, same idiom as the server-pushed
            // "waitlist_spot_available" type already handles for a specific class.
            content.userInfo = ["type": "waitlist_open_slots"]

            let request = UNNotificationRequest(
                identifier: "waitlist_open_slots",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            )
            UNUserNotificationCenter.current().add(request)
        }
    }
}
