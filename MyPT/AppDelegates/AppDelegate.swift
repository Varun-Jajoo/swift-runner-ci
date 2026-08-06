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
            }
        }
        // Optionally send to your server
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

         completionHandler()
     }

    /// Every waitlisted member gets the same "a spot opened up" push at once
    /// (`WaitlistNotifier::notifyAll`), so tapping it needs to open the claim
    /// screen directly rather than just landing on the home tab. Android's
    /// equivalent: `MyFirebaseMessagingService.sendNotification`'s
    /// `waitlist_spot_available` branch.
    private static func routeNotificationTap(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String,
              type.caseInsensitiveCompare("waitlist_spot_available") == .orderedSame,
              let scheduleId = userInfo["schedule_id"] as? String,
              !scheduleId.isEmpty else {
            return
        }

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
