//
//  DashboardGuestViewController.swift
//  MyPT
//
//  Created by techsaga corp on 08/11/24.
//

import UIKit
import FacebookLogin

class DashboardGuestViewController: CommonViewController {
    
    //MARK: ------------------VARIABLE
    var currentAddrText: String? = "" {
        didSet{
            self.setLeftMenu(leftImgs: [AppImages.chooseLocation, AppImages.forward], setTitle: ["\(currentAddrText?.trimmingCharacters(in: .whitespaces) ?? "")",nil], setTintColor: .appWhite, setTitleColor: .appWhite)
        }
    }
    
    var studiosData:[TrainerModel]? = []
    var upcomingClassesData:[UpcomingClassModel]? = []
    var productCategory:[String]?
    
    //MARK: -------------------IBOUTLET
    @IBOutlet weak var topNameMBV: UIView!
    @IBOutlet weak var topNameTopConstrtnt: NSLayoutConstraint!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userProfileBtn: UIButton!
    @IBOutlet weak var bookTrainerBckImgV: UIImageView!
    @IBOutlet weak var workoutMBckImgView: UIImageView!
    @IBOutlet weak var planWorkoutImgV: UIImageView!
    @IBOutlet weak var purchaseGymPassImgV: UIImageView!
    @IBOutlet weak var grabNowMBckImgV: UIImageView!
    @IBOutlet weak var grabNowMBV: UIView!
    @IBOutlet weak var shopProductsMBV: UIView!
    @IBOutlet weak var bookTrainerTitleLbl: UILabel!
    @IBOutlet weak var bookTrainerDescLbl: UILabel!
    @IBOutlet weak var bookTrainerExploreBtn: UIButton!
    @IBOutlet weak var differentWorkoutTitleLbl: UILabel!
    @IBOutlet weak var differentWorkoutExploreBtn: UIButton!
    @IBOutlet weak var planWorkoutTitleLbl: UILabel!
    @IBOutlet weak var planWorkoutExploreBtn: UIButton!
    @IBOutlet weak var purchaseGymPassMBV: UIView!
    @IBOutlet weak var purchaseGymPassTitleLbl: UILabel!
    @IBOutlet weak var purchaseGymPassDescLbl: UILabel!
    @IBOutlet weak var purchaseGymPassBtn: UIButton!
    @IBOutlet weak var transfromationStoriesTitleLbl: UILabel!
    @IBOutlet weak var nearByGymsTitleLbl: UILabel!
    @IBOutlet weak var upcomingClassesTitleLbl: UILabel!
    @IBOutlet weak var shopProductsTitleLbl: UILabel!
    @IBOutlet weak var getFreeSessionTitleLbl: UILabel!
    @IBOutlet weak var bodyAnalysisLbl: UILabel!
    @IBOutlet weak var personalizedWorkoutPlanLbl: UILabel!
    @IBOutlet weak var oneCoachingLbl: UILabel!
    @IBOutlet weak var grabNowPriceLbl: UILabel!
    @IBOutlet weak var grabNowBtn: UIButton!
    @IBOutlet weak var transformationStoriesCollView: UICollectionView!
    @IBOutlet weak var upcomingNearClassesMBV: UIView!
    @IBOutlet weak var upcomingCollView: UICollectionView!
    @IBOutlet weak var productCategoryCollView: UICollectionView!
    @IBOutlet weak var productListCollView: UICollectionView!
    @IBOutlet weak var nearByYouCollView: UICollectionView!
    @IBOutlet weak var thougthLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var onTheWayLbl: UILabel!
    @IBOutlet weak var startTrackingBtn: UIButton!
    @IBOutlet weak var trainerTrackingMBV: UIView!
    @IBOutlet weak var footerLineLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.trainerTrackingMBV.isHidden = true
        self.getLocation()
        self.productCategory = ["All Equipment",
                                "Fitness Equipment",
                                "Apparel & Accessories"
                               ]
        setUpFont()
        setupUI()
        
