//
//  CustomTabViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/11/24.
//

import UIKit


enum vcDashboard: Int {
    case dashboardGuest = 1
    case dashboard
    
    func viewController() -> UIViewController {
        switch self {
        case .dashboardGuest:
            return DashboardGuestViewController.instantiate(appStoryboard: .dashboard)
        case .dashboard:
            return DashboardViewController.instantiate(appStoryboard: .dashboard)
        }
    }
}


class CustomTabViewController: UITabBarController, UITabBarControllerDelegate {

    //MARK: -----------LINE VIEW
    private var didSetupTabBar = false
    var lineView = UIView()
    var isForGeustDashboard:Bool?
    var num: Int = 1
    private var shapeLayer = CAShapeLayer()
    
    //MARK: -------------Controllers
    let homeVC:DashboardViewController = DashboardViewController.instantiate(appStoryboard: .dashboard)
    let homeGeustuserVC:DashboardGuestViewController = DashboardGuestViewController.instantiate(appStoryboard: .dashboard)
    let bookingsVC:BookingListViewController = BookingListViewController.instantiate(appStoryboard: .booking)
    let libraryVC:LibraryViewController = LibraryViewController.instantiate(appStoryboard: .library)
    let calendarVC:CalendarViewController = CalendarViewController.instantiate(appStoryboard: .calendar)
    let moreVC:MoreViewController = MoreViewController.instantiate(appStoryboard: .more)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.view.backgroundColor = .clear
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTabFlow), name: NSNotification.Name("reloadTab"), object: nil)
        setupTabbar()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.layoutIfNeeded()
        DispatchQueue.main.async {
            self.setupHeightTabbar()
            self.setupCustomTabBar()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupTabbar()
        DispatchQueue.main.async {
             self.setupHeightTabbar()
             self.setupCustomTabBar()
         }
    }
    
    //MARK: --------------FORCLY RELOAD TABVIEW
    @objc func reloadTabFlow(_ notification: Notification) {
        if let shouldReload = notification.object as? Bool {
            print("Reloading tab because object is true")
            isForGeustDashboard = shouldReload
            appUserDefaults.setIsPackageCreated(value: !shouldReload)
//            self.setupTabbar()
        }
    }
 
    //MARK: --------SET TABBAR
    func setupTabbar() {
        let homeTabBarItem = UITabBarItem(title: AppStrings.homeStr, image: AppImages.home, selectedImage: AppImages.homeSelected)
        let bookingsTabBarItem = UITabBarItem(title: AppStrings.bookingStr, image: AppImages.bookings, selectedImage: AppImages.bookingSelected)
        let libraryTabBarItem = UITabBarItem(title: AppStrings.libraryStr, image: AppImages.Library, selectedImage: AppImages.LibrarySelected)
        let calendarTabBarItem = UITabBarItem(title: AppStrings.calendarStr, image: AppImages.calendar, selectedImage: AppImages.calendarSelected)
        let moreTabBarItem = UITabBarItem(title: AppStrings.moreStr, image: AppImages.more, selectedImage: AppImages.moreSelected)
        
        //-------------******************** Add view controllers and tab bar items
        homeGeustuserVC.tabBarItem = homeTabBarItem
        homeVC.tabBarItem = homeTabBarItem
        bookingsVC.tabBarItem = bookingsTabBarItem
        libraryVC.tabBarItem = libraryTabBarItem
        calendarVC.tabBarItem = calendarTabBarItem
        moreVC.tabBarItem = moreTabBarItem
        
        //---------*******
        bookingsVC.isFromTab = true
        calendarVC.isFromTab = true
        selectedIndex = 0
        let vc = ((isForGeustDashboard == true) ? homeGeustuserVC : homeVC)
        let controllers = [vc, bookingsVC, libraryVC, calendarVC, moreVC]
        //--------------------*******
        let navControllers = controllers.map { viewController -> UINavigationController in
            // Disable large title for each controller
            viewController.navigationItem.largeTitleDisplayMode = .never
            let nav = UINavigationController(rootViewController: viewController)
            nav.navigationBar.prefersLargeTitles = false
            return nav
        }
        viewControllers = navControllers
        //--------------------------**********
        tabBar.tintColor = .appYellow
//        tabBar.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        //----------****************Setup Appearence/Lineview called
        setAppearence()
        setupCustomTabBar()
    }
    
    //MARK: ------------SETUP APPEARENCE
    func setAppearence(){
        self.tabBar.isTranslucent = false
        if #available(iOS 15.0, *) {
                 let appearance = UITabBarAppearance()
                 appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 0.5)
                 tabBar.standardAppearance = appearance
