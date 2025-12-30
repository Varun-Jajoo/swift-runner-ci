//
//  MoreViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/11/24.
//

import UIKit
import FacebookLogin

class MoreViewController: UIViewController {
    
    //MARK: --------------VARIABLE
//    var sectionData:[String]?
    var moreSectionData:[HydrationModel]?
    var getLat:Double?
    var getLong:Double?
    

    //MARK: ----------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var exploreCollView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first,  let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
            self.getLat = Double(lat)
            self.getLong = Double(long)
        }else{
            self.getLocation()
        }

        
//        // Configure the collection view layout
//        DispatchQueue.main.async {
//            let layout = UICollectionViewFlowLayout()
//            layout.headerReferenceSize = CGSize(width: self.exploreCollView.frame.size.width-20, height: 50) // Set header size
//            self.exploreCollView.collectionViewLayout = layout
//        }
      
        
//        sectionData = [
//            "Fitness & Progress",
//            "My Network",
//            "Account Management",
//            "Support",
//            "E-commerce"
//        ]
        
        
        //---------------------*******************
        exploreCollView.register(UINib(nibName: "MoreExploreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MoreExploreCollectionViewCell")
        
        exploreCollView.register(CustomHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomHeaderView.identifier)
        exploreCollView.register(MoreLogoutCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: "MoreLogoutCollectionReusableView")
        
        self.setupInputData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first,  let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
            self.getLat = Double(lat)
            self.getLong = Double(long)
        }else{
            self.getLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: -------------GET Lat long
    private func getLocation(){
        GetLocationManager.shared.requestLocation(completion: { [weak self] getLocation in
            guard let self = self, let getLocation = getLocation else { return  }

            self.getLat = getLocation.coordinate.latitude
            self.getLong = getLocation.coordinate.longitude
        })
    }
    
    func setupInputData(){
        self.moreSectionData = [
            HydrationModel(title: "Fitness & Progress", items:[
                HydrationDataModel(subTitle: AppStrings.my_Goals, qnty: "ic_myGoals"),
                HydrationDataModel(subTitle: AppStrings.my_Bookings, qnty: "ic_myBookings_more"),
                 HydrationDataModel(subTitle: AppStrings.my_health_stats, qnty: "ic_MyHealth_Stats"),
                HydrationDataModel(subTitle: AppStrings.my_milestone, qnty: "ic_MyMilestone"),
                HydrationDataModel(subTitle: AppStrings.my_meals, qnty: "ic_meals_more"),
                HydrationDataModel(subTitle: AppStrings.workout_Library, qnty: "ic_WorkoutLibrary_more"),
                HydrationDataModel(subTitle: AppStrings.my_favourite_workouts, qnty: "ic_MyFavourite_Workouts")
            ]
            ),
            HydrationModel(title: "My Network", items:[
                HydrationDataModel(subTitle: AppStrings.my_trainers, qnty: "ic_trainer_more"),
                HydrationDataModel(subTitle: AppStrings.chats, qnty: "ic_chats"),
                HydrationDataModel(subTitle: AppStrings.find_gym, qnty: "ic_find_gym"),
                HydrationDataModel(subTitle: AppStrings.find_trainer, qnty: "ic_find_trainer")
            ]
            ),
            HydrationModel(title: "Account Management", items:[
                HydrationDataModel(subTitle: AppStrings.profile, qnty: "ic_profile_more"),
                HydrationDataModel(subTitle: AppStrings.settings, qnty: "ic_settings_more"),
                HydrationDataModel(subTitle: AppStrings.payment_history, qnty: "ic_Payment_History")
            ]
            ),
            HydrationModel(title: "Support", items:[
                HydrationDataModel(subTitle: AppStrings.help_support, qnty: "ic_help_support")
            ]
            ),
            HydrationModel(title: "E-commerce", items:[
                HydrationDataModel(subTitle: AppStrings.shop, qnty: "ic_shop_more"),
                HydrationDataModel(subTitle: AppStrings.my_orders, qnty: "ic_noSessions"),
                HydrationDataModel(subTitle: AppStrings.cart, qnty: "ic_cart_more")
            ]
            )
        ]
        
        self.exploreCollView.reloadData()
    }
}


extension MoreViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    // Number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return moreSectionData?.count ?? 0 //sectionData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moreSectionData?[section].items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:MoreExploreCollectionViewCell = exploreCollView.dequeueReusableCell(withReuseIdentifier: "MoreExploreCollectionViewCell", for: indexPath) as! MoreExploreCollectionViewCell
        cell.titleLbl.text = moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String
        cell.categoryImgView.image = UIImage(named: moreSectionData?[indexPath.section].items[indexPath.row].qnty as? String ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width*0.20, height: collectionView.frame.width*0.35)
        
