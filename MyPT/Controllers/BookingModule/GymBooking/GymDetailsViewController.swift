//
//  GymDetailsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 12/12/24.
//

import UIKit
import GoogleMaps

class GymDetailsViewController: CommonViewController {

    //MARK: -------------VARIABLE
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    
    var mapView: GMSMapView!
    var locationManager: CLLocationManager?
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var gymImgView: UIImageView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.setUpCustomPageControl()
        self.updatePage(to: 0)
        self.setUpFont()
        self.setMapShowData()
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
        let firstIndexPath = IndexPath(item: 0, section: 0)
        DispatchQueue.main.async {
            self.categoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.categoryCollView.delegate?.collectionView?(self.categoryCollView, didSelectItemAt: firstIndexPath)
            self.view.layoutIfNeeded()
        }
    }
    
    func setUpUI(){
        
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
    
    func setUpFont(){
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
    func setUpCustomPageControl(){
        self.pageContrl.numberOfPages = 3  // Set the total number of pages
        self.pageContrl.currentPage = 0    // Set the initial page
        self.pageContrl.activeDotSize = CGSize(width: 26, height: 8)
        self.pageContrl.currentDotColor = UIColor.appWhite // UIColor(red: 158/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1)
        self.pageContrl.defaultDotColor = UIColor.txtDarkGray
        
    }
    
    // Update the current page based on some user interaction (e.g., swiping between views)
    func updatePage(to index: Int) {
        self.pageContrl.currentPage = index
    }
    
    @IBAction func bookSlotBtnActn(_ sender: Any) {
        print("book slot btn actn.........")
        
        let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
        vc.flowSlot = calendarFlow.bookTrainer
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setMapShowData(){

//        let camera = GMSCameraPosition.camera(withLatitude: 28.5854355, longitude: 77.3087411, zoom: 10.0)
        let camera = GMSCameraPosition.camera(withLatitude: 28.5854355, longitude: 77.3087411, zoom: 10.0)
                
        DispatchQueue.main.async {
            // Create a map view using -init
            let mapView = GMSMapView()
            mapView.frame = self.showLocMap.bounds
            mapView.camera = camera

            self.mapView?.removeFromSuperview()
            self.mapView = mapView
            self.mapView.delegate = self
            self.mapView.isMyLocationEnabled = false
            self.mapView.isUserInteractionEnabled = false
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
    
}


//MARK: ---------------UICOLLECTIONVIEW DATASOURCE/DELEGATE
extension GymDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollView{
            let categoryCell:WorkoutCategoryCollectionViewCell = categoryCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            return categoryCell
        }
        else if collectionView == gymOffersCollView{
            let offersCell:MoreExploreCollectionViewCell = gymOffersCollView.dequeueReusableCell(withReuseIdentifier: "MoreExploreCollectionViewCell", for: indexPath) as! MoreExploreCollectionViewCell
            
            return offersCell

        }
        else if collectionView == gymRatingCollView{
            let mediaCell:RatingsCollectionViewCell = gymRatingCollView.dequeueReusableCell(withReuseIdentifier: "RatingsCollectionViewCell", for: indexPath) as! RatingsCollectionViewCell
            return mediaCell
        }
        else if collectionView == mediaGalleryCollView{
            let mediaCell:WithMeCollectionViewCell = mediaGalleryCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            return mediaCell
        }

        
        else{
           return UICollectionViewCell()
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
    
}


//MARK: ---------------UITABLEVIEW DATASOURCE/DELEGATE
extension GymDetailsViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == equipmentInsideTblView {
            return 8
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
            return equipmentCell
        }
        else{
            let gymTimeCell:PointsTableViewCell = gymTimeTblView.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
            gymTimeCell.titleLbl.text = "Morning 6AM - 13:00 PM \nEvening 16 PM  - 23:00 PM"
            
            gymTimeCell.leftImgView.isHidden = true
            gymTimeCell.leftIgViewTrailingConstrnt.constant = 1.0
            gymTimeCell.widthImgViewConstrnt.constant = 0.0
            
            return gymTimeCell
        }
    }
}
    

extension GymDetailsViewController: GMSMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {
            return
        }
        self.locationManager?.stopUpdatingLocation()
        self.locationManager = nil
        
        let addStr =  getCurrentAddr(location: location)
        
        
        addMarkers(marker: MarkerModel(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, title: title, snippet: addStr, iconImageName: AppImages.Radius))
        
//        getCurrentAddr(location: location)
        locationManager?.stopUpdatingLocation()
        
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