//                 tabBar.scrollEdgeAppearance = tabBar.standardAppearance
             }
        if #available(iOS 13.0, *) {
            let appearance = UITabBarItemAppearance()
            let attributes = [NSAttributedString.Key.font: AppFont.semibold.size(12.0, familyName: familyManrope)] //UIFont.boldSystemFont(ofSize: 18.0)
            appearance.normal.titleTextAttributes = attributes as [NSAttributedString.Key: Any]
            appearance.normal.titleTextAttributes = [.foregroundColor: UIColor(red: 189/255.0, green: 189/255.0, blue: 189/255.0, alpha: 1) as Any] // attributes as [NSAttributedString.Key: Any]
            appearance.selected.titleTextAttributes = [.foregroundColor: UIColor.appYellow]  //attributes as [NSAttributedString.Key: Any]
                        
            tabBar.standardAppearance.stackedLayoutAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance?.stackedLayoutAppearance = appearance
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    //-------------------*****************************
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.view.layoutIfNeeded()
//        DispatchQueue.main.async {
//            self.setupCustomTabBar()
//            self.setupHeightTabbar()
//        }
//    }

    private func setupHeightTabbar(heightIncrease: CGFloat = 15, imageBottomInset: CGFloat = 20) {
         self.tabBar.backgroundColor = UIColor.mainBg.withAlphaComponent(1.0)
         self.tabBar.isTranslucent = false
         var getFrame: CGRect = self.tabBar.frame
         getFrame.origin.y -= heightIncrease
         getFrame.size.height += heightIncrease
         self.tabBar.frame = getFrame
        if let items = self.tabBar.items {
             for (index, item) in items.enumerated() {
                 item.imageInsets = (index == self.selectedIndex) ?
                     UIEdgeInsets(top: 0, left: 0, bottom: imageBottomInset, right: 0) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
             }
         }
         self.tabBar.setNeedsLayout()
         self.tabBar.layoutIfNeeded()
     }

    /*
    private func createPathCircle() -> CGPath? {
        guard let items = tabBar.items,
              let selectedItem = tabBar.selectedItem ?? items.first,
              let index = items.firstIndex(of: selectedItem) else {
            print("Error: No tab bar items available.")
            return nil
        }
     
        let tabWidth = tabBar.frame.width / CGFloat(items.count)
        let centerX = tabWidth * CGFloat(index) + tabWidth / 2
        let radius: CGFloat = 35.0
        let curveDepth: CGFloat = 25.0
     
        let path = UIBezierPath()
     
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: centerX - radius, y: 0))
     
        // Add smooth upward curve (concave)
        path.addQuadCurve(
            to: CGPoint(x: centerX, y: curveDepth),
            controlPoint: CGPoint(x: centerX - radius / 2, y: 0)
        )
     
        path.addQuadCurve(
            to: CGPoint(x: centerX + radius, y: 0),
            controlPoint: CGPoint(x: centerX + radius / 2, y: 0)
        )
     
        path.addLine(to: CGPoint(x: tabBar.frame.width, y: 0))
        path.addLine(to: CGPoint(x: tabBar.frame.width, y: tabBar.frame.height + 20))
        path.addLine(to: CGPoint(x: 0, y: tabBar.frame.height + 20))
        path.close()
     
        return path.cgPath
    }
     
    private func setupCustomTabBar() {
        guard tabBar.superview != nil else { return }
     
        // Remove old custom layers
        self.tabBar.layer.sublayers?
            .filter { $0.name == "tabbar_layer_Circle" }
            .forEach { $0.removeFromSuperlayer() }
     
        // Setup new shape layer
        self.shapeLayer.name = "tabbar_layer_Circle"
        self.shapeLayer.fillColor = UIColor.mainBg.withAlphaComponent(1.0).cgColor
        self.shapeLayer.strokeColor = UIColor.white.withAlphaComponent(0.1).cgColor
        self.shapeLayer.lineWidth = 0.3
     
        self.shapeLayer.shadowColor = UIColor.black.cgColor
        self.shapeLayer.shadowOpacity = 0.2
        self.shapeLayer.shadowOffset = CGSize(width: 0, height: -2)
        self.shapeLayer.shadowRadius = 6
     
        // Clear native tab bar background
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundColor = .clear
        self.tabBar.layer.borderWidth = 0
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
     
        // Set path
        if let path = createPathCircle() {
            self.shapeLayer.path = path
        } else {
            print("Error: Failed to create valid path.")
            return
        }
     
        // Add shape layer below tab items
        if self.shapeLayer.superlayer == nil {
            self.tabBar.layer.insertSublayer(self.shapeLayer, at: 0)
        }
    }
     */
     
    
    
    private func setupCustomTabBar() {
        guard self.tabBar.superview != nil else { return }
        
        self.shapeLayer.sublayers?
           .filter { $0.name == "tabbar_layer_Circle" }.forEach({$0.removeFromSuperlayer()})
        
        self.shapeLayer.name = "tabbar_layer_Circle"
        
        if let path = createPathCircle() {
             self.shapeLayer.path = path
         } else {
             print("Error: Failed to create a valid path for the tab bar.")
             return
         }
        
//        self.shapeLayer.path = self.createPathCircle()
        self.shapeLayer.strokeColor = UIColor.white.cgColor
        self.shapeLayer.fillColor = UIColor.mainBg.withAlphaComponent(1.0).cgColor
        self.shapeLayer.lineWidth = 0.2 //0.5
        self.shapeLayer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.shapeLayer.shadowOffset = CGSize(width: 0, height: -2)
        
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        self.tabBar.layer.borderWidth = 0
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        
        if self.shapeLayer.superlayer == nil {
            self.tabBar.layer.insertSublayer(self.shapeLayer, at: 0)
        }
    }
    
    private func createPathCircle() -> CGPath? {
        guard let items = tabBar.items, let selectedItem = self.tabBar.selectedItem ?? items.first, let index = items.firstIndex(of: selectedItem) else {
            print("Error: No tab bar items available.")
            return UIBezierPath().cgPath
        }
        
        let path = UIBezierPath()
        let tabWidth = self.tabBar.frame.width / CGFloat(items.count)
        let centerX = tabWidth * CGFloat(index) + tabWidth / 2
        let radius: CGFloat = 30.0
        
        // Start drawing the custom path
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: centerX - radius * 2, y: 0))
        path.addArc(
            withCenter: CGPoint(x: centerX, y: 0),
            radius: radius,
            startAngle: CGFloat(180).degreesToRadians,
            endAngle: CGFloat(0).degreesToRadians,
            clockwise: false
        )
        path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: self.tabBar.frame.height + 20))
        path.addLine(to: CGPoint(x: 0, y: self.tabBar.frame.height + 20))
        path.close()
        path.lineWidth = 1.0
        path.stroke()
        path.fill()
        self.shapeLayer.path = path.cgPath
        self.shapeLayer.frame = self.tabBar.bounds
        
        return path.cgPath
    }
    
    
    /*
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        _ = self.createPathCircle()
        DispatchQueue.main.async {
            print("Update layout of tabbar")
            self.setupCustomTabBar()
            self.setupHeightTabbar()
        }
        
        if let geustUser = isForGeustDashboard, geustUser == true , let index = tabBar.items?.firstIndex(of: item) {
            print("Selected tab index: \(index)")
            if index != 0 {
                if appUserDefaults.clearUserDefault() {
                    appSceneDelegate?.goToMainView()
                }
            }
        }
    }
    */
    
    // This method gets called when tab selection changes
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
          let index = tabBarController.selectedIndex
          print("Selected tab index: \(index)")
          DispatchQueue.main.async {
              self.setupCustomTabBar()
              self.setupHeightTabbar()
          }
        
          if let isGuestUser = isForGeustDashboard, isGuestUser, index != 0 {
              if appUserDefaults.clearUserDefault() {
                  appSceneDelegate?.goToMainView()
              }
          }
      }
    
    // Central method for handling tab changes
       func handleTabSelection(index: Int) {
           print("Tab selected: \(index)")
           // Update tab bar appearance
           DispatchQueue.main.async {
               self.setupCustomTabBar()
               self.setupHeightTabbar()
           }
       }

}

extension CGFloat {
    var degreesToRadians: CGFloat {
           return self * .pi / 180
       }
}
