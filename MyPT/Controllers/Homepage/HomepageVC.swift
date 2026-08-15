//
//  HomepageVC.swift
//  MyPT
//
//  Created by Radha on 11/02/26.
//

import UIKit
import AVKit

class HomepageVC: CommonViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var bannerTimer: Timer?
    var currentIndex = 0
    var bannerData: [HomepageBannerData]?
    var homeTopData: [HomePageData]?
    var homeStories: GetStoriesData?
    var storyList: [Story] = []
    var trainerData: [TrainerModel]? = []
    var gymTrainerData: [GymTrainerModel]? = []
    var homeStoriesData: [Datum]?
    var assesmentStatusData: AssesmentStatusData?
    var getLat: Double?
    var getLong: Double?
    var addressData: [AddressDataModel]? = []
    var userPlans = [PlanDetailsModel]()
    private var isHomeTrainerSelected: Bool = true
    //    var currentAddrText: String? = "" {
    //        didSet{
    ////            self.setLeftMenu(leftImgs: [AppImages.chooseLocation, AppImages.forward], setTitle: ["\(currentAddrText?.trimmingCharacters(in: .whitespaces) ?? "")",nil], setTintColor: .appWhite, setTitleColor: .appWhite)
    //        }
    //    }
    
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var vieTop: UIView!
    @IBOutlet weak var imageTop: UIImageView!
    @IBOutlet weak var lblSeeMyPtAction: UILabel!
    @IBOutlet weak var viewPtAction: UIView!
    @IBOutlet weak var collectionMyPt: UICollectionView!
    @IBOutlet weak var viewBanner: UIView!
    @IBOutlet weak var collectionBanner: UICollectionView!
    @IBOutlet weak var viewMeetYourMatch: UIView!
    @IBOutlet weak var lblMeetMatch: UILabel!
    @IBOutlet weak var collectionTrainer: UICollectionView!
    @IBOutlet weak var imgGreenLocation: UIImageView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var lbl1: UILabel!
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var lbl2: UILabel!
    
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var offerImg: UIImageView!
    @IBOutlet weak var btnNameInitial: UIButton!
    @IBOutlet weak var imgHeader: UIImageView!
//    @IBOutlet weak var meetYourMatchSegment: UISegmentedControl!
    @IBOutlet weak var viewTrainersType: UIView!
    @IBOutlet weak var btnHomeTrainers: UIButton!
    @IBOutlet weak var btnGymTrainers: UIButton!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var btnBookFreeAss: UIButton!

    /// Group Classes carousel, inserted into the storyboard's content stack view
    /// at runtime (see `setupGroupClassesSection()`).
    private var groupClassesCarousel: GroupClassesCarouselView?

    private weak var notificationUnreadDot: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setupGroupClassesSection()
        lblAddress.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        notificationUnreadDot = NotificationBellInstaller.install(leftOf: btnNameInitial, in: self)

    }

    // MARK: - Group Classes carousel

    /// Inserts the Group Classes carousel directly below the banner section,
    /// matching Android's `fragment_guest_user_home_new.xml` where
    /// `groupClassesSection` sits between the banner/dots block and the
    /// "Meet Your Match" trainer tabs.
    ///
    /// This is the guest / no-active-package home screen — a *different*
    /// controller from `ActiveHomepageVCViewController`, so it needs its own
    /// wiring (Android wires both `GuestUserHomeFragmentNew` and
    /// `ActiveUserHomeFragmentNew` the same way).
    private func setupGroupClassesSection() {
        guard groupClassesCarousel == nil else { return }

        groupClassesCarousel = GroupClassesCarouselView.insert(after: viewBanner) { [weak self] tapThroughData in
            guard let self = self else { return }
            GroupClassNavigator.pushDetail(from: self, data: tapThroughData)
        }
        groupClassesCarousel?.onSeeAllTapped = { [weak self] in
            guard let self = self else { return }
            let controller = SeeAllGroupClassesViewController()
            controller.initialLat = self.getLat ?? GroupClassCardFormatter.fallbackLatitude
            controller.initialLng = self.getLong ?? GroupClassCardFormatter.fallbackLongitude
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }

        if groupClassesCarousel == nil {
            print("GroupClasses: banner anchor not found — carousel not inserted")
        }
    }

    private func loadGroupClasses() {
        groupClassesCarousel?.loadClasses(lat: getLat, long: getLong)
    }
    
    private func uiSetup() {
        self.collectionMyPt.delegate = self
        self.collectionMyPt.dataSource = self
        self.collectionBanner.delegate = self
        self.collectionBanner.dataSource = self
        self.collectionTrainer.delegate = self
        self.collectionTrainer.dataSource = self
        self.collectionMyPt.register(
        UINib(nibName: "SeePtActionCVCell", bundle: nil),
        forCellWithReuseIdentifier: "SeePtActionCVCell"
    )
    
        self.collectionBanner.register(
        UINib(nibName: "BannerHomepageCVCell", bundle: nil),
        forCellWithReuseIdentifier: "BannerHomepageCVCell"
    )
    
        self.collectionTrainer.register(
        UINib(nibName: "GridTrainerCollectionViewCell", bundle: nil),
        forCellWithReuseIdentifier: "GridTrainerCollectionViewCell"
    )
        DispatchQueue.main.async {
            self.pageController.currentPageIndicatorTintColor = .white
            self.pageController.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.5)
            self.btnHomeTrainers.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.btnGymTrainers.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.btnNameInitial.titleLabel?.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
            self.btnNameInitial.tintColor = UIColor(red: 178.0/255.0, green: 107.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            self.lblType.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblAddress.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            [self.lblSeeMyPtAction, self.lblMeetMatch].forEach {
                $0?.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
            }
            [self.lbl1, self.lbl2, self.lbl3].forEach {
                $0?.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
            }
            
            self.imageTop.roundBottomCorners(radius: 24)
            let selectedTextAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black
            ]

            let normalTextAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white
            ]