        purchaseGymPassMBV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(purchaseGymPassTapAct(tap: ))))
        
        let greatingTimeStr = DateFormatterHelper.shared.getTimeOfDay()
        self.userNameLbl.text = "Good " + greatingTimeStr
        
        self.lockFeature()
        self.setInputData()
        
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        self.setNavUI()
        self.topUserNameMBV()
        
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first{
            print("Current lat", lat)
            let currentLoc: String? = appUserDefaults.getCurrentAddr()
            if let currentLoc = currentLoc {
                self.currentAddrText = String(currentLoc.prefix(25))
            }
            
            self.getTrainerApi(inputFilter: "0", inpuntTagId: 0)
            self.upcomingClassesApi()
            
        }else{
            self.getLocation()
        }
        
        self.lockFeature()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.selectedCell()
        self.topUserNameMBV()
        self.getLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        
        [
            self.bookTrainerBckImgV,
            self.planWorkoutImgV,
            self.workoutMBckImgView,
            self.purchaseGymPassImgV
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0.addGradientLayer(colors: [UIColor(red: 8.0/255.0, green: 18.0/255.0, blue: 22.0/255.0, alpha: 0), UIColor(red: 22.0/255.0, green: 18.0/255.0, blue: 8.0/255.0, alpha: 0.5)], locations: [0, 1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
        })
                
        self.differentWorkoutExploreBtn.backgroundColor = UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6)
        self.planWorkoutExploreBtn.backgroundColor = UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6)
        self.purchaseGymPassBtn.backgroundColor = UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6)
       
        [
            self.bookTrainerExploreBtn,
            self.differentWorkoutExploreBtn,
            self.planWorkoutExploreBtn
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0.roundSideCorners(radius: 16.0, cornerSide: [.topRight])
        })
        
        self.purchaseGymPassBtn.roundSideCorners(radius: 16.0, cornerSide: [.topLeft])
        
        self.grabNowMBckImgV.addGradientLayer(colors: [UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 0.2), UIColor(red: 4.0/255.0, green: 4.0/255.0, blue: 5.0/255.0, alpha: 0), UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 0.2)], locations: [0, 0.5, 1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 1.0)
        
        /*
        self.grabNowBtn.setGradientMultiBorder(cornerRadius: 12.0, width: 1.0, colors: [
            UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 0),
            UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0),
            UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0),
            UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
           ], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
        
        self.grabNowBtn.addGradient(colors: [UIColor(red: 96/255.0, green: 55/255.0, blue: 9/255.0, alpha: 1), UIColor(red: 243/255.0, green: 141/255.0, blue: 27/255.0, alpha: 1), UIColor(red: 96/255.0, green: 55/255.0, blue: 9/255.0, alpha: 1)], locations: [0,0.5, 1.0], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
        */
        
    }
    
    private func topUserNameMBV(){
        //---------------------- Navigationview
        if let navigationController = self.navigationController {
            let navBarHeight = navigationController.navigationBar.frame.height
            let topSafeArea = (self.view.safeAreaInsets.top - 10.0)
            let totalTopHeight = navBarHeight + topSafeArea
            self.topNameTopConstrtnt.constant = totalTopHeight
            
            self.userProfileBtn.setNeedsLayout()
            self.userProfileBtn.layoutIfNeeded()
            self.topNameMBV.setNeedsLayout()
            self.topNameMBV.layoutIfNeeded()
        }
    }
    
    func selectedCell(){
        DispatchQueue.main.async {
            
            // Automatically select the first cell
            let firstIndexPath = IndexPath(item: 0, section: 0)
            self.productCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.productCategoryCollView.delegate?.collectionView?(self.productCategoryCollView, didSelectItemAt: firstIndexPath)
            self.view.layoutIfNeeded()
        }
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.chooseLocation, AppImages.forward], setTitle: [" \(currentAddrText ?? "")",nil], setTintColor: .appWhite, setTitleColor: .appWhite)
       
//        let logout = UIImage(named: "ic_logout")?.resized(to: CGSize(width: 25.0, height: 25.0))?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor.appWhite)
        
//        self.setRighMenu(rightImgs: [AppImages.notification], setTitle: [nil], setTintColor: UIColor.appWhite, setTitleColor: UIColor.appWhite)
  
