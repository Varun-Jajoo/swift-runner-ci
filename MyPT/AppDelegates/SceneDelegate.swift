//
//  SceneDelegate.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import UIKit
import FacebookCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var stroyBoard:UIStoryboard?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        self.goToSplash()
        
//        self.checkIsUserLogin()
       
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else {
            return
        }
        navigateUniversalLink(incomingURL, window: window)
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    //MARK: -----------CHECK USER LOGIN
    func checkIsUserLogin(){
        if appUserDefaults.getUserFromUserDefaults(as: SubmitDataModel.self)?.id != 0 && appUserDefaults.getUserFromUserDefaults(as: SubmitDataModel.self)?.user?.isCompleted == 1 {
           
//            self.setupTab(selectedTab: 0, isGoGeustDashboard: true)
            
            self.setupTab(selectedTab: 0, isGoGeustDashboard: appUserDefaults.getIsPackageCreated())
        }
        else if appUserDefaults.getRegistrationSkip() == true {
            appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
        }
        else{
            self.goToMainView()
        }
    }
    
    
    //MARK: -------------SET FLOW
    func goToSplash() {
        stroyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navController: UINavigationController? = stroyBoard?.instantiateViewController(withIdentifier: "navigation") as? UINavigationController
      
        let vc:CustomSplashViewController = CustomSplashViewController.instantiate(appStoryboard: .main)
        navController?.setViewControllers([vc], animated: false)
        window?.rootViewController = navController
    }
    
    func goToMainView() {
        stroyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navController: UINavigationController? = stroyBoard?.instantiateViewController(withIdentifier: "navigation") as? UINavigationController
      
       let vc: MainViewController = MainViewController.instantiate(appStoryboard: .main)
//       let vc: NameViewController = NameViewController.instantiate(appStoryboard: .main)

//      let vc: AgeViewController = AgeViewController.instantiate(appStoryboard: .main)
//       let vc: WeightViewController = WeightViewController.instantiate(appStoryboard: .main)
        navController?.setViewControllers([vc], animated: false)
        window?.rootViewController = navController
    }
    
        //MARK: ------------ GO TO GUESTDASHBOARD
    func goToGuestDashboard() {
        stroyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navController: UINavigationController? = stroyBoard?.instantiateViewController(withIdentifier: "navigation") as? UINavigationController
        let dashboardVC: DashboardGuestViewController = DashboardGuestViewController.instantiate(appStoryboard: .dashboard)
        navController?.setViewControllers([dashboardVC], animated: false)
        window?.rootViewController = navController
    }
    
    //MARK: ------------ GO TO DASHBOARD
    func goToDashboard() {
        stroyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navController: UINavigationController? = stroyBoard?.instantiateViewController(withIdentifier: "navigation") as? UINavigationController
        let dashboardVC: DashboardViewController = DashboardViewController.instantiate(appStoryboard: .dashboard)
        navController?.setViewControllers([dashboardVC], animated: false)
        window?.rootViewController = navController
    }
    
    
    //MARK: ------------ GO TO Tabbar
    //set selectedTab is 0 to start from dashboard
    func setupTab(selectedTab:Int, isGoGeustDashboard:Bool = true){
        let tab = CustomTabViewController() // CustomViewController()
        tab.selectedIndex = selectedTab
        tab.isForGeustDashboard = isGoGeustDashboard
        window?.makeKeyAndVisible()
        let objNav = UINavigationController(rootViewController: tab)
        objNav.isNavigationBarHidden = true
        window?.rootViewController = objNav
        
//        // Now that TabBar is shown, handle deep link
//        if let url = DeepLinkRouter.shared.pendingURL {
//            DeepLinkRouter.shared.handle(url: url, window: window)
//            DeepLinkRouter.shared.pendingURL = nil // clear after handling
//          }
    }
    
}