//            self.meetYourMatchSegment.setTitleTextAttributes(normalTextAttributes, for: .normal)
//            self.meetYourMatchSegment.setTitleTextAttributes(selectedTextAttributes, for: .selected)

            // Selected segment background
//            self.meetYourMatchSegment.selectedSegmentTintColor = .white
            
            self.btnBookFreeAss.setTitle(" Get Your Free Fitness Assessment", for: .normal)
            self.btnBookFreeAss.setImage(UIImage(named: "Chevron Right"), for: .normal)
            self.btnBookFreeAss.semanticContentAttribute = .forceRightToLeft
            self.btnBookFreeAss.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
            self.btnBookFreeAss.tintColor = .white   // arrow color
            self.btnBookFreeAss.setTitleColor(.white, for: .normal)
            self.btnBookFreeAss.cornersWithBorder(radius: 8, corners: .allCorners)
            self.btnBookFreeAss.imageView?.contentMode = .scaleAspectFit

            // Reduce spacing between title & image
            self.btnBookFreeAss.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
            self.btnBookFreeAss.titleEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewTrainersType.layer.cornerRadius = 24
        btnHomeTrainers.layer.cornerRadius = 18
        btnGymTrainers.layer.cornerRadius = 18
        btnHomeTrainers.layer.masksToBounds = true
        btnGymTrainers.layer.masksToBounds = true
        self.navigationController?.isNavigationBarHidden = true
        NotificationBellInstaller.refreshUnreadBadge(notificationUnreadDot)
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first,
            let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last {
            print("Current lat", lat)
            self.getLat = Double(lat)
            self.getLong = Double(long)
            let currentLoc: String? = appUserDefaults.getCurrentAddr()
            if let currentLoc = currentLoc {
                self.lblAddress.text = String(currentLoc.prefix(25))
            }
            self.getTrainerApi(inputFilter: "0", inpuntTagId: 0)
//            self.getSelectGymList(trainerId: "")
            //            self.upcomingClassesApi()
            
        } else {
            self.getLocation()
        }
        
        if let userName = appUserDefaults.getUserName() {
            self.btnNameInitial.setTitle(userName.filter({$0.isLetter}).prefix(1).uppercased(), for: .normal)
        }
        self.getAddressListApi()
        self.getPlansApi()
        getTopContentsApi()
        getStoriesApi()
        getBannerApi()
        checkAssessmentStatusApi()
        loadGroupClasses()
        updateTrainerSelection(isHomeTrainerSelected: true)
        groupClassesCarousel?.startRealtime()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        groupClassesCarousel?.stopRealtime()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(view.subviews)
    }
    
    private func getLocation() {
        GetLocationManager.shared.requestLocationWithAddress {[weak self] location, addressPart in
            guard let self = self, let getLocation = location else { return }
            
            appUserDefaults.setLatLong(value: "\(location?.coordinate.latitude ?? 0),\(location?.coordinate.longitude ?? 0)")
            appUserDefaults.setCurrentAddr(value: addressPart.0)
            self.getLat = getLocation.coordinate.latitude
            self.getLong = getLocation.coordinate.longitude
            let currentLoc: String? = addressPart.0
            if let currentLoc = currentLoc {
                self.lblAddress.text = String(currentLoc.prefix(25))
            }
            
            self.getTrainerApi(inputFilter: "0", inpuntTagId: 0)
            self.loadGroupClasses()
            //            self.upcomingClassesApi()
        }
    }

    private func hasPlan(type: String) -> Bool {
        return self.userPlans.contains {
            $0.type?.value == type
        }
    }
    
    private func setUpData() {
        if let homeBGImageData = homeTopData?.filter({$0.id == 4}) {
            if let bgImage = homeBGImageData.first?.image {
                imageTop.loadImage(urlString: bgImage, placeholder: nil)
            }
        }
        
        if let homeBGImageData = homeTopData?.filter({$0.id == 13}) {
            if let bgImage = homeBGImageData.first?.image {
                imgHeader.loadImage(urlString: bgImage, placeholder: nil)
            }
        }
        
        if let homeBGImageData = homeTopData?.filter({$0.id == 14}) {
            if let bgImage = homeBGImageData.first?.image {
                offerImg.loadImage(urlString: bgImage, placeholder: nil)
            }
        }
        
//        if let homeBGImageData = homeTopData?.filter({$0.id == 15}) {
//            if let bgImage = homeBGImageData.first?.image {
//                btnBookFreeAss.loadImage(urlString: bgImage, placeholder: nil)
//            }
//        }
        DispatchQueue.main.async {
            if let homeBGImageData = self.homeTopData?.filter({$0.id == 15}),
               let bgImage = homeBGImageData.first?.image,
               let url = URL(string: bgImage),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                self.btnBookFreeAss.setBackgroundImage(image, for: .normal)
            }
        }

        if let homeBGImageData = homeTopData?.filter({$0.id == 6}) {
            if let bgImage = homeBGImageData.first?.image {
                img1.loadImage(urlString: bgImage, placeholder: nil)
            }
            lbl1.text = homeBGImageData.first?.name
        }
        
        if let homeBGImageData = homeTopData?.filter({$0.id == 7}) {
            if let bgImage = homeBGImageData.first?.image {
                img2.loadImage(urlString: bgImage, placeholder: nil)
            }
            lbl2.text = homeBGImageData.first?.name
        }
        
        if let homeBGImageData = homeTopData?.filter({$0.id == 8}) {
            if let bgImage = homeBGImageData.first?.image {
                img3.loadImage(urlString: bgImage, placeholder: nil)
            }
            lbl3.text = homeBGImageData.first?.name
        }
        if let userName = appUserDefaults.getUserName() {
            self.btnNameInitial.setTitle(userName.filter({$0.isLetter}).prefix(1).uppercased(), for: .normal)
        }
        self.collectionBanner.reloadData()
    }
    
    private func onTapHomeOrGymPlan(planType: String) {
        print("Continue btn actn.....")
        if self.addressData?.count != 0 { // when address is
            guard let getLat = getLat,
                  let getLong = getLong else {
                getLocation()
                return
            }
            if planType == "home" { // Home
                let homeTrue = hasPlan(type: "home")
                if homeTrue { // If user have package
                    let vc: ChoosePrimaryTrainerVC = ChoosePrimaryTrainerVC.instantiate(appStoryboard: .purchase)
                    //                    vc.packageType = packageType
                    vc.inputType = "home"
                    vc.inputLat = getLat
                    vc.inputLong = getLong
                    vc.inputParam = DetailsParam(
                        type: "home",
                        long: "\(self.getLong ?? 0.0)",
                        lat: "\(self.getLat ?? 0.0)",
                        addressId: self.addressData?.first?.id?.value,
                        addressData: self.addressData?.first
                    )
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else { // If user does not have package
                    let vc: CreatePackageViewViewController = CreatePackageViewViewController.instantiate(appStoryboard: .booking)
                    vc.inputType = "home"
                    vc.inputLat = getLat
                    vc.inputLong = getLong
                    vc.inputParam = DetailsParam(
                        type: "home",
                        long: "\(self.getLong ?? 0.0)",
                        lat: "\(self.getLat ?? 0.0)",
                        addressId: self.addressData?.first?.id?.value,
                        addressData: self.addressData?.first
                    )
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else { // GYM
                // Normal Flow
                let vc: GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
                vc.flowGymwork = .bookTrainerGymWorkout
                vc.inputType = "gym"
                vc.inputLat = getLat
                vc.inputLong = getLong
                vc.hasGymPackage = hasPlan(type: "gym") // check for user have package or not
                vc.inputParam = DetailsParam(
                    type: "gym",
                    long: "\(self.getLong ?? 0.0)",
                    lat: "\(self.getLat ?? 0.0)",
                    isFreeAssessmentSelected: false
                )
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc: LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
            vc.flowLocation = .addAddress
            vc.isFromEditAddress = false
            vc.inputType = planType == "home" ? "home" : "gym"
            vc.inputLat = "\(getLat ?? 0.0)"
            vc.inputLong = "\(getLong ?? 0.0)"
            vc.isFreeAssessmentSelected = false
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func updateTrainerSelection(isHomeTrainerSelected: Bool) {
        self.isHomeTrainerSelected = isHomeTrainerSelected
        let darkColor = UIColor(
            red: 24/255,
            green: 29/255,
            blue: 32/255,
            alpha: 1
        )
        
        if isHomeTrainerSelected {
            // Best Plan Selected
            btnHomeTrainers.backgroundColor = .white
            btnHomeTrainers.setTitleColor(.black, for: .normal)
            
            btnGymTrainers.backgroundColor = darkColor
            btnGymTrainers.setTitleColor(.white, for: .normal)
            self.getTrainerApi(inputFilter: "0", inpuntTagId: 0)
        } else {
            // Customization Selected
            btnGymTrainers.backgroundColor = .white
            btnGymTrainers.setTitleColor(.black, for: .normal)
            
            btnHomeTrainers.backgroundColor = darkColor
            btnHomeTrainers.setTitleColor(.white, for: .normal)
            self.getSelectGymList(trainerId: "")
        }
    }
    
    func startAutoScroll() {
        bannerTimer?.invalidate()
        
        bannerTimer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(scrollBanner), userInfo: nil, repeats: true)
    }
    
    @objc func scrollBanner() {
        guard let count = bannerData?.count, count > 0 else { return }
        
        if currentIndex < count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0 // loop back
        }
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        
        collectionBanner.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageController.currentPage = currentIndex
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        currentIndex = page
        pageController.currentPage = page
    }
    
    deinit {
        bannerTimer?.invalidate()
    }

    @IBAction func onTapTrainers(_ sender: UIButton) {
        TapticEngine.selection.feedback()
        updateTrainerSelection(isHomeTrainerSelected: sender.tag == 0)
    }
    
    @IBAction func onTapLocation(_ sender: UIButton) {
        let vc: LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
        vc.flowLocation = .homePage
        vc.isFromEditAddress = false
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapProfile(_ sender: UIButton) {
        TapticEngine.selection.feedback()
        let vc: ProfileViewController = ProfileViewController.instantiate(appStoryboard: .profile)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapBookAssessment(_ sender: UIButton) {
        if self.assesmentStatusData?.can_book ?? false {
            let vc: AssesmentDemoVC = AssesmentDemoVC.instantiate(appStoryboard: .homepage)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.assesmentStatusData?.is_completed ?? false {
            let vc: MyAssessmentViewController = MyAssessmentViewController.instantiate(appStoryboard: .homepage)
//            vc.assesmentStatusData = self.assesmentStatusData
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc: AssessmentBookingDetailViewController = AssessmentBookingDetailViewController.instantiate(appStoryboard: .homepage)
            vc.assesmentStatusData = assesmentStatusData
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onTapTopCards(_ sender: UIButton) {
        TapticEngine.selection.feedback()
        if sender.tag == 0 { // Home
            onTapHomeOrGymPlan(planType: "home")
//            let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
//            vc.isHomeOrGymSelected = true
//            vc.isHomePreSelected = true
//            self.navigationController?.pushViewController(vc, animated: false)
        } else if sender.tag == 1 { // Gym
            onTapHomeOrGymPlan(planType: "gym")
//            let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
//            vc.isHomeOrGymSelected = true
//            vc.isHomePreSelected = false
//            self.navigationController?.pushViewController(vc, animated: false)
        } else  { // Membership
            let vc: GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
            vc.flowGymwork = .withoutTrainerMembership
            vc.inputType = "gym"
            vc.inputLat = Double(appUserDefaults.getLatLong()?.components(separatedBy: ",").first ?? "0.0")
            vc.inputLong = Double(appUserDefaults.getLatLong()?.components(separatedBy: ",").last ?? "0.0")
            vc.inputParam = DetailsParam(
                type: "gym",
                long: appUserDefaults.getLatLong()?.components(separatedBy: ",").last ?? "0.0",
                lat: appUserDefaults.getLatLong()?.components(separatedBy: ",").first ?? "0.0"
            )
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onTapChooseYourPlan(_ sender: UIButton) {
        let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func onTapAssessment(_ sender: UIButton) {
        if self.assesmentStatusData?.can_book ?? false {
            let vc: AssesmentDemoVC = AssesmentDemoVC.instantiate(appStoryboard: .homepage)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.assesmentStatusData?.is_completed ?? false {
            let vc: MyAssessmentViewController = MyAssessmentViewController.instantiate(appStoryboard: .homepage)
//            vc.assesmentStatusData = self.assesmentStatusData
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc: AssessmentBookingDetailViewController = AssessmentBookingDetailViewController.instantiate(appStoryboard: .homepage)
            vc.assesmentStatusData = assesmentStatusData
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func bookSlotBtnActn(sender: UIButton) {
        TapticEngine.selection.feedback()
        if isHomeTrainerSelected {
            let getIndx = self.trainerData?.firstIndex(where: {
                $0.id == Int(sender.accessibilityHint ?? "0")
            })
            if let getIndx = getIndx {
                let trainerDetails = self.trainerData?[getIndx]
                if trainerDetails?.isPackage ?? false { // Old Flow to book a slot
                    if let isFull = trainerDetails?.isfull, let slotAvail = trainerDetails?.slot?.value, isFull && slotAvail.lowercased() == "no".lowercased() {
                        AlertHelper.shared.alertMesssage(view: self, title: "", message: "No slots available")
                        print("No slots available")
                    } else {
                        let vc: SelectYourLocationViewController = SelectYourLocationViewController.instantiate(appStoryboard: .booking)
                        vc.trainerIdStr = "\(trainerDetails?.id ?? 0)"
                        //                            vc.studioIdStr = studioId
                        vc.inputType = "home"
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else { // New Flow without slot booking
                    let homeTrue = hasPlan(type: "home")
                    if homeTrue { // If user have package
                        let vc: ChoosePrimaryTrainerVC = ChoosePrimaryTrainerVC.instantiate(appStoryboard: .purchase)
                        //                    vc.packageType = packageType
                        vc.inputType = "home"
                        vc.inputLat = getLat
                        vc.inputLong = getLong
                        vc.inputParam = DetailsParam(
                            trainer_id: "\(trainerDetails?.id ?? 0)",
                            type: "home",
                            long: "\(self.getLong ?? 0.0)",
                            lat: "\(self.getLat ?? 0.0)",
                            addressId: self.addressData?.first?.id?.value,
                            addressData: self.addressData?.first,
                            isGroup: trainerDetails?.is_group ?? false,
                            isFromHomeTrainers: true
                        )
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else { // If user does not have package
                        let vc: CreatePackageViewViewController = CreatePackageViewViewController.instantiate(appStoryboard: .booking)
                        vc.inputType = "home"
                        vc.inputLat = getLat
                        vc.inputLong = getLong
                        vc.inputParam = DetailsParam(
                            trainer_id: "\(trainerDetails?.id ?? 0)",
                            type: "home",
                            long: "\(self.getLong ?? 0.0)",
                            lat: "\(self.getLat ?? 0.0)",
                            addressId: self.addressData?.first?.id?.value,
                            addressData: self.addressData?.first,
                            isGroup: trainerDetails?.is_group ?? false,
                            isFromHomeTrainers: true
                        )
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        } else { // For Gym Trainers
            let getIndx = self.gymTrainerData?.firstIndex(where: {
                $0.id == Int(sender.accessibilityHint ?? "0")
            })
            if let getIndx = getIndx {
                let trainerDetails = self.gymTrainerData?[getIndx]
                let vc: TrainerGymAddressVC = TrainerGymAddressVC.instantiate(appStoryboard: .homepage)
                vc.modalPresentationStyle = .automatic
                vc.inputParam = DetailsParam(
                    trainer_id: "\(trainerDetails?.id ?? 0)",
                    type: "gym",
                    long: "\(self.getLong ?? 0.0)",
                    lat: "\(self.getLat ?? 0.0)",
                    addressId: self.addressData?.first?.id?.value,
                    addressData: self.addressData?.first,
                    isGroup: trainerDetails?.is_group ?? false,
                    isFromHomeTrainers: true
                )
                vc.callBack = { studioDetails in
                    if trainerDetails?.isPackage ?? false {  // Old Flow to book a slot
                        if let isFull = trainerDetails?.isfull , let slotAvail = trainerDetails?.slot, isFull && slotAvail.lowercased() == "no".lowercased() {
                            AlertHelper.shared.alertMesssage(view: self, title: "", message: "No slots available")
                            print("No slots available")
                        } else {
                            let currentMonth = Calendar.current.component(.month, from: Date())
                            let vc: BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
                            vc.slotBookFlow = .bookTrainerGymWorkout
                            vc.studioIdStr = "\(studioDetails.id ?? 0)"
                            vc.params = AvailParmsModel(type: "gym", trainer_id: "\(trainerDetails?.id ?? 0)", studio_id: "\(studioDetails.id ?? 0)", month: "\(currentMonth)", address_id: "")
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else { // New Flow without slot booking
                        let gymTrue = self.hasPlan(type: "gym")
                        if gymTrue { // If user have package
                            let vc: ChoosePrimaryTrainerVC = ChoosePrimaryTrainerVC.instantiate(appStoryboard: .purchase)
                            //                    vc.packageType = packageType
                            vc.inputType = "gym"
                            vc.inputLat = self.getLat
                            vc.inputLong = self.getLong
                            vc.inputParam = DetailsParam(
                                trainer_id: "\(trainerDetails?.id ?? 0)",
                                studio_id: "\(studioDetails.id ?? 0)",
                                type: "gym",
                                long: "\(self.getLong ?? 0.0)",
                                lat: "\(self.getLat ?? 0.0)",
                                addressId: self.addressData?.first?.id?.value,
                                addressData: self.addressData?.first,
                                isGroup: trainerDetails?.is_group ?? false,
                                isFromHomeTrainers: true
                            )
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else { // If user does not have package
                            let vc: CreatePackageViewViewController = CreatePackageViewViewController.instantiate(appStoryboard: .booking)
                            vc.inputType = "gym"
                            vc.inputLat = self.getLat
                            vc.inputLong = self.getLong
                            vc.inputParam = DetailsParam(
                                trainer_id: "\(trainerDetails?.id ?? 0)",
                                studio_id: "\(studioDetails.id ?? 0)",
                                type: "gym",
                                long: "\(self.getLong ?? 0.0)",
                                lat: "\(self.getLat ?? 0.0)",
                                addressId: self.addressData?.first?.id?.value,
                                addressData: self.addressData?.first,
                                isGroup: trainerDetails?.is_group ?? false,
                                isFromHomeTrainers: true
                            )
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                self.present(vc, animated: true)
            }
        }
    }
    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionMyPt {
            let count = homeStoriesData?.count ?? 0
            if count == 0 {
                collectionView.showEmptyView(
                    title: "No Result Found",
                    image: AppImages.search_NoResult,
                    centerOffset: -30   // adjust if needed
                )
            } else {
                collectionView.restoreEmptyView()
            }
            return count
        } else if collectionView == collectionBanner {
            return bannerData?.count ?? 0
        } else if collectionView == collectionTrainer {
            let count = isHomeTrainerSelected ? trainerData?.count ?? 0 : gymTrainerData?.count ?? 0
            if count == 0 {
                collectionView.showEmptyView(
                    title: "No Result Found",
                    image: AppImages.search_NoResult,
                    centerOffset: -30   // adjust if needed
                )
            } else {
                collectionView.restoreEmptyView()
            }
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionMyPt {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeePtActionCVCell", for: indexPath) as? SeePtActionCVCell else { return UICollectionViewCell() }
            if let singleStoryData = homeStoriesData?[indexPath.row] {
                cell.configure(with: singleStoryData)
            }
            return cell
        } else if collectionView == collectionBanner {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerHomepageCVCell", for: indexPath) as? BannerHomepageCVCell else { return UICollectionViewCell() }
            cell.imgBanner.sd_setImage(with: URL(string: bannerData?[indexPath.row].image ?? ""), placeholderImage: UIImage(named: "placeholder"))
            //            cell.cellConfigure(customData: self.customisePlans)
            //
            return cell
        } else if collectionView == collectionTrainer {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridTrainerCollectionViewCell", for: indexPath
            ) as! GridTrainerCollectionViewCell
            cell.viewProfileBtn.setTitle("BOOK THIS TRAINER", for: .normal)
            cell.trainerTagsData = isHomeTrainerSelected ? self.trainerData?[indexPath.row].tags : self.gymTrainerData?[indexPath.row].tags
            if isHomeTrainerSelected {
                cell.setupCellData(trainerData: self.trainerData?[indexPath.row])
            } else {
                cell.setGymCellData(trainerData: self.gymTrainerData?[indexPath.row])
            }
            
            cell.viewProfileBtn.accessibilityHint = isHomeTrainerSelected ? "\(self.trainerData?[indexPath.row].id ?? 0)" : "\(self.gymTrainerData?[indexPath.row].id ?? 0)"
//            cell.viewProfileBtn.isHidden = true
            cell.distanceBtn.titleLabel?.numberOfLines = 1
            cell.distanceBtn.titleLabel?.lineBreakMode = .byClipping
            cell.viewProfileBtn.addTarget(self, action: #selector(bookSlotBtnActn(sender: )), for: .touchUpInside)
            //            cell.viewProfileBtn.addTarget(self, action: #selector(viewProfileBtnActn(sender: )), for: .touchUpInside)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionMyPt {
            return CGSize(width: (collectionView.frame.size.width - 10) / 4.1, height: 140)
        } else if collectionView == collectionBanner {
            return CGSize(width: collectionView.frame.size.width, height: 330)
        } else if collectionView == collectionTrainer {
            let cellWdth = collectionView.frame.size.width/2
            return CGSize(width: cellWdth, height: collectionView.frame.size.height )
        }
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collectionTrainer {
            return 15
        } else if collectionView == collectionBanner {
            return 20
        }
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collectionTrainer {
            return 20
        } else {
            return 10
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionMyPt {
            let storiesList = homeStoriesData?[indexPath.row].stories
            let vc : ViewStoryVC = ViewStoryVC.instantiate(appStoryboard: .homepage)
            vc.hidesBottomBarWhenPushed = true
            let cell = collectionView.cellForItem(at: indexPath) as? SeePtActionCVCell
            vc.currStories = storiesList
            vc.userImage = cell?.imgaction.image
            vc.userName = cell?.lblActionName.text
            self.navigationController?.pushViewController(vc, animated: true)
        } else if collectionView == collectionTrainer {
            if isHomeTrainerSelected { // only for home trainers
                let vc: TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
                vc.hasHomePackage = hasPlan(type: "home")
                vc.hasGymPackage = hasPlan(type: "gym")
                vc.inputParam = DetailsParam(
                    trainer_id: isHomeTrainerSelected ? "\(self.trainerData?[indexPath.row].id ?? 0)" : "\(self.gymTrainerData?[indexPath.row].id ?? 0)",
                    //                studio_id: !isHomeTrainerSelected ? "\(self.gymTrainerData?[indexPath.row].id ?? 0)" : "",
                    type: isHomeTrainerSelected ? "home" : "gym",
                    long: "\(self.getLong ?? 0.0)",
                    lat: "\(self.getLat ?? 0.0)",
                    addressId: self.addressData?.first?.id?.value,
                    addressData: self.addressData?.first,
                    isFreeAssessmentSelected: false,
                    isGroup: isHomeTrainerSelected ? self.trainerData?[indexPath.row].is_group ?? false : self.gymTrainerData?[indexPath.row].is_group ?? false,
                    isFromHomeTrainers: true
                )
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let trainerDetails = self.gymTrainerData?[indexPath.row]
                let vc: TrainerGymAddressVC = TrainerGymAddressVC.instantiate(appStoryboard: .homepage)
                vc.modalPresentationStyle = .automatic
                vc.inputParam = DetailsParam(
                    trainer_id: "\(trainerDetails?.id ?? 0)",
                    type: "gym",
                    long: "\(self.getLong ?? 0.0)",
                    lat: "\(self.getLat ?? 0.0)",
                    addressId: self.addressData?.first?.id?.value,
                    addressData: self.addressData?.first,
                    isGroup: trainerDetails?.is_group ?? false,
                    isFromHomeTrainers: true
                )
                vc.callBack = { studioDetails in
                    let vc: TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
                    vc.hasHomePackage = self.hasPlan(type: "home")
                    vc.hasGymPackage = self.hasPlan(type: "gym")
                    vc.inputParam = DetailsParam(
                        trainer_id: self.isHomeTrainerSelected ? "\(self.trainerData?[indexPath.row].id ?? 0)" : "\(self.gymTrainerData?[indexPath.row].id ?? 0)",
                        studio_id:  "\(studioDetails.id ?? 0)",
                        type: self.isHomeTrainerSelected ? "home" : "gym",
                        long: "\(self.getLong ?? 0.0)",
                        lat: "\(self.getLat ?? 0.0)",
                        addressId: self.addressData?.first?.id?.value,
                        addressData: self.addressData?.first,
                        isFreeAssessmentSelected: false,
                        isGroup: self.isHomeTrainerSelected ? self.trainerData?[indexPath.row].is_group ?? false : self.gymTrainerData?[indexPath.row].is_group ?? false,
                        isFromHomeTrainers: true
                    )
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
//                    if trainerDetails?.isPackage ?? false {  // Old Flow to book a slot
//                        if let isFull = trainerDetails?.isfull , let slotAvail = trainerDetails?.slot, isFull && slotAvail.lowercased() == "no".lowercased() {
//                            AlertHelper.shared.alertMesssage(view: self, title: "", message: "No slots available")
//                            print("No slots available")
//                        } else {
//                            let currentMonth = Calendar.current.component(.month, from: Date())
//                            let vc: BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
//                            vc.slotBookFlow = .bookTrainerGymWorkout
//                            vc.studioIdStr = "\(studioDetails.id ?? 0)"
//                            vc.params = AvailParmsModel(type: "gym", trainer_id: "\(trainerDetails?.id ?? 0)", studio_id: "\(studioDetails.id ?? 0)", month: "\(currentMonth)", address_id: "")
//                            vc.hidesBottomBarWhenPushed = true
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        }
//                    } else { // New Flow without slot booking
//                        let gymTrue = self.hasPlan(type: "gym")
//                        if gymTrue { // If user have package
//                            let vc: ChoosePrimaryTrainerVC = ChoosePrimaryTrainerVC.instantiate(appStoryboard: .purchase)
//                            //                    vc.packageType = packageType
//                            vc.inputType = "gym"
//                            vc.inputLat = self.getLat
//                            vc.inputLong = self.getLong
//                            vc.inputParam = DetailsParam(
//                                trainer_id: "\(trainerDetails?.id ?? 0)",
//                                studio_id: "\(studioDetails.id ?? 0)",
//                                type: "gym",
//                                long: "\(self.getLong ?? 0.0)",
//                                lat: "\(self.getLat ?? 0.0)",
//                                addressId: self.addressData?.first?.id?.value,
//                                addressData: self.addressData?.first,
//                                isGroup: trainerDetails?.is_group ?? false,
//                                isFromHomeTrainers: true
//                            )
//                            vc.hidesBottomBarWhenPushed = true
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        } else { // If user does not have package
//                            let vc: CreatePackageViewViewController = CreatePackageViewViewController.instantiate(appStoryboard: .booking)
//                            vc.inputType = "gym"
//                            vc.inputLat = self.getLat
//                            vc.inputLong = self.getLong
//                            vc.inputParam = DetailsParam(
//                                trainer_id: "\(trainerDetails?.id ?? 0)",
//                                studio_id: "\(studioDetails.id ?? 0)",
//                                type: "gym",
//                                long: "\(self.getLong ?? 0.0)",
//                                lat: "\(self.getLat ?? 0.0)",
//                                addressId: self.addressData?.first?.id?.value,
//                                addressData: self.addressData?.first,
//                                isGroup: trainerDetails?.is_group ?? false,
//                                isFromHomeTrainers: true
//                            )
//                            vc.hidesBottomBarWhenPushed = true
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        }
//                    }
                }
                self.present(vc, animated: true)
            }
        }
    }
    
    // MARK: - Api's
    private func getTopContentsApi() {
        HomepageViewModel.homepageApi(params: nil) { [weak self] result in
            guard let self = self else { return }
            
            if let plans = result?.data {
                self.homeTopData = plans
                setUpData()
                //                self.collectionBestPlan.reloadData()
                //                DispatchQueue.main.async {
                //                    self.updateBottomLabelsForBestPlan()
                //                }
            }
        }
    }
    
    private func getBannerApi() {
        HomepageViewModel.homepageBannerApi(params: nil) { [weak self] result in
            guard let self = self else { return }
            
            if let banner = result?.data {
                self.bannerData = banner
                DispatchQueue.main.async {
                    self.collectionBanner.reloadData()
                    self.startAutoScroll()
                    self.pageController.numberOfPages = self.bannerData?.count ?? 0
                    self.pageController.currentPage = 0
                }
            }
        }
    }
   
    private func getStoriesApi() {
        HomepageViewModel.getStoriesApi(params: nil) { [weak self] result in
            guard let self = self else { return }
            
            if let storiesData = result?.data?.data {
                self.homeStoriesData = storiesData
                DispatchQueue.main.async {
                    self.collectionMyPt.reloadData()
                }
            }
        }
    }
    
    private func checkAssessmentStatusApi() {
        HomepageViewModel.checkAssessmentStatusApi(params: nil) { [weak self] result in
            guard let self = self else { return }
            
            if let assesmentData = result?.data {
                self.assesmentStatusData = assesmentData
            }
        }
    }
    
    // MARK: --------------------GET TRAINER LIST API
    private func getTrainerApi(inputFilter: String?, inpuntTagId: Int?){
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
            let params:[String:String] = [
                "type": "home",
                "is_filter": "",
                "tag_id": "" ,
                "long": long,
                "lat": lat
            ]
            
            TrainerVM.gerTrainerApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                print("get trainer list result data: ", getResultData as Any)
                self.trainerData?.removeAll()
                self.gymTrainerData?.removeAll()
                self.trainerData = getResultData.data?.trainers ?? []
//                self.trainerData?.append(contentsOf: getResultData.data?.trainers ?? [])
                self.collectionTrainer.reloadData()
            })
        } else {
            self.getLocation()
        }
    }
    
    private func getSelectGymList(trainerId: String?) {
        
        let params: [String: String] = [
            "long": "\(self.getLong ?? 0.0)",
            "lat": "\(self.getLat ?? 0.0)"
        ]
        
        HomepageViewModel.getGymTrainersApi(params: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            print(getResultData)
            self.gymTrainerData?.removeAll()
            self.trainerData?.removeAll()
            self.gymTrainerData?.append(contentsOf: getResultData.data?.trainers ?? [])
            self.collectionTrainer.reloadData()
        })
        
    }
    
    private func getAddressListApi(){
        TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            print("getResultData", getResultData.data as Any)
            self.addressData?.removeAll()
            self.addressData?.append(contentsOf: getResultData.data ?? [])
        })
    }
    
    private func getPlansApi() {
        DashboardVM.getHomePagePlansApi(type: "2") { [weak self] result in
            guard let self = self else { return }
            
            if result?.status == true {
                self.userPlans = result?.data ?? []
            }
        }
    }
}
