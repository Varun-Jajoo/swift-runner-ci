//
//  LocationsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 04/11/24.
//

import UIKit
import GoogleMaps
import GooglePlaces

enum LocationFlow {
    case addAddress
    case editAddress
    case homePage
    case updateProfile
    case confirmAddAddress
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
                    self.addMarkers(marker: MarkerModel(latitude: latitude, longitude: longitude, title: self.getAddressData?.building_name?.value ?? "", snippet: self.getAddressData?.city_name ?? "", iconImageName: AppImages.Radius))
                    
                    self.locationManager?.stopUpdatingLocation()
                }
            }
        }
    }
    
    var isFromEditAddress:Bool? = false
    var getAddressData:AddressDataModel? = AddressDataModel()
    var sendBackAddr: ((String?) -> Void)?
    private var currentAddr: String?
    private var backgroundGradient: CAGradientLayer?
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var locSearch: UISearchBar!
    @IBOutlet weak var mainAddrLbl: UILabel!
    @IBOutlet weak var subAddrLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var currentLocMap: UIView!
    @IBOutlet weak var rightSearchBtn: UIButton!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var viewBottom: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locSearch.delegate = self
        setUpFont()
        setupUI()
//        self.enableContinueBtn(isSelected: true)
        setMapShowData()
        setUISearchbar()
        setupBackgroundGradient()
        updateContinueButton(isEnabled: true)
        setupContinueButtonIcon(isEnabled: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch flowLocation {
        case .addAddress, .confirmAddAddress:
            print("add Address..")
            
        case .editAddress:
            if let lat = getAddressData?.lat, let long = getAddressData?.long {
                print("from edit: ", lat, long, Double(lat.value ?? "0.0") ?? 0.0, Double(long.value ?? "0.0") ?? 0.0)
                
                self.locationManager?.stopUpdatingLocation()
                self.showmapCamera = CLLocationCoordinate2D(latitude: Double(lat.value ?? "0.0") ?? 0.0, longitude: Double(long.value ?? "0.0") ?? 0.0)
                
                self.getCurrentAddr(location: CLLocation(latitude: Double(lat.value ?? "0.0") ?? 0.0, longitude: Double(long.value ?? "0.0") ?? 0.0))
                
            }else{
                print("New add address...")
            }
        case .homePage:
            print("Home form")
        case .updateProfile:
            print("update Profile")
        case .defaultLoc:
            print("none.....")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient?.frame = viewBackground.bounds
    }
    
    func setNavUI(){
     
        switch flowLocation {
        case .addAddress, .editAddress, .homePage, .updateProfile, .confirmAddAddress:
            
            self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
            //        self.setNavigationTitle(title: AppStrings.select_plan, color: UIColor.black, font: AppFont.Bold.size(22.0))
            
        case .defaultLoc:
            self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
            self.setProgress(0.8)
            
            self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
            self.setRighMenu(setTitle: [AppStrings.skipStr], setTintColor: .black, setTitleColor: UIColor.txtSkip)
          
         
//            self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite) skipe remove need of client
            
            //        self.setNavigationTitle(title: AppStrings.select_plan, color: UIColor.black, font: AppFont.Bold.size(22.0))
        }
    }
    
    override func rightBtnActn(sender: UIButton) {
       
        switch flowLocation {
        case .addAddress, .editAddress, .homePage, .updateProfile, .confirmAddAddress:
            print("address....")
        case .defaultLoc:
            appUserDefaults.setRegistrationSkip(value: true)
            appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
            
//            appSceneDelegate?.goToGuestDashboard()
        }
    }
    
    private func setupBackgroundGradient() {
        // Remove old gradient if any
        backgroundGradient?.removeFromSuperlayer()

        let gradient = CAGradientLayer()
        gradient.colors = UIColor.appMultiColor(.greenBgGradient).map { $0.cgColor }

        // VERY IMPORTANT – match first UI direction
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint   = CGPoint(x: 1.0, y: 1.0)

        gradient.locations = [0.0, 0.5, 1.0]
        gradient.cornerRadius = 0

        viewBackground.layer.insertSublayer(gradient, at: 0)
        backgroundGradient = gradient
    }
    
    func updateContinueButton(isEnabled: Bool) {
        continueBtn.isEnabled = isEnabled
        continueBtn.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0.2) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.continueBtn.tintColor = .mainBg   // arrow color
                self.continueBtn.backgroundColor = .appWhite
                self.continueBtn.setTitleColor(.mainBg, for: .normal)
            } else {
                self.continueBtn.tintColor = .appWhite
                self.continueBtn.backgroundColor = .appDarkGray
                self.continueBtn.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {
        let arrowImage = UIImage(named: isEnabled ? "blackRightArrow" : "whiteRightArrow")?
            .withRenderingMode(.alwaysTemplate)
        
        continueBtn.setImage(arrowImage, for: .normal)
        
        // Force image on right side
        continueBtn.semanticContentAttribute = .forceRightToLeft
        
        // Space between text and image
        continueBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -12)
        continueBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -1, bottom: 0, right: 12)
        
        continueBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    //MARK: ---------- SET UI
    private func setupUI() {
        
        self.mainAddrLbl.numberOfLines = 2
        self.subAddrLbl.numberOfLines = 2
        
        DispatchQueue.main.async {
            self.locSearch.setCornerRadius(borderWidth: 1, borderColor: .appBorder, cornerRadious: 12.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
//            self.viewBottom.addGradient(colors: UIColor.appMultiColor(.locationBgGradient), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0)
        }
    }
    
    //------------------************Font
    private func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.mainAddrLbl.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
        self.subAddrLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }
    
    
    //MARK: ---------------- Searchbar Customize
