//
//  DashboardViewController.swift
//  MyPT
//
//  Created by techsaga corp on 12/11/24.
//

import UIKit

enum flowPackageCreate {
    case notPackage
    case packageCreated
    case membershipExpire
    case defaultPackage
}

class DashboardViewController: CommonViewController {
    
    //MARK: ------------------VARIABLE
        
    var flowpackage: flowPackageCreate = .defaultPackage
    
    var currentAddrText: String? = "" {
        didSet{
            self.setLeftMenu(leftImgs: [AppImages.chooseLocation, AppImages.forward], setTitle: ["\(currentAddrText?.trimmingCharacters(in: .whitespaces) ?? "")",nil], setTintColor: .appWhite, setTitleColor: .appWhite)
        }
    }
    
    var productCategory:[String]?
    var workoutDays:[String]?
    private let pageControl = CustomPageControl()
    
    var upcomingSessionData:[BookingDataModel]? = [] {
        didSet{
            self.upcomingSessionsCollView.reloadData()
        }
    }
    
    var studiosData:[TrainerModel]? = []
    var upcomingClassesData:[UpcomingClassModel]? = []
    
    var isDayStreakHeight: Bool?
    
    
    //MARK: ------------IBOUTLET
    @IBOutlet weak var topHeaderImgView: UIImageView!
    @IBOutlet weak var topNameMBV: UIView!
    @IBOutlet weak var topNameMBVTopConstrnt: NSLayoutConstraint!
    @IBOutlet weak var bookTrainerAtHomeBtn: UIButton!
    @IBOutlet weak var membershipBtn: UIButton!
    @IBOutlet weak var userImgeView: UIImageView!
    @IBOutlet weak var userImgViewBtn: UIButton!
    @IBOutlet weak var memberTypeLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var upcomingSessionsLbl: UILabel!
    @IBOutlet weak var upcomingSessionsCollView: UICollectionView!
    @IBOutlet weak var upcomingSessionsCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var UpcomingMeals2MBV: UIView!
    @IBOutlet weak var upcomingMealsTitle2Lbl: UILabel!
    @IBOutlet weak var rightNutritionTitleLbl: UILabel!
    @IBOutlet weak var rightNutritionDescLbl: UILabel!
    @IBOutlet weak var customPageControl: CustomPageControl!
    @IBOutlet weak var upcomingMealsLbl: UILabel!
    @IBOutlet weak var upcomingMealsCollView: UICollectionView!
    @IBOutlet weak var classesNearYouLbl: UILabel!
    @IBOutlet weak var classesNearYouCollView: UICollectionView!
    @IBOutlet weak var gymsNearbyLbl: UILabel!
    @IBOutlet weak var gymsNearbyCollView: UICollectionView!
    @IBOutlet weak var shopProductsLbl: UILabel!
    @IBOutlet weak var productCategoryCollView: UICollectionView!
    @IBOutlet weak var productCategoryCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var productListCollView: UICollectionView!
    @IBOutlet weak var dailyProgressLbl: UILabel!
    @IBOutlet weak var waterIntekMBV: UIView!
    @IBOutlet weak var waterIntekLbl: UILabel!
    @IBOutlet weak var quantityMBV: UIView!
    @IBOutlet weak var roundupQuantityLbl: UILabel!
    @IBOutlet weak var plusQuantityBtn: UIButton!
    @IBOutlet weak var calorieIntakeMBV: UIView!
    @IBOutlet weak var calorieTitleLbl: UILabel!
    @IBOutlet weak var quantitykcalLbl: UILabel!
    @IBOutlet weak var kcalProgressView: UIView!
    @IBOutlet weak var calorieBurnMBV: UIView!
    @IBOutlet weak var calorieBurnLbl: UILabel!
    @IBOutlet weak var quantityburnKcalLbl: UILabel!
    @IBOutlet weak var dayStreakContainerView: UIView!
    @IBOutlet weak var dayStreakMBV: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var calendarMBV: UIView!
    @IBOutlet weak var myActivityLbl: UILabel!
    @IBOutlet weak var myActiveChallengeLbl: UILabel!
    @IBOutlet weak var sundayLbl: UILabel!
    @IBOutlet weak var dayStreakCollView: UICollectionView!
    @IBOutlet weak var dayStreakCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var sunSubMBV: UIView!
    @IBOutlet weak var day1CountLbl: UILabel!
    @IBOutlet weak var day1ImgView: UIImageView!
    @IBOutlet weak var day2Lbl:UILabel!
    @IBOutlet weak var day2MBV:UIView!
    @IBOutlet weak var day2CountLbl:UILabel!
    @IBOutlet weak var day2CountImgView:UIImageView!
    @IBOutlet weak var day3Lbl:UILabel!
    @IBOutlet weak var day3MBV:UIView!
    @IBOutlet weak var day3CountLbl:UILabel!
    @IBOutlet weak var day3CountImgView:UIImageView!
    @IBOutlet weak var day4Lbl:UILabel!
    @IBOutlet weak var day4MBV:UIView!
    @IBOutlet weak var day4CountLbl:UILabel!
    @IBOutlet weak var day4CountImgView:UIImageView!
    @IBOutlet weak var day5Lbl:UILabel!
    @IBOutlet weak var day5MBV:UIView!
    @IBOutlet weak var day5CountLbl:UILabel!
    @IBOutlet weak var day5CountImgView:UIImageView!
    @IBOutlet weak var day6Lbl:UILabel!
    @IBOutlet weak var day6MBV:UIView!
    @IBOutlet weak var day6CountLbl:UILabel!
    @IBOutlet weak var day6CountImgView:UIImageView!
    @IBOutlet weak var day7Lbl:UILabel!
    @IBOutlet weak var day7MBV:UIView!
    @IBOutlet weak var day7CountLbl:UILabel!
    @IBOutlet weak var day7CountImgView:UIImageView!
    @IBOutlet weak var dayStrekLbl: UILabel!
    @IBOutlet weak var calendarLine: UILabel!
    @IBOutlet weak var dayStreakNoteLbl: UILabel!
    @IBOutlet weak var footerLine: UILabel!
    @IBOutlet weak var thougthLbl: UILabel!
    @IBOutlet weak var thoughtWriterLbl: UILabel!
    @IBOutlet weak var workoutsMBV: UIView!
    @IBOutlet weak var myWorkoutsLbl: UILabel!
    @IBOutlet weak var workoutsDayCollView: UICollectionView!
    @IBOutlet weak var workoutsDayCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var workoutTblView: UITableView!
    @IBOutlet weak var UpcomingSessionMBV: UIView!
    @IBOutlet weak var upcomingMealsMBV: UIView!
    @IBOutlet weak var dailyProgressMBV: UIView!
    @IBOutlet weak var myActivityMBV: UIView!
    @IBOutlet weak var upcomingClassesNearYouMBV: UIView!
    @IBOutlet weak var myActiveChallengeMBV: UIView!
    @IBOutlet weak var gymsNearbyMBV: UIView!
    @IBOutlet weak var shopProductsMBV: UIView!
    @IBOutlet weak var spacerDayStreakMBV: UIView!
    @IBOutlet weak var transformationStoryMBV: UIView!
    @IBOutlet weak var transformationStoryTitleLbl: UILabel!
    @IBOutlet weak var transformationStoryBtn: UIButton!
    @IBOutlet weak var transformationStoryCollView: UICollectionView!
    @IBOutlet weak var stepsConnectMBV: UIView!
    @IBOutlet weak var trackStepsTitleLbl: UILabel!
    @IBOutlet weak var trackStepsConnectDescLbl: UILabel!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var myActivityCategoryCollView: UICollectionView!
    @IBOutlet weak var myActivityCategoryCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var upcomingSessionArrowBtn: UIButton!
    @IBOutlet weak var meals2ArrowBtn: UIButton!
    @IBOutlet weak var mealsArrowBtn: UIButton!
    @IBOutlet weak var dailyProgressArrowBtn: UIButton!
    @IBOutlet weak var myWorkoutsArrowBtn: UIButton!
    @IBOutlet weak var myActivityArrowBtn: UIButton!
    @IBOutlet weak var classesNearArrowBtn: UIButton!
    @IBOutlet weak var myActiveChallengesArrowBtn: UIButton!
    @IBOutlet weak var gymNearbyArrowBtn: UIButton!
    @IBOutlet weak var shopProductsArrowBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.getLocation()
        self.upcomingSessionsCollViewHeightConstrnt.constant = 220
        self.myActivityCategoryCollViewHeightConstrnt.constant = 1.0
        self.workoutsDayCollViewHeightConstrnt.constant = 35 //1.0
        