//        return CGSize(width: collectionView.frame.width*0.20, height: collectionView.frame.width*0.25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let subtitle = moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String,
           let type = MoreSectionItemType.from(subtitle) {
            
            let info = type.comingSoonInfo
            
            // Uncomment below when features go live
            switch type {
            case .myGoals:
                let vc = MyGoalsViewController.instantiate(appStoryboard: .more)
                self.navigationController?.pushViewController(vc, animated: true)
            case .myMeals:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
//                let vc = MealsViewController.instantiate(appStoryboard: .more)
//                self.navigationController?.pushViewController(vc, animated: true)
            case .shop:
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                /*
                 let vc = ShopViewController.instantiate(appStoryboard: .shop)
                 self.navigationController?.pushViewController(vc, animated: true)
                 */
            case .myOrders:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
                /*
                 let vc = OrderHistoryViewController.instantiate(appStoryboard: .shop)
                 self.navigationController?.pushViewController(vc, animated: true)
                 */
                
            case .cart:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
                /*
                 let vc = CheckoutCartViewController.instantiate(appStoryboard: .shop)
                 self.navigationController?.pushViewController(vc, animated: true)
                 */
            case .profile:
                let vc: ProfileViewController = ProfileViewController.instantiate(appStoryboard: .profile)
                self.navigationController?.pushViewController(vc, animated: true)
                
//                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
            case .mybookings:
//                self.tabBarController?.selectedIndex = 1
                if let tabBarVC = self.tabBarController as? CustomTabViewController {
                    tabBarVC.selectedIndex = 1
                    tabBarVC.handleTabSelection(index: 1)
                }
                
                //                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
            case .my_Health_Stats:
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
//                        let vc:HydrationViewViewController = HydrationViewViewController.instantiate(appStoryboard: .more)
//                        self.navigationController?.pushViewController(vc, animated: true)
                
            case .My_Milestone:
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
            case .workout_library:
//                self.tabBarController?.selectedIndex = 2
                
                if let tabBarVC = self.tabBarController as? CustomTabViewController {
                    tabBarVC.selectedIndex = 2
                    tabBarVC.handleTabSelection(index: 2)
                }
                
//            self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .My_Favourite_Workouts:
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .My_Trainers:
                let vc: FollowersViewController = FollowersViewController.instantiate(appStoryboard: .profile)
                self.navigationController?.pushViewController(vc, animated: true)
//                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .Chats:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .find_a_Gym:
                
//                let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
//                self.navigationController?.pushViewController(vc, animated: false)
                
                //                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                if let getLat = getLat, let getLong = getLong {
                    let vc:GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
                    vc.inputType = "gym"
                    vc.inputLat = "\(getLat)"
                    vc.inputLong = "\(getLong)"
                    
                    appUserDefaults.setGymPackage(value: "gym")
                    
                    //---------------- Flow set for membership
                    vc.flowGymwork = .withoutTrainerMembership
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }else{
                    self.getLocation()
                }
                    
            case .find_a_Trainer:
                
                let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
                self.navigationController?.pushViewController(vc, animated: false)
                
//                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .settings:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .payment_History:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .help_and_Support:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .my_Orders:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .myPT_Products:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .Product:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .add_Address:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
                
            case .order_Refund:
                
                self.comingSoon(NavTitle: info.navTitle, titleStr: info.title, descStr: info.description)
            }
        }
        
        /*
         if (moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String)?.uppercased() == AppStrings.my_Goals.uppercased() {
         
         self.comingSoon(NavTitle: "My Goals", titleStr: "Locked for Now", descStr: "Goal setting and progress tracking will be live soon. Get ready to aim higher!")
         
         /*
          let vc: MyGoalsViewController = MyGoalsViewController.instantiate(appStoryboard: .more)
          self.navigationController?.pushViewController(vc, animated: true)
          */
         
         }else if (moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String)?.uppercased() == AppStrings.my_meals.uppercased() {
         
         self.comingSoon(NavTitle: AppStrings.my_meals, titleStr: "Locked for Now", descStr: "Extra features are on the way. We’re adding more tools to power your fitness goals")
         
         /*
          let vc: MealsViewController = MealsViewController.instantiate(appStoryboard: .more)
          self.navigationController?.pushViewController(vc, animated: true)
          */
         }
         else if (moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String)?.uppercased() == AppStrings.shop.uppercased() {
         
         self.comingSoon(NavTitle: AppStrings.shop, titleStr: "Locked for Now", descStr: "Soon you’ll be able to shop essentials and chat with the community — stay tuned!")
         
         /*
          let vc: ShopViewController = ShopViewController.instantiate(appStoryboard: .shop)
          self.navigationController?.pushViewController(vc, animated: true)
          */
         }
         else if (moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String)?.uppercased() == AppStrings.my_orders.uppercased() {
         self.comingSoon(NavTitle: AppStrings.my_orders, titleStr: "Locked for Now", descStr: "Soon you’ll be able to shop essentials and chat with the community — stay tuned!")
         
         /*
          let vc: OrderHistoryViewController = OrderHistoryViewController.instantiate(appStoryboard: .shop)
          self.navigationController?.pushViewController(vc, animated: true)
          */
         }
         else if (moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String)?.uppercased() == AppStrings.cart.uppercased() {
         
         self.comingSoon(NavTitle: AppStrings.cart, titleStr: "Locked for Now", descStr: "Soon you’ll be able to shop essentials and chat with the community — stay tuned!")
         /*
          let vc: CheckoutCartViewController = CheckoutCartViewController.instantiate(appStoryboard: .shop)
          self.navigationController?.pushViewController(vc, animated: true)
          */
         }
         else if (moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String)?.uppercased() == AppStrings.profile.uppercased() {
         
         self.comingSoon(NavTitle: "Profile",titleStr: "Locked for Now", descStr: "Profiles are in progress. Soon you'll be able to track your journey and customize your experience.")
         
         //            self.setTopBackgroundImage(named: "ic_Mygoals_Upcoming")
         //            self.addTopNavigationButton(action: #selector(handleTopButtonTapped))
         //            self.addTopNavigationButton(title: "Profile", image: AppImages.backarrow, action: #selector(handleTopButtonTapped))
         }
         */
        
        //        let vc: MyGoalsViewController = MyGoalsViewController.instantiate(appStoryboard: .more)
        //
        ////        let vc:HydrationViewViewController = HydrationViewViewController.instantiate(appStoryboard: .more)
        //
        ////        let vc:DummyRulerViewController = DummyRulerViewController.instantiate(appStoryboard: .more)
        //
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Header configuration
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CustomHeaderView.identifier, for: indexPath) as! CustomHeaderView
            
            header.configure(text: moreSectionData?[indexPath.section].title as? String ?? "")