//    func setUISearchbar() {
//        self.locSearch.barTintColor = UIColor.mainBg
//        self.locSearch.tintColor = UIColor.blue
//        self.locSearch.searchTextField.backgroundColor = UIColor.clear
//        self.locSearch.searchTextField.textColor = UIColor.appWhite
//        self.locSearch.isTranslucent = false
//        self.locSearch.placeholder = "Search for area, street name..."
//        self.locSearch.searchTextField.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
//        self.locSearch.showsCancelButton = false
//        self.locSearch.searchTextField.setRightPaddingPoint(40.0)
//        
//        if let textField = self.locSearch.value(forKey: "searchField") as? UITextField {
//            textField.clearButtonMode = .never
//            textField.attributedPlaceholder = NSAttributedString(
//                string: "Search for area, street name...",
//                attributes: [NSAttributedString.Key.foregroundColor: UIColor.txtDarkGray]
//            )
//        }
//    }
    func setUISearchbar() {

        locSearch.backgroundImage = UIImage()
        locSearch.isTranslucent = false

        // Outer container style
//        locSearch.layer.cornerRadius = 18
        locSearch.layer.masksToBounds = true
        locSearch.layer.borderWidth = 1
        locSearch.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

       let tf = locSearch.searchTextField
//        tf.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        tf.textColor = .white
        tf.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        tf.attributedPlaceholder = NSAttributedString(
            string: " Search for area, street name...",
            attributes: [.foregroundColor: UIColor.txtDarkGray]
        )
        tf.clearButtonMode = .never
//        tf.leftView?.tintColor = .white
//        tf.layer.cornerRadius = 12
//        tf.layer.masksToBounds = true

        // 🔹 ADD your custom icon
        let icon = UIImageView(image: UIImage(named: "search-normal"))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 10, y: 0, width: 24, height: 24)

        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 20))
        icon.center = iconContainer.center
        iconContainer.addSubview(icon)

        tf.leftView = iconContainer
        tf.leftViewMode = .always

        
        // 🔥 IMPORTANT – remove iOS default gap
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.leadingAnchor.constraint(equalTo: locSearch.leadingAnchor, constant: 0),
            tf.trailingAnchor.constraint(equalTo: locSearch.trailingAnchor, constant: 0),
            tf.topAnchor.constraint(equalTo: locSearch.topAnchor, constant: 0),
            tf.bottomAnchor.constraint(equalTo: locSearch.bottomAnchor, constant: 0)
        ])
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
//            self.mapView.isMyLocationEnabled = false
            self.mapView.isUserInteractionEnabled = true
//            self.mapView.mapType = .terrain // Other types: .normal, .hybrid, .satellite
            self.mapView.accessibilityElementsHidden = false
            self.mapView.gestureRecognizers = nil
            self.mapView.padding=UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.mapView.settings.myLocationButton = false
            self.mapView.settings.compassButton = true