        self.productCategory = ["All Equipment",
                                "Fitness Equipment",
                                "Apparel & Accessories"
        ]
        self.workoutDays = ["Today1","Today2","Today3","Today4","Today5","Today6"]
        self.setupUI()
        self.regiterCollections()
        self.setupFont()
//        setUpCustomPageControl()
//        self.updatePage(to: 0)
        

        // Use the blurredGrayImage as needed, e.g., display it in an UIImageView:
//        if let imgView = UIImage(named: "ic_streak_Badage2") {
////            self.streakBadage3ImgView.image = createGrayBlurImage(from: imgView, blurRadius: 2.0)
//        }
        
        self.setupInputData()
        
//        let originalImage = UIImage(named: "ic_streak_Badage2")!
//        let colors = [UIColor(red: 45/255.0, green: 49/255.0, blue: 45/255.0, alpha: 1.0).cgColor,UIColor(red: 45/255.0, green: 49/255.0, blue: 45/255.0, alpha: 1.0).cgColor,UIColor(red: 45/255.0, green: 49/255.0, blue: 45/255.0, alpha: 1.0).cgColor]
//        let locations: [CGFloat] = [0.0, 0.2, 0.3, 0.5, 1.0]
//
//        let gradientImage = addGradientBackgroundToImage(image: originalImage, colors: colors, locations: locations)
//        
//        self.streakBadage2ImgView.image = gradientImage
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isDayStreakHeight = true
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        self.setNavUI()
        self.topUserNameMBV()
//        self.getLocation()
        self.bookingListApi(typeStr: "2", dateStr: nil, sessionType: nil, location: nil)
        
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first{
            print("Current lat", lat)
            let currentLoc: String? = appUserDefaults.getCurrentAddr()
            if let currentLoc = currentLoc {
                self.currentAddrText = String(currentLoc.prefix(25))
            }
            
            self.getTrainerApi(inputFilter: "0", inpuntTagId: 0)
            self.self.upcomingClassesApi()
            
        }else{
            self.getLocation()
        }
        
        flowpackage = .notPackage
        setupFlowPackageCreate()
        self.checkPackage()
//        self.upcomingClassesApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Automatically select the first cell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        DispatchQueue.main.async {
            self.productCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.productCategoryCollView.delegate?.collectionView?(self.productCategoryCollView, didSelectItemAt: firstIndexPath)
//            self.productCategoryCollView.reloadData()
            
            self.workoutsDayCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.workoutsDayCollView.delegate?.collectionView?(self.workoutsDayCollView, didSelectItemAt: firstIndexPath)
//            self.workoutsDayCollView.reloadData()
            
