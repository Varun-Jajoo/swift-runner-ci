//
//  CustomViewController.swift
//  MyPT
//
//  Created by techsaga corp on 19/11/24.
//

import UIKit

class CustomViewController: UITabBarController {
    
    //MARK: -----------LINE VIEW
    var lineView = UIView()
    
//    private var shapeLayer = CAShapeLayer()
    
    private var shapeLayer: CALayer?
    
    //MARK: -------------Controllers
    let homeVC:DashboardViewController = DashboardViewController.instantiate(appStoryboard: .dashboard)
    let bookingsVC:BookingsViewController = BookingsViewController.instantiate(appStoryboard: .booking)
    let libraryVC:LibraryViewController = LibraryViewController.instantiate(appStoryboard: .library)
    let calendarVC:CalendarViewController = CalendarViewController.instantiate(appStoryboard: .calendar)
    let moreVC:MoreViewController = MoreViewController.instantiate(appStoryboard: .more)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
       
        self.shadowView()
        setupTabbar()
//        setupCustomTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func shadowView(){
        // Set up the shadow
        if let tabBar = self.tabBarController?.tabBar {
            tabBar.layer.shadowColor = UIColor.black.cgColor
            tabBar.layer.shadowOpacity = 0.2
            tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
            tabBar.layer.shadowRadius = 4

            // Optional: Ensure the shadow displays correctly by disabling the default border
            tabBar.layer.borderColor = UIColor.clear.cgColor
            tabBar.layer.borderWidth = 0
            tabBar.clipsToBounds = false
        }
        
        if #available(iOS 13.0, *) {
               let appearance = UITabBarAppearance()
               appearance.configureWithOpaqueBackground()
               appearance.backgroundColor = .white
               
               // Add shadow
               appearance.shadowColor = UIColor.black
               appearance.shadowImage = UIImage() // Removes the default shadow image
               
               self.tabBarController?.tabBar.standardAppearance = appearance
               
               // For iOS 15+, you may also want to configure `scrollEdgeAppearance`
               if #available(iOS 15.0, *) {
                   self.tabBarController?.tabBar.scrollEdgeAppearance = appearance
               }
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
        homeVC.tabBarItem = homeTabBarItem
        bookingsVC.tabBarItem = bookingsTabBarItem
        libraryVC.tabBarItem = libraryTabBarItem
        calendarVC.tabBarItem = calendarTabBarItem
        moreVC.tabBarItem = moreTabBarItem
        
//        notificationVC.isFromTab = true
//        profileVC.isFromTabProfile = true
//        meshnetVC.isFromTabbar = true
       
        selectedIndex = 0
        let controllers = [homeVC, bookingsVC, libraryVC, calendarVC, moreVC]
        viewControllers = controllers
        viewControllers = controllers.map({UINavigationController(rootViewController: $0)})
        
        tabBar.tintColor = .yellow
        tabBar.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
//        rgba(16, 17, 19, 1)
        
        //----------****************Setup Appearence/Lineview called
        setAppearence()
        
        addShape()
        
//        setupLineView()
        
//        setupCustomTabBar()
        
//        let customTabBar = CustomizedTabBar()
             
             // Set the customized tab bar