//            self.mapView.isMyLocationEnabled = true
            self.mapView.isIndoorEnabled = true
            self.mapView.isMyLocationEnabled = false
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
        case .addAddress:
            
            if let getAddressData = getAddressData {
                print(getAddressData)
                
                let vc:BookingAddressViewController = BookingAddressViewController.instantiate(appStoryboard: .booking)
                vc.modalPresentationStyle = .automatic
                vc.bookingAddressFlow = .addAddress
                vc.addressData = self.getAddressData
                vc.navCtrnl = self.navigationController
                self.present(vc, animated: true)
                
            }else{
                AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.enter_Location)
            }
        case .editAddress:
            if let getAddressData = getAddressData {
                print(getAddressData)
                
                let vc:BookingAddressViewController = BookingAddressViewController.instantiate(appStoryboard: .booking)
                vc.modalPresentationStyle = .automatic
                vc.bookingAddressFlow = .editAddress
                vc.addressData = self.getAddressData
                vc.navCtrnl = self.navigationController
                self.present(vc, animated: true)
                
            }else{
                AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.enter_Location)
            }
            
        case .homePage:
            print("From Home Page.")
            self.navigationController?.popViewController(animated: true)
       
        case .updateProfile:
            print("update profile..")
            self.sendBackAddr?(self.currentAddr)
            self.navigationController?.popViewController(animated: true)
            
        case .confirmAddAddress:
            
            if let getAddressData = getAddressData {
                print(getAddressData)
//                vc.addressData = self.getAddressData
                let vc: AddNewAddressViewController = AddNewAddressViewController.instantiate(appStoryboard: .booking)
                vc.addressData = getAddressData
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
       
            
        case .defaultLoc:
            
            if let mainAddrLbl = self.mainAddrLbl.text , !mainAddrLbl.isEmpty, let subAddrLbl = self.subAddrLbl.text, !subAddrLbl.isEmpty, let lat = showmapCamera?.latitude as? Double, let long = showmapCamera?.longitude as? Double {
                print(mainAddrLbl, subAddrLbl, lat, long)
                let fullAddr = mainAddrLbl + " " + subAddrLbl
                print(fullAddr)
                
                RegistrationVM.addLocationApi(viewController: self, inputLat: "\(lat)", inputLong: "\(long)", inputAddress: fullAddr, completion: { [weak self] getResultData in
                    guard let self = self, let getResultData = getResultData else { return  }
                    
                    if getResultData.status == true {
                        appUserDefaults.setRegistrationSkip(value: false)
                        
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
        self.startUpdating()
    }
    
    func startUpdating() {
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
    
    //MARK: -------------- ENABLE CONTINUE
//    func enableContinueBtn(isSelected:Bool = false){
//        if isSelected {
//            self.continueBtn.isUserInteractionEnabled = true
//            self.continueBtn.backgroundColor = UIColor.appWhite
//            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
//        } else {
//            self.continueBtn.isUserInteractionEnabled = false
//            self.continueBtn.backgroundColor = UIColor.appDarkGray
//            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
//        }
//    }
    
    
    private func searchPlace(){
        let autocompleteController = GMSAutocompleteViewController()
             autocompleteController.delegate = self
             present(autocompleteController, animated: true, completion: nil)
    }
    
}

//MARK: ----------------Extension for searchbar
extension LocationsViewController:UISearchBarDelegate{
    // Delegate method to handle search actions
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.locSearch.showsCancelButton = false
        self.locSearch.searchTextField.setRightPaddingPoint(40.0)
        self.searchPlace()
       }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.text = nil
           searchBar.showsCancelButton = false

          dismiss(animated: true, completion: nil)
           // Remove focus from the search bar.
           searchBar.endEditing(true)

           // Perform any necessary work.  E.g., repopulating a table view
           // if the search bar performs filtering.
       }
    
       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

           // Perform search action with the search text

           print("Search text: \(searchBar.text ?? "")")
           dismiss(animated: true, completion: nil)
           self.locSearch.endEditing(true)
       }

}

//MARK: ---------------- Extension for google map delegate
extension LocationsViewController: GMSMapViewDelegate, CLLocationManagerDelegate {
    
    
    private func startUpdatingLocation() {
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // Handle marker tap events
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        
        self.isFromEditAddress = false
        
        addMarkers(marker: MarkerModel(latitude: coordinate.latitude, longitude: coordinate.longitude, title: "title", snippet: self.mainAddrLbl.text, iconImageName: AppImages.Radius))
        
        self.getCurrentAddr(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        
        self.setUpMapHeigth()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //        reverseGeocodeCoordinate(position.target)
        if let isFromEditAddress = self.isFromEditAddress, !isFromEditAddress {
            let centerCoordinate = mapView.projection.coordinate(for: self.mapView.center)
            self.showmapCamera = centerCoordinate
            self.getCurrentAddr(location: CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude))
        }
        
        //        let centerCoordinate = mapView.projection.coordinate(for: self.mapView.center)
        //        self.showmapCamera = centerCoordinate
        //        self.getCurrentAddr(location: CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude))
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        //
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
         case .authorizedAlways, .authorizedWhenInUse:
             startUpdatingLocation()
         case .denied, .restricted:
            AlertHelper.shared.showCustomeAlert(title: AppAlertStrings.location_permission, message: AppAlertStrings.loaction_access, actions: ["Open Settings"], withCancel: false, completion: {[weak self] tag in
                guard self != nil else { return }
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings)
                }
            })
            
         default:
             break
         }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {
            return
        }
        
        self.showmapCamera = location.coordinate
        self.locationManager?.stopUpdatingLocation()
        self.locationManager = nil
    
        if let isFromEditAddress = self.isFromEditAddress, !isFromEditAddress {
            addMarkers(marker: MarkerModel(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, title: title, snippet: self.mainAddrLbl.text, iconImageName: AppImages.Radius))
            
            getCurrentAddr(location: location)
            locationManager?.stopUpdatingLocation()
        }else{
            locationManager?.stopUpdatingLocation()
        }
        
