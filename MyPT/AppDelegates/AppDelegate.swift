//
//  AppDelegate.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import IQKeyboardToolbarManager
import GooglePlaces
import Tabby
import Firebase
import GoogleSignIn
import FacebookCore
import UserNotifications
import FirebaseMessaging
import Mixpanel


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
               
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        if #available(iOS 15.0, *) {
            UIButton.appearance().configuration = nil
        }
        
        // Initialize Mixpanel
        Mixpanel.initialize(token: "6ef019008995f6e716fcc60e56aa50a1", trackAutomaticEvents: true)
        
        FirebaseApp.configure()
        GMSServices.provideAPIKey(AppConstant.gMap_services_Key)
        GMSPlacesClient.provideAPIKey(AppConstant.gMap_services_Key)
        TabbySDK.shared.setup(withApiKey: AppConstant.tabby_key)
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardToolbarManager.shared.isEnabled = true
        
 
        if FirebaseApp.app() == nil {
               FirebaseApp.configure()
           }
    
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        // Ask for permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        // Register with APNs
         application.registerForRemoteNotifications()

        // Safety net alongside the refresh-callback upload in
        // `messaging(_:didReceiveRegistrationToken:)`: catches a token that
        // rotated while the app wasn't running to receive that callback, or
        // simply hasn't been re-confirmed to the server in a while. No-ops
        // if the cached token is already in sync and recent (see
        // `FcmTokenSync.needsUpload`), or if nobody's logged in yet.
        FcmTokenSync.sync(token: appUserDefaults.getReFCMToken())

        return true
    }
    
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Check if the user activity is from Universal Link
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else {
            return false
        }
        
        navigateUniversalLink(incomingURL, window: window)
        return true
    }

    
    func applicationDidBecomeActive(_ application: UIApplication) {
           // App has become active, Restart any paused tasks
       }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Pause ongoing tasks or disable UI updates
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save app state and release shared resources
    }

    func applicationWillTerminate(_ application: UIApplication) {
       //----------------
    }
    

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                       didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
//         Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print message ID.
        if let messageID = userInfo["gcm.Message_ID"] {
          print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)
      }
    

    func application(_ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
       fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      Messaging.messaging().appDidReceiveMessage(userInfo)
      completionHandler(.noData)
    }

      // [END receive_message]
      func application(_ application: UIApplication,
                       didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
      }

   
    //----------------------*************
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // FCM token received
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("✅ FCM Token: \(fcmToken ?? "None")")

        Messaging.messaging().token { token, error in
            if let error = error {
                print("❌ Error fetching FCM token: \(error)")
            } else if let token = token {
                print("✅ FCM Token: \(token)")
                appUserDefaults.setFCMToken(refreshToken: token)
                // This was the actual bug: the refreshed token was saved
                // locally and never told to the backend, so the server kept
                // pushing to the old, dead token once Firebase rotated it -
                // notifications worked right after login, then silently
                // stopped until the next one. `upload` unconditionally (not
                // `sync`'s staleness check) since a genuinely NEW token from
                // FCM should always be pushed regardless of when the last
                // sync happened.
                FcmTokenSync.upload(token)
                DispatchQueue.main.async {
                    AppDelegate.showDebugFCMToken(token)
                }
            }
        }
    }

    // TEMP DEBUG - remove once the FCM token's been copied out.
    private static func showDebugFCMToken(_ token: String) {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }

        keyWindow.viewWithTag(999_888).map { $0.removeFromSuperview() }

        let textView = UITextView()
        textView.tag = 999_888
        textView.text = token
        textView.textColor = .blue
        textView.backgroundColor = .white
        textView.font = .systemFont(ofSize: 11)
        textView.isEditable = false
        textView.isSelectable = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        keyWindow.addSubview(textView)
        keyWindow.bringSubviewToFront(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            textView.topAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.topAnchor, constant: 4),
            textView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

   
    // Show push notifications when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            // For iOS 14+, .banner is available
            completionHandler([.banner, .sound, .badge])
        } else {
            // For iOS 10 to 13, use .alert instead of .banner
            completionHandler([.alert, .sound, .badge])
        }
    }

    // Notification tapped
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//        didReceive response: UNNotificationResponse,
//        withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        // Handle deep linking/navigation here
//        completionHandler()
//    }
    
    // Receive displayed notifications for iOS 10 devices.
        
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
       let userInfo = response.notification.request.content.userInfo

       // Print full message.
       print(userInfo)

         Messaging.messaging().appDidReceiveMessage(userInfo)

         AppDelegate.routeNotificationTap(userInfo: userInfo)
         if let type = userInfo["type"] as? String {
             NotificationReadTracker.markReadByContext(pushType: type, scheduleId: userInfo["schedule_id"] as? String)
         }

         completionHandler()
     }

    /// Not private: also called directly by NotificationsViewController's row
    /// tap (NotificationRouting.route(notificationType:data:)) so the list
    /// screen and an actual push tap can never navigate differently for the
    /// same type.
    static func routeNotificationTap(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return }
        let scheduleId = userInfo["schedule_id"] as? String

        // Genuinely no single class to land on - a waitlist offer that timed
        // out or an invitation that expired isn't "this class was cancelled"
        // (ClassCancelledByAdminViewController's copy would be wrong), and
        // there's no dedicated screen for either outcome, so the Bookings
        // tab is the honest destination, not a compromise.
        if type.caseInsensitiveCompare("waitlist_not_converted") == .orderedSame
            || type.caseInsensitiveCompare("waitlist_invitation_expired") == .orderedSame {
            AppDelegate.jumpToBookingsTab()
            return
        }

        // class_cancelled_by_admin (admin pulled the whole class) and
        // gx_booking_cancelled_ban (this member's booking specifically was
        // cancelled because they got banned) both mean the same true thing
        // from the tapping member's side - "this class has been cancelled" -
        // so both open the same rejection screen, hydrated fresh via
        // class-detail since the push/DB payload only ever carries schedule_id.
        if type.caseInsensitiveCompare("class_cancelled_by_admin") == .orderedSame {
            if let scheduleId = scheduleId, !scheduleId.isEmpty {
                AppDelegate.pushCancelledClassScreen(scheduleId: scheduleId)
            } else {
                AppDelegate.jumpToBookingsTab()
            }
            return
        }

        if type.caseInsensitiveCompare("waitlist_open_slots") == .orderedSame {
            // The local "N spots opened up" notification only carries a
            // schedule_id when there was exactly one match - go straight to
            // its claim screen then, same as the specific server-pushed
            // "waitlist_spot_available" type. With more than one match there's
            // no single class to deep link to, so fall back to the Bookings tab.
            if let scheduleId = scheduleId, !scheduleId.isEmpty {
                AppDelegate.pushClaimScreen(scheduleId: scheduleId)
            } else {
                AppDelegate.jumpToBookingsTab()
            }
            return
        }

        if type.caseInsensitiveCompare("waitlist_spot_available") == .orderedSame {
            if let scheduleId = scheduleId, !scheduleId.isEmpty {
                AppDelegate.pushClaimScreen(scheduleId: scheduleId)
            }
            return
        }

        // The member's own cancellation - they already saw the confirmation
        // at the moment they cancelled, so there's nothing deeper to show;
        // the Bookings tab (where the now-cancelled row lives) is the real
        // destination, not a shortcut.
        if type.caseInsensitiveCompare("my_bookings") == .orderedSame {
            AppDelegate.jumpToBookingsTab()
            return
        }

        // group_class_detail (booking confirmed, class updated/reminder,
        // attended, no-show warning) and waitlist_joined are always about a
        // class this member already has a booking or waitlist row for - land
        // on that row's actual state (confirmed/cancelled/completed/no-show/
        // waitlisted) instead of the generic browse-this-class screen.
        if type.caseInsensitiveCompare("waitlist_joined") == .orderedSame
            || type.caseInsensitiveCompare("group_class_detail") == .orderedSame {
            if let scheduleId = scheduleId, !scheduleId.isEmpty {
                AppDelegate.pushBookingStatusScreen(scheduleId: scheduleId)
            } else {
                AppDelegate.jumpToPlansTab()
            }
            return
        }

        // The actual ban screen (BookingPausedViewController), live-checked
        // rather than trusting the notification's own snapshot - see
        // pushBanScreen()'s own doc comment.
        if type.caseInsensitiveCompare("gx_blacklisted") == .orderedSame {
            AppDelegate.pushBanScreen(blacklistId: userInfo["blacklist_id"] as? String)
            return
        }

        // membership_expired, gx_blacklist_removed, gx_waitlist_removed_ban -
        // no dedicated screen can be driven from just what these carry
        // (RenewPlanVC/PackageExpireVC need a pre-fetched plan list injected
        // by their caller, not just an id to self-fetch from; a lifted ban
        // or a waitlist removal has no detail screen at all) - Menu tab is
        // the honest destination for these three, not a shortcut.
        if type.caseInsensitiveCompare("my_profile") == .orderedSame {
            AppDelegate.jumpToMenuTab()
            return
        }
    }

    /// `class_booking_confirmed`/`class_updated` (push type
    /// `group_class_detail`) - only a scheduleId is known from the push
    /// payload, so seed a minimal GroupClassTapThroughData and let
    /// GroupTrainingDetailViewController's own viewDidLoad fetch the rest,
    /// same minimal-seed pattern SlotOpenViewController.redirectToDetailScreen()
    /// already uses after a claim.
    private static func pushClassDetailScreen(scheduleId: String) {
        guard let navigationController = AppDelegate.topNavigationController() else { return }

        var tapThrough = GroupClassTapThroughData()
        tapThrough.scheduleId = scheduleId

        let controller = GroupTrainingDetailViewController()
        controller.tapThrough = tapThrough
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: true)
    }

    /// `class_cancelled_by_admin`/`gx_booking_cancelled_ban` - same idea as
    /// pushClassDetailScreen() above, but the target
    /// (ClassCancelledByAdminViewController) isn't self-fetching, so this
    /// does the class-detail lookup itself (same API + fallback-location
    /// pattern GroupTrainingDetailViewController.fetchClassDetail() uses)
    /// and hydrates the input before pushing. A failed/empty lookup falls
    /// back to the Bookings tab rather than pushing a blank rejection screen.
    private static func pushCancelledClassScreen(scheduleId: String) {
        let params: [String: String] = [
            "lat": "\(GroupClassCardFormatter.fallbackLatitude)",
            "long": "\(GroupClassCardFormatter.fallbackLongitude)",
            "schdule_id": scheduleId
        ]

        UpcomingClassVM.classDetailsApi(inputParams: params, isShowLoader: false) { result in
            DispatchQueue.main.async {
                guard result?.status == true, let detail = result?.data,
                      let navigationController = AppDelegate.topNavigationController() else {
                    AppDelegate.jumpToBookingsTab()
                    return
                }

                var input = ClassCancelledByAdminInput()
                input.classTitle = detail.className ?? ""
                input.classTime = detail.time ?? ""
                input.classLocation = detail.location ?? ""
                input.trainerName = detail.name ?? ""
                input.distance = detail.distance ?? ""
                input.studioLat = detail.studioLat?.doubleValue ?? 0
                input.studioLng = detail.studioLng?.doubleValue ?? 0

                let controller = ClassCancelledByAdminViewController()
                controller.input = input
                controller.hidesBottomBarWhenPushed = true
                navigationController.pushViewController(controller, animated: true)
            }
        }
    }

    /// `group_class_detail`/`waitlist_joined` for a class this member already
    /// has a booking or waitlist row for - self-fetches this member's real
    /// state via `api/my-class-booking-status` and lands on the actual
    /// confirm/cancelled/completed/no-show/waitlisted screen (reusing
    /// `SlotConfirmedViewController`/`WaitlistConfirmedViewController`/
    /// `SlotOpenViewController` exactly as the Bookings-list row tap already
    /// does) instead of `pushClassDetailScreen()`'s generic browse view.
    /// Falls back to that generic screen when the lookup itself is empty
    /// (`state == "none"`) or the request fails outright - nothing more
    /// specific to show at that point.
    private static func pushBookingStatusScreen(scheduleId: String) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .my_class_booking_status,
                                             method: .get,
                                             queries: ["schedule_id": scheduleId],
                                             isShowLoading: false) { responseData, _ in
            DispatchQueue.main.async {
                guard let data = responseData,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let payload = json["data"] as? [String: Any],
                      let navigationController = AppDelegate.topNavigationController() else {
                    AppDelegate.pushClassDetailScreen(scheduleId: scheduleId)
                    return
                }

                let state = payload["state"] as? String ?? "none"
                let classTitle = payload["title"] as? String ?? ""
                let classTime = payload["timing"] as? String ?? ""
                let classLocation = payload["location"] as? String ?? ""
                let trainerName = payload["trainer"] as? String ?? ""
                let distance = payload["distance"] as? String ?? ""
                let studioLat = Double(payload["studio_lat"] as? String ?? "") ?? 0
                let studioLng = Double(payload["studio_long"] as? String ?? "") ?? 0

                switch state {
                case "booking":
                    // Same split BookingListViewController's own row-tap
                    // decision tree makes: a schedule-wide admin cancel gets
                    // ClassCancelledByAdminViewController, never the shared
                    // receipt screen - that screen's "cancelled" copy is
                    // hardcoded to "as per your request", which would be
                    // wrong here (SlotConfirmedViewController is never
                    // reached with cancelled_by_admin == true from the
                    // Bookings list either, for the same reason).
                    if payload["cancelled_by_admin"] as? Bool == true {
                        var input = ClassCancelledByAdminInput()
                        input.classTitle = classTitle
                        input.classTime = classTime
                        input.classLocation = classLocation
                        input.trainerName = trainerName
                        input.distance = distance
                        input.studioLat = studioLat
                        input.studioLng = studioLng

                        let controller = ClassCancelledByAdminViewController()
                        controller.input = input
                        controller.hidesBottomBarWhenPushed = true
                        navigationController.pushViewController(controller, animated: true)
                        return
                    }

                    let controller = SlotConfirmedViewController()
                    controller.classTitle = classTitle
                    controller.classTime = classTime
                    controller.classLocation = classLocation
                    controller.trainerName = trainerName
                    controller.distance = distance
                    controller.studioLat = studioLat
                    controller.studioLng = studioLng
                    controller.classPrice = payload["price"] as? String ?? ""
                    controller.isReadOnly = true
                    controller.bookingId = payload["booking_id"] as? String ?? ""
                    controller.canCancelBooking = payload["can_cancel_booking"] as? Bool ?? false
                    controller.bookingStatus = payload["booking_status"] as? String ?? "confirmed"
                    controller.cancelledReason = payload["cancelled_reason"] as? String ?? ""
                    controller.noShowCount = (payload["no_show_count"] as? NSNumber)?.intValue ?? 0
                    controller.noShowBlockedUntil = payload["no_show_blocked_until"] as? String ?? ""
                    controller.hidesBottomBarWhenPushed = true
                    navigationController.pushViewController(controller, animated: true)

                case "waitlist":
                    let hasOpenSpot = payload["has_open_spot"] as? Bool ?? false
                    if hasOpenSpot {
                        // Same claim screen the "spot available" push already
                        // opens - a spot's actually open right now, so the
                        // countdown/claim flow is the real destination, not
                        // a static "you're waitlisted" readout.
                        AppDelegate.pushClaimScreen(scheduleId: scheduleId)
                        return
                    }
                    let controller = WaitlistConfirmedViewController()
                    controller.classTitle = classTitle
                    controller.classTime = classTime
                    controller.classLocation = classLocation
                    controller.trainerName = trainerName
                    controller.distance = distance
                    controller.studioLat = studioLat
                    controller.studioLng = studioLng
                    controller.waitlistType = payload["waitlist_type"] as? String ?? "normal"
                    if let waitlistId = payload["waitlist_id"] as? String, !waitlistId.isEmpty {
                        controller.bookingId = "wl-" + waitlistId
                    }
                    controller.hidesBottomBarWhenPushed = true
                    navigationController.pushViewController(controller, animated: true)

                default:
                    AppDelegate.pushClassDetailScreen(scheduleId: scheduleId)
                }
            }
        }
    }

    /// `gx_blacklisted` - deliberately does NOT trust hoursBlocked/resumesOn
    /// off the notification payload itself, even though they ride along in
    /// it. Those are a snapshot from the moment the ban was imposed; tapping
    /// an old one after the ban has since been lifted (or just expired) must
    /// not show stale "you're still banned" data, so this always re-checks
    /// live via api/blacklist-status first, passing blacklistId (from the
    /// notification's own data) so a member banned more than once gets THAT
    /// ban's history, not whichever is most recent. Still banned -> the
    /// normal live screen. No longer banned but a record was found ->
    /// same screen in isHistorical mode ("you were banned on X for Y hours").
    /// Nothing found at all (shouldn't happen from a real gx_blacklisted tap,
    /// but defensive) -> Menu tab.
    private static func pushBanScreen(blacklistId: String?) {
        var queries: [String: String] = [:]
        if let blacklistId = blacklistId, !blacklistId.isEmpty {
            queries["blacklist_id"] = blacklistId
        }

        NetworkManager.shared.genericAPICall(serviceEndPoint: .blacklist_status,
                                             method: .get,
                                             queries: queries,
                                             isShowLoading: false) { responseData, _ in
            DispatchQueue.main.async {
                guard let data = responseData,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let payload = json["data"] as? [String: Any],
                      let navigationController = AppDelegate.topNavigationController() else {
                    AppDelegate.jumpToMenuTab()
                    return
                }

                let isBlacklisted = payload["is_blacklisted"] as? Bool == true
                let wasBlacklisted = payload["was_blacklisted"] as? Bool == true
                guard isBlacklisted || wasBlacklisted else {
                    AppDelegate.jumpToMenuTab()
                    return
                }

                let controller = BookingPausedViewController()
                controller.isHistorical = !isBlacklisted
                if let reason = payload["reason"] as? String, !reason.isEmpty {
                    controller.reason = reason
                }
                if isBlacklisted {
                    if let hoursRemaining = payload["hours_remaining"] as? String, !hoursRemaining.isEmpty {
                        controller.hoursRemaining = hoursRemaining
                    }
                    if let resumesOn = payload["resumes_on"] as? String, !resumesOn.isEmpty {
                        controller.resumesOn = resumesOn
                    }
                } else {
                    if let hoursBlocked = payload["hours_blocked"] as? String, !hoursBlocked.isEmpty {
                        controller.hoursRemaining = hoursBlocked
                    }
                    if let bannedOn = payload["banned_on"] as? String, !bannedOn.isEmpty {
                        controller.resumesOn = bannedOn
                    }
                }
                controller.hidesBottomBarWhenPushed = true
                navigationController.pushViewController(controller, animated: true)
            }
        }
    }

    /// Every waitlisted member gets the same "a spot opened up" push at once
    /// (`WaitlistNotifier::notifyAll`), so tapping it needs to open the claim
    /// screen directly rather than just landing on the home tab. Android's
    /// equivalent: `MyFirebaseMessagingService.sendNotification`'s
    /// `waitlist_spot_available` branch.
    private static func pushClaimScreen(scheduleId: String) {
        guard let navigationController = AppDelegate.topNavigationController() else { return }

        let controller = SlotOpenViewController()
        controller.scheduleId = scheduleId
        controller.onClaimed = { [weak navigationController] classTitle, time, location, trainer in
            let confirmed = SlotConfirmedViewController()
            confirmed.classTitle = classTitle
            confirmed.classTime = time
            confirmed.classLocation = location
            confirmed.trainerName = trainer
            confirmed.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(confirmed, animated: true)
        }
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: true)
    }

    /// Finds the active scene's navigation controller, unwrapping a tab bar
    /// root if present, so the push lands on whatever tab the user is
    /// currently on rather than assuming a fixed root type.
    private static func topNavigationController() -> UINavigationController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        var root = keyWindow?.rootViewController
        if let nav = root as? UINavigationController {
            if let tab = nav.viewControllers.first as? UITabBarController,
               let selectedNav = tab.selectedViewController as? UINavigationController {
                return selectedNav
            }
            return nav
        }
        if let tab = root as? UITabBarController {
            root = tab.selectedViewController
        }
        return root as? UINavigationController
    }

    /// Local "N spots opened up" notification's tap target - the Bookings
    /// tab itself (index 2, same constant every confirmation screen already
    /// uses), not any specific class, since the count spans every class
    /// this member is waitlisted for. Not private: also the shared "land on
    /// Bookings" target for any sheet/screen that doesn't have a reliable
    /// `navigationController` of its own to fall back on (e.g. a modally
    /// presented sheet) - see `DoubleBookingSheetViewController.manageBookingTapped()`.
    static func jumpToBookingsTab() {
        jumpToTab(atIndex: 2)
    }

    /// Menu tab - Android's equivalent notification types (`my_profile`)
    /// land on `R.id.menu`, same tab order position here (see
    /// CustomTabViewController.setupTabbar(): Home, Plans, Bookings, Menu).
    static func jumpToMenuTab() {
        jumpToTab(atIndex: 3)
    }

    /// Plans tab - Android's `group_class_detail`/`waitlist_alert` land on
    /// `R.id.plans` (their Calendar tab). Only used here as the no-schedule-id
    /// fallback for `group_class_detail`; when a schedule_id is present,
    /// routeNotificationTap() pushes straight to GroupTrainingDetailViewController
    /// instead, which iOS's tab structure makes possible and Android's doesn't.
    static func jumpToPlansTab() {
        jumpToTab(atIndex: 1)
    }

    private static func jumpToTab(atIndex tabIndex: Int) {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        var candidate = keyWindow?.rootViewController
        var tabBarController: UITabBarController?
        while let current = candidate {
            if let tab = current as? UITabBarController {
                tabBarController = tab
                break
            }
            candidate = current.presentedViewController ?? current.children.first
        }

        guard let tabBarController = tabBarController,
              let tabs = tabBarController.viewControllers,
              tabs.indices.contains(tabIndex) else {
            return
        }

        (tabs[tabIndex] as? UINavigationController)?.popToRootViewController(animated: false)
        tabBarController.selectedIndex = tabIndex
    }
   
    
    /*
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo["gcm.Message_ID"] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      return UIBackgroundFetchResult.newData
    }
    */
    
}
