//
//  CustomTabViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/11/24.
//

import UIKit

enum HomeType {
    case guest
    case activePackage
}

enum vcDashboard: Int {
    case dashboardGuest = 1
    case dashboard
    
    func viewController() -> UIViewController {
        switch self {
        case .dashboardGuest:
            return HomepageVC.instantiate(appStoryboard: .homepage)
//            return DashboardGuestViewController.instantiate(appStoryboard: .dashboard)
        case .dashboard:
//            return HomepageVC.instantiate(appStoryboard: .homepage)
            return ActiveHomepageVCViewController.instantiate(appStoryboard: .homepage)
//            return DashboardViewController.instantiate(appStoryboard: .dashboard)
        }
    }
}


final class CustomTabViewController: UITabBarController, UITabBarControllerDelegate {

    //MARK: -----------LINE VIEW
//    private var didSetupTabBar = false
//    var lineView = UIView()
//    var num: Int = 1
//    private var shapeLayer = CAShapeLayer()
    private let customTabBar = CustomTabBar()
    var isForGeustDashboard:Bool?
    
    //MARK: -------------Controllers
//    let homeVC: HomepageVC = HomepageVC.instantiate(appStoryboard: .homepage)
   let homeVC:ActiveHomepageVCViewController = ActiveHomepageVCViewController.instantiate(appStoryboard: .homepage)
//    let homeVC:DashboardViewController = DashboardViewController.instantiate(appStoryboard: .dashboard)
    let homeGeustuserVC: ActiveHomepageVCViewController = ActiveHomepageVCViewController.instantiate(appStoryboard: .homepage)
//    let homeGeustuserVC:DashboardGuestViewController = DashboardGuestViewController.instantiate(appStoryboard: .dashboard)
    let bookingsVC:BookingListViewController = BookingListViewController.instantiate(appStoryboard: .booking)
    let libraryVC:LibraryViewController = LibraryViewController.instantiate(appStoryboard: .library)
    let calendarVC:CalendarViewController = CalendarViewController.instantiate(appStoryboard: .calendar)
    let moreVC:MoreViewController = MoreViewController.instantiate(appStoryboard: .more)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        setValue(customTabBar, forKey: "tabBar")

//        setupTabbar(homeType: <#HomeType#>)
        setupAppearance()
        if !(isForGeustDashboard ?? false) {
            checkPackageAndLoadTabs()
        } else {
            setupTabbar(homeType: .guest)
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadTabFlow),
            name: NSNotification.Name("reloadTab"),
            object: nil
        )
    }
    
    override var selectedIndex: Int {
        didSet {
            customTabBar.updateIndicatorPosition(index: selectedIndex)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customTabBar.updateIndicatorPosition(index: selectedIndex)
    }
    
    private func checkPackageAndLoadTabs() {

        CreatePackageVM.checkPackageCreatedApi(viewController: self, inputParms: [:]) { [weak self] result in
            guard let self = self,
                  let data = result?["data"] as? [String:Any] else {
                self?.setupTabbar(homeType: .guest)
                return
            }

            // guest logic
            let isActiveUser = (data["isActive"] as? Bool ?? false)
            self.setupTabbar(homeType: isActiveUser ? .activePackage : .guest)
        }
    }

    // MARK: Setup Tabs
    private func setupTabbar(homeType: HomeType) {

        let homeController: UIViewController

//        if isForGeustDashboard == true {
//            homeController = HomepageVC.instantiate(appStoryboard: .homepage)
//        } else {
            switch homeType {
            case .guest:
                homeController = HomepageVC.instantiate(appStoryboard: .homepage)

            case .activePackage:
                homeController = ActiveHomepageVCViewController.instantiate(appStoryboard: .homepage)
            }
//        }

        // Tab Items
        homeController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "ic_home")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "homeSelected")?.withRenderingMode(.alwaysOriginal)
        )

        libraryVC.tabBarItem = UITabBarItem(
            title: "Plans",
            image: UIImage(named: "ic_bookings")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "planSelected")?.withRenderingMode(.alwaysOriginal)
        )

        bookingsVC.tabBarItem = UITabBarItem(
            title: "Bookings",
            image: UIImage(named: "ic_calendar")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "bookingSelected")?.withRenderingMode(.alwaysOriginal)
        )

        moreVC.tabBarItem = UITabBarItem(
            title: "Menu",
            image: UIImage(named: "ic_more")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "menuSelected")?.withRenderingMode(.alwaysOriginal)
        )

        viewControllers = [
            UINavigationController(rootViewController: homeController),
            UINavigationController(rootViewController: libraryVC),
            UINavigationController(rootViewController: bookingsVC),
            UINavigationController(rootViewController: moreVC)
        ]

        selectedIndex = 0
        DispatchQueue.main.async {
            self.customTabBar.updateIndicatorPosition(index: self.selectedIndex)
        }
    }

    // MARK: Appearanceprivate
    func setupAppearance() {
        
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // 🔥 REMOVE system blur & background
        appearance.backgroundEffect = nil
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        
        let itemAppearance = appearance.stackedLayoutAppearance
        
        // Text style
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 0.55),
            .font: AppFont.regular.size(12.0, familyName: familyFunnelSans)
        ]
        
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0),
            .font: AppFont.regular.size(12.0, familyName: familyFunnelSans)
        ]
        
        // spacing
        itemAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -6)
        itemAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -6)
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        // extra safety (UIKit sometimes re-adds blur)
        tabBar.isTranslucent = true
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
    }

    // MARK: Tab Selection
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        customTabBar.updateIndicatorPosition(index: selectedIndex)

        if let isGuest = isForGeustDashboard,
           isGuest,
           selectedIndex != 0 {
//            if appUserDefaults.clearUserDefault() {
//                appSceneDelegate?.goToMainView()
//            }
        } else {
            
        }
    }

    // MARK: Reload
    @objc private func reloadTabFlow(_ notification: Notification) {
        if let shouldReload = notification.object as? Bool {
            isForGeustDashboard = shouldReload
            checkPackageAndLoadTabs() // 🔥 important
        }
    }
}

