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


class CustomTabViewController: UITabBarController {

    //MARK: -----------LINE VIEW
    var lineView = UIView()
    var isForGeustDashboard:Bool?
    var num: Int = 1
    
    private var shapeLayer = CAShapeLayer()
    
    //MARK: -------------Controllers
//    let homeVC:DashboardViewController = DashboardViewController.instantiate(appStoryboard: .dashboard)
//    
    let homeGeustuserVC:DashboardGuestViewController = DashboardGuestViewController.instantiate(appStoryboard: .dashboard)
    
//    let homeGeustuserVC:DashboardViewController = DashboardViewController.instantiate(appStoryboard: .dashboard) //only for testing
    
//    let bookingsVC:BookingsViewController = BookingsViewController.instantiate(appStoryboard: .booking)
    let bookingsVC:BookingListViewController = BookingListViewController.instantiate(appStoryboard: .booking)
    let libraryVC:LibraryViewController = LibraryViewController.instantiate(appStoryboard: .library)
    let calendarVC:CalendarViewController = CalendarViewController.instantiate(appStoryboard: .calendar)
    let moreVC:MoreViewController = MoreViewController.instantiate(appStoryboard: .more)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
       
        setupTabbar()
//        setupCustomTabBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.layoutIfNeeded()
//        setupTabbar()
        DispatchQueue.main.async {
            self.setupHeightTabbar()
            self.setupCustomTabBar()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
             self.setupHeightTabbar()
             self.setupCustomTabBar()
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
        
//        homeVC.tabBarItem = homeTabBarItem
        
//        homeGeustuserVC.tabBarItem = homeTabBarItem

                
        homeGeustuserVC.tabBarItem = homeTabBarItem
        bookingsVC.tabBarItem = bookingsTabBarItem
        libraryVC.tabBarItem = libraryTabBarItem
        calendarVC.tabBarItem = calendarTabBarItem
        moreVC.tabBarItem = moreTabBarItem
        
//        notificationVC.isFromTab = true
//        profileVC.isFromTabProfile = true
//        meshnetVC.isFromTabbar = true
        
//        guard let homeVC = homeVC?.viewController() else { return }
       
        selectedIndex = 0
//        let controllers = [homeVC, bookingsVC, libraryVC, calendarVC, moreVC]
        let controllers = [homeGeustuserVC, bookingsVC, libraryVC, calendarVC, moreVC]
        
//        if let geustDashboard =  isForGeustDashboard, geustDashboard {
//            homeGeustuserVC.tabBarItem = homeTabBarItem
//            controllers = [homeGeustuserVC, bookingsVC, libraryVC, calendarVC, moreVC]
//        }else{
//            homeVC.tabBarItem = homeTabBarItem
//            controllers = [homeVC, bookingsVC, libraryVC, calendarVC, moreVC]
//        }
        
        
        viewControllers = controllers
        viewControllers = controllers.map({UINavigationController(rootViewController: $0)})
        
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
        self.setupHeightTabbar()
        self.setupCustomTabBar()
    }

    private func setupHeightTabbar() {
        self.tabBar.backgroundColor = UIColor.mainBg.withAlphaComponent(1.0)
        self.tabBar.isTranslucent = false
        
        var getFrame: CGRect = self.tabBar.frame
        getFrame.origin.y -= 15
        getFrame.size.height += 15
        self.tabBar.frame = getFrame
           
        if let items = self.tabBar.items {
            for (index, item) in items.enumerated() {
                item.imageInsets = (index == self.selectedIndex) ?
                    UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0) :
                    .zero
            }
        }
        
        self.tabBar.frame = getFrame
    }

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
        let radius: CGFloat = 40.0
        
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

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        _ = self.createPathCircle()
    }
    
}