//      self.setValue(customTabBar, forKey: "tabBar")
      
    }
    
    //MARK: ------------SETUP APPEARENCE
    func setAppearence(){
        self.tabBar.isTranslucent = true
        
        if #available(iOS 15.0, *) {
                 let appearance = UITabBarAppearance()
                 appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black.withAlphaComponent(0.3) //UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 0.4)
          
                 tabBar.standardAppearance = appearance
                 tabBar.scrollEdgeAppearance = tabBar.standardAppearance
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
        shapeLayer?.frame = tabBar.bounds
        
        DispatchQueue.main.async {
            
            // Update frame if needed
            let tabBarHeight: CGFloat = 150 //100
            self.tabBar.frame = CGRect(
                x: self.tabBar.frame.origin.x,
                y: self.view.frame.height - tabBarHeight,
                width: self.tabBar.frame.width,
                height: tabBarHeight
            )
            
            if let tabBar = self.tabBarController?.tabBar {
                tabBar.layer.shadowColor = UIColor.black.cgColor
                tabBar.layer.shadowOpacity = 0.2
                tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
                tabBar.layer.shadowRadius = 4
                
                // Optional: Ensure the shadow displays correctly by disabling the default border
                tabBar.layer.borderColor = UIColor.red.cgColor
                tabBar.layer.borderWidth = 0
                tabBar.clipsToBounds = false
            }
        }
        
        view.layoutIfNeeded()
        
//        // Update frame if needed
//          let tabBarHeight: CGFloat = 100
//          tabBar.frame = CGRect(
//              x: tabBar.frame.origin.x,
//              y: view.frame.height - tabBarHeight,
//              width: tabBar.frame.width,
//              height: tabBarHeight
//          )
//        
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

    
//    private func setupCustomTabBar() {
//         // Configure the shape layer
//         shapeLayer.path = createPathCircle()
//         shapeLayer.fillColor = UIColor.mainBg.cgColor // Customize the color here
//        shapeLayer.shadowColor = UIColor.black.withAlphaComponent(1.0).cgColor // Reduced opacity for better visual effect
//         shapeLayer.shadowOffset = CGSize(width: 0, height: -2)
//        shapeLayer.strokeColor = UIColor.clear.cgColor
//
//         // Add the shape layer to the tab bar
//         tabBar.layer.insertSublayer(shapeLayer, at: 0)
//
//         // Remove the default tab bar border
//         tabBar.backgroundImage = UIImage()
//         tabBar.shadowImage = UIImage()
//     }
    
    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.mainBg.withAlphaComponent(0.3).cgColor
        shapeLayer.lineWidth = 0.2

        if let oldShapeLayer = self.shapeLayer {
            self.tabBar.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.tabBar.layer.insertSublayer(shapeLayer, at: 0)
        }

        self.shapeLayer = shapeLayer
        
    }
    
    func createPath() -> CGPath {

        let height: CGFloat = 37.0
        let path = UIBezierPath()
        let centerWidth = self.tabBar.frame.width / 2

        path.move(to: CGPoint(x: 0, y: 0)) // start top left
        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0)) // the beginning of the trough

        // first curve down
        path.addCurve(to: CGPoint(x: centerWidth, y: height),
                      controlPoint1: CGPoint(x: (centerWidth - 30), y: 0), controlPoint2: CGPoint(x: centerWidth - 35, y: height))
        // second curve up
        path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
                      controlPoint1: CGPoint(x: centerWidth + 35, y: height), controlPoint2: CGPoint(x: (centerWidth + 30), y: 0))

        // complete the rect
        path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: self.tabBar.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.tabBar.frame.height))
        path.close()

        return path.cgPath
    }
    
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        let buttonRadius: CGFloat = 35
//        return abs(self.center.x - point.x) > buttonRadius || abs(point.y) > buttonRadius
//    }

    func createPathCircle() -> CGPath {

        let radius: CGFloat = 37.0
        let path = UIBezierPath()
        let centerWidth = self.tabBar.frame.width / 2

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: (centerWidth - radius * 2), y: 0))
        path.addArc(withCenter: CGPoint(x: centerWidth, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
        path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: self.tabBar.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.tabBar.frame.height))
        path.close()
        return path.cgPath
    }
    
    