//        addMarkers(marker: MarkerModel(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, title: title, snippet: self.mainAddrLbl.text, iconImageName: AppImages.Radius))
//        
//        getCurrentAddr(location: location)
//        locationManager?.stopUpdatingLocation()
        
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
                                self.currentAddr = lines.first
                                self.mainAddrLbl.text = lines.first
                                appUserDefaults.setLatLong(value: "\(getLcation.coordinate.latitude),\(getLcation.coordinate.longitude)")
                                appUserDefaults.setCurrentAddr(value: lines.first)
                                
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
                                
                                //----------------Get Address
                                
                                // Extract different parts from lines
                                let addressComponents = lines.joined(separator: ", ").components(separatedBy: ", ")
                                
                                let buildingName = addressComponents.count > 0 ? addressComponents[0] : ""
                                let streetName = addressComponents.count > 1 ? addressComponents[1] : ""
                                let landmark = addressComponents.count > 2 ? addressComponents[2] : ""
                                
                                self.getAddressData?.landmark = landmark
                                
                                if self.getAddressData?.building_name == nil {
                                    self.getAddressData?.building_name = FlexibleValue(value: buildingName)
                                } else {
                                    self.getAddressData?.building_name?.value = buildingName
                                }
                                
                                if self.getAddressData?.street == nil {
                                    self.getAddressData?.street = FlexibleValue(value: streetName)
                                } else {
                                    self.getAddressData?.street?.value = streetName
                                }
                                
                                if self.getAddressData?.lat == nil {
                                    self.getAddressData?.lat = FlexibleValue(value: "\(getLcation.coordinate.latitude)")
                                } else {
                                    self.getAddressData?.lat?.value = "\(getLcation.coordinate.latitude)"
                                }
                                
                                if self.getAddressData?.long == nil {
                                    self.getAddressData?.long = FlexibleValue(value: "\(getLcation.coordinate.longitude)")
                                } else {
                                    self.getAddressData?.long?.value = "\(getLcation.coordinate.longitude)"
                                }
                                
                                
                                self.setUpMapHeigth()
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

extension LocationsViewController: GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place selected: \(place.name ?? "No name")")
                print("Address: \(place.formattedAddress ?? "")")
                print("Coordinates: \(place.coordinate.latitude), \(place.coordinate.longitude)")
   
        self.locSearch.text = place.name
//        self.locationManager?.stopUpdatingLocation()
        self.showmapCamera = place.coordinate
        self.getCurrentAddr(location: CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
       
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: any Error) {
        dismiss(animated: true, completion: nil)
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}



struct MarkerModel {
    let latitude: Double
    let longitude: Double
    let title: String?
    let snippet: String?
    let iconImageName: UIImage?
}