final class CustomTabBar: UITabBar {

    private let bgImageView = UIImageView()
    private let indicatorDot = UIView()
    private let verticalOffset: CGFloat = 5   // change -5, -10, -15 for more top space

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = super.sizeThatFits(size)

        let safeBottom = window?.safeAreaInsets.bottom ?? 0
        newSize.height = 65 + safeBottom   // ← adjust 70 → 75 → 80 as needed
    
        return newSize
    }

    private func setupUI() {
        backgroundImage = UIImage()
        shadowImage = UIImage()
        backgroundColor = .clear
        isTranslucent = true
        
        bgImageView.backgroundColor = .clear
        bgImageView.image = UIImage(named: "bottomTabBar")
        bgImageView.contentMode = .scaleToFill
        addSubview(bgImageView)
        sendSubviewToBack(bgImageView)

        indicatorDot.backgroundColor = UIColor(red: 224/255, green: 254/255, blue: 8/255, alpha: 1)
        indicatorDot.layer.cornerRadius = 3
        indicatorDot.frame.size = CGSize(width: 6, height: 6)
        addSubview(indicatorDot)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        bgImageView.frame = bounds

        // Move tab bar buttons upward
        let tabButtons = subviews
            .filter { String(describing: type(of: $0)) == "UITabBarButton" }

        for button in tabButtons {
            var frame = button.frame
            frame.origin.y += verticalOffset
            button.frame = frame
        }

        updateIndicatorPosition()
    }

    func updateIndicatorPosition(index: Int? = nil) {

        guard let items = items,
              let selectedItem = selectedItem,
              let selectedIndex = items.firstIndex(of: selectedItem)
        else { return }

        let indexToUse = index ?? selectedIndex

        // Get tab bar buttons
        let tabButtons = subviews
            .filter { String(describing: type(of: $0)) == "UITabBarButton" }
            .sorted { $0.frame.minX < $1.frame.minX }

        guard indexToUse < tabButtons.count else { return }

        let selectedButton = tabButtons[indexToUse]

        // Find title label inside selected button
        if let titleLabel = selectedButton.subviews.first(where: { $0 is UILabel }) {

            let labelFrame = titleLabel.convert(titleLabel.bounds, to: self)

            // Dot just left of title
            indicatorDot.center = CGPoint(
                x: labelFrame.minX - 8,
                y: labelFrame.midY
            )
        }
    }
}

extension CGFloat {
    var degreesToRadians: CGFloat {
           return self * .pi / 180
       }
}