//    private func createPathCircle() -> CGPath {
//        
//        guard let items = tabBar.items, let index = items.firstIndex(of: tabBarItem) else { return  shapeLayer.path ?? UIBezierPath().cgPath}
//        let tabWidth = tabBar.frame.width / CGFloat(items.count)
//        let centerX = tabWidth * CGFloat(index) + tabWidth / 2
//
//        // Update the shape layer's path
//        let radius: CGFloat = 40.0
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: centerX - radius * 2, y: 0))
//        path.addArc(withCenter: CGPoint(x: centerX, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
//        path.addLine(to: CGPoint(x: tabBar.frame.width, y: 0))
//        path.addLine(to: CGPoint(x: tabBar.frame.width, y: tabBar.frame.height))
//        path.addLine(to: CGPoint(x: 0, y: tabBar.frame.height))
//        path.close()
//        shapeLayer.path = path.cgPath
//        
//        return path.cgPath
//        
//    }
    
    
//    private func createPathCircle() -> CGPath {
//            let radius: CGFloat = 40.0
//            let path = UIBezierPath()
//            let centerWidth = tabBar.frame.width / 2
//
//            path.move(to: CGPoint(x: 0, y: 0))
//            path.addLine(to: CGPoint(x: (centerWidth - radius * 2), y: 0))
//            path.addArc(withCenter: CGPoint(x: centerWidth, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
//            path.addLine(to: CGPoint(x: tabBar.frame.width, y: 0))
//            path.addLine(to: CGPoint(x: tabBar.frame.width, y: tabBar.frame.height))
//            path.addLine(to: CGPoint(x: 0, y: tabBar.frame.height))
//            path.close()
//            return path.cgPath
//        }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
//        if let items = tabBarController?.tabBar.items {
        
//        if let items = tabBar.items {
//            for (index, item) in items.enumerated() {
//                if index == selectedIndex {
//                    item.imageInsets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10) // Adjust for selected
//
//                } else {
//                    item.imageInsets = .zero // Reset for unselected
//                }
//            }
//        }
        
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
        path.addLine(to: CGPoint(x: 0, y: tabBar.frame.height))
        path.close()
//        shapeLayer?.path = path.cgPath
    }

    
    


}


class CustomizedTabBar: UITabBar {

    private var shapeLayer: CALayer?

//    private func addShape() {
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = createPath()
//        shapeLayer.strokeColor = UIColor.clear.cgColor
//        shapeLayer.fillColor = UIColor.mainBg.cgColor
//        shapeLayer.lineWidth = 1.0
//
//        if let oldShapeLayer = self.shapeLayer {
//            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
//        } else {
//            self.layer.insertSublayer(shapeLayer, at: 0)
//        }
//
//        self.shapeLayer = shapeLayer
//    }

    override func draw(_ rect: CGRect) {
//        self.addShape()
    }

//    func createPath() -> CGPath {
//
//        let height: CGFloat = 37.0
//        let path = UIBezierPath()
//        let centerWidth = self.frame.width / 2
//
//        path.move(to: CGPoint(x: 0, y: 0)) // start top left
//        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0)) // the beginning of the trough
//
//        // first curve down
//        path.addCurve(to: CGPoint(x: centerWidth, y: height),
//                      controlPoint1: CGPoint(x: (centerWidth - 30), y: 0), controlPoint2: CGPoint(x: centerWidth - 35, y: height))
//        // second curve up
//        path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
//                      controlPoint1: CGPoint(x: centerWidth + 35, y: height), controlPoint2: CGPoint(x: (centerWidth + 30), y: 0))
//
//        // complete the rect
//        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
//        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
//        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
//        path.close()
//
//        return path.cgPath
//    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let buttonRadius: CGFloat = 35
        return abs(self.center.x - point.x) > buttonRadius || abs(point.y) > buttonRadius
    }

    func createPathCircle() -> CGPath {

        let radius: CGFloat = 37.0
        let path = UIBezierPath()
        let centerWidth = self.frame.width / 2

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: (centerWidth - radius * 2), y: 0))
        path.addArc(withCenter: CGPoint(x: centerWidth, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()
        return path.cgPath
    }
}

extension CGFloat {
//    var degreesToRadians: CGFloat { return self * .pi / 180 }
    var radiansToDegrees: CGFloat { return self * 180 / .pi }
}