/*
class CustomTabViewController: UITabBarController {

    
    //MARK: -----------LINE VIEW
    var lineView = UIView()
    var isForGeustDashboard:Bool?
    
    private var shapeLayer = CAShapeLayer()
    
   private var setShapeLayer:CAShapeLayer? = nil  {
        didSet{
            DispatchQueue.main.async {
                if let setShapeLayer = self.setShapeLayer {
                    self.shapeLayer = setShapeLayer
                    self.shapeLayer.frame = self.tabBar.bounds
                   
                    self.setupCustomTabBar()
                }
            }
        }
    }
    
    //MARK: -------------Controllers
    let homeVC:DashboardViewController = DashboardViewController.instantiate(appStoryboard: .dashboard)
    let homeGeustuserVC:DashboardGuestViewController = DashboardGuestViewController.instantiate(appStoryboard: .dashboard)
    
//    let bookingsVC:BookingsViewController = BookingsViewController.instantiate(appStoryboard: .booking)
    let bookingsVC:BookingListViewController = BookingListViewController.instantiate(appStoryboard: .booking)
    let libraryVC:LibraryViewController = LibraryViewController.instantiate(appStoryboard: .library)
    let calendarVC:CalendarViewController = CalendarViewController.instantiate(appStoryboard: .calendar)
    let moreVC:MoreViewController = MoreViewController.instantiate(appStoryboard: .more)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
       
        setupTabbar()
//        setupCustomTabBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.layoutIfNeeded()
//        setupTabbar()
        
        self.tabBar.frame = CGRect(
            x: self.tabBar.frame.origin.x,
            y: self.tabBar.frame.origin.y - 15,
            width: self.tabBar.frame.width,
            height: self.tabBar.frame.height + 15
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
 
    //MARK: --------SET TABBAR
    func setupTabbar() {
        
        let homeTabBarItem = UITabBarItem(title: AppStrings.homeStr, image: AppImages.home, selectedImage: AppImages.homeSelected)
        
        let bookingsTabBarItem = UITabBarItem(title: AppStrings.bookingStr, image: AppImages.bookings, selectedImage: AppImages.bookingSelected)
        
        let libraryTabBarItem = UITabBarItem(title: AppStrings.libraryStr, image: AppImages.Library, selectedImage: AppImages.LibrarySelected)
        
        let calendarTabBarItem = UITabBarItem(title: AppStrings.calendarStr, image: AppImages.calendar, selectedImage: AppImages.calendarSelected)
        let moreTabBarItem = UITabBarItem(title: AppStrings.moreStr, image: AppImages.more, selectedImage: AppImages.moreSelected)
        
        //-------------******************** Add view controllers and tab bar items
        
//        homeVC.tabBarItem = homeTabBarItem
        
        homeGeustuserVC.tabBarItem = homeTabBarItem
        bookingsVC.tabBarItem = bookingsTabBarItem
        libraryVC.tabBarItem = libraryTabBarItem
        calendarVC.tabBarItem = calendarTabBarItem
        moreVC.tabBarItem = moreTabBarItem
        
//        notificationVC.isFromTab = true
//        profileVC.isFromTabProfile = true
//        meshnetVC.isFromTabbar = true
       
        selectedIndex = 0
//        let controllers = [homeVC, bookingsVC, libraryVC, calendarVC, moreVC]
        let controllers = [homeGeustuserVC, bookingsVC, libraryVC, calendarVC, moreVC]
        
//        if let geustDashboard =  isForGeustDashboard, geustDashboard {
//            homeGeustuserVC.tabBarItem = homeTabBarItem
//            controllers = [homeGeustuserVC, bookingsVC, libraryVC, calendarVC, moreVC]
//        }else{
//            homeVC.tabBarItem = homeTabBarItem
//            controllers = [homeVC, bookingsVC, libraryVC, calendarVC, moreVC]
//        }
        
        
        viewControllers = controllers
        viewControllers = controllers.map({UINavigationController(rootViewController: $0)})
        
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
        //rgba(189, 189, 189, 1)
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
    
    //MARK: --------------- Setup Lineview
    func setupLineView() {
        lineView.removeFromSuperview()
        lineView.backgroundColor = UIColor.green
        lineView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(lineView)
        
       
        
        let height: CGFloat = 30
        NSLayoutConstraint.activate([
            lineView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            lineView.heightAnchor.constraint(equalToConstant: height),
            lineView.widthAnchor.constraint(equalTo: tabBar.widthAnchor, multiplier: 1.0 / CGFloat(tabBar.items?.count ?? 1)),
            lineView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor)
        ])
    }
    
    func updateLineViewPosition(animated: Bool) {
        guard let selectedItem = tabBar.selectedItem else { return }
        let index = CGFloat(tabBar.items?.firstIndex(of: selectedItem) ?? 0)
        let itemWidth = tabBar.frame.width / CGFloat(tabBar.items?.count ?? 1)
        
        let newLeadingConstant = itemWidth * index
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.lineView.frame.origin.x = newLeadingConstant
        }
    }
    
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        updateLineViewPosition(animated: true)
//    }

    
    //-------------------**********
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        shapeLayer.frame = tabBar.bounds
        
        shapeLayer.name = "tabbarLayer"
        setShapeLayer?.name = "setShapeLayer"
//        DispatchQueue.main.async {
            // Update frame if needed
            self.tabBar.frame = CGRect(
                x: self.tabBar.frame.origin.x,
                y: self.tabBar.frame.origin.y - 15,
                width: self.tabBar.frame.width,
                height: self.tabBar.frame.height + 15
            )
            
            //----------**********
            if let items = self.tabBar.items {
                for (index, item) in items.enumerated() {
                    if index == self.selectedIndex {
                        item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0) // Adjust for selected
                        
                    } else {
                        item.imageInsets = .zero // Reset for unselected
                    }
                }
            }
            
//            self.looadPathCircle()
            
            self.tabBar.backgroundColor = UIColor.clear
            
            self.tabBar.isTranslucent = false
            
            
            self.shapeLayer.frame = self.tabBar.bounds
            self.setShapeLayer?.frame = self.tabBar.bounds
            
            self.setupCustomTabBar()
        
            
//        }
        
        //    y: view.frame.height - tabBarHeight,
        
        //        if let tabBar = self.tabBarController?.tabBar {
        //            tabBar.layer.shadowColor = UIColor.black.cgColor
        //            tabBar.layer.shadowOpacity = 0.2
        //            tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        //            tabBar.layer.shadowRadius = 4
        //
        //            // Optional: Ensure the shadow displays correctly by disabling the default border
        //            tabBar.layer.borderColor = UIColor.red.cgColor
        //            tabBar.layer.borderWidth = 0
        //            tabBar.clipsToBounds = false
        //        }
    }

//    private func setupHeightTabbar(){
//        DispatchQueue.main.async {
//            self.tabBar.frame = CGRect(
//                x: self.tabBar.frame.origin.x,
//                y: self.tabBar.frame.origin.y - 15,
//                width: self.tabBar.frame.width,
//                height: self.tabBar.frame.height + 15
//            )
//        }
//    }
    
    private func setupCustomTabBar() {
        DispatchQueue.main.async {
            
            // Configure the shape layer
            self.shapeLayer.path = self.createPathCircle()
            self.shapeLayer.strokeColor = UIColor.white.cgColor
            self.shapeLayer.fillColor = UIColor.mainBg.withAlphaComponent(1.0).cgColor
            self.shapeLayer.lineWidth = 0.2
            self.shapeLayer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor // Reduced opacity for better visual effect
            self.shapeLayer.shadowOffset = CGSize(width: 0, height: -2)
            
            // Add the shape layer to the tab bar
            self.tabBar.layer.insertSublayer(self.shapeLayer, at: 0)
            
            // Remove the default tab bar border
            self.tabBar.backgroundImage = UIImage()
            self.tabBar.shadowImage = UIImage()
        }
    }
    
    private func createPathCircle() -> CGPath {
        
        guard let items = tabBar.items, let index = items.firstIndex(of: tabBarItem) else { return  shapeLayer.path ?? UIBezierPath().cgPath}
        
        let path = UIBezierPath()
        
        DispatchQueue.main.async {
            let tabWidth = self.tabBar.frame.width / CGFloat(items.count)
            let centerX = tabWidth * CGFloat(index) + tabWidth / 2
            
            // Update the shape layer's path
            let radius: CGFloat = 40.0
//            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: centerX - radius * 2, y: 0))
            path.addArc(withCenter: CGPoint(x: centerX, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
            path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: 0))
            path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: self.tabBar.frame.height+20))
            path.addLine(to: CGPoint(x: 0, y: self.tabBar.frame.height+20))
            path.close()
            self.shapeLayer.path = path.cgPath
            self.setShapeLayer?.path = path.cgPath
        }
        
            return path.cgPath
       
    }
    
    
    private func looadPathCircle()  {
        guard let items = tabBar.items else { return }
        
        DispatchQueue.main.async {
            
            let tabWidth = self.tabBar.frame.width / CGFloat(items.count)
            let centerX = tabWidth * CGFloat(self.selectedIndex) + tabWidth / 2
            
            // Update the shape layer's path
            let radius: CGFloat = 40.0
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: centerX - radius * 2, y: 0))
            path.addArc(withCenter: CGPoint(x: centerX, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
            path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: 0))
            path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: self.tabBar.frame.height))
            path.addLine(to: CGPoint(x: 0, y: self.tabBar.frame.height ))
            path.close()
            self.shapeLayer.path = path.cgPath
//            self.setShapeLayer?.path = path.cgPath
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        self.looadPathCircle()
        
        /*
        guard let items = tabBar.items, let index = items.firstIndex(of: item) else { return }
        let tabWidth = tabBar.frame.width / CGFloat(items.count)
        let centerX = tabWidth * CGFloat(index) + tabWidth / 2

        // Update the shape layer's path
        let radius: CGFloat = 40.0
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: centerX - radius * 2, y: 0))
        path.addArc(withCenter: CGPoint(x: centerX, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
        path.addLine(to: CGPoint(x: tabBar.frame.width, y: 0))
        path.addLine(to: CGPoint(x: tabBar.frame.width, y: tabBar.frame.height))
        path.addLine(to: CGPoint(x: 0, y: tabBar.frame.height ))
        path.close()
        shapeLayer.path = path.cgPath
        self.setShapeLayer?.path = path.cgPath
        
        */
    }
}

