//
//  GymDetailsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 12/12/24.
//

import UIKit
import GoogleMaps
import AVKit

class GymDetailsViewController: CommonViewController {
    
    //MARK: -------------VARIABLE
    var showmapCamera: CLLocationCoordinate2D? = nil {
        didSet{
            if let latitude = showmapCamera?.latitude , let longitude = showmapCamera?.longitude {
                let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
                DispatchQueue.main.async {
                    self.mapView?.camera = camera
                    
                    self.addMarkers(marker: MarkerModel(latitude: latitude, longitude: longitude, title: "", snippet: self.studioDetails?.address ?? "", iconImageName: AppImages.Radius))
                    
                    self.locationManager?.stopUpdatingLocation()
                }
            }
        }
    }
    
    private var videoUrl: String? {
        didSet {
            guard let videoStr = videoUrl, let videoURL = URL(string: videoStr) else { return }

            let player = AVPlayer(url: videoURL)
            let vc = CustomPlayerViewController()
            vc.player = player
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true) {
                player.play()
            }
        }
    }
    
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    
    var mapView: GMSMapView!
    var locationManager: CLLocationManager?
    var inputType:String?
    var inputStudioId:String?
    var inputLat:String?
    var inputLong:String?
    var studioDetails: StudioDetailsModel?
    var localDatAmenity: [String]? = []
    
    var sectionData:[[String:Any]]?
    var gymDetailsFlow:calendarFlow = .defaultFlow
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var mainScrollV: UIScrollView!
    @IBOutlet weak var gymImgView: UIImageView!
    @IBOutlet weak var gymBannerCollView: UICollectionView!
    @IBOutlet weak var gymNameLbl: UILabel!
    @IBOutlet weak var pageContrl: CustomPageControl!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var locAddr: UIButton!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var categoryCollView: UICollectionView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var gymOffersMBV: UIView!
    @IBOutlet weak var equipmentInsideGymMBV: UIView!
    @IBOutlet weak var gymTimeMBV: UIView!
    @IBOutlet weak var mediaGalleryMBV: UIView!
    @IBOutlet weak var gymLocMBV: UIView!
    @IBOutlet weak var showLocMap: UIView!
    @IBOutlet weak var gymRatingMBV: UIView!
    @IBOutlet weak var gymOffersTitleLbl: UILabel!
    @IBOutlet weak var equipmentInsideTitleLbl: UILabel!
    @IBOutlet weak var gymTimeTitleLbl: UILabel!
    @IBOutlet weak var mediaGalleryTitleLbl: UILabel!
    @IBOutlet weak var gymLocTitleLbl: UILabel!
    @IBOutlet weak var gymLocAddrLbl: UILabel!
    @IBOutlet weak var gymRatingTitleBtn: UIButton!
    @IBOutlet weak var gymOffersCollView: UICollectionView!
    @IBOutlet weak var mediaGalleryCollView: UICollectionView!
    @IBOutlet weak var gymRatingCollView: UICollectionView!
    @IBOutlet weak var equipmentInsideTblView: UITableView!
    @IBOutlet weak var gymTimeTblView: UITableView!
    @IBOutlet weak var showAllEquipmentsBtn: UIButton!
    @IBOutlet weak var showAllReviewsBtn: UIButton!
    @IBOutlet weak var bookASlotBtn: UIButton!
    @IBOutlet weak var gymOffersCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var equipmentInsideTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var mediaGalleryCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var showLocMapHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var gymRatingCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var gymTimeTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var showAllEquipmentsBtnHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showAllEquipmentsBtn.isHidden = true
        self.showAllEquipmentsBtn.setTitle(nil, for: .normal)
        self.showAllEquipmentsBtnHeightConstrnt.constant = 1.0
        
        self.gymRatingMBV.isHidden = true
        self.setUpUI()
        self.setUpFont()
        self.setMapShowData()
        self.studioDatialsApi()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.shareGymWorkout], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Automatically select the first cell
        //        let firstIndexPath = IndexPath(item: 0, section: 0)
        //        DispatchQueue.main.async {
        //            self.categoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
        //            // Optional: perform any additional setup for the selected cell
        //            self.categoryCollView.delegate?.collectionView?(self.categoryCollView, didSelectItemAt: firstIndexPath)
        //            self.view.layoutIfNeeded()
        //        }
    }
    
    @objc func handleMapPanGesture(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            mainScrollV.isScrollEnabled = false  // Disable ScrollView scrolling when map interaction starts
        } else if gesture.state == .ended || gesture.state == .cancelled {
            mainScrollV.isScrollEnabled = true  // Enable it back after interaction ends
        }
    }
    
    private func setInputData(){
        self.showAllReviewsBtn.setTitle("SHOW ALL REVIEWS", for: .normal)
        
        self.gymNameLbl.text = studioDetails?.name
        self.distanceBtn.setTitle(studioDetails?.distance, for: .normal)
        self.locAddr.setTitle(studioDetails?.address, for: .normal)
        let avgRating = studioDetails?.averageRating ?? "0.0"
        let noOfRating = studioDetails?.noOfRating ?? "0.0"
        
        self.ratingBtn.setTitle( avgRating + "\u{2022}" + noOfRating, for: .normal)
        self.descLbl.text = studioDetails?.description
        self.gymLocAddrLbl.text = studioDetails?.address
        self.gymRatingTitleBtn.setTitle(avgRating + "\u{2022}" + noOfRating, for: .normal)
        //        self.showAllEquipmentsBtn.setTitle("12", for: .normal)
        //        self.showAllReviewsBtn.setTitle("40", for: .normal)
        
        self.setUpCustomPageControl()
        self.updatePage(to: 0)
        
        self.sectionData = [
            ["title":"About The Gym","img":UIImage(named: "ic_barbell_ diagonal") as Any],
            ["title":"Gym Features","img": UIImage(named: "ic_star_white") as Any],
            ["title":"Equipment","img": UIImage(named: "ic_story_white") as Any],
            ["title":"Gallery","img": UIImage(named: "ic_gallery_white") as Any],
            ["title":"Review","img": UIImage(named: "ic_star_white") as Any]
        ]
        self.categoryCollView.reloadData()
        
        //-----------------************
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let count =  self.sectionData?.count, count >= 0{
                self.categoryCollView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
                self.view.layoutIfNeeded()
            }
        }
        
        //------------------**********
        self.descLbl.appendReadmore(after: studioDetails?.description ?? "", trailingContent: .readmore)
        
        self.descLbl.addReadMoreTapGesture(target: self, action: #selector(handleReadMoreTap(_:)))
    }
    
    //MARK: ------------------FOR MAKING EXPANDABLE STRING OF UILABEL
    @objc private func handleReadMoreTap(_ gesture: UITapGestureRecognizer) {
           let tapLocation = gesture.location(in: self.descLbl)
           guard let tappedIndex = self.descLbl.getTappedTextIndex(tapLocation) else { return }
           
           let readMoreText = TrailingContent.readmore.text
           let readLessText = TrailingContent.readless.text
           let fullAttributedString = self.descLbl.attributedText?.string ?? ""

           if fullAttributedString.range(of: readMoreText) != nil, tappedIndex >= (fullAttributedString.count - readMoreText.count) {
               self.descLbl.appendReadLess(after: self.studioDetails?.description ?? "", trailingContent: .readless)
           } else if fullAttributedString.range(of: readLessText) != nil, tappedIndex >= (fullAttributedString.count - readLessText.count) {
               self.descLbl.appendReadmore(after: self.studioDetails?.description ?? "", trailingContent: .readmore)
           }
       }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if gymOffersCollView.contentSize.height != 0 {
            if gymOffersCollView.contentSize.height < 300 {
                self.gymOffersCollViewHeightConstrnt.constant = gymOffersCollView.contentSize.height
            }else{
                self.gymOffersCollViewHeightConstrnt.constant = 300
            }
        }
        
        if equipmentInsideTblView.contentSize.height != 0 {
            equipmentInsideTblViewHeightConstrnt.constant = equipmentInsideTblView.contentSize.height
            self.equipmentInsideTblView.layoutIfNeeded()
//            if equipmentInsideTblView.contentSize.height < 300 {
//                equipmentInsideTblViewHeightConstrnt.constant = equipmentInsideTblView.contentSize.height
//            }else{
//                equipmentInsideTblViewHeightConstrnt.constant = 300
//            }
        }
        
        if gymTimeTblView.contentSize.height != 0 {
            if gymTimeTblView.contentSize.height < 250 {
                gymTimeTblViewHeightConstrnt.constant = gymTimeTblView.contentSize.height
            }else{
                gymTimeTblViewHeightConstrnt.constant = 250
            }
        }
        
        view.layoutIfNeeded()
    }
    
    private func setUpUI(){
        gymBannerCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        gymOffersCollView.register(UINib(nibName: "MoreExploreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MoreExploreCollectionViewCell")
        categoryCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        mediaGalleryCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        
        gymRatingCollView.register(UINib(nibName: "RatingsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RatingsCollectionViewCell")
        
        equipmentInsideTblView.register(UINib(nibName: "PointsTableViewCell", bundle: nil), forCellReuseIdentifier: "PointsTableViewCell")
        gymTimeTblView.register(UINib(nibName: "PointsTableViewCell", bundle: nil), forCellReuseIdentifier: "PointsTableViewCell")
        
        DispatchQueue.main.async {
            self.showAllEquipmentsBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.showAllReviewsBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.bookASlotBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setUpFont(){
        self.gymNameLbl.font = AppFont.medium.size(22, familyName: familyClashDisplay)
        self.distanceBtn.titleLabel?.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.locAddr.titleLabel?.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.ratingBtn.titleLabel?.font = AppFont.semibold.size(12, familyName: familyManrope)
        self.descLbl.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.gymOffersTitleLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.equipmentInsideTitleLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.gymTimeTitleLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.mediaGalleryTitleLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.gymLocTitleLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.gymLocAddrLbl.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.gymRatingTitleBtn.titleLabel?.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.showAllEquipmentsBtn.titleLabel?.font = AppFont.bold.size(16, familyName: familyManrope)
        self.showAllReviewsBtn.titleLabel?.font = AppFont.bold.size(16, familyName: familyManrope)
        self.bookASlotBtn.titleLabel?.font = AppFont.semibold.size(16, familyName: familyManrope)
    }
    
    //MARK: --------------SETUP page controll
    private func setUpCustomPageControl(){
        self.pageContrl.numberOfPages = studioDetails?.profile?.count ?? 0  // Set the total number of pages
        self.pageContrl.currentPage = 0    // Set the initial page
        self.pageContrl.activeDotSize = CGSize(width: 26, height: 8)
        self.pageContrl.currentDotColor = UIColor.appWhite // UIColor(red: 158/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1)
        self.pageContrl.defaultDotColor = UIColor.txtDarkGray
        
    }
    
    // Update the current page based on some user interaction (e.g., swiping between views)
    private func updatePage(to index: Int) {
        self.pageContrl.currentPage = index
    }
    
    //MARK: ----------------EQUIPMENT BTNACTN
    @IBAction func equipmentBtnActn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        print("sender.isSelected", sender.isSelected)
        if let amenityConut = studioDetails?.amenity?.count {
            if sender.isSelected && amenityConut > 3 {
                self.showAllEquipmentsBtn.setTitle("LESS ALL EQUIPMENTS", for: .normal)
                self.localDatAmenity?.removeAll()
                self.localDatAmenity?.append(contentsOf: studioDetails?.amenity ?? [])
                self.equipmentInsideTblView.reloadData()
               
            }else{
                self.showAllEquipmentsBtn.setTitle("SHOW ALL EQUIPMENTS", for: .normal)
                self.localDatAmenity?.removeAll()
                let amenities = studioDetails?.amenity ?? []
                self.localDatAmenity?.append(contentsOf: amenities.prefix(4))
                self.equipmentInsideTblView.reloadData()
            }
        }else{
            self.showAllEquipmentsBtn.setTitle(nil, for: .normal)
            self.showAllEquipmentsBtn.isHidden = true
        }
    }
    
    @IBAction func bookSlotBtnActn(_ sender: Any) {
        print("book slot btn actn.........")
        switch gymDetailsFlow {
            
        case .withTrainerMembership , .gymMembership:
            print("gym with membership")
            let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
            vc.isFromHome = false
            vc.studioId = self.inputStudioId
            vc.inputLat = self.inputLat
            vc.inputLong = self.inputLong
            vc.inputType = self.inputType
            //--------------Flow for membership
            vc.flowSlot = gymDetailsFlow
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .withoutTrainerMembership:
            print("gym without membership")
            let vc:ChooseSessionViewController = ChooseSessionViewController.instantiate(appStoryboard: .booking)
            vc.validityMembershipParam = (self.inputStudioId,"1")
            vc.flowSession = .validityMembership
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .bookTrainerHomeWorkout, .bookTrainerGymWorkout , .createPackage , .defaultFlow:
            let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
            vc.flowSlot = gymDetailsFlow
            vc.isFromHome = false
            vc.studioId = self.inputStudioId
            vc.inputLat = self.inputLat
            vc.inputLong = self.inputLong
            vc.inputType = self.inputType
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func setMapShowData(){
        
        //28.584125,77.2753162
        //        let camera = GMSCameraPosition.camera(withLatitude: 28.584125, longitude: 77.2753162, zoom: 10.0)
        
        DispatchQueue.main.async {
            // Create a map view using -init
            let mapView = GMSMapView()
            mapView.frame = self.showLocMap.bounds
            //            mapView.camera = camera
            
            self.mapView?.removeFromSuperview()
            self.mapView = mapView
            self.mapView.delegate = self
            self.mapView.isMyLocationEnabled = false
            self.mapView.isUserInteractionEnabled = true
            //            self.mapView.mapType = .terrain // Other types: .normal, .hybrid, .satellite
            self.mapView.accessibilityElementsHidden = false
            self.mapView.gestureRecognizers=nil
            self.mapView.padding=UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.mapView.settings.myLocationButton = true
            self.mapView.settings.compassButton = true
            self.mapView.isMyLocationEnabled = true
            self.mapView.isIndoorEnabled = true
            self.showLocMap.addSubview(self.mapView)
            
            self.mapView.settings.myLocationButton = false
            self.mapView.isMyLocationEnabled = false
            
            //            // Add a marker
            //                   let marker = GMSMarker()
            //                   marker.position = CLLocationCoordinate2D(latitude: 28.5854355, longitude: 77.3087411) // San Francisco
            ////                   marker.title = "San Francisco"
            ////                   marker.snippet = "California"
            //                   marker.icon = GMSMarker.markerImage(with: .red) // Optional: Custom marker color
            //                   marker.map =  self.mapView
            
            self.showLocMap.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.mapView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            
            // Prevent ScrollView from intercepting map gestures
            for gestureRecognizer in self.mapView.gestureRecognizers ?? [] {
                gestureRecognizer.delegate = self
            }
            // Add a pan gesture recognizer to detect when the map is being interacted with
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleMapPanGesture(_:)))
            panGesture.delegate = self
            self.mapView.addGestureRecognizer(panGesture)
            
            /*
             do {
             // Set the map style by passing the URL of the local file.
             if let styleURL = Bundle.main.url(forResource: "overlay", withExtension: "json") {
             print("load json....")
             //                  mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
             self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
             } else {
             NSLog("Unable to find style.json")
             }
             } catch {
             NSLog("One or more of the map styles failed to load. \(error)")
             }
             */
            
        }
        
        self.locationManager = CLLocationManager()
        if let locationManager = self.locationManager {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.requestAlwaysAuthorization()
            locationManager.distanceFilter = 50
            locationManager.startUpdatingLocation()
        }
    }
    
    func openGoogleMapsToDestination(destinationLatitude: Double, destinationLongitude: Double, destinationName: String = "Destination") {
        
        // Get user's current coordinates
        var sourceLatitude: Double?
        var sourceLongitude: Double?
        
        GetLocationManager.shared.requestLocationWithAddress {[weak self] location, addressPart in
            guard let self = self else { return }
            sourceLatitude = location?.coordinate.latitude
            sourceLongitude = location?.coordinate.longitude
            
            // Get user's current coordinates
            guard let sourceLatitude = sourceLatitude, let sourceLongitude = sourceLongitude else {
                print("Current location not available.")
                return
            }
            
            // Build the Google Maps URL
            let urlString = "comgooglemaps://?saddr=\(sourceLatitude),\(sourceLongitude)&daddr=\(destinationLatitude),\(destinationLongitude)&directionsmode=driving"
            
            // Check if Google Maps is installed
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback to Google Maps web if the app is not installed
                let webUrlString = "https://www.google.com/maps/dir/?api=1&origin=\(sourceLatitude),\(sourceLongitude)&destination=\(destinationLatitude),\(destinationLongitude)&travelmode=driving"
                if let webUrl = URL(string: webUrlString) {
                    UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, touch.view is GMSMapView {
            //            scrollView.isScrollEnabled = false
            
            //---------------*************
            if let scrollView = self.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
                print("Found scroll view: \(scrollView)")
                scrollView.isScrollEnabled = false
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        scrollView.isScrollEnabled = true
        //---------------*************
        if let scrollView = self.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            print("Found scroll view: \(scrollView)")
            scrollView.isScrollEnabled = true
        }
    }
    */
}


//MARK: ---------------UICOLLECTIONVIEW DATASOURCE/DELEGATE
extension GymDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == gymBannerCollView {
            
//            return collectionView.numberOfRows(count: studioDetails?.profile?.count ?? 0, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100, height: 100)), messageImageHeight: 80, fromCenter: -10, fromTop: nil)
            
            return collectionView.numberOfRows(count: studioDetails?.profile?.count ?? 0, title: AppAlertStrings.no_results_found, message: nil, messageImage: nil, messageImageHeight: 80, fromCenter: -10, fromTop: nil)
        }else if collectionView == categoryCollView {
            
            return self.sectionData?.count ?? 0
        }else if collectionView == gymRatingCollView{
            
            return collectionView.numberOfRows(count: studioDetails?.reviews?.count ?? 0, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100, height: 100)), messageImageHeight: 100, fromCenter: nil, fromTop: 2)
        }
        else if collectionView == mediaGalleryCollView{
            
            return collectionView.numberOfRows(count: studioDetails?.gallery?.count ?? 0, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100, height: 100)), messageImageHeight: 100, fromCenter: nil, fromTop: 2)
            
        }else if collectionView == gymOffersCollView{
            
            return collectionView.numberOfRows(count: studioDetails?.facility?.count ?? 0, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100, height: 100)), messageImageHeight: 100, fromCenter: nil , fromTop: 2)
        }
        else{
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == gymBannerCollView {
            let cell: WithMeCollectionViewCell = gymBannerCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            
            cell.centerImgView.isHidden = true
            cell.videoThumbnailImgView.loadImage(urlString: studioDetails?.profile?[indexPath.row], placeholder: UIImage())
            
            return cell
        }
        else if collectionView == categoryCollView{
            let categoryCell:WorkoutCategoryCollectionViewCell = categoryCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            
            DispatchQueue.main.async {
                categoryCell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: categoryCell.cellMBV.frame.size.height/2.0)
            }
            
            categoryCell.categoryTitleLbl.text = sectionData?[indexPath.row]["title"] as? String
            categoryCell.categoryImgView.image = sectionData?[indexPath.row]["img"] as? UIImage
            
            return categoryCell
        }
        else if collectionView == gymOffersCollView{
            let offersCell:MoreExploreCollectionViewCell = gymOffersCollView.dequeueReusableCell(withReuseIdentifier: "MoreExploreCollectionViewCell", for: indexPath) as! MoreExploreCollectionViewCell
            
            DispatchQueue.main.async {
                offersCell.categoryImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
            
            offersCell.categoryImgView.loadImage(urlString: studioDetails?.facility?[indexPath.row].icon, placeholder: UIImage())
            offersCell.titleLbl.text = studioDetails?.facility?[indexPath.row].name as? String
            
            return offersCell
            
        }
        else if collectionView == gymRatingCollView{
            let ratingCell:RatingsCollectionViewCell = gymRatingCollView.dequeueReusableCell(withReuseIdentifier: "RatingsCollectionViewCell", for: indexPath) as! RatingsCollectionViewCell
            
            ratingCell.userImgView.loadImage(urlString: studioDetails?.reviews?[indexPath.row].image, placeholder: UIImage())
            ratingCell.userNameLbl.text = studioDetails?.reviews?[indexPath.row].name
            //            ratingCell.reviewMsgLbl.text = studioDetails?.reviews?[indexPath.row].rating
            return ratingCell
        }
        else if collectionView == mediaGalleryCollView{
            let mediaCell:WithMeCollectionViewCell = mediaGalleryCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            
            if let getUrl = URL(string: studioDetails?.gallery?[indexPath.row].mediaPath ?? "") {
                getThumbnailImageFromVideoUrl(url: getUrl, completion: { (thumbNailImage) in
                    mediaCell.videoThumbnailImgView.image = thumbNailImage
                    mediaCell.centerImgView.isHidden = false
                    mediaCell.centerImgView.image = UIImage(named: "ic_play_white")
                    //ic_thumbnailVideo
                })
            } else{
                mediaCell.centerImgView.isHidden = true
            }
            
            return mediaCell
        }
        
        
        else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == categoryCollView {
            if (sectionData?[indexPath.row]["title"] as? String)?.uppercased() == "About The Gym".uppercased() {
                scrollToView(self.descLbl)
            }else  if (sectionData?[indexPath.row]["title"] as? String)?.uppercased() == "Gym Features".uppercased() {
                scrollToView(self.gymOffersCollView)
            }else  if (sectionData?[indexPath.row]["title"] as? String)?.uppercased() == "Equipment".uppercased() {
                scrollToView(self.equipmentInsideTblView)
            }else  if (sectionData?[indexPath.row]["title"] as? String)?.uppercased() == "Gallery".uppercased() {
                scrollToView(self.mediaGalleryCollView)
            }
            else  if (sectionData?[indexPath.row]["title"] as? String)?.uppercased() == "Review".uppercased() {
                scrollToView(self.gymRatingCollView)
            }
        }
        else if collectionView == mediaGalleryCollView{
            self.videoUrl = studioDetails?.gallery?[indexPath.row].mediaPath  //detailsModel?.galleries?[indexPath.row].mediaPath
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == gymOffersCollView{
            return CGSize(width: collectionView.frame.width*0.22, height: collectionView.frame.width*0.3)
            
        }
        else if collectionView == mediaGalleryCollView{
            return CGSize(width: collectionView.frame.width*0.45, height: collectionView.frame.height)
            
        }
        else if collectionView == gymRatingCollView{
            return CGSize(width: collectionView.frame.width*0.78, height: collectionView.frame.height)
            
        }
        else{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Get the visible cell closest to the center of the collection view
        let centerPoint = CGPoint(x: gymBannerCollView.bounds.midX + gymBannerCollView.contentOffset.x,
                                  y: gymBannerCollView.bounds.midY + gymBannerCollView.contentOffset.y)
        
        if let indexPath = gymBannerCollView.indexPathForItem(at: centerPoint) {
            print("Currently visible index: \(indexPath.row)")
            
            self.updatePage(to: indexPath.row)
        }
    }
    
}


//MARK: ---------------UITABLEVIEW DATASOURCE/DELEGATE
extension GymDetailsViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == equipmentInsideTblView {
            return localDatAmenity?.count ?? 00  //studioDetails?.amenity?.count ?? 0
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == equipmentInsideTblView {
            let equipmentCell:PointsTableViewCell = equipmentInsideTblView.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
            equipmentCell.leftImgView.backgroundColor = UIColor.appWhite
            equipmentCell.leftImgView.tintColor = UIColor.appWhite
            equipmentCell.leftImgView.image = nil
            equipmentCell.widthImgViewConstrnt.constant = 10.0
            equipmentCell.titleLbl.text = studioDetails?.amenity?[indexPath.row] as? String
            
            return equipmentCell
        }
        else{
            let gymTimeCell:PointsTableViewCell = gymTimeTblView.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
            
            gymTimeCell.titleLbl.text = studioDetails?.timing as? String //"Morning 6AM - 13:00 PM \nEvening 16 PM  - 23:00 PM"
            
            gymTimeCell.leftImgView.isHidden = true
            gymTimeCell.leftIgViewTrailingConstrnt.constant = 1.0
            gymTimeCell.widthImgViewConstrnt.constant = 0.0
            
            return gymTimeCell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.updateViewConstraints()
    }
}


extension GymDetailsViewController: GMSMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // Handle marker tap events
        print(marker.position.latitude,marker.position.longitude)
        self.openGoogleMapsToDestination(destinationLatitude: marker.position.latitude, destinationLongitude: marker.position.longitude, destinationName: "")
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {
            return
        }
        self.showmapCamera = location.coordinate
        
        //        self.locationManager?.stopUpdatingLocation()
        //        self.locationManager = nil
        
//        let addStr =  getCurrentAddr(location: location)
        
        
        //        addMarkers(marker: MarkerModel(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, title: title, snippet: addStr, iconImageName: AppImages.Radius))
        
        //        getCurrentAddr(location: location)
        self.locationManager?.stopUpdatingLocation()
        self.locationManager = nil
        //        locationManager?.stopUpdatingLocation()
        
    }
    
    //MARK: --------SHOW MULTIPLE MARK
    func addMarkers(marker: MarkerModel) {
        
        if  marker.latitude != 0 && marker.longitude != 0 {
            let camera = GMSCameraPosition.camera(withLatitude: marker.latitude, longitude: marker.longitude, zoom: 10.0)
            self.mapView?.camera = camera
        }
        mapView?.clear()
        
        let gmsMarker = GMSMarker()
        gmsMarker.position = CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude)
        gmsMarker.title = marker.title
        gmsMarker.snippet = marker.snippet
        gmsMarker.icon = GMSMarker.markerImage(with: .red) // marker.iconImageName// Set custom icon if provided
        gmsMarker.map = self.mapView
        
    }
    //MARK: ------------GET CURRENT ADDRESS
    func getCurrentAddr(location:CLLocation?) -> String{
        var addrStr:String = ""
        if let getLcation = location {
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate((CLLocationCoordinate2DMake((getLcation.coordinate.latitude), (getLcation.coordinate.longitude)))) { response, error in
                //
                if error != nil {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                } else {
                    if let places = response?.results() {
                        if let place = places.first {
                            
                            
                            if let lines = place.lines {
                                print("GEOCODE: Formatted Address: \(lines)")
                                
                                var subAddrStr = ""
                                
                                addrStr = lines.first ?? ""
                                
                                if let subLocality = places.first?.subLocality  {
                                    subAddrStr += subLocality + ", "
                                }
                                if let placeslocality = places.first?.locality  {
                                    subAddrStr += placeslocality + ", "
                                }
                                if let administrativeArea = places.first?.administrativeArea  {
                                    subAddrStr += administrativeArea + ", "
                                }
                                if let postalCode = places.first?.postalCode  {
                                    subAddrStr += postalCode + ", "
                                }
                                if let country = places.first?.country  {
                                    
                                }
                            }
                            
                        } else {
                            print("GEOCODE: nil first in places")
                        }
                    } else {
                        print("GEOCODE: nil in places")
                    }
                }
            }
        }
        
        return addrStr
    }
}