            self.topUserNameMBV()
            self.view.layoutIfNeeded()
        }
        
        self.dayStreakCardScroll()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            for cell in self.dayStreakCollView.visibleCells {
//                let basePosition = cell.convert(cell.bounds, to: self.view)
//                let center = self.view.center
//                let distance = abs(basePosition.midX - center.x)DashboardViewController
//                let scale = max(0.75, 1 - (distance / self.view.bounds.width))
//                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
//            }
//        }

        
        //--------------Coming soon
        self.dailyProgressMBV.setComingSoon(mainVTop: 30, mainVBottom: 2, centerY: -35, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title: "Locked", desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
        
        
        self.workoutsMBV.setComingSoon(mainVTop: 35, mainVBottom: 30, centerY: -35, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title: "Locked", desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
       
        self.myActivityMBV.setComingSoon(mainVTop: 35,
                                         mainVBottom: 35, centerY: -35, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title: "Locked", desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
      
        
        self.upcomingClassesNearYouMBV.setComingSoon(mainVTop: 30, mainVBottom: 0, centerY: -40, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title: "Locked", desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
        
        
        self.myActiveChallengeMBV.setComingSoon(mainVTop: 30, mainVBottom: 0, centerY: -40, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title: "Locked", desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
        
        self.myActiveChallengeMBV.setComingSoon(mainVTop: 30, mainVBottom: 0, centerY: -40, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title: "Locked", desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
        
        self.shopProductsMBV.setComingSoon(mainVTop: 30, mainVBottom: 0, centerY: -40, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title: "Locked", desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
        
       
        self.topView.isHidden = true
        self.dayStreakMBV.setComingSoon(mainVTop: -50, mainVBottom: 0, centerY: -40, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title: "Locked", desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
    }
    
    
    private func dayStreakCardScroll(){
        
        self.dayStreakCardAnuimated(scrollView: dayStreakCollView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            self.dayStreakCollView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: true)
            
            //            if let allClassVideosCount = self.classeData?.allClassVideos?.count , allClassVideosCount > 1 {
            //                self.dayStreakCardAnuimated.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: true)
            //            }
        }
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            for cell in self.dayStreakCollView.visibleCells {
                let basePosition = cell.convert(cell.bounds, to: self.view)
                let center = self.view.center
                let distance = abs(basePosition.midX - center.x)
                let scale = max(0.75, 1 - (distance / self.view.bounds.width))
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            
            let centerX = self.dayStreakCollView.bounds.width / 2 + self.dayStreakCollView.contentOffset.x
            
            var maxX: CGFloat = -CGFloat.infinity
            var rightmostCell: DayStreakCollectionViewCell?
            
            var minX: CGFloat = CGFloat.infinity
            for cell in self.dayStreakCollView.visibleCells {
                guard let myCell = cell as? DayStreakCollectionViewCell else { continue }
                
                // Convert to superview to take transformations into account
                let convertedFrame = cell.superview?.convert(cell.frame, to: self.dayStreakCollView) ?? cell.frame
                
                let basePosition = convertedFrame.midX
                let distance = abs(centerX - basePosition)
                let scale = max(0.70, 1 - distance / self.dayStreakCollView.bounds.width)
                myCell.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                // Determine rightmost visible cell
                if convertedFrame.maxX > maxX {
                    maxX = convertedFrame.maxX
                    rightmostCell = myCell
                }
                
                // Determine leftmost visible cell
                if convertedFrame.minX < minX {
                    minX = convertedFrame.minX
                }
            }
            
            for cell in self.dayStreakCollView.visibleCells {
                guard let myCell = cell as? DayStreakCollectionViewCell else { continue }
                // Blur only the actual rightmost cell
                myCell.setBlurred(myCell == rightmostCell)
            }
            
            self.dayStreakCollView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: true)
        }
        */
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.topView.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: self.topView.frame.size.height/2.0)
        
        self.calendarMBV.addGradient(colors: [
            UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.3),
            UIColor(red: 71/255.0, green: 77/255.0, blue:
                                            96/255.0, alpha: 1.0)
        ], locations: [0,1], startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 20.0)
        
        [
            self.sunSubMBV,
            self.day2MBV,
            self.day3MBV,
            self.day4MBV,
            self.day5MBV,
            self.day6MBV,
            self.day7MBV
        ].forEach({
            $0.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: $0.frame.size.width/2.0)
        })
    }
    
    private func topUserNameMBV(){
        //---------------------- Navigationview
        if let navigationController = self.navigationController {
            let navBarHeight = navigationController.navigationBar.frame.height
            let topSafeArea = (self.view.safeAreaInsets.top - 10.0)
            let totalTopHeight = navBarHeight + topSafeArea
            self.topNameMBVTopConstrnt.constant = totalTopHeight
            
            self.topHeaderImgView.setNeedsLayout()
            self.topHeaderImgView.layoutIfNeeded()
            self.topNameMBV.setNeedsLayout()
            self.topNameMBV.layoutIfNeeded()
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        if let navigationController = self.navigationController {
//            let navBarHeight = navigationController.navigationBar.frame.height
//            let topSafeArea = (self.view.safeAreaInsets.top - 10.0)
//            let totalTopHeight = navBarHeight + topSafeArea
//            self.topNameMBVTopConstrnt.constant = totalTopHeight
//        }
//    }
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.chooseLocation, AppImages.forward], setTitle: [" \(currentAddrText ?? "")",nil], setTintColor: .appWhite, setTitleColor: .appWhite)
        let logout = UIImage(named: "ic_logout")?.resized(to: CGSize(width: 25.0, height: 25.0))?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor.appWhite)
        
        self.setRighMenu(rightImgs: [logout ,AppImages.notification], setTitle: [nil,nil], setTintColor: UIColor.appWhite, setTitleColor: UIColor.appWhite)
        
//        self.setRighMenu(rightImgs: [AppImages.notificationCount,AppImages.notification], setTitle: ["10",nil], setTintColor: nil, setTitleColor: UIColor.appWhite)
    }
    
    override func leftBtnActn(sender: UIButton) {
        let vc:LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
        vc.flowLocation = .homePage
        vc.isFromEditAddress = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func rightBtnActn(sender: UIButton) {
        print("right btn tag= ", sender.tag)
        if sender.tag == 0 {
            AlertHelper.shared.showCustomeAlert(title: "", message: AppAlertStrings.logoutAlertMsg, actions: ["Ok", "Cancel"], withCancel: true, completion: { [weak self] tagGet in
                guard self != nil else { return }
                
                if tagGet == 0 {
                    if appUserDefaults.clearUserDefault() {
                        appSceneDelegate?.goToMainView()
                    }
                }
            })
        }
        
    }
    
    //MARK: ---------FLOW PACKAGE CREATE
    private func setupFlowPackageCreate(){
        switch flowpackage {
        case .notPackage:
            print("Package not created")
            self.upcomingMealsMBV.isHidden = true
//            self.UpcomingMeals2MBV.isHidden = false
            self.UpcomingMeals2MBV.isHidden = true
            self.transformationStoryMBV.isHidden = false
            self.dailyProgressMBV.isHidden = true
            self.myActiveChallengeMBV.isHidden = true
            self.dayStreakContainerView.isHidden = true
            self.memberTypeLbl.isHidden = true
            self.memberTypeLbl.text = nil
            
            break
        case .packageCreated:
            print("Package created")
            self.upcomingMealsMBV.isHidden = false
            self.UpcomingMeals2MBV.isHidden = true
            self.transformationStoryMBV.isHidden = true
            self.dailyProgressMBV.isHidden = false
            self.myActiveChallengeMBV.isHidden = false
            self.dayStreakContainerView.isHidden = false
            self.memberTypeLbl.isHidden = false
            self.memberTypeLbl.text = "Gold Member"
            
            self.myActivityMBV.setComingSoon(mainVTop: 35,
                                             mainVBottom: 35, centerY: -35, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title: "Locked", desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
         
            self.workoutsMBV.setComingSoon(mainVTop: 35, mainVBottom: 30, centerY: -35, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title: "Locked", desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
        
            self.myActiveChallengeMBV.setComingSoon(mainVTop: 30, mainVBottom: 0, centerY: -40, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title: "Locked", desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
            
            break
        case .membershipExpire:
            print("membership expire")
            break
        case .defaultPackage:
            print("none..")
            break
        }
    }
    
    //MARK: ---------------BTN TAG
    enum Btntag: Int {
        case bookTrainer = 2201, membership, upcomingSeeion, meals2withoutPackage, meals, dailyProgress, myWorkouts, myActivity, classesNear, MyActiveChallenges, gymNearBy, shopProducts
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        print("btn tag", sender.tag)
        
        switch sender.tag {
        case Btntag.bookTrainer.rawValue:
            print("book trainer")
            let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
            vc.flowCreatePackage = .createPackage
            self.navigationController?.pushViewController(vc, animated: false)
        case Btntag.membership.rawValue:
            let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
            vc.flowCreatePackage = .gymMembership
            self.navigationController?.pushViewController(vc, animated: false)
        case Btntag.upcomingSeeion.rawValue:
            print("upcoming session clicked..")
//            let vc: PaymentMethodsViewController = PaymentMethodsViewController.instantiate(appStoryboard: .booking)
//            self.navigationController?.pushViewController(vc, animated: false)
            
//            let vc:PlanPopupViewController = PlanPopupViewController.instantiate(appStoryboard: .calendar)
            
//            let vc: CCAvenuePaymentViewController = CCAvenuePaymentViewController.instantiate(appStoryboard: .booking)
//            vc.modalPresentationStyle = .overFullScreen
//            self.navigationController?.present(vc, animated: true)
            
//            self.navigationController?.pushViewController(vc, animated: true)
            
        case Btntag.meals2withoutPackage.rawValue:
            print("meals2withoutPackage clicked..")
        case Btntag.meals.rawValue:
            print("meals clicked..")
        case Btntag.dailyProgress.rawValue:
            print("dailyProgress clicked..")
        case Btntag.myWorkouts.rawValue:
            print("myWorkouts clicked..")
        case Btntag.myActivity.rawValue:
            print("myActivity clicked..")
        case Btntag.classesNear.rawValue:
            print("classesNear clicked..")
            
            /// need need for client
//            let vc: UpcomingClassesViewController = UpcomingClassesViewController.instantiate(appStoryboard: .dashboard)
//            self.navigationController?.pushViewController(vc, animated: false)
            
        case Btntag.MyActiveChallenges.rawValue:
            print("MyActiveChallenges clicked..")
        case Btntag.gymNearBy.rawValue:
            print("gymNearBy clicked..")
            
            if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
                
                let vc:GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
                vc.inputType = "gym"
                vc.inputLat = lat
                vc.inputLong = long
                
                appUserDefaults.setGymPackage(value: "gym")
                
                //---------------- Flow set for membership
                vc.flowGymwork = .withTrainerMembership
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                self.getLocation()
            }
            
        case Btntag.shopProducts.rawValue:
            print("shopProducts clicked..")
            
        default:
            print("None.....")
//            let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
//            vc.flowCreatePackage = .gymMembership
//            self.navigationController?.pushViewController(vc, animated: false)
//            
            break
        }
    }
    
    private func setupInputData(){
        if let userData = appUserDefaults.getUserFromUserDefaults(as: SubmitDataModel.self), let userName = userData.user?.name {
            let greatingTimeStr = DateFormatterHelper.shared.getTimeOfDay()
            
            self.userNameLbl.text = "Good " + greatingTimeStr + " " + userName
        }
    }
    
    private func regiterCollections(){
        //------------------------*************UICollectionview init
        transformationStoryCollView.register(UINib(nibName: "TransformationStoriesCollViewCell", bundle: nil), forCellWithReuseIdentifier: "TransformationStoriesCollViewCell")
        upcomingSessionsCollView.register(UINib(nibName: "UpcomingSessionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingSessionsCollectionViewCell")
        upcomingMealsCollView.register(UINib(nibName: "UpcomingMealsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingMealsCollectionViewCell")
        
        classesNearYouCollView.register(UINib(nibName: "UpcomingClassCollViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingClassCollViewCell")
        gymsNearbyCollView.register(UINib(nibName: "GymsNearbyCollViewCell", bundle: nil), forCellWithReuseIdentifier: "GymsNearbyCollViewCell")
        productCategoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        productListCollView.register(UINib(nibName: "ProductsListCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductsListCollViewCell")
        workoutsDayCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        dayStreakCollView.register(UINib(nibName: "DayStreakCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DayStreakCollectionViewCell")
        
        //----------------------*************UITableview init
        self.workoutTblView.register(UINib(nibName: "MyWorkoutsTableViewCell", bundle: nil), forCellReuseIdentifier: "MyWorkoutsTableViewCell")
    }
    
    //MARK: -------------GET Lat long
    
    private func getLocation(){
        
        GetLocationManager.shared.requestLocationWithAddress {[weak self] location, addressPart in
            guard let self = self else { return }
            
            appUserDefaults.setLatLong(value: "\(location?.coordinate.latitude ?? 0),\(location?.coordinate.longitude ?? 0)")
            appUserDefaults.setCurrentAddr(value: addressPart.0)
            
            let currentLoc: String? = addressPart.0
            if let currentLoc = currentLoc {
                self.currentAddrText = String(currentLoc.prefix(25))
            }
            
            self.getTrainerApi(inputFilter: "0", inpuntTagId: 0)
            self.self.upcomingClassesApi()
        }
    }
    
    //MARK: ---------- SET UI
    private func setupUI(){
        
        if let imgView = UIImage(named: "ic_bookTranierBackImg") {
            self.bookTrainerAtHomeBtn.setBackgroundImage(imgView, for: .normal)
            self.bookTrainerAtHomeBtn.clipsToBounds = true
            self.bookTrainerAtHomeBtn.addGradientLayer(colors: [UIColor.mainBg.withAlphaComponent(0.9), UIColor.clear], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 14.0)
        }
        
        self.membershipBtn.addGradientLayer(colors: [UIColor.mainBg.withAlphaComponent(0.9), UIColor.clear], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
        
//        var topInset: CGFloat = 0.0
        
        DispatchQueue.main.async {
            //Book a Trainer at Gym/Home
            //Buy MyPT Studio Membership
                                
            //[UIColor(red: 17.0/255.0, green: 18.0/255.0, blue: 20.0/255.0, alpha: 1), UIColor(red: 0/255.0, green: 5.0/255.0, blue: 2.0/255.0, alpha: 1)]
            
            self.topHeaderImgView.addGradientImgV(colors: [UIColor(red: 17.0/255.0, green: 18.0/255.0, blue: 20.0/255.0, alpha: 1), UIColor(red: 0/255.0, green: 5.0/255.0, blue: 2.0/255.0, alpha: 1)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0))
            self.topNameMBV.backgroundColor = UIColor.clear
            self.topNameMBV.addGradient(colors: [UIColor(red: 17.0/255.0, green: 18.0/255.0, blue: 20.0/255.0, alpha: 0.2), UIColor(red: 0/255.0, green: 5.0/255.0, blue: 2.0/255.0, alpha: 1)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1))
            
            //setGradientMultiBorder
            self.userImgeView.setCornerRadius(borderWidth: 1.5, borderColor: nil, cornerRadious: 18.0)
            self.userImgeView.setGradientMultiBorder(cornerRadius: 18.0, width: 1.5, colors: [UIColor(red: 207.0/255.0, green: 171.0/255.0, blue: 104.0/255.0, alpha: 1.0),UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 216.0/255.0, alpha: 1.0),UIColor(red: 173/255.0, green: 130/255.0, blue: 54/255.0, alpha: 1.0)], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            
            self.userImgViewBtn.setGradientMultiBorder(cornerRadius: 18.0, width: 1.5, colors: [UIColor(red: 207.0/255.0, green: 171.0/255.0, blue: 104.0/255.0, alpha: 1.0),UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 216.0/255.0, alpha: 1.0),UIColor(red: 173/255.0, green: 130/255.0, blue: 54/255.0, alpha: 1.0)], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            
            self.bookTrainerAtHomeBtn.titleLabel?.numberOfLines = 0
            self.bookTrainerAtHomeBtn.titleLabel?.lineBreakMode = .byClipping
            self.membershipBtn.titleLabel?.numberOfLines = 0
            self.membershipBtn.titleLabel?.lineBreakMode = .byClipping
            
            self.bookTrainerAtHomeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.bookTrainerAtHomeBtn.frame.size.height*0.23)
            self.membershipBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.membershipBtn.frame.size.height*0.23)
                        
            [
                self.waterIntekMBV,
                self.calorieBurnMBV
            ].forEach({
                $0.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,0.8], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 18.0)
            })
            
            self.calorieIntakeMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 0.9), cornerRadius: 18.0)
            
            self.quantityMBV.addGradient(colors: [UIColor(red: 0/255.0, green: 184/255.0, blue: 251/255.0, alpha: 1.0), UIColor(red: 0/255.0, green: 79/255.0, blue: 255/255.0, alpha: 1)], locations: [0.3,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 18)
            
            self.plusQuantityBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 10.0)
                        
            self.kcalProgressView.drawLineProgress(progressfill: 0.2, fillLineColor: UIColor.appRatingYellow, cornerRadius: 3.0)
            self.calendarLine.backgroundColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0)
//            self.calendarLine.addGradient(colors: UIColor.appMultiColor(.lineVGradient2), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            
            
            [
                self.dayStreakMBV,
                self.calendarMBV
            ].forEach({[weak self] in
                guard self != nil else { return  }
                $0.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
                $0.setGradientMultiBorder(cornerRadius: 20.0, width: 1.0, colors: [UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0), UIColor(red: 0, green: 0, blue: 0, alpha: 0)], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 1, y: 1))
            })
            
            self.topView.setGradientMultiBorder(cornerRadius: 20.0, width: 1.0, colors: [UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0), UIColor(red: 0, green: 0, blue: 0, alpha: 0)], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 1, y: 1))
            self.footerLine.backgroundColor = UIColor.clear
            self.footerLine.addGradient(colors: UIColor.appMultiColor(.lineVGradient2), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            
            [
                self.sunSubMBV,
                self.day2MBV,
                self.day3MBV,
                self.day4MBV,
                self.day5MBV,
                self.day6MBV,
                self.day7MBV
            ].forEach({
                $0.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: $0.frame.size.height/2.0)
            })
            
            self.calendarLine.backgroundColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0)
            self.connectBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
        
        self.dayStreakNoteLbl.text = "Workout each day to say fit and maintain your streak"
        
//        self.calendarMBV.setNeedsLayout()
//        self.calendarMBV.layoutIfNeeded()
//        self.dayStreakMBV.setNeedsLayout()
//        self.dayStreakMBV.layoutIfNeeded()
//        self.dayStreakContainerView.setNeedsLayout()
//        self.dayStreakContainerView.layoutIfNeeded()
        
    }
    
    private func setupFont(){
        
        [
            self.bookTrainerAtHomeBtn.titleLabel,
            self.membershipBtn.titleLabel,
            self.sundayLbl,
            self.day2Lbl,
            self.day3Lbl,
            self.day4Lbl,
            self.day5Lbl,
            self.day6Lbl,
            self.day7Lbl,
            self.day1CountLbl,
            self.day2CountLbl,
            self.day3CountLbl,
            self.day4CountLbl,
            self.day5CountLbl,
            self.day6CountLbl,
            self.day7CountLbl,
            self.waterIntekLbl
        ].forEach({[weak self] in
            guard self != nil else { return  }
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        self.memberTypeLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.userNameLbl.font = AppFont.bold.size(18.0, familyName: familyManrope)
        
        [
            self.upcomingSessionsLbl,
            self.upcomingMealsTitle2Lbl,
            self.upcomingMealsLbl,
            self.classesNearYouLbl,
            self.gymsNearbyLbl,
            self.shopProductsLbl,
            self.dailyProgressLbl,
            self.myWorkoutsLbl,
            self.myActivityLbl,
            self.myActiveChallengeLbl,
            self.transformationStoryTitleLbl
            
        ].forEach({[weak self] in
            guard self != nil else { return  }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })

        self.calorieTitleLbl.font = AppFont.regular.size(12.0, familyName: familyManrope)
        self.calorieBurnLbl.font = AppFont.regular.size(12.0, familyName: familyManrope)
        self.plusQuantityBtn.titleLabel?.font = AppFont.semibold.size(13.7, familyName: familyManrope)
        
        
        //-------------------- water intake Attributed
        let defaultMLAttr = [
            .font: AppFont.semibold.size(20.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeMLAttr = [
            .font: AppFont.regular.size(12.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
                
        let mlAttri = [
            "1,200",
            NSAttributedString(string: "/2200 ml",
                               attributes: makeMLAttr)
        ] as [AttributedStringComponent]
        
        self.roundupQuantityLbl.attributedText = NSAttributedString(from: mlAttri, defaultAttributes: defaultMLAttr)
        
        //-------------------- Calorie intake Attributed
        let kcalAttri = [
            "1,500",
            NSAttributedString(string: "/2200 kcal",
                               attributes: makeMLAttr)
        ] as [AttributedStringComponent]
        
        self.quantitykcalLbl.attributedText =  NSAttributedString(from: kcalAttri, defaultAttributes: defaultMLAttr)
        
        
        let burncalAttri = [
            "1,548",
            NSAttributedString(string: "/2200 kcal",
                               attributes: makeMLAttr)
        ] as [AttributedStringComponent]
        
        self.quantityburnKcalLbl.attributedText =  NSAttributedString(from: burncalAttri, defaultAttributes: defaultMLAttr)
        
        self.dayStrekLbl.font = AppFont.semibold.size(16.0, familyName: familyClashDisplay)
        self.dayStreakNoteLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        self.rightNutritionTitleLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.rightNutritionDescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.trackStepsTitleLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.trackStepsConnectDescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.connectBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.thougthLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.thoughtWriterLbl.font = AppFont.regular.size(12.0, familyName: familyManrope)

    }
    
    //MARK: --------------SETUP page controll
    func setUpCustomPageControl(){
        self.customPageControl.numberOfPages = 5  // Set the total number of pages
        self.customPageControl.currentPage = 0    // Set the initial page
        self.customPageControl.activeDotSize = CGSize(width: 26, height: 8)
        self.customPageControl.currentDotColor = UIColor(red: 158/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1)
        self.customPageControl.defaultDotColor = UIColor.txtDarkGray
        
    }
    
    // Update the current page based on some user interaction (e.g., swiping between views)
    func updatePage(to index: Int) {
        self.customPageControl.currentPage = index
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if self.workoutsDayCollView.contentSize.height != 0 {
            self.workoutsDayCollViewHeightConstrnt.constant = self.workoutsDayCollView.contentSize.height
            self.productCategoryCollView.setNeedsLayout()
            self.productCategoryCollView.layoutIfNeeded()
        }
        
        if self.productCategoryCollView.contentSize.height != 0 {
            self.productCategoryCollViewHeightConstrnt.constant = self.productCategoryCollView.contentSize.height
            self.productCategoryCollView.setNeedsLayout()
            self.productCategoryCollView.layoutIfNeeded()
        }
        
        
        view.layoutIfNeeded()
    }
}


//MARK: --------------------Extension for UICollectionview Delegate/Datasource
extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == upcomingSessionsCollView {
            //            return upcomingSessionData?.count ?? 0
            
            return collectionView.numberOfRows(count: self.upcomingSessionData?.count, title: AppStrings.no_sessions_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100, height: 100)), messageImageHeight: 100, fromTop: 10)
        }
        else if collectionView == transformationStoryCollView {
            return 3
        }
        else if collectionView == productCategoryCollView{
            return productCategory?.count ?? 0
        }
        else if collectionView == workoutsDayCollView{
            return workoutDays?.count ?? 0
        }
        else if collectionView == gymsNearbyCollView{
            return collectionView.numberOfRows(count: self.studiosData?.count, title: "No gym found", message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100.0, height: 100.0)), messageImageHeight: 100.0, fromTop: nil)
        }
        else if collectionView == dayStreakCollView{
            return 10
        }
        else if collectionView == classesNearYouCollView{
            //            return upcomingClassesData?.count ?? 0
            
            return collectionView.numberOfRows(count: self.upcomingClassesData?.count, title: "No classes found", message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100.0, height: 100.0)), messageImageHeight: 100.0, fromTop: nil)
        }
        else{
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == upcomingSessionsCollView {
            let cell:UpcomingSessionsCollectionViewCell = upcomingSessionsCollView.dequeueReusableCell(withReuseIdentifier: "UpcomingSessionsCollectionViewCell", for: indexPath) as! UpcomingSessionsCollectionViewCell
            //             self.updatePage(to: indexPath.row)
            cell.setinputData(data: upcomingSessionData?[indexPath.row])
            
            return cell
        }
        else if collectionView == transformationStoryCollView {
            let cell:TransformationStoriesCollViewCell = transformationStoryCollView.dequeueReusableCell(withReuseIdentifier: "TransformationStoriesCollViewCell", for: indexPath) as! TransformationStoriesCollViewCell
            
            
            return cell
        }
        else if collectionView == upcomingMealsCollView{
            let cell:UpcomingMealsCollectionViewCell = upcomingMealsCollView.dequeueReusableCell(withReuseIdentifier: "UpcomingMealsCollectionViewCell", for: indexPath) as! UpcomingMealsCollectionViewCell
            cell.shareBtn.isHidden = true
            cell.likeBtn.setImage(AppImages.filterUncheck, for: .normal)
            return cell
        }
        else if collectionView == classesNearYouCollView{
            let cell:UpcomingClassCollViewCell = classesNearYouCollView.dequeueReusableCell(withReuseIdentifier: "UpcomingClassCollViewCell", for: indexPath) as! UpcomingClassCollViewCell
            cell.setCell(cellData: upcomingClassesData?[indexPath.row])
            return cell
        }
        else if collectionView == gymsNearbyCollView{
            let cell:GymsNearbyCollViewCell = gymsNearbyCollView.dequeueReusableCell(withReuseIdentifier: "GymsNearbyCollViewCell", for: indexPath) as! GymsNearbyCollViewCell
            cell.voucherImgView.isHidden = true
            cell.voucherLbl.isHidden = true
            cell.setCellData(studioData: self.studiosData?[indexPath.row])
            
            return cell
        }
        else if collectionView == productCategoryCollView{
            let cell:ProductCategoryCollViewCell = productCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
            
            DispatchQueue.main.async {
                cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: cell.cellMBV.frame.height/2.0)
            }
            
            cell.titleLblTopConstrnt.constant = 9.0
            cell.titleLbl.text = self.productCategory?[indexPath.row] as? String
            
            return cell
        }
        else if collectionView == productListCollView{
            let cell:ProductsListCollViewCell = productListCollView.dequeueReusableCell(withReuseIdentifier: "ProductsListCollViewCell", for: indexPath) as! ProductsListCollViewCell
            
            return cell
        }else if collectionView == workoutsDayCollView{
            let cell:ProductCategoryCollViewCell = workoutsDayCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
            
            DispatchQueue.main.async {
                cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: cell.cellMBV.frame.height/2.0)
            }
            
            cell.titleLblTopConstrnt.constant = 9.0
            cell.titleLbl.text = self.workoutDays?[indexPath.row] as? String
            
            return cell
        }
        else if collectionView == dayStreakCollView{
            let dayStreakCell: DayStreakCollectionViewCell = dayStreakCollView.dequeueReusableCell(withReuseIdentifier: "DayStreakCollectionViewCell", for: indexPath) as! DayStreakCollectionViewCell
            
            dayStreakCell.dayStreakImgView.image = UIImage(named: "ic_dayStreakBg")?.resized(to: CGSize(width: collectionView.frame.width*0.315, height: collectionView.frame.width*0.315))
            
            dayStreakCell.cellMBV.backgroundColor = UIColor.clear
            
            DispatchQueue.main.async {
                dayStreakCell.dayStreakImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: dayStreakCell.dayStreakImgView.frame.height/2.0)
            }
            
            dayStreakCell.dayCountLbl.text = "\(indexPath.row)"
            
            return  dayStreakCell
        }
        
        else{
            return  UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == upcomingSessionsCollView {
            return CGSize(width: collectionView.frame.width*0.841, height: collectionView.frame.height)
        }
        else if collectionView == transformationStoryCollView {
            return CGSize(width: collectionView.frame.width*0.88, height: collectionView.frame.height)
        }
        else if collectionView == upcomingMealsCollView{
            return CGSize(width: collectionView.frame.width*0.75, height: collectionView.frame.height)
        }
        else if collectionView == classesNearYouCollView{
            return CGSize(width: collectionView.frame.width*0.78, height: collectionView.frame.height)
        }
        else if collectionView == gymsNearbyCollView{
            //0.78
            return CGSize(width: collectionView.frame.width*0.70, height: collectionView.frame.height)
        }
        else if collectionView == productCategoryCollView{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        else if collectionView == productListCollView{
            return CGSize(width: collectionView.frame.width*0.45, height: collectionView.frame.height)
        }
        else if collectionView == workoutsDayCollView{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        else if collectionView == dayStreakCollView{
            if let _ = isDayStreakHeight {
                self.isDayStreakHeight = nil
                self.dayStreakCollViewHeightConstrnt.constant = collectionView.frame.width*0.37
                self.dayStreakCollView.layoutIfNeeded()
            }
            return CGSize(width: collectionView.frame.width*0.37, height: collectionView.frame.width*0.37)
        }
        return CGSize(width: collectionView.frame.width*0.88, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == upcomingSessionsCollView {
            let vc:BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)
            if let isReschedule = self.upcomingSessionData?[indexPath.row].isReschedule, isReschedule, let isTrainerReschedule = self.upcomingSessionData?[indexPath.row].isTrainer {
                vc.detailsFlow = (isTrainerReschedule ? .reschedule : .rescheduleConsumer)
                
            }else{
                vc.detailsFlow = .upcoming
            }
            vc.bookingIdStr = "\(self.upcomingSessionData?[indexPath.row].id ?? 0)"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView == workoutsDayCollView{
            let cell = collectionView.cellForItem(at: indexPath) as? ProductCategoryCollViewCell
            guard let cell = cell else { return }
            cell.cellMBV.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1.0)
        }
        else if collectionView == productCategoryCollView{
            let cell = collectionView.cellForItem(at: indexPath) as? ProductCategoryCollViewCell
            guard let cell = cell else { return }
            cell.cellMBV.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1.0)
        }
        else if collectionView == gymsNearbyCollView{
            let vc:GymDetailsViewController = GymDetailsViewController.instantiate(appStoryboard: .booking)
            vc.inputStudioId = "\(self.studiosData?[indexPath.row].id ?? 0)"
            vc.inputLat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first //self.inputLat
            vc.inputLong = appUserDefaults.getLatLong()?.components(separatedBy: ",").last //self.inputLong
            vc.inputType = "gym"
            vc.gymDetailsFlow = .bookTrainerGymWorkout
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView == classesNearYouCollView{
            let vc: ClassDetailsViewController = ClassDetailsViewController.instantiate(appStoryboard: .dashboard)
            vc.scheludeIdStr = "\(upcomingClassesData?[indexPath.row].scheduleID ?? 0)"
            vc.inputLat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first //self.inputLat
            vc.inputLong = appUserDefaults.getLatLong()?.components(separatedBy: ",").last //self.inputLong
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if collectionView == workoutsDayCollView{
            let cell = collectionView.cellForItem(at: indexPath) as? ProductCategoryCollViewCell
            guard let cell = cell else { return }
            cell.cellMBV.backgroundColor = UIColor.clear
        }
        else if collectionView == productCategoryCollView{
            let cell = collectionView.cellForItem(at: indexPath) as? ProductCategoryCollViewCell
            guard let cell = cell else { return }
            cell.cellMBV.backgroundColor = UIColor.clear
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Get the visible cell closest to the center of the collection view
        if scrollView == self.upcomingSessionsCollView {
            let centerPoint = CGPoint(x: upcomingSessionsCollView.bounds.midX + upcomingSessionsCollView.contentOffset.x,
                                      y: upcomingSessionsCollView.bounds.midY + upcomingSessionsCollView.contentOffset.y)
            
            if let indexPath = upcomingSessionsCollView.indexPathForItem(at: centerPoint) {
                print("Currently visible index: \(indexPath.row)")
                
                //              self.updatePage(to: indexPath.row)
            }
        }
        self.dayStreakCardAnuimated(scrollView: scrollView)
        
    }
    
    private func dayStreakCardAnuimated(scrollView : UIScrollView){
        //MARK: -----------------USED FOR MAKE CENTER ANUIMATED CELL OF UICOLLECION VIEW
        if scrollView == self.dayStreakCollView {
            let centerX = dayStreakCollView.bounds.width / 2 + dayStreakCollView.contentOffset.x
            
            var maxX: CGFloat = -CGFloat.infinity
            var rightmostCell: DayStreakCollectionViewCell?
            
            var minX: CGFloat = CGFloat.infinity
            //            var leftmostCell: DayStreakCollectionViewCell?
            
            for cell in dayStreakCollView.visibleCells {
                guard let myCell = cell as? DayStreakCollectionViewCell else { continue }
                
                // Convert to superview to take transformations into account
                let convertedFrame = cell.superview?.convert(cell.frame, to: dayStreakCollView) ?? cell.frame
                let basePosition = convertedFrame.midX
                let distance = abs(centerX - basePosition)
                let scale = max(0.70, 1 - distance / dayStreakCollView.bounds.width)
                myCell.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                // Determine rightmost visible cell
                if convertedFrame.maxX > maxX {
                    maxX = convertedFrame.maxX
                    rightmostCell = myCell
                }
                
                // Determine leftmost visible cell
                if convertedFrame.minX < minX {
                    minX = convertedFrame.minX
                    //                    leftmostCell = myCell
                }
            }
            
            for cell in dayStreakCollView.visibleCells {
                guard let myCell = cell as? DayStreakCollectionViewCell else { continue }
                // Blur only the actual rightmost cell
                myCell.setBlurred(myCell == rightmostCell)
                // OPTIONAL: If you want to also mark the leftmost
                // myCell.setSomeLeftIndicator(myCell == leftmostCell)
            }
        }
    }
}


//MARK: ---------------------------EXTENSION FOR UITABLEVIEW DATASOURSE/DELEGATE
extension DashboardViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.numberOfRows(count: 3, title: "Get ready for your new workout plan", message: " Your trainer will get in touch with you to curate a plan tailored to your goals.", messageImage: UIImage(named: "ic_trainer_more")?.resized(to: CGSize(width: 130.0, height: 130.0)), messageImageHeight: nil, reloadBtnBgColor: nil, reloadBtnTitleColor: nil, reloadSetTitle: nil, reloadBtnImg: nil, fromTop: 1) //4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyWorkoutsTableViewCell = workoutTblView.dequeueReusableCell(withIdentifier: "MyWorkoutsTableViewCell", for: indexPath) as! MyWorkoutsTableViewCell
        
        DispatchQueue.main.async {
//            cell.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
            
            cell.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
        }
        
        cell.completedUserMBV.isHidden = true
        cell.setupcellData()
        
        return cell
    }
    
    
}

//MARK: ---------------API
extension DashboardViewController{
    
    private func checkPackage(){
        CreatePackageVM.checkPackageCreatedApi(viewController: self, inputParms: [ : ], completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            if let getData = getResultData["data"] as? [String:Any], let isPackageCreated = getData["package"] as? Bool {
                if isPackageCreated {
                    self.flowpackage = .packageCreated
                    self.setupFlowPackageCreate()
                }else{
                    self.flowpackage = .notPackage
                    self.setupFlowPackageCreate()
                }
            }
        })
    }
    
    //MARK: --------------UPCOMING SESSION
    private func bookingListApi(typeStr: String, dateStr: String?, sessionType: String?, location: String?){
//        type: 0, 1 => completed, 2 => upcoming, 0 => cancel
        
        BookingVM.getBookingApi(inputType: typeStr, inputDate: dateStr, inputSessionType: sessionType, inputLocation: location, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
           
            print("getResultData", getResultData)
            self.upcomingSessionData?.removeAll()
            
            if getResultData.status == true {
                self.upcomingSessionData?.append(contentsOf: getResultData.data ?? [])
                self.upcomingSessionsCollView.reloadData()
                
                /*
                if self.upcomingSessionData?.count != 0 {
                    self.upcomingSessionsCollViewHeightConstrnt.constant = 220
                    self.upcomingSessionsCollView.setNeedsLayout()
                    self.upcomingSessionsCollView.layoutIfNeeded()
                }
                */
            }
        })
    }
    
    //MARK: --------------------GET TRAINER LIST API
    private func getTrainerApi(inputFilter: String?, inpuntTagId: Int?){
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
            let params:[String:String] = [
                "type": "gym",
                "is_filter": "",
                "tag_id": "" ,
                "long": long,
                "lat": lat
            ]
            
            TrainerVM.gerTrainerApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                print("get trainer list result data: ", getResultData as Any)
                self.studiosData?.removeAll()
                self.studiosData?.append(contentsOf: getResultData.data?.studios ?? [])
                self.gymsNearbyCollView.reloadData()
            })
        }else{
            self.getLocation()
        }
    }
    
    private func upcomingClassesApi(){
      
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
           
            let params:[String:String] = [
                "long": long,
                "lat": lat
            ]
            
            UpcomingClassVM.upcomingClassesApi(inputParams: params, isShowLoader: true, completion: {[weak self] resultData in
                guard let self = self, let resultData = resultData  else { return }
                
                self.upcomingClassesData?.removeAll()
                self.upcomingClassesData?.append(contentsOf: resultData.data?.allClasses ?? [])
                print("self.upcomingClassesData: \(self.upcomingClassesData ?? [])")
                if let _ = self.upcomingClassesData {
                    self.classesNearYouCollView.reloadData()
                    
                    /*
                    if upcomingClassesData.count == 1 {
                        self.classesNearYouCollView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
                        
                        if let flowLayout = classesNearYouCollView.collectionViewLayout as? UICollectionViewFlowLayout {
                            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: classesNearYouCollView.bounds.width)
                        }
                    }else{
                        if let flowLayout = classesNearYouCollView.collectionViewLayout as? UICollectionViewFlowLayout {
                            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 19)
                        }
                    }
                    */
                }
            })
        }else{
            self.getLocation()
        }
    }
}


