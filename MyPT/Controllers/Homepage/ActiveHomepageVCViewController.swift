//
//  ActiveHomepageVCViewController.swift
//  MyPT
//
//  Created by Pratham Gupta on 14/02/26.
//

import UIKit
import AVKit

class ActiveHomepageVCViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var getLat: Double?
    var getLong: Double?
    var addressData: [AddressDataModel]? = []
    var bannerTimer: Timer?
    var currentIndex = 0
    var bannerData: [HomepageBannerData]?
    var slotData: SubscriptionSlotsData?
    var trainers: [SubscriptionSlotTrainer] = []
    var dates: [Date] = []
    var selectedIndex: Int = 0   // default select today (first index)
    var homeTopData: [HomePageData]?
    var sessionTypeData: [HomePageData]?
    var homeStories: GetStoriesData?
    var storyList: [Story] = []
    var homeStoriesData: [Datum]?
    var upcomingSessionData:[BookingDataModel]? = [] {
        didSet{
            self.collectionMyBooking.reloadData()
        }
    }
    var userPlans: [PlanDetailsModel] = [] {
        didSet {
//            if userPlans.contains(where: { $0.is_expired == true }) {
//                heightOfCollectionPlan?.constant = 213
//            } else {
//                heightOfCollectionPlan?.constant = 230
//            }
            collectionPlan.reloadData()
        }
    }
    
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var lblAddressType: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgOffer: UIImageView!
    @IBOutlet weak var collectionSessionType: UICollectionView!
    @IBOutlet weak var lblMyBooking: UILabel!
    @IBOutlet weak var collectionMyBooking: UICollectionView!
    @IBOutlet weak var lblSmartSuggestion: UILabel!
    @IBOutlet weak var collectionDate: UICollectionView!
    @IBOutlet weak var collectionBookingSuggestion: UICollectionView!
    @IBOutlet weak var viewValidityCard: UIView!
    @IBOutlet weak var viewMyPtAction: UIView!
    @IBOutlet weak var lblMyPtAction: UILabel!
    @IBOutlet weak var collectionMyPTAction: UICollectionView!
    @IBOutlet weak var lblTrainingTEam: UILabel!
    @IBOutlet weak var collectionBanner: UICollectionView!
    @IBOutlet weak var collectionPlan: UICollectionView!
    @IBOutlet weak var lblteamName: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var imgTeam: UIImageView!
    //    @IBOutlet weak var lblSuggestionNoData: UILabel!
    @IBOutlet weak var viewTeam: UIView!
    //    @IBOutlet weak var lblBookingNoData: UILabel!
    @IBOutlet weak var viewYourTrainingTeamHeading: UIView!
    @IBOutlet weak var lblTrainingTeamHeading: UILabel!
    @IBOutlet weak var btnNameInitial: UIButton!
    @IBOutlet weak var pageController: UIPageControl!

    @IBOutlet weak var heightOfCollectionPlan: NSLayoutConstraint!
    


    /// Group Classes carousel, inserted into the storyboard's content stack view
    /// at runtime (see `setupGroupClassesSection()`).
    private var groupClassesCarousel: GroupClassesCarouselView?

    private weak var notificationUnreadDot: UIView?


    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        notificationUnreadDot = NotificationBellInstaller.install(leftOf: btnNameInitial, in: self)
        setupGroupClassesSection()
        generateDates()
        collectionDate.reloadData()
        //        lblSuggestionNoData.isHidden = true
        //        lblBookingNoData.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        groupClassesCarousel?.startRealtime()
        NotificationBellInstaller.refreshUnreadBadge(notificationUnreadDot)

        // Reset date selection and suggestions when returning from another tab.
        generateDates()
        selectedIndex = 0
        trainers.removeAll()
        collectionDate.reloadData()
        collectionBookingSuggestion.reloadData()
        
        // `getLocation()`'s own completion already calls `loadGroupClasses()`
        // once real coordinates land - calling it again here unconditionally
        // fired the same "viewall-classes" request twice on every cold-cache
        // appearance (once with fallback coordinates, once for real).
        var hasCachedLocation = false
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first,
            let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last {
            print("Current lat", lat)
            self.getLat = Double(lat)
            self.getLong = Double(long)
            hasCachedLocation = true
            let currentLoc: String? = appUserDefaults.getCurrentAddr()
            if let currentLoc = currentLoc {
                self.lblAddress.text = String(currentLoc.prefix(25))
            }
        } else {
            self.getLocation()
        }
        if let userName = appUserDefaults.getUserName() {
            self.btnNameInitial.setTitle(userName.filter({$0.isLetter}).prefix(1).uppercased(), for: .normal)
        }
        getAddressListApi()
        getTopContentsApi()
        getStoriesApi()
        bookingListApi()
        getPlansApi()
        getBannerApi()
        if hasCachedLocation {
            loadGroupClasses()
        }
        if let firstDate = dates.first {
            let todayDate = getFormattedDate(from: firstDate)
            callSlotsApi(date: todayDate)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        groupClassesCarousel?.stopRealtime()
    }

    private func uiSetup() {
        collectionSessionType.delegate = self
        collectionSessionType.dataSource = self
        collectionMyBooking.delegate = self
        collectionMyBooking.dataSource = self
        collectionDate.delegate = self
        collectionDate.dataSource = self
        collectionBookingSuggestion.delegate = self
        collectionBookingSuggestion.dataSource = self
        collectionMyPTAction.delegate = self
        collectionMyPTAction.dataSource = self
        collectionBanner.delegate = self
        collectionBanner.dataSource = self
        collectionPlan.delegate = self
        collectionPlan.dataSource = self
        if let layout = collectionPlan.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
            layout.minimumLineSpacing = 15
            layout.minimumInteritemSpacing = 15
        }
        collectionSessionType.register(
            UINib(nibName: "TypesOfSessionCVCell", bundle: nil),
            forCellWithReuseIdentifier: "TypesOfSessionCVCell"
        )
        collectionMyBooking.register(
            UINib(nibName: "BookingHomepageCVCell", bundle: nil),
            forCellWithReuseIdentifier: "BookingHomepageCVCell"
        )
        collectionDate.register(
            UINib(nibName: "DateCVCell", bundle: nil),
            forCellWithReuseIdentifier: "DateCVCell"
        )
        collectionBookingSuggestion.register(
            UINib(nibName: "TrainerSuggestionCVCell", bundle: nil),
            forCellWithReuseIdentifier: "TrainerSuggestionCVCell"
        )
        collectionMyPTAction.register(
            UINib(nibName: "SeePtActionCVCell", bundle: nil),
            forCellWithReuseIdentifier: "SeePtActionCVCell"
        )
        collectionBanner.register(
            UINib(nibName: "BannerHomepageCVCell", bundle: nil),
            forCellWithReuseIdentifier: "BannerHomepageCVCell"
        )
        collectionPlan.register(
            UINib(nibName: "PlanCVCell", bundle: nil),
            forCellWithReuseIdentifier: "PlanCVCell"
        )
        collectionPlan.register(
            UINib(nibName: "NewExpiredPlanCVCell", bundle: nil),
            forCellWithReuseIdentifier: "NewExpiredPlanCVCell"
        )
        DispatchQueue.main.async {
            self.pageController.currentPageIndicatorTintColor = .white
            self.pageController.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.5)
            self.btnNameInitial.titleLabel?.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
            //            self.btnNameInitial.tintColor = UIColor(red: 178.0/255.0, green: 107.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            self.lblAddressType.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblAddress.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            [self.lblMyBooking, self.lblSmartSuggestion, self.lblTrainingTEam, self.lblMyPtAction, self.lblTrainingTeamHeading].forEach {
                $0?.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
            }
        }
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
            getTopContentsApi()
            getStoriesApi()
            bookingListApi()
            getPlansApi()
            loadGroupClasses()
        }
    }

    // MARK: - Group Classes carousel

    /// Inserts the Group Classes carousel directly below the "Smart Suggestions"
    /// section, matching Android's `fragment_active_user_home_new.xml` where
    /// `groupClassesSection` sits between the smart-suggestion block and the
    /// "Your Training Team" header.
    ///
    /// The anchor is resolved from the already-wired `lblSmartSuggestion` outlet:
    /// its enclosing section view (label + date strip + suggestions carousel) is a
    /// direct arranged subview of the screen's vertical content stack view, so no
    /// storyboard XML has to change.
    private func setupGroupClassesSection() {
        guard groupClassesCarousel == nil else { return }

        groupClassesCarousel = GroupClassesCarouselView.insert(after: lblSmartSuggestion) { [weak self] tapThroughData in
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
            print("GroupClasses: Smart Suggestions anchor not found — carousel not inserted")
        }
    }

    private func loadGroupClasses() {
        groupClassesCarousel?.loadClasses(lat: getLat, long: getLong)
    }

    private func setUpData() {
        
        // Background Image (id 4)
        if let bgItem = homeTopData?.first(where: { $0.id == 4 }),
           let bgImage = bgItem.image {
            imgBackground.loadImage(urlString: bgImage, placeholder: nil)
        }
        
        // Offer Image (id 14)
        if let offerItem = homeTopData?.first(where: { $0.id == 14 }),
           let offerImage = offerItem.image {
            imgOffer.loadImage(urlString: offerImage, placeholder: nil)
        }
        
        if let homeBGImageData = homeTopData?.filter({$0.id == 13}) {
            if let bgImage = homeBGImageData.first?.image {
                imgHeader.loadImage(urlString: bgImage, placeholder: nil)
            }
        }
        
        if let userName = appUserDefaults.getUserName() {
            self.btnNameInitial.setTitle(userName.filter({$0.isLetter}).prefix(1).uppercased(), for: .normal)
        }
        self.collectionBanner.reloadData()
        
        //        // Offer Image (id 14)
        //        if let offerItem = homeTopData?.first(where: { $0.id == 13 }),
        //           let offerImage = offerItem.image {
        //            imgHeader.loadImage(urlString: offerImage, placeholder: nil)
        //        }
    }
    
    private func generateDates() {
        dates.removeAll()
        
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
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
    
    @IBAction func onTapViewAll(_ sender: UIButton) {
        let vc: BookingListViewController = BookingListViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func onTapLocation(_ sender: UIButton) {
        let vc: LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
        vc.flowLocation = .homePage
        vc.isFromEditAddress = false
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapProfile(_ sender: UIButton) {
        let vc: ProfileViewController = ProfileViewController.instantiate(appStoryboard: .profile)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func viewYourTeam(_ sender: UIButton) {
        if !trainers.isEmpty {
            let vc:TrainingTeamViewController = TrainingTeamViewController.instantiate(appStoryboard: .purchase)
            vc.fromHomeToGetgroupDetail = true
            vc.groupId = "\(self.slotData?.group?.id ?? 0)"
            vc.hidesBottomBarWhenPushed = true
            //        vc.trainerIdStr = "\(trainerDetails?.id ?? 0)"
            //        vc.studioIdStr = studioId
            //        vc.inputType = self.inputType
            //        vc.package_type = self.package_type
            //        var newData = self.inputParam
            //        newData?.trainer_id = "\(trainerDetails?.id ?? 0)"
            //        vc.inputParam = newData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func useSessionBtnActn(sender: UIButton) {
        TapticEngine.selection.feedback()

        // Resolve the index of the tapped plan card
        var view: UIView? = sender
        while view != nil, !(view is UICollectionViewCell) {
            view = view?.superview
        }
        let planIndex: Int
        if let cell = view as? UICollectionViewCell,
           let indexPath = collectionPlan.indexPath(for: cell) {
            planIndex = indexPath.row
        } else {
            planIndex = 0
        }

        guard userPlans.indices.contains(planIndex) else { return }
        let plan = userPlans[planIndex]

        if plan.is_expired == true {
            let bookingReviewPurchaseVC: BookingReviewPurchaseVC = BookingReviewPurchaseVC.instantiate(appStoryboard: .newBookingModule)
            bookingReviewPurchaseVC.inputParam = DetailsParam(
                type: plan.type?.value
            )
            bookingReviewPurchaseVC.sessions = plan.sessions?.value
            bookingReviewPurchaseVC.hidesBottomBarWhenPushed = true
            bookingReviewPurchaseVC.previousSubscriptionID = plan.id?.value
            bookingReviewPurchaseVC.isGymMembership = plan.is_membership ?? false
            self.navigationController?.pushViewController(bookingReviewPurchaseVC, animated: false)
//            let vc: PackageExpireVC = PackageExpireVC.instantiate(appStoryboard: .newBookingModule)
//            vc.hidesBottomBarWhenPushed = true
//            vc.userPlans = self.userPlans
//            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            if plan.is_membership ?? false {
                let bookingReviewPurchaseVC: BookingReviewPurchaseVC = BookingReviewPurchaseVC.instantiate(appStoryboard: .newBookingModule)
                bookingReviewPurchaseVC.inputParam = DetailsParam(
                    type: plan.type?.value
                )
                bookingReviewPurchaseVC.sessions = plan.sessions?.value
                bookingReviewPurchaseVC.hidesBottomBarWhenPushed = true
                bookingReviewPurchaseVC.previousSubscriptionID = plan.id?.value
                bookingReviewPurchaseVC.isGymMembership = plan.is_membership ?? false
                self.navigationController?.pushViewController(bookingReviewPurchaseVC, animated: false)
            } else {
                let vc: NewBookingModuleVC = NewBookingModuleVC.instantiate(appStoryboard: .newBookingModule)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionSessionType {
            return 4
        } else if collectionView == collectionMyBooking {
            let count = upcomingSessionData?.count ?? 0
            if count == 0 {
                collectionView.showEmptyView(
                    title: "You have no upcoming bookings",
                    image: AppImages.search_NoResult,
                    centerOffset: -30   // adjust if needed
                )
            } else {
                collectionView.restoreEmptyView()
            }
            return count
        } else if collectionView == collectionDate {
            return dates.count
        } else if collectionView == collectionBookingSuggestion {
            if trainers.isEmpty {
                collectionView.showEmptyView(
                    title: "Your trainer is not available on this date",
                    image: AppImages.search_NoResult,
                    imageSize: 110,
                    centerOffset: -20
                )
            } else {
                collectionView.restoreEmptyView()
            }
            return trainers.count
        } else if collectionView == collectionMyPTAction {
            //            return homeStoriesData?.count ?? 0
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
        } else if collectionView == collectionPlan {
            let count = userPlans.count
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
        if collectionView == collectionSessionType {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TypesOfSessionCVCell",
                for: indexPath
            ) as! TypesOfSessionCVCell
            
            let item = sessionTypeData?[indexPath.row]
            
            //            cell.lblTypeOfSession.text = item?.name
            
            if let imageUrl = item?.image {
                cell.imgTypeOfSession.loadImage(urlString: imageUrl, placeholder: nil)
            }
            
            return cell
        }
        
        else if collectionView == collectionMyBooking {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookingHomepageCVCell", for: indexPath) as! BookingHomepageCVCell
            
            let data = upcomingSessionData?[indexPath.row]
            cell.setInputData(data: data)
            cell.btnCheckIn.accessibilityHint = self.upcomingSessionData?[indexPath.row].id?.value
            cell.btnCheckIn.addTarget(self, action: #selector(checkInBtnActn(sender: )), for: .touchUpInside)
            return cell
        } else if collectionView == collectionDate {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DateCVCell",
                for: indexPath
            ) as! DateCVCell
            
            let date = dates[indexPath.row]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM"
            cell.lblDate.text = formatter.string(from: date).uppercased()
            
            // Selection UI
            if indexPath.row == selectedIndex {
                cell.viewDate.backgroundColor = UIColor(red: 224/255, green: 254/255, blue: 8/255, alpha: 0.05)
                cell.lblDate.textColor = .white
                cell.viewDate.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 224/255, green: 254/255, blue: 8/255, alpha: 0.4), cornerRadious: 8)
            } else {
                cell.viewDate.backgroundColor = .clear
                cell.lblDate.textColor = .white
                cell.viewDate.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 0)
            }
            
            cell.viewDate.layer.cornerRadius = 8
            
            return cell
        }  else if collectionView == collectionBookingSuggestion {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TrainerSuggestionCVCell",
                for: indexPath
            ) as! TrainerSuggestionCVCell
            let trainer = trainers[indexPath.row]
            cell.viewInfo.isHidden = self.slotData?.is_remaining_session ?? false
            cell.btnStackView.isHidden = !(self.slotData?.is_remaining_session ?? false)
            cell.btnQuickBook.isHidden = !(self.slotData?.is_remaining_session ?? false)
            cell.btnFullReschedule.isHidden = true
            cell.configure(with: trainer)
            cell.lblInfo.text = self.slotData?.message
            cell.btnQuickBook.accessibilityHint = trainer.id?.value ?? ""
            cell.btnFullReschedule.accessibilityHint = trainer.id?.value ?? ""
            cell.btnFullReschedule.addTarget(self, action: #selector(fullScheduleBtnActn(sender: )), for: .touchUpInside)
            cell.btnQuickBook.addTarget(self, action: #selector(quickBookBtnActn(sender: )), for: .touchUpInside)
            return cell
        }  else if collectionView == collectionMyPTAction {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeePtActionCVCell", for: indexPath) as? SeePtActionCVCell else { return UICollectionViewCell() }
            if let singleStoryData = homeStoriesData?[indexPath.row] {
                cell.configure(with: singleStoryData)
            }
            return cell
        }  else if collectionView == collectionBanner {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerHomepageCVCell", for: indexPath) as? BannerHomepageCVCell else { return UICollectionViewCell() }
            
            cell.imgBanner.sd_setImage(with: URL(string: bannerData?[indexPath.row].image ?? ""), placeholderImage: UIImage(named: "placeholder"))
            //            cell.cellConfigure(customData: self.customisePlans)
            //
            return cell
        } else if collectionView == collectionPlan {
            let plan = userPlans[indexPath.row]
            if plan.is_expired == true {
//                guard let expiredCell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "ExpiredPlanCVCell",
//                    for: indexPath
//                ) as? ExpiredPlanCVCell else {
//                    return UICollectionViewCell()
//                }
                guard let expiredCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "NewExpiredPlanCVCell",
                    for: indexPath
                ) as? NewExpiredPlanCVCell else {
                    return UICollectionViewCell()
                }
                expiredCell.configure(with: plan)
                expiredCell.btnRenewNow.addTarget(self, action: #selector(useSessionBtnActn(sender: )), for: .touchUpInside)
                return expiredCell
            } else {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PlanCVCell",
                    for: indexPath
                ) as? PlanCVCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: plan)
                cell.btnUseSession.addTarget(self, action: #selector(useSessionBtnActn(sender: )), for: .touchUpInside)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionMyPTAction {
            return CGSize(width: (collectionView.frame.size.width - 10) / 4.1, height: 140)
        } else if collectionView == collectionBanner {
            return CGSize(width: collectionView.frame.size.width, height: 330)
        } else if collectionView == collectionMyBooking {
            return CGSize(width: 385, height: 210)
        } else if collectionView == collectionDate {
            return CGSize(width: 104, height: 32)
        } else if collectionView == collectionBookingSuggestion {
            return CGSize(width: 343, height: 211)
        } else if collectionView == collectionPlan {
            let isExpired = userPlans.indices.contains(indexPath.row) ? (userPlans[indexPath.row].is_expired ?? false) : false
//            let cellHeight: CGFloat = isExpired ? 283 : 213
            let cellHeight: CGFloat = 213
            return CGSize(width: collectionView.frame.width - 20, height: cellHeight)
        }
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionMyBooking {
            guard let session = self.upcomingSessionData?[indexPath.row] else { return }
            let typeStr = session.sessionType?.value?.lowercased() ?? ""
            let bookingType = session.bookingType?.lowercased() ?? ""
            let isGroupClass = typeStr.contains("group") || typeStr == "class" || bookingType.contains("group") || bookingType == "class"
            if isGroupClass {
                let confirmed = SlotConfirmedViewController()
                let title = session.bookingType?.isEmpty == false ? session.bookingType : session.sessionType?.value
                confirmed.classTitle = title ?? ""
                confirmed.classTime = session.timing?.value ?? ""
                confirmed.classLocation = session.location?.value ?? ""
                confirmed.trainerName = session.trainer?.value ?? ""
                confirmed.distance = session.distance?.value ?? ""
                confirmed.classPrice = session.price?.value ?? ""
                confirmed.studioLat = Double(session.studioLat?.value ?? "") ?? 0
                confirmed.studioLng = Double(session.studioLng?.value ?? "") ?? 0
                confirmed.isReadOnly = true
                confirmed.bookingId = session.id?.value ?? ""
                confirmed.canCancelBooking = true
                confirmed.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(confirmed, animated: true)
                return
            }
            let vc: BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)
            vc.detailsFlow = .upcoming
            vc.bookingIdStr = "\(session.id?.value ?? "0")"
            vc.typeStr = session.sessionType?.value
            self.navigationController?.pushViewController(vc, animated: true)
        } else if collectionView == collectionMyPTAction {
            let storiesList = homeStoriesData?[indexPath.row].stories
            let vc : ViewStoryVC = ViewStoryVC.instantiate(appStoryboard: .homepage)
            vc.hidesBottomBarWhenPushed = true
            let cell = collectionView.cellForItem(at: indexPath) as? SeePtActionCVCell
            vc.currStories = storiesList
            vc.userImage = cell?.imgaction.image
            vc.userName = cell?.lblActionName.text
            self.navigationController?.pushViewController(vc, animated: true)
        } else if collectionView == collectionDate {
            selectedIndex = indexPath.row
            collectionDate.reloadData()
            
            let selectedDate = getFormattedDate(from: dates[indexPath.row])
            callSlotsApi(date: selectedDate)
        } else if collectionView == collectionSessionType {
            let vc : TopPlanVC = TopPlanVC.instantiate(appStoryboard: .homepage)
            let vc1: NewBookingModuleVC = NewBookingModuleVC.instantiate(appStoryboard: .newBookingModule)
            let packageExpireVC: PackageExpireVC = PackageExpireVC.instantiate(appStoryboard: .newBookingModule)
            let myTrainersVC: MyTrainersVC = MyTrainersVC.instantiate(appStoryboard: .newBookingModule)
            let bookingReviewPurchaseVC: BookingReviewPurchaseVC = BookingReviewPurchaseVC.instantiate(appStoryboard: .newBookingModule)
            let renewPlanVC: RenewPlanVC = RenewPlanVC.instantiate(appStoryboard: .newBookingModule)
            switch indexPath.row {
            case 0: // Book Session
                vc1.hidesBottomBarWhenPushed = true
                packageExpireVC.hidesBottomBarWhenPushed = true
                guard let selectedPlan = self.userPlans.first(where: { $0.is_expired == true && $0.is_membership == false}) ?? self.userPlans.first else {
                    return
                }
                packageExpireVC.userPlans = selectedPlan
                self.navigationController?.pushViewController(selectedPlan.is_expired == true ? packageExpireVC : vc1, animated: false)
                return
            case 1: // Renew Plan
                if self.userPlans.count > 1 {
                    renewPlanVC.userPlans = self.userPlans
                    renewPlanVC.modalPresentationStyle = .automatic
//                    renewPlanVC.isModalInPresentation = true
//                    renewPlanVC.modalPresentationStyle = .pageSheet
//                    if #available(iOS 15.0, *) {
//                        if let sheet = renewPlanVC.sheetPresentationController {
//                            sheet.detents = [.medium(), .large()]
//                            sheet.selectedDetentIdentifier = .medium
//                            sheet.prefersGrabberVisible = true
//                            sheet.preferredCornerRadius = 20
//                        }
//                    }
                    self.present(renewPlanVC, animated: true)
                } else if let selectedPlan = self.userPlans.first {
                    bookingReviewPurchaseVC.inputParam = DetailsParam(
                        type: selectedPlan.type?.value
                    )
                    bookingReviewPurchaseVC.sessions = selectedPlan.sessions?.value
                    bookingReviewPurchaseVC.hidesBottomBarWhenPushed = true
                    bookingReviewPurchaseVC.previousSubscriptionID = selectedPlan.id?.value
                    bookingReviewPurchaseVC.isGymMembership = selectedPlan.is_membership ?? false
                    self.navigationController?.pushViewController(bookingReviewPurchaseVC, animated: false)
                }
                return
            case 2: // My Trainers
//                vc.selectedPlanType = .renew
//                vc.selectedPlanType = .myTrainers
                myTrainersVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(myTrainersVC, animated: false)
                return
            case 3: // Group Classes
//                vc.selectedPlanType = .upgrade
                vc.selectedPlanType = .groupClasses
            default:
                return
            }
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        if collectionView == collectionPlan {
            return 15
        }

        return 0
    }
    
    func convertTo12Hour(_ time: String?) -> String {
        
        guard var time = time else { return "" }
        
        time = time.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "hh:mm a"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Try multiple formats (important 🔥)
        let formats = ["HH:mm", "HH:mm:ss"]
        
        for format in formats {
            inputFormatter.dateFormat = format
            
            if let date = inputFormatter.date(from: time) {
                return outputFormatter.string(from: date)
            }
        }
        
        print("❌ Time format not matched:", time)
        return time
    }
    
    private func presentTrainerSchedule(with slots: [SelectedSlot], selectedDate: String?, trainerData: SubscriptionSlotTrainer?) {
        let vc: TrainerScheduleVC = TrainerScheduleVC.instantiate(appStoryboard: .homepage)
        vc.modalPresentationStyle = .automatic
        vc.fromHome = true
        vc.restOfTheslots = slots
        vc.selectedDate = selectedDate
        vc.callBack = { [weak self] selectedSlot in
            guard let self = self else { return }
            
            let quickVC: QuickTrainerBookVC = QuickTrainerBookVC.instantiate(appStoryboard: .homepage)
            quickVC.modalPresentationStyle = .overFullScreen
            quickVC.slotData = slotData
            quickVC.trainerData = trainerData
            quickVC.selectedDate = selectedDate
            quickVC.selectedSlot = selectedSlot
            quickVC.inputParam = DetailsParam(
                trainer_id: trainerData?.id?.value,
//                type: "home",
                type: slotData?.type,
                long: "\(self.getLong ?? 0.0)",
                lat: "\(self.getLat ?? 0.0)",
                addressId: self.addressData?.first?.id?.value,
                addressData: self.addressData?.first
            )
            quickVC.onTapBackCallBack = { [weak self] in
                self?.presentTrainerSchedule(with: slots, selectedDate: selectedDate, trainerData: trainerData)
            }
            self.present(quickVC, animated: true)
        }
        
        self.present(vc, animated: true)
    }
    
    private func fullSchedule(with slots: [SelectedSlot], selectedDate: String?, trainerData: SubscriptionSlotTrainer?) {
        let vc: TrainerScheduleVC = TrainerScheduleVC.instantiate(appStoryboard: .homepage)
        vc.modalPresentationStyle = .automatic
        vc.forFullSchedule = true
        vc.restOfTheslots = slots
        vc.selectedDate = selectedDate
        
//        vc.callBack = { [weak self] selectedSlot in
//            guard let self = self else { return }
//            
//            let quickVC: QuickTrainerBookVC = QuickTrainerBookVC.instantiate(appStoryboard: .homepage)
//            quickVC.modalPresentationStyle = .overFullScreen
//            quickVC.trainerData = trainerData
//            quickVC.selectedDate = selectedDate
//            quickVC.selectedSlot = selectedSlot
//            quickVC.inputParam = DetailsParam(
//                trainer_id: trainerData?.id?.value,
//                type: "home",
////                type: slotData?.type,
//                long: "\(self.getLong ?? 0.0)",
//                lat: "\(self.getLat ?? 0.0)",
//                addressId: self.addressData?.first?.id?.value,
//                addressData: self.addressData?.first
//            )
//            quickVC.onTapBackCallBack = { [weak self] in
//                self?.presentTrainerSchedule(with: slots, selectedDate: selectedDate, trainerData: trainerData)
//            }
//            self.present(quickVC, animated: true)
//        }
        
        self.present(vc, animated: true)
    }
    
    @objc func quickBookBtnActn(sender: UIButton) {
        if let getIndx = self.trainers.firstIndex(where: {
            $0.id?.value == sender.accessibilityHint ?? "0"
        }) {
            var result: [SelectedSlot] = []
            
            // ✅ Sirf selected trainer lo
            let trainer = trainers[getIndx]
            let trainerName = trainer.name
            
            if let slots = trainer.slots {
                for slot in slots {
                    
                    let selectedSlot = SelectedSlot(
                        startTime: convertTo12Hour(slot.startTime ?? ""),
                        endTime: convertTo12Hour(slot.endTime ?? ""),
                        status: nil,
                        name: trainerName,
                        id: slot.id,
                        isSelected: false
                    )
                    result.append(selectedSlot)
                }
            }
            
            // ✅ correct trainerData pass karo
            presentTrainerSchedule(
                with: result,
                selectedDate: slotData?.date,
                trainerData: trainer
            )
        }
    }
    
//    @objc func quickBookBtnActn(sender: UIButton) {
//        if let getIndx = self.trainers.firstIndex(where: {
//            $0.id?.value == sender.accessibilityHint ?? "0"
//        }) {
//            var result: [SelectedSlot] = []
//            var trainerData: SubscriptionSlotTrainer?
//            for trainer in trainers {
//                let trainerName = trainer.name
//                trainerData = trainer
//                if let slots = trainer.slots {
//                    for slot in slots {
//                        let selectedSlot = SelectedSlot(
//                            startTime: convertTo12Hour(slot.startTime ?? ""),
//                            endTime: convertTo12Hour(slot.endTime ?? ""),
//                            status: nil, // agar backend se aaye to map kar dena
//                            name: trainerName,
//                            id: slot.id,
//                            isSelected: false
//                        )
//                        result.append(selectedSlot)
//                    }
//                }
//            }
//            presentTrainerSchedule(with: result, selectedDate: slotData?.date, trainerData: trainerData)
//        }
//    }
    
    @objc func fullScheduleBtnActn(sender: UIButton) {
        if let getIndx = self.trainers.firstIndex(where: {
            $0.id?.value == sender.accessibilityHint ?? "0"
        }) {
            var result: [SelectedSlot] = []
            var trainerData: SubscriptionSlotTrainer?
            for trainer in trainers {
                let trainerName = trainer.name
                trainerData = trainer
                if let slots = trainer.slots {
                    for slot in slots {
                        let selectedSlot = SelectedSlot(
                            startTime: convertTo12Hour(slot.startTime ?? ""),
                            endTime: convertTo12Hour(slot.endTime ?? ""),
                            status: nil, // agar backend se aaye to map kar dena
                            name: trainerName,
                            id: slot.id,
                            isSelected: false
                        )
                        result.append(selectedSlot)
                    }
                }
            }
            fullSchedule(with: result, selectedDate: slotData?.date, trainerData: trainerData)
        }
    }
    
    @objc func checkInBtnActn(sender:UIButton) {

        let vc: BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)

        if let getIndx = self.upcomingSessionData?.firstIndex(where: {
            $0.id?.value == sender.accessibilityHint ?? "0"
        }), let session = self.upcomingSessionData?[getIndx] {
            let typeStr = session.sessionType?.value?.lowercased() ?? ""
            let bookingType = session.bookingType?.lowercased() ?? ""
            let isGroupClass = typeStr.contains("group") || typeStr == "class" || bookingType.contains("group") || bookingType == "class"
            if isGroupClass {
                let confirmed = SlotConfirmedViewController()
                let title = session.bookingType?.isEmpty == false ? session.bookingType : session.sessionType?.value
                confirmed.classTitle = title ?? ""
                confirmed.classTime = session.timing?.value ?? ""
                confirmed.classLocation = session.location?.value ?? ""
                confirmed.trainerName = session.trainer?.value ?? ""
                confirmed.distance = session.distance?.value ?? ""
                confirmed.classPrice = session.price?.value ?? ""
                confirmed.studioLat = Double(session.studioLat?.value ?? "") ?? 0
                confirmed.studioLng = Double(session.studioLng?.value ?? "") ?? 0
                confirmed.isReadOnly = true
                confirmed.bookingId = session.id?.value ?? ""
                confirmed.canCancelBooking = true
                confirmed.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(confirmed, animated: true)
                return
            }
            let vc:BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)
            vc.detailsFlow = .upcoming
            vc.bookingIdStr = "\(session.id?.value ?? "0")"
            vc.typeStr = session.sessionType?.value
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func getTopContentsApi() {
        HomepageViewModel.homepageApi(params: nil) { [weak self] result in
            guard let self = self else { return }
            
            if let plans = result?.data {
                
                self.homeTopData = plans
                
                //  filter only for collection
                self.sessionTypeData = plans.filter {
                    guard let id = $0.id else { return false }
                    return id >= 9 && id <= 12
                }
                
                DispatchQueue.main.async {
                    self.setUpData()
                    self.collectionSessionType.reloadData()
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
                    self.collectionMyPTAction.reloadData()
                }
            }
        }
    }
    
    private func bookingListApi() {
        BookingVM.getBookingApi(
            inputType: "2",
            inputDate: nil,
            inputSessionType: nil,
            inputLocation: nil
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            if result?.status == true {
                self.upcomingSessionData = result?.data ?? []
                
                DispatchQueue.main.async {
                    self.collectionMyBooking.reloadData()
                }
            }
        }
    }
    
    private func getPlansApi() {
        DashboardVM.getHomePagePlansApi(type: "2") { [weak self] result in
            guard let self = self else { return }
            if result?.status == true {
                self.userPlans = result?.data ?? []
            }
        }
    }
    
    func callSlotsApi(date: String) {
        DashboardVM.getSubscriptionSlotsApi(date: date) { [weak self] result in
            guard let self = self else { return }
            if let data = result?.data {
                DispatchQueue.main.async {
                    
                    self.slotData = data
                    self.trainers = data.trainers ?? []
                    
                    if data.isGroup == true {
//                        self.viewYourTrainingTeamHeading.isHidden = true
                        self.viewYourTrainingTeamHeading.isHidden = false
//                        self.viewTeam.isHidden = false
                        self.viewTeam.isHidden = true
                        self.lblteamName.text = data.group?.name
                        self.lblDetail.text = data.group?.msg
                        
                        if let imageUrl = data.group?.image {
                            self.imgTeam.loadImage(urlString: imageUrl, placeholder: UIImage(named: "TrainingTeam"))
                        }
                    } else {
                        self.viewTeam.isHidden = true
                        self.viewYourTrainingTeamHeading.isHidden = false
                    }
                    
                    self.collectionBookingSuggestion.reloadData()
                    self.view.layoutIfNeeded()
                }
                self.collectionBookingSuggestion.reloadData()
            }
        }
    }
    
    func getFormattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
    
    private func getAddressListApi(){
        TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            print("getResultData", getResultData.data as Any)
            self.addressData?.removeAll()
            self.addressData?.append(contentsOf: getResultData.data ?? [])
        })
    }
}

extension UICollectionView {
    
    func showEmptyView(title: String,
                       image: UIImage?,
                       imageSize: CGFloat = 130,
                       centerOffset: CGFloat = 0) {
        
        let containerView = UIView(frame: self.bounds)
        containerView.backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Image
        if let image = image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            let dynamicSize = self.bounds.height * 0.85
            
            imageView.heightAnchor.constraint(equalToConstant: dynamicSize).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: dynamicSize).isActive = true
            
            stackView.addArrangedSubview(imageView)
        }
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor.appWhite
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: centerOffset),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20)
        ])
        
        self.backgroundView = containerView
    }
    
    func restoreEmptyView() {
        self.backgroundView = nil
    }
}