//            header.configure(text: sectionData?[indexPath.section] as? String ?? "")
            
            return header
        }
        else if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MoreLogoutCollectionReusableView.reuseIdentifier, for: indexPath) as! MoreLogoutCollectionReusableView
            footer.backgroundColor = UIColor.clear

            // Remove old targets to avoid duplicate actions
            footer.button.removeTarget(nil, action: nil, for: .allEvents)

            // Add action
            footer.button.addTarget(self, action: #selector(footerButtonTapped), for: .touchUpInside)
            
            footer.deleteAccBtn.removeTarget(nil, action: nil, for: .allEvents)
            footer.deleteAccBtn.addTarget(self, action: #selector(deleteUserBtnActn), for: .touchUpInside)
            
            return footer
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.bounds.width, height: 60) // Adjust height as needed
        
        if section == collectionView.numberOfSections - 1 {
                return CGSize(width: collectionView.bounds.width, height: 130)
            } else {
                return .zero // no footer for other sections
            }
    }
    
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func footerButtonTapped() {
        print("Footer button tapped!")
        AlertHelper.shared.showCustomeAlert(title: "", message: AppAlertStrings.logoutAlertMsg, actions: ["Ok", "Cancel"], withCancel: true, completion: { [weak self] tagGet in
            guard self != nil else { return }
            
            if tagGet == 0 {
                self?.logoutIfFacebookLoggedIn()
                if appUserDefaults.clearUserDefault() {
                    appSceneDelegate?.goToMainView()
                }
            }
        })
    }
    
    func logoutIfFacebookLoggedIn() {
        if let token = AccessToken.current, !token.isExpired {
            // User is logged in — proceed to logout
            let loginManager = LoginManager()
            loginManager.logOut()
            print("Facebook user has been logged out.")
        } else {
            print("No Facebook session found. Logout not needed.")
        }
    }
    
    @objc func deleteUserBtnActn() {
        print("Delete use btn clicked.")
        let vc:DeleteAccPopupViewController = DeleteAccPopupViewController.instantiate(appStoryboard: .more)
        vc.modalPresentationStyle = .automatic
        self.present(vc, animated: true)
    }
    
    
    //MARK: ---------------SETUP COMMING SOON
    private func comingSoon(NavTitle: String? = "Profile",titleStr: String? = AppStrings.coming_soon, descStr: String? = "Profiles are in progress. Soon you'll be able to track your journey and customize your experience."){
        self.view.setComingSoon(bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_upcomingStripe", lockImgName: "ic_upcomingLock" ,title: titleStr, desc: descStr)
        self.view.addTopNavigationButton(title: NavTitle, image: AppImages.backarrow, target: self.view)
    }
    
    //=======  
    enum MoreSectionItemType: String, CaseIterable {
        case myGoals = "MY GOALS"
        case myMeals = "MY MEALS"
        case shop = "SHOP"
        case myOrders = "MY ORDERS"
        case cart = "CART"
        case profile = "PROFILE"
        case mybookings = "MY BOOKINGS"
        case my_Health_Stats = "MY HEALTH & STATS"
        case My_Milestone = "MY MILESTONE"
        case workout_library = "Workout Library"
        case My_Favourite_Workouts = "MY FAVOURITE WORKOUTS"
        case My_Trainers = "MY TRAINERS"
        case Chats = "CHATS"
        case find_a_Gym = "Find a Gym"
        case find_a_Trainer = "Find a Trainer"
        case settings = "Settings"
        case payment_History = "Payment History"
        case help_and_Support = "Help and Support"
        case my_Orders = "My Orders"
        case myPT_Products = "MyPT Products"
        case Product = "Product"
        case add_Address = "Add Address"
        case order_Refund = "Order Refund"
        
        static func from(_ raw: String) -> MoreSectionItemType? {
            return Self.allCases.first { $0.rawValue.uppercased() == raw.uppercased() }
        }
        
        var comingSoonInfo: (navTitle: String, title: String, description: String) {
            switch self {
            case .myGoals:
                return ("My Goals", AppStrings.coming_soon, "Goal setting and progress tracking will be live soon. Get ready to aim higher!")
            case .myMeals:
                return ("My Meals",  AppStrings.coming_soon, "Extra features are on the way. We’re adding more tools to power your fitness goals.")
            case .shop:
                return ("Shop",  AppStrings.coming_soon, "Soon you’ll be able to shop essentials and chat with the community — stay tuned!")
            case .myOrders, .my_Orders:
                return ("My Orders",  AppStrings.coming_soon, "Your order history will be available here soon.")
            case .cart:
                return ("Cart",  AppStrings.coming_soon, "Your cart will be ready soon for easier shopping.")
            case .profile:
                return ("Profile",  AppStrings.coming_soon, "Profiles are in progress. Soon you'll be able to track your journey and customize your experience.")
            case .mybookings:
                return ("My Bookings",  AppStrings.coming_soon, "You’ll soon be able to view and manage your bookings.")
            case .my_Health_Stats:
                return ("My Health & Stats",  AppStrings.coming_soon, "Health tracking will be launching soon.")
            case .My_Milestone:
                return ("My Milestone",  AppStrings.coming_soon, "Your achievements and milestones will be available soon.")
            case .My_Favourite_Workouts:
                return ("My Favourite Workouts",  AppStrings.coming_soon, "Save and revisit your top workouts soon.")
            case .My_Trainers:
                return ("My Trainers",  AppStrings.coming_soon, "Connect with your trainers — coming soon.")
            case .Chats:
                return ("Chats",  AppStrings.coming_soon, "Soon you’ll be able to shop essentials and chat with the community — stay tuned!")
            case .find_a_Gym:
                return ("Find a Gym",  AppStrings.coming_soon, "Discover gyms near you — feature coming soon.")
            case .find_a_Trainer:
                return ("Find a Trainer",  AppStrings.coming_soon, "Trainer discovery will be available shortly.")
            case .settings:
                return ("Settings",  AppStrings.coming_soon, "More control and preferences are on the way.")
            case .payment_History:
                return ("Payment History",  AppStrings.coming_soon, "View past transactions soon.")
            case .help_and_Support:
                return ("Help & Support",  AppStrings.coming_soon, "Support features are coming to help you better.")
            case .myPT_Products:
                return ("MyPT Products",  AppStrings.coming_soon, "Track your product subscriptions here soon.")
            case .Product:
                return ("Product",  AppStrings.coming_soon, "Product details and purchases will be added soon.")
            case .add_Address:
                return ("Add Address",  AppStrings.coming_soon, "Save your delivery addresses — feature coming soon.")
            case .order_Refund:
                return ("Order Refund",  AppStrings.coming_soon, "Request refunds for orders — available soon.")
            case .workout_library:
                return ("Workout Library",  AppStrings.coming_soon, "Your personal library of workouts is almost ready. Hang tight — it's unlocking soon!")
            }
        }
    }
    
}