//        self.setRighMenu(rightImgs: [AppImages.notificationCount,AppImages.notification], setTitle: ["0",nil], setTintColor: nil, setTitleColor: UIColor.appWhite)
    }
    
    private func lockFeature(){
//        self.grabNowMBV.setComingSoon(mainVTop: 0, mainVBottom: 0, centerY: -40, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title:  AppStrings.coming_soon, desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
       
        self.shopProductsMBV.setComingSoon(mainVTop: 30, mainVBottom: 0, centerY: -40, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title:  AppStrings.coming_soon, desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
      
        self.upcomingNearClassesMBV.setComingSoon(mainVTop: 30, mainVBottom: 0, centerY: -40, bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_lock_yellow", lockImgName: "ic_lock_yellow" ,title:  AppStrings.coming_soon, desc: "This feature is locked for now — stay tuned for the next phase of the app rollout!")
    }
    
    override func leftBtnActn(sender: UIButton) {
        let vc:LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
        vc.flowLocation = .homePage
        vc.isFromEditAddress = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func rightBtnActn(sender: UIButton) {
        print("right btn tag= ", sender.tag)
        /*
        if sender.tag == 0 {
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
        */
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
            self.upcomingClassesApi()
        }
    }
    
    @objc func purchaseGymPassTapAct(tap : UITapGestureRecognizer){
        print("Purchase your Gym Pass")
        
    }
    
    private func setInputData(){
//        self.getFreeSessionTitleLbl.applyGradientLabel(colors: [UIColor.appWhite, UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], locations: [0, 0.3, 1.0])
//        self.getFreeSessionTitleLbl.text = "Buy 10 Sessions,\nGet 2 Free"
    
        let getSessionStr = "Buy 10 Sessions,\nGet 2 Free"
        self.getFreeSessionTitleLbl.attributedText = getSessionStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: self.getFreeSessionTitleLbl.bounds, font: AppFont.medium.size(32.0, familyName: familyClashDisplay), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
 
        self.bodyAnalysisLbl.text = "Body \nAnalysis"
        self.personalizedWorkoutPlanLbl.text = "Personalized \nWorkout Plan"
        self.oneCoachingLbl.text = "One-on-one \nCoaching"
        
        self.bookTrainerDescLbl.text = "At Home or the Gym, \nWe’ve Got You Covered"
        self.planWorkoutTitleLbl.text = "Plan Your \nWorkout"
        self.differentWorkoutTitleLbl.text = "Explore Different \nWorkouts"
    }
    
    
    //------------------************Font
    private func setUpFont(){
        
        self.bookTrainerDescLbl.font = AppFont.medium.size(11.0, familyName: familyManrope)
        self.purchaseGymPassDescLbl.font = AppFont.medium.size(11.0, familyName: familyManrope)
        self.userNameLbl.font = AppFont.bold.size(18.0, familyName: familyManrope)
        self.getFreeSessionTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.grabNowPriceLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.grabNowBtn.titleLabel?.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        
        self.thougthLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.authorLbl.font = AppFont.regular.size(12.0, familyName: familyClashDisplay)
        self.onTheWayLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.startTrackingBtn.titleLabel?.font = AppFont.bold.size(12.0, familyName: familyManrope)
        
        [
            self.bookTrainerTitleLbl,
            self.purchaseGymPassTitleLbl,
            self.transfromationStoriesTitleLbl,
            self.upcomingClassesTitleLbl,
            self.shopProductsTitleLbl,
            self.nearByGymsTitleLbl,
            self.nearByGymsTitleLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
        
        [
            self.bookTrainerExploreBtn.titleLabel,
            self.differentWorkoutExploreBtn.titleLabel,
            self.planWorkoutExploreBtn.titleLabel,
            self.purchaseGymPassBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        [
            self.differentWorkoutTitleLbl,
            self.planWorkoutTitleLbl,
            self.bodyAnalysisLbl,
            self.personalizedWorkoutPlanLbl,
            self.oneCoachingLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
    }
    
    
    //MARK: ---------- SET UI
    private func setupUI(){
        
        //---------*************UICollectionview init
        transformationStoriesCollView.register(UINib(nibName: "TransformationStoriesCollViewCell", bundle: nil), forCellWithReuseIdentifier: "TransformationStoriesCollViewCell")
        upcomingCollView.register(UINib(nibName: "UpcomingClassCollViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingClassCollViewCell")
        productCategoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        productListCollView.register(UINib(nibName: "ProductsListCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductsListCollViewCell")
        nearByYouCollView.register(UINib(nibName: "GymsNearbyCollViewCell", bundle: nil), forCellWithReuseIdentifier: "GymsNearbyCollViewCell")
        
        //-----------*************
        DispatchQueue.main.async {
            
            self.topNameMBV.backgroundColor = UIColor.clear
            self.topNameMBV.addGradient(colors: [UIColor(red: 17.0/255.0, green: 18.0/255.0, blue: 20.0/255.0, alpha: 0.2), UIColor(red: 0/255.0, green: 5.0/255.0, blue: 2.0/255.0, alpha: 1)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1))
            self.userProfileBtn.setGradientMultiBorder(cornerRadius: 18.0, width: 1.5, colors: [UIColor(red: 207.0/255.0, green: 171.0/255.0, blue: 104.0/255.0, alpha: 1.0),UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 216.0/255.0, alpha: 1.0),UIColor(red: 173/255.0, green: 130/255.0, blue: 54/255.0, alpha: 1.0)], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            
            //            self.topNameMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0)
            
            
            [
                self.bookTrainerBckImgV,
                self.workoutMBckImgView,
                self.planWorkoutImgV,
                self.purchaseGymPassImgV,
                self.grabNowMBckImgV
            ].forEach({[weak self] in
                guard self != nil else {
                    return
                }
                $0.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
            
            self.startTrackingBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
            //            self.grabNowBtn.setCornerRadius(borderWidth: 0.6, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            //
            //            self.grabNowBtn.layerGradient(startPoint: .topLeft, endPoint: .bottomLeft, colorArray: [UIColor(red: 96/255.0, green: 55/255.0, blue: 9/255.0, alpha: 1).cgColor, UIColor(red: 243/255.0, green: 141/255.0, blue: 27/255.0, alpha: 1).cgColor, UIColor(red: 96/255.0, green: 55/255.0, blue: 9/255.0, alpha: 1).cgColor,], type: .axial)
            
            self.footerLineLbl.backgroundColor = UIColor.clear
            self.footerLineLbl.addGradient(colors: UIColor.appMultiColor(.lineVGradient2), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
        }
        
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: AppFont.medium.size(32.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
//        let makeAttributes = [
//            .font: AppFont.medium.size(16.0, familyName: familyClashDisplay),
//            .foregroundColor: UIColor.appWhite
//        ] as [NSAttributedString.Key : Any]
//        
//        let attributedNickName = [
//            "299",
//            NSAttributedString(string: "AED",
//                               attributes: makeAttributes), "329AED".strikeThrough(with: AppFont.medium.size(16.0, familyName: familyClashDisplay), color: UIColor.txtDarkGray)
//        ] as [AttributedStringComponent]
        
        
        let attributedNickName = [
            "299".attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: self.grabNowPriceLbl.bounds, font: AppFont.medium.size(32.0, familyName: familyClashDisplay), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 0)),
            "AED".attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: self.grabNowPriceLbl.bounds, font: AppFont.medium.size(16.0, familyName: familyClashDisplay), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 0)),
            "329AED".strikeThrough(with: AppFont.medium.size(16.0, familyName: familyClashDisplay), color: UIColor.appLightGray)
        ] as [AttributedStringComponent]
        
        self.grabNowPriceLbl.attributedText =  NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
        
        //-------------------------*************
        self.bookTrainerBckImgV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookTrainer(sender: ))))
        
    }
    
    @objc func bookTrainer(sender:Any){
        if appUserDefaults.clearUserDefault() {
            appSceneDelegate?.goToMainView()
        }
        
        /*
        let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
        vc.flowCreatePackage = .createPackage
        self.navigationController?.pushViewController(vc, animated: false)
        */
    }
    
    //MARK: -------------BTN ACTN
    enum CommonBtnTag: Int {
    case diffSubWorkoutExplore = 101, planWorkoutEplore, purchaseGymPass, userProfile, GrabNow
    }
    
    
    //MARK: --------------COMMON BTN ACTN
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case CommonBtnTag.diffSubWorkoutExplore.rawValue:
            let vc:LibraryViewController = LibraryViewController.instantiate(appStoryboard: .library)
            self.navigationController?.pushViewController(vc, animated: true)
        case CommonBtnTag.planWorkoutEplore.rawValue:
            let vc: CalendarViewController = CalendarViewController.instantiate(appStoryboard: .calendar)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case CommonBtnTag.purchaseGymPass.rawValue:
            
            if appUserDefaults.clearUserDefault() {
                appSceneDelegate?.goToMainView()
            }
            
            /*
            let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
            vc.flowCreatePackage = .gymMembership
            self.navigationController?.pushViewController(vc, animated: false)
            */
            
        case CommonBtnTag.userProfile.rawValue:
            if appUserDefaults.clearUserDefault() {
                appSceneDelegate?.goToMainView()
            }
            
            /*
            let vc: ProfileViewController = ProfileViewController.instantiate(appStoryboard: .profile)
            self.navigationController?.pushViewController(vc, animated: true)
            */
            
        case CommonBtnTag.GrabNow.rawValue:
            let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
            vc.flowCreatePackage = .createPackage
            self.navigationController?.pushViewController(vc, animated: false)
            
        default:
            print("None........")
            break
        }
        
        
        //        let vc:LibraryViewController = LibraryViewController.instantiate(appStoryboard: .library)
        //        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


//MARK: --------------------Extension for UICollectionview Delegate/Datasource
extension DashboardGuestViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == productCategoryCollView{
            return productCategory?.count ?? 0
        }
        else if collectionView == upcomingCollView{
            return collectionView.numberOfRows(count: self.upcomingClassesData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100.0, height: 100.0)), messageImageHeight: 100.0, fromTop: nil)
        }
        else if collectionView == nearByYouCollView{
            return collectionView.numberOfRows(count: self.studiosData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100.0, height: 100.0)), messageImageHeight: 100.0, fromTop: nil)
        }
        else{
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == transformationStoriesCollView {
            let cell:TransformationStoriesCollViewCell = transformationStoriesCollView.dequeueReusableCell(withReuseIdentifier: "TransformationStoriesCollViewCell", for: indexPath) as! TransformationStoriesCollViewCell
            
            
            return cell
        }
        else if collectionView == upcomingCollView{
            let cell:UpcomingClassCollViewCell = upcomingCollView.dequeueReusableCell(withReuseIdentifier: "UpcomingClassCollViewCell", for: indexPath) as! UpcomingClassCollViewCell
            
            cell.setCell(cellData: upcomingClassesData?[indexPath.row])
            return cell
        }
        else if collectionView == productCategoryCollView{
            let cell:ProductCategoryCollViewCell = productCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
            cell.titleLblTopConstrnt.constant = 9.0
            cell.titleLbl.text = self.productCategory?[indexPath.row] as? String
            return cell
        }
        else if collectionView == productListCollView{
            let cell:ProductsListCollViewCell = productListCollView.dequeueReusableCell(withReuseIdentifier: "ProductsListCollViewCell", for: indexPath) as! ProductsListCollViewCell
            
            return cell
        }
        else if collectionView == nearByYouCollView{
            let cell:GymsNearbyCollViewCell = nearByYouCollView.dequeueReusableCell(withReuseIdentifier: "GymsNearbyCollViewCell", for: indexPath) as! GymsNearbyCollViewCell
            
            cell.voucherImgView.isHidden = true
            cell.voucherLbl.isHidden = true
            cell.setCellData(studioData: self.studiosData?[indexPath.row])
           
            return cell
        }
        else{
            return  UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == upcomingCollView{
            if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
                let vc: ClassDetailsViewController = ClassDetailsViewController.instantiate(appStoryboard: .dashboard)
                vc.flowClassDetails = .guestUser
                vc.scheludeIdStr = "\(upcomingClassesData?[indexPath.row].scheduleID ?? 0)"
                vc.inputLat = lat
                vc.inputLong = long
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                self.getLocation()
            }
            
        }
        else if collectionView == nearByYouCollView{
            if appUserDefaults.clearUserDefault() {
                appSceneDelegate?.goToMainView()
            }
            
            /*
            let vc:GymDetailsViewController = GymDetailsViewController.instantiate(appStoryboard: .booking)
            vc.inputStudioId = "\(self.studiosData?[indexPath.row].id ?? 0)"
            vc.inputLat = self.inputLat
            vc.inputLong = self.inputLong
            vc.inputType = "gym"
            vc.gymDetailsFlow = .bookTrainerGymWorkout
            self.navigationController?.pushViewController(vc, animated: true)
            */
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == transformationStoriesCollView {
            return CGSize(width: collectionView.frame.width*0.88, height: collectionView.frame.height)
        }
        else if collectionView == upcomingCollView{
            return CGSize(width: collectionView.frame.width*0.78, height: collectionView.frame.height)
        }
        else if collectionView == productCategoryCollView{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        else if collectionView == productListCollView{
            return CGSize(width: collectionView.frame.width*0.45, height: collectionView.frame.height)
        }
        else if collectionView == nearByYouCollView{
            return CGSize(width: collectionView.frame.width*0.78, height: collectionView.frame.height)
        }
        return CGSize(width: collectionView.frame.width*0.88, height: collectionView.frame.height)
    }
    
    
}

extension DashboardGuestViewController{
    
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
                self.nearByYouCollView.reloadData()
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
                    self.upcomingCollView.reloadData()
                    
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
    
    
    
    /*
     http://mypt.test/api/book-trainer
     1=>for home 2=>for gym
     */
    
    //    func getTrainerApi(){
    //        DashboardVM.gerTrainerApi(viewController: self, inputType: "gym", completion: { [weak self] getDataResult in
    //            guard let self = self else { return  }
    //
    //            print(getDataResult as Any)
    //
    //        })
    //    }
}