*/



/*
class CustomTabViewController: UITabBarController {

    
    //MARK: -----------LINE VIEW
    var lineView = UIView()
    var isForGeustDashboard:Bool?
    
    private var shapeLayer = CAShapeLayer()
    
   private var setShapeLayer:CAShapeLayer? = nil  {
        didSet{
            DispatchQueue.main.async {
                if let setShapeLayer = self.setShapeLayer {
                    self.shapeLayer = setShapeLayer
                    self.shapeLayer.frame = self.tabBar.bounds
                   
                    self.setupCustomTabBar()
                }
            }
        }
    }
    
    //MARK: -------------Controllers
    let homeVC:DashboardViewController = DashboardViewController.instantiate(appStoryboard: .dashboard)
    let homeGeustuserVC:DashboardGuestViewController = DashboardGuestViewController.instantiate(appStoryboard: .dashboard)
    
//    let bookingsVC:BookingsViewController = BookingsViewController.instantiate(appStoryboard: .booking)
    let bookingsVC:BookingListViewController = BookingListViewController.instantiate(appStoryboard: .booking)
    let libraryVC:LibraryViewController = LibraryViewController.instantiate(appStoryboard: .library)
    let calendarVC:CalendarViewController = CalendarViewController.instantiate(appStoryboard: .calendar)
    let moreVC:MoreViewController = MoreViewController.instantiate(appStoryboard: .more)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
       
        setupTabbar()
//        setupCustomTabBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.layoutIfNeeded()
//        setupTabbar()
        
        self.tabBar.frame = CGRect(
            x: self.tabBar.frame.origin.x,
            y: self.tabBar.frame.origin.y - 15,
            width: self.tabBar.frame.width,
            height: self.tabBar.frame.height + 15
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
 
    //MARK: --------SET TABBAR
    func setupTabbar() {
        
        let homeTabBarItem = UITabBarItem(title: AppStrings.homeStr, image: AppImages.home, selectedImage: AppImages.homeSelected)
        
        let bookingsTabBarItem = UITabBarItem(title: AppStrings.bookingStr, image: AppImages.bookings, selectedImage: AppImages.bookingSelected)
        
        let libraryTabBarItem = UITabBarItem(title: AppStrings.libraryStr, image: AppImages.Library, selectedImage: AppImages.LibrarySelected)
        
        let calendarTabBarItem = UITabBarItem(title: AppStrings.calendarStr, image: AppImages.calendar, selectedImage: AppImages.calendarSelected)
        let moreTabBarItem = UITabBarItem(title: AppStrings.moreStr, image: AppImages.more, selectedImage: AppImages.moreSelected)
        
        //-------------******************** Add view controllers and tab bar items
        
//        homeVC.tabBarItem = homeTabBarItem
        
        homeGeustuserVC.tabBarItem = homeTabBarItem
        bookingsVC.tabBarItem = bookingsTabBarItem
        libraryVC.tabBarItem = libraryTabBarItem
        calendarVC.tabBarItem = calendarTabBarItem
        moreVC.tabBarItem = moreTabBarItem
        
//        notificationVC.isFromTab = true
//        profileVC.isFromTabProfile = true
//        meshnetVC.isFromTabbar = true
       
        selectedIndex = 0
//        let controllers = [homeVC, bookingsVC, libraryVC, calendarVC, moreVC]
        let controllers = [homeGeustuserVC, bookingsVC, libraryVC, calendarVC, moreVC]
        
//        if let geustDashboard =  isForGeustDashboard, geustDashboard {
//            homeGeustuserVC.tabBarItem = homeTabBarItem
//            controllers = [homeGeustuserVC, bookingsVC, libraryVC, calendarVC, moreVC]
//        }else{
//            homeVC.tabBarItem = homeTabBarItem
//            controllers = [homeVC, bookingsVC, libraryVC, calendarVC, moreVC]
//        }
        
        
        viewControllers = controllers
        viewControllers = controllers.map({UINavigationController(rootViewController: $0)})
        
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
        //rgba(189, 189, 189, 1)
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
    
    //MARK: --------------- Setup Lineview
    func setupLineView() {
        lineView.removeFromSuperview()
        lineView.backgroundColor = UIColor.green
        lineView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(lineView)
        
       
        
        let height: CGFloat = 30
        NSLayoutConstraint.activate([
            lineView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            lineView.heightAnchor.constraint(equalToConstant: height),
            lineView.widthAnchor.constraint(equalTo: tabBar.widthAnchor, multiplier: 1.0 / CGFloat(tabBar.items?.count ?? 1)),
            lineView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor)
        ])
    }
    
    func updateLineViewPosition(animated: Bool) {
        guard let selectedItem = tabBar.selectedItem else { return }
        let index = CGFloat(tabBar.items?.firstIndex(of: selectedItem) ?? 0)
        let itemWidth = tabBar.frame.width / CGFloat(tabBar.items?.count ?? 1)
        
        let newLeadingConstant = itemWidth * index
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.lineView.frame.origin.x = newLeadingConstant
        }
    }
    
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        updateLineViewPosition(animated: true)
//    }

    
    //-------------------**********
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        shapeLayer.frame = tabBar.bounds
        
        shapeLayer.name = "tabbarLayer"
        setShapeLayer?.name = "setShapeLayer"
//        DispatchQueue.main.async {
            // Update frame if needed
            self.tabBar.frame = CGRect(
                x: self.tabBar.frame.origin.x,
                y: self.tabBar.frame.origin.y - 15,
                width: self.tabBar.frame.width,
                height: self.tabBar.frame.height + 15
            )
            
            //----------**********
            if let items = self.tabBar.items {
                for (index, item) in items.enumerated() {
                    if index == self.selectedIndex {
                        item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0) // Adjust for selected
                        
                    } else {
                        item.imageInsets = .zero // Reset for unselected
                    }
                }
            }
            
            self.looadPathCircle()
            
            self.tabBar.backgroundColor = UIColor.clear
            
            self.tabBar.isTranslucent = false
            
            
            self.shapeLayer.frame = self.tabBar.bounds
            self.setShapeLayer?.frame = self.tabBar.bounds
            
            self.setupCustomTabBar()
        
            
//        }
        
        //    y: view.frame.height - tabBarHeight,
        
        //        if let tabBar = self.tabBarController?.tabBar {
        //            tabBar.layer.shadowColor = UIColor.black.cgColor
        //            tabBar.layer.shadowOpacity = 0.2
        //            tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        //            tabBar.layer.shadowRadius = 4
        //
        //            // Optional: Ensure the shadow displays correctly by disabling the default border
        //            tabBar.layer.borderColor = UIColor.red.cgColor
        //            tabBar.layer.borderWidth = 0
        //            tabBar.clipsToBounds = false
        //        }
    }

//    private func setupHeightTabbar(){
//        DispatchQueue.main.async {
//            self.tabBar.frame = CGRect(
//                x: self.tabBar.frame.origin.x,
//                y: self.tabBar.frame.origin.y - 15,
//                width: self.tabBar.frame.width,
//                height: self.tabBar.frame.height + 15
//            )
//        }
//    }
    
    private func setupCustomTabBar() {
        DispatchQueue.main.async {
            
            // Configure the shape layer
            self.shapeLayer.path = self.createPathCircle()
            self.shapeLayer.strokeColor = UIColor.white.cgColor
            self.shapeLayer.fillColor = UIColor.mainBg.withAlphaComponent(1.0).cgColor
            self.shapeLayer.lineWidth = 0.2
            self.shapeLayer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor // Reduced opacity for better visual effect
            self.shapeLayer.shadowOffset = CGSize(width: 0, height: -2)
            
            // Add the shape layer to the tab bar
            self.tabBar.layer.insertSublayer(self.shapeLayer, at: 0)
            
            // Remove the default tab bar border
            self.tabBar.backgroundImage = UIImage()
            self.tabBar.shadowImage = UIImage()
        }
    }
    
    private func createPathCircle() -> CGPath {
        
        guard let items = tabBar.items, let index = items.firstIndex(of: tabBarItem) else { return  shapeLayer.path ?? UIBezierPath().cgPath}
        
        let path = UIBezierPath()
        
        DispatchQueue.main.async {
            let tabWidth = self.tabBar.frame.width / CGFloat(items.count)
            let centerX = tabWidth * CGFloat(index) + tabWidth / 2
            
            // Update the shape layer's path
            let radius: CGFloat = 40.0
//            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: centerX - radius * 2, y: 0))
            path.addArc(withCenter: CGPoint(x: centerX, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
            path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: 0))
            path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: self.tabBar.frame.height+20))
            path.addLine(to: CGPoint(x: 0, y: self.tabBar.frame.height+20))
            path.close()
            self.shapeLayer.path = path.cgPath
            self.setShapeLayer?.path = path.cgPath
        }
        
            return path.cgPath
       
    }
    
    
    private func looadPathCircle()  {
        guard let items = tabBar.items else { return }
        
        DispatchQueue.main.async {
            
            let tabWidth = self.tabBar.frame.width / CGFloat(items.count)
            let centerX = tabWidth * CGFloat(self.selectedIndex) + tabWidth / 2
            
            // Update the shape layer's path
            let radius: CGFloat = 40.0
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: centerX - radius * 2, y: 0))
            path.addArc(withCenter: CGPoint(x: centerX, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
            path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: 0))
            path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: self.tabBar.frame.height))
            path.addLine(to: CGPoint(x: 0, y: self.tabBar.frame.height ))
            path.close()
            self.shapeLayer.path = path.cgPath
            self.setShapeLayer?.path = path.cgPath
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        guard let items = tabBar.items, let index = items.firstIndex(of: item) else { return }
        let tabWidth = tabBar.frame.width / CGFloat(items.count)
        let centerX = tabWidth * CGFloat(index) + tabWidth / 2

        // Update the shape layer's path
        let radius: CGFloat = 40.0
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: centerX - radius * 2, y: 0))
        path.addArc(withCenter: CGPoint(x: centerX, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
        path.addLine(to: CGPoint(x: tabBar.frame.width, y: 0))
        path.addLine(to: CGPoint(x: tabBar.frame.width, y: tabBar.frame.height))
        path.addLine(to: CGPoint(x: 0, y: tabBar.frame.height ))
        path.close()
        shapeLayer.path = path.cgPath
        self.setShapeLayer?.path = path.cgPath
    }
}
*/

extension CGFloat {
    var degreesToRadians: CGFloat {
           return self * .pi / 180
       }
}