//MARK: -------------------EXTENSION FOR API
extension GymDetailsViewController {
    
    //MARK: --------------------GET STUDIO DETAILS API
    private func studioDatialsApi(){
        let params:[String:String] = [
            "id": self.inputStudioId ?? "",
            "long": self.inputLong ?? "",
            "lat": self.inputLat ?? "",
        ]
        
        TrainerVM.studioDetailsApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            print(getResultData)
            self.studioDetails = nil
            self.studioDetails = getResultData.data
            self.setInputData()
            self.gymBannerCollView.reloadData()
            self.gymOffersCollView.reloadData()
//            self.equipmentInsideTblView.reloadData()
            self.gymTimeTblView.reloadData()
            self.gymRatingCollView.reloadData()
            self.mediaGalleryCollView.reloadData()
            
            //-----------------------Equipment
            if let amenityConut = studioDetails?.amenity?.count {
                if amenityConut > 4 {
                    self.showAllEquipmentsBtn.setTitle("SHOW ALL EQUIPMENTS", for: .normal)
                    self.showAllEquipmentsBtnHeightConstrnt.constant = 56.0
                    self.showAllEquipmentsBtn.isHidden = false
                    self.localDatAmenity?.removeAll()
                    let amenities = studioDetails?.amenity ?? []
                    self.localDatAmenity?.append(contentsOf: amenities.prefix(4))
                    self.equipmentInsideTblView.reloadData()
                }else{
                    self.showAllEquipmentsBtn.setTitle(nil, for: .normal)
                    self.showAllEquipmentsBtnHeightConstrnt.constant = 1.0
                    self.showAllEquipmentsBtn.isHidden = true
                    self.localDatAmenity?.removeAll()
                    self.localDatAmenity?.append(contentsOf: studioDetails?.amenity ?? [])
                    self.equipmentInsideTblView.reloadData()
                }
            }
            
            if let getLat = studioDetails?.latitude, let getLong = studioDetails?.longitude, let lat = Double(getLat), let long = Double(getLong) {
                
                self.showmapCamera = CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
        })
    }
}

extension GymDetailsViewController: UIGestureRecognizerDelegate{
    
    // Ensure both UIScrollView and MapView gestures are handled properly
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
