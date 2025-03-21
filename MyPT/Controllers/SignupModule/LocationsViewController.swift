//
//  LocationsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 04/11/24.
//

import UIKit
import GoogleMaps


enum LocationFlow {
    case addAdress
    case defaultLoc
}

class LocationsViewController: CommonViewController {
    
    //MARK: ----------- VARIABLE
    var flowLocation:LocationFlow = .defaultLoc
    
    var mapView: GMSMapView!
    var locationManager: CLLocationManager?
    
    var showmapCamera: CLLocationCoordinate2D? = nil {
        didSet{
            if let latitude = showmapCamera?.latitude , let longitude = showmapCamera?.longitude {
                let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 10.0)
                DispatchQueue.main.async {
                    self.mapView?.camera = camera
                    self.locationManager?.stopUpdatingLocation()
                }
            }
        }
    }
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var locSearch: UISearchBar!
    @IBOutlet weak var mainAddrLbl: UILabel!
    @IBOutlet weak var subAddrLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var currentLocMap: UIView!
    @IBOutlet weak var rightSearchBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locSearch.delegate = self
        setUpFont()
        setupUI()
        self.enableContinueBtn(isSelected: true)
        setMapShowData()
        setUISearchbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    
    func setNavUI(){
     
        switch flowLocation {
        case .addAdress:
            
            self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
            //        self.setNavigationTitle(title: AppStrings.select_plan, color: UIColor.black, font: AppFont.Bold.size(22.0))
            
        case .defaultLoc:
            self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
            self.setProgress(1.0)
            
            self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
            self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
            //        self.setNavigationTitle(title: AppStrings.select_plan, color: UIColor.black, font: AppFont.Bold.size(22.0))
        }
    }
    
    override func rightBtnActn(sender: UIButton) {
       
        switch flowLocation {
        case .addAdress:
            print("address....")
        case .defaultLoc:
            appSceneDelegate?.goToGuestDashboard()
        }
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        DispatchQueue.main.async {
            self.locSearch.setCornerRadius(borderWidth: 1, borderColor: .appBorder, cornerRadious: 12.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    //------------------************Font
    func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.mainAddrLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.subAddrLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    
    //MARK: ---------------- Searchbar Customize
    func setUISearchbar(){
        self.locSearch.barTintColor = UIColor.mainBg
        self.locSearch.tintColor = UIColor.blue
        self.locSearch.searchTextField.backgroundColor = UIColor.clear
        self.locSearch.searchTextField.textColor = UIColor.appWhite
        self.locSearch.isTranslucent = false
        self.locSearch.placeholder = "Search for area, street name..."
        self.locSearch.setPlaceholderColor(UIColor.txtDarkGray)
        self.locSearch.searchTextField.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.locSearch.showsCancelButton = false
        self.locSearch.searchTextField.setRightPaddingPoint(40.0)
        
        if let textField = self.locSearch.value(forKey: "searchField") as? UITextField {
            textField.clearButtonMode = .never
        }
    
    }
    
    //MARK: ----------------MAP VIEW
    // Set the status bar style to complement night-mode.
     override var preferredStatusBarStyle: UIStatusBarStyle {
       return .lightContent
     }
    
//     override func loadView() {
////       let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 14.0)
////       let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//
//       do {
//         // Set the map style by passing the URL of the local file.
//         if let styleURL = Bundle.main.url(forResource: "overlay", withExtension: "json") {
//             self.mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
//         } else {
//           NSLog("Unable to find style.json")
//         }
//       } catch {
//         NSLog("One or more of the map styles failed to load. \(error)")
//       }
//
//       self.currentLocMap = mapView
//     }
    
    
    func setMapShowData(){

//        let camera = GMSCameraPosition.camera(withLatitude: 28.5854355, longitude: 77.3087411, zoom: 10.0)
        let camera = GMSCameraPosition.camera(withLatitude: 0.0, longitude: 0.0, zoom: 10.0)
                
        DispatchQueue.main.async {
            // Create a map view using -init
            let mapView = GMSMapView()
            mapView.frame = self.currentLocMap.bounds
            mapView.camera = camera

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
            self.currentLocMap.addSubview(self.mapView)
                        
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
        
        addMarkers(marker: MarkerModel(latitude: 28.5854355, longitude: 77.3087411, title: title, snippet: self.mainAddrLbl.text, iconImageName: AppImages.Radius))
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("Continue btn actn...")
        
        switch flowLocation {
        case .addAdress:
            
            if let mainAddrLbl = self.mainAddrLbl.text , !mainAddrLbl.isEmpty, let subAddrLbl = self.subAddrLbl.text, !subAddrLbl.isEmpty, let lat = showmapCamera?.latitude as? Double, let long = showmapCamera?.longitude as? Double {
                print(mainAddrLbl, subAddrLbl, lat, long)
                let fullAddr = mainAddrLbl + " " + subAddrLbl
                print(fullAddr)
                
                let vc:BookingAddressViewController = BookingAddressViewController.instantiate(appStoryboard: .booking)
                vc.modalPresentationStyle = .automatic
                vc.bookingAddressFlow = .addAddress
                self.present(vc, animated: true)
                
            }else{
                AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.enter_Location)
            }
            
        case .defaultLoc:
            
            if let mainAddrLbl = self.mainAddrLbl.text , !mainAddrLbl.isEmpty, let subAddrLbl = self.subAddrLbl.text, !subAddrLbl.isEmpty, let lat = showmapCamera?.latitude as? Double, let long = showmapCamera?.longitude as? Double {
                print(mainAddrLbl, subAddrLbl, lat, long)
                let fullAddr = mainAddrLbl + " " + subAddrLbl
                
                print(fullAddr)
                
                RegistrationVM.addLocationApi(viewController: self, inputLat: "\(lat)", inputLong: "\(long)", inputAddress: fullAddr, completion: { [weak self] getResultData in
                    guard let self = self, let getResultData = getResultData else { return  }
                    
                    if getResultData.status == true {
                        if let detailsData = getResultData.data {
                            appUserDefaults.saveUserToUserDefaults(detailsData)
                        }
                        
                        let vc:GetStartViewController = GetStartViewController.instantiate(appStoryboard: .main)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
                
            }else{
                AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.enter_Location)
            }
        }
        
       /*
        if let mainAddrLbl = self.mainAddrLbl.text , !mainAddrLbl.isEmpty, let subAddrLbl = self.subAddrLbl.text, !subAddrLbl.isEmpty, let lat = showmapCamera?.latitude as? Double, let long = showmapCamera?.longitude as? Double {
            print(mainAddrLbl, subAddrLbl, lat, long)
            let fullAddr = mainAddrLbl + " " + subAddrLbl
            
            print(fullAddr)
            
            RegistrationVM.addLocationApi(viewController: self, inputLat: "\(lat)", inputLong: "\(long)", inputAddress: fullAddr, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                
                if getResultData.status == true {
                    if let detailsData = getResultData.data {
                        appUserDefaults.saveUserToUserDefaults(detailsData)
                    }
                    
                    let vc:GetStartViewController = GetStartViewController.instantiate(appStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
            
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.enter_Location)
        }
        */
    }
    
    @IBAction func rightSearchBtnActn(_ sender: Any) {
        print("rightSearchBtnActn clicked")
        self.locSearch.text = nil
    }
    
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false){
        if isSelected {
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = UIColor.appWhite
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
}

//MARK: ----------------Extension for searchbar
extension LocationsViewController:UISearchBarDelegate{
    // Delegate method to handle search actions
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.locSearch.showsCancelButton = false
        self.locSearch.searchTextField.setRightPaddingPoint(40.0)
       }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.text = nil
           searchBar.showsCancelButton = false

           // Remove focus from the search bar.
           searchBar.endEditing(true)

           // Perform any necessary work.  E.g., repopulating a table view
           // if the search bar performs filtering.
       }
       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

           // Perform search action with the search text

           print("Search text: \(searchBar.text ?? "")")
           
           self.locSearch.endEditing(true)

       }

}

//MARK: ---------------- Extension for google map delegate
extension LocationsViewController: GMSMapViewDelegate, CLLocationManagerDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // Handle marker tap events
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        
        addMarkers(marker: MarkerModel(latitude: coordinate.latitude, longitude: coordinate.longitude, title: "title", snippet: self.mainAddrLbl.text, iconImageName: AppImages.Radius))
        
        self.getCurrentAddr(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        
        self.setUpMapHeigth()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        //
    }
    
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
        
        self.showmapCamera = location.coordinate
        self.locationManager?.stopUpdatingLocation()
        self.locationManager = nil
        
        
        addMarkers(marker: MarkerModel(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, title: title, snippet: self.mainAddrLbl.text, iconImageName: AppImages.Radius))
        
        getCurrentAddr(location: location)
        
        
        /*
        // Get user's current location name
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarksArray, error) in
            
            
            if (placemarksArray?.count)! > 0 {
                
                var locality =  ""
                var postalCode =  ""
                var administrativeArea = ""
                var country = ""
                var sublocality = ""
                var throughfare = ""
//                var name = ""
                
                if let containsPlacemark = placemarksArray?.first {
                    locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality! : ""
                    postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode! : ""
                    administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea! : ""
                    country = (containsPlacemark.country != nil) ? containsPlacemark.country! : ""
                    sublocality = (containsPlacemark.subLocality != nil) ? containsPlacemark.subLocality! : ""
                    throughfare = (containsPlacemark.thoroughfare != nil) ? containsPlacemark.thoroughfare! : ""
                    
                }
                
                var adr: String  = ""
                
                if throughfare != "" {
                    
                    adr = throughfare + ", "
                    
                }
                if sublocality != "" {
                    
                    adr = adr + sublocality + ", "
                    
                }
                if locality != "" {
                    
                    adr = adr + locality + ", "
                    
                }
                if administrativeArea != "" {
                    
                    adr = adr + administrativeArea + ", "
                    
                }
                if postalCode != "" {
                    
                    adr = adr + postalCode + ", "
                    
                }
                if country != "" {
                    
                    adr = adr + country
                }
                
                self.mainAddrLbl.text = adr
            
            }
        }
        */
        
       
        
        locationManager?.stopUpdatingLocation()
        
        self.setUpMapHeigth()
    }
    
    
    
    //MARK: --------SHOW MULTIPLE MARK
    func addMarkers(marker: MarkerModel) {
        mapView?.clear()
        let gmsMarker = GMSMarker()
        gmsMarker.position = CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude)
        gmsMarker.title = marker.title
        gmsMarker.snippet = marker.snippet
        gmsMarker.icon = marker.iconImageName// Set custom icon if provided
        gmsMarker.map = self.mapView
        
    }
    
    //MARK: ------------GET CURRENT ADDRESS
    
    func getCurrentAddr(location:CLLocation?){
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
                                
                                self.mainAddrLbl.text = lines.first
                                
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
                                    subAddrStr += country
                                }
                                
                                self.subAddrLbl.text = subAddrStr
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
    }
    
    func setUpMapHeigth(){
        DispatchQueue.main.async {
            self.mapView.frame = self.currentLocMap.bounds
            self.currentLocMap.addSubview(self.mapView)
        }
    }
    
    //    func getAddressFromLatLon(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    //        let geocoder = CLGeocoder()
    //        let location = CLLocation(latitude: latitude, longitude: longitude)
    //
    //        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
    //            if let error = error {
    //                print("Reverse geocoding failed: \(error.localizedDescription)")
    //                return
    //            }
    //
    //            if let placemark = placemarks?.first {
    //
    //                let buildingNumber = placemark.subThoroughfare ?? "N/A" // House/Building Number
    //                let streetName = placemark.thoroughfare ?? "N/A"       // Street Name
    //                let landmark = placemark.locality ?? "N/A"             // City or Area
    //
    //                print("Building Number: \(buildingNumber)")
    //                print("Street Name: \(streetName)")
    //                print("Landmark: \(landmark)")
    //                print("Full Address: \(placemark.name ?? "N/A")")
    //            }
    //        }
    //    }
        
        /* Using Google Places API for Autocomplete
        func fetchPlaceDetails(placeID: String) {
            let placesClient = GMSPlacesClient.shared()
            placesClient.lookUpPlaceID(placeID) { (place, error) in
                if let error = error {
                    print("Error fetching place details: \(error.localizedDescription)")
                    return
                }
                if let place = place {
                    let buildingNumber = place.addressComponents?.first(where: { $0.types.contains("street_number") })?.name ?? "N/A"
                    let streetName = place.addressComponents?.first(where: { $0.types.contains("route") })?.name ?? "N/A"
                    let landmark = place.addressComponents?.first(where: { $0.types.contains("sublocality_level_1") })?.name ?? "N/A"
                    
                    print("Building Number: \(buildingNumber)")
                    print("Street Name: \(streetName)")
                    print("Landmark: \(landmark)")
                }
            }
        }
        */
}

struct MarkerModel {
    let latitude: Double
    let longitude: Double
    let title: String?
    let snippet: String?
    let iconImageName: UIImage?
}
