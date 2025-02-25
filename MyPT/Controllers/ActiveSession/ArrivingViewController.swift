//
//  ArrivingViewController.swift
//  MyPT
//
//  Created by techsaga corp on 22/01/25.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps

class ArrivingViewController: CommonViewController, UITextFieldDelegate {
    
    //MARK: ----------- VARIABLE
   weak var mapView: GMSMapView!
    
//    lazy var mapView: GMSMapView = {
//        let camera = GMSCameraPosition.camera(withLatitude: 40.7128, longitude: -74.0060, zoom: 10.0)
//        let mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
//        mapView.isMyLocationEnabled = true
//        return mapView
//    }()
    
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
    
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var mapMBV: UIView!
    @IBOutlet weak var bottomMBV: UIView!
    @IBOutlet weak var timeMBV: UIView!
    @IBOutlet weak var beforeArrivesBtn: UIButton!
    @IBOutlet weak var sessionDetailsBtn: UIButton!
    @IBOutlet weak var otpSessionBtn: UIButton!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var cat1Btn: UIButton!
    @IBOutlet weak var cat2Btn: UIButton!
    @IBOutlet weak var cat3Btn: UIButton!
    @IBOutlet weak var arrivingAddrLbl: UILabel!
    @IBOutlet weak var timeCountLbl: UILabel!
    @IBOutlet weak var timeTitleLbl: UILabel!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var otp1TxtField: UITextField!
    @IBOutlet weak var otp2TxtField: UITextField!
    @IBOutlet weak var otp3TxtField: UITextField!
    @IBOutlet weak var otp4TxtField: UITextField!
    @IBOutlet weak var trainerMsgTxtView: IQTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        [
//            self.otp1TxtField,
//            self.otp2TxtField,
//            self.otp3TxtField,
//            self.otp4TxtField
//        ].forEach({
//            $0?.delegate = self
//        })
        
        self.otp1TxtField.delegate = self
        self.otp2TxtField.delegate = self
        self.otp3TxtField.delegate = self
        self.otp4TxtField.delegate = self
        
        self.setupFont()
        self.setupUI()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //----------------
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.track_My_Trainer], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.setupUI()
//    }
    
    
    @IBAction func beforeArrivesBtnActn(_ sender: Any) {
        let vc:PlanPopupViewController = PlanPopupViewController.instantiate(appStoryboard: .calendar)
        vc.modalPresentationStyle = .automatic
        vc.planFlowSetup = .checkListActiveSession
        self.navigationController?.present(vc, animated: true)
    }
    
    
    @IBAction func otpSessionBtnActn(_ sender: Any) {
        print("Otp session btn action")
    }
    
    @IBAction func phoneBtnActn(_ sender: Any) {
        self.callNumber(phoneNumber: "1234567899")
    }
    
    //-----------------Make calling
    private func callNumber(phoneNumber: String) {
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func setMapShowData(){
        
        //        let camera = GMSCameraPosition.camera(withLatitude: 28.5854355, longitude: 77.3087411, zoom: 10.0)
        
        let camera = GMSCameraPosition.camera(withLatitude: 0.0, longitude: 0.0, zoom: 10.0)
        
        DispatchQueue.main.async {
            // Create a map view using -init
            let mapView = GMSMapView()
            mapView.frame = self.mapMBV.bounds
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
            self.mapMBV.addSubview(self.mapView)
            
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
        
        //        addMarkers(marker: MarkerModel(latitude: 28.5854355, longitude: 77.3087411, title: title, snippet: self.mainAddrLbl.text, iconImageName: AppImages.Radius))
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.bottomMBV.setGradientBorder(cornerRadious: 20, width: 3, colors: [UIColor.appWhite, UIColor.clear], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 0.1))
            self.bottomMBV.roundSideCorners(radius: 20, cornerSide: [.topLeft, .topRight])
            self.trainerImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.trainerImgView.frame.size.height/2.0)
            self.phoneBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12)
            self.trainerMsgTxtView.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.txtDarkGray, cornerRadious: 8.0)
            self.beforeArrivesBtn.addGradient(colors: [UIColor(red: 23.0/255.0, green: 14.0/255.0, blue: 8.0/255.0, alpha: 1.0),UIColor(red: 97.0/255.0, green: 69.0/255.0, blue: 49.0/255.0, alpha: 1.0),UIColor(red: 28.0/255.0, green: 16.0/255.0, blue: 8.0/255.0, alpha: 1.0)], locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 1)
            self.beforeArrivesBtn.roundSideCorners(radius: 20, cornerSide: [.topLeft, .topRight])
            self.timeMBV.addGradient(colors: [UIColor(red: 91.0/255.0, green: 42.0/255.0, blue: 12.0/255.0, alpha: 1.0),UIColor(red: 191.0/255.0, green: 109.0/255.0, blue: 49.0/255.0, alpha: 1.0),UIColor(red: 91.0/255.0, green: 42.0/255.0, blue: 12.0/255.0, alpha: 1.0)], locations: [0,0.4,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 1)
            self.timeMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
            
            [
                self.otp1TxtField,
                self.otp2TxtField,
                self.otp3TxtField,
                self.otp4TxtField
            ].forEach({
                $0?.setGradientBorder(cornerRadious: 8, width: 1.5, colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 1), UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1))
            })
        }
    }
    
    func setupFont(){
        //----------------for setup delegate
        [
            self.otp1TxtField,
            self.otp2TxtField,
            self.otp3TxtField,
            self.otp4TxtField
        ].forEach({
            $0.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        })
        
        
        //---------------------------------
        self.beforeArrivesBtn.titleLabel?.font = AppFont.regular.size(12.0, familyName: familyOverpass)
        self.sessionDetailsBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        [self.cat1Btn,
         self.cat2Btn,
         self.cat3Btn].forEach({
            $0?.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        self.timeCountLbl.font = AppFont.semibold.size(28.0, familyName: familyManrope)
        self.timeTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.trainerNameLbl.font = AppFont.medium.size(16.0, familyName: familyManrope)
        [
            self.otp1TxtField,
            self.otp2TxtField,
            self.otp3TxtField,
            self.otp4TxtField
        ].forEach({
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
        self.otpSessionBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        
        self.trainerMsgTxtView.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        //-------------------- Attributed text
        let defaultAttributes = [
            .font: AppFont.regular.size(16.0, familyName: familyManrope),
            .foregroundColor: UIColor.appDarkGray
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.medium.size(16.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "Arriving at your home ",
            NSAttributedString(string: "- 23B, Dubai Mall Street Road",
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        
        self.arrivingAddrLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
    
    //-----------------------textFieldDidChange
    @objc func textFieldDidChange(textField: UITextField){
        
        let text = textField.text
        
        if (text?.utf16.count)! >= 1{
            switch textField{
            case otp1TxtField:
                otp2TxtField.becomeFirstResponder()
            case otp2TxtField:
                otp3TxtField.becomeFirstResponder()
            case otp3TxtField:
                otp4TxtField.becomeFirstResponder()
            case otp4TxtField:
                otp4TxtField.resignFirstResponder()
                
                if let  txt =  otp4TxtField.text , !txt.isEmpty {
                    self.view.endEditing(true)
                    print("done.........")
                    
                    if isValiadteOtp() {
                        let vc:ArrivingLoddingViewController = ArrivingLoddingViewController.instantiate(appStoryboard: .library)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
            default:
                break
            }
        }else{
            switch textField{
            case otp1TxtField:
                otp1TxtField.becomeFirstResponder()
            case otp2TxtField:
                otp1TxtField.becomeFirstResponder()
            case otp3TxtField:
                otp2TxtField.becomeFirstResponder()
            case otp4TxtField:
                otp3TxtField.becomeFirstResponder()
            default:
                break
            }
        }
        
    }
    
    // UITextFieldDelegate method to restrict the input to 1 digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only numeric input
        let allowedCharacterSet = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        if !allowedCharacterSet.isSuperset(of: characterSet) {
            return false // Disallow non-numeric input
        }
        
        // Check the total length after the proposed change
        if let currentText = textField.text, let stringRange = Range(range, in: currentText) {
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            return updatedText.count <= 1 // Allow input only if it results in 1 or fewer digits
        }
        
        return true
    }
    
    //MARK: --> VALIDATION
    func isValiadteOtp() -> Bool{
        if (otp1TxtField.text == "") || (otp2TxtField.text == "") || (otp3TxtField.text == "") || (otp4TxtField.text == "") {
            print("Please Enter Otp")
            AlertHelper.shared.showCustomeAlert(message: "Please Enter Otp", actions: ["Ok"])
            return false
        }
        return true
    }
    
}


//MARK: ----------EXTENSION FOR GOOGLE MAP DELEGATE
extension ArrivingViewController: GMSMapViewDelegate, CLLocationManagerDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // Handle marker tap events
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        
        addMarkers(marker: MarkerModel(latitude: coordinate.latitude, longitude: coordinate.longitude, title: "title", snippet: "mainAddr", iconImageName: AppImages.Radius))
        
        self.getCurrentAddr(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        
        self.setUpMapHeigth()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(coordinate: position.target)
        //        self.showmapCamera = position.target
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
        
        
        addMarkers(marker: MarkerModel(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, title: title, snippet: "mainAddr", iconImageName: AppImages.Radius))
        
        getCurrentAddr(location: location)
        
        // //28.6011486,77.2502725,
        //28.6527397,77.2962483
        
        self.getRouteSteps(from: CLLocationCoordinate2D(latitude: 28.6011486, longitude: 77.2502725), to: CLLocationCoordinate2D(latitude: 28.6527397, longitude: 77.2962483))
        
        
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
    
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        if  coordinate.latitude != 0 && coordinate.longitude != 0 {
            let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 10.0)
            self.mapView?.camera = camera
        }
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                print("Location Name: \(placemark.name ?? "Unknown")")
                print("City: \(placemark.locality ?? "Unknown")")
                print("Country: \(placemark.country ?? "Unknown")")
            }
        }
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
                                
                                //                                self.mainAddrLbl.text = lines.first
                                
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
                                //                                self.subAddrLbl.text = subAddrStr
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
            self.mapView.frame = self.self.mapMBV.bounds
            self.mapMBV.addSubview(self.mapView)
        }
    }
    
    //MARK: --------------------FOR MAKE POLYLINE
    /*
     func getPolyline(startLocation: CLLocation, destinationLocation: CLLocation){
     let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
     let destination = "\(destinationLocation.coordinate.latitude),\(destinationLocation.coordinate.longitude)"
     
     let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=API_KEY"
     
     let url = URL(string: urlString)
     URLSession.shared.dataTask(with: url!, completionHandler: {
     (data, response, error) in
     if(error != nil){
     print("error")
     }else{
     do{
     let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
     let routes = json["routes"] as! NSArray
     self.mapView.clear()
     
     OperationQueue.main.addOperation({
     for route in routes
     {
     let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
     let points = routeOverviewPolyline.object(forKey: "points")
     let path = GMSPath.init(fromEncodedPath: points! as! String)
     let polyline = GMSPolyline.init(path: path)
     polyline.strokeWidth = 3
     
     let bounds = GMSCoordinateBounds(path: path!)
     self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
     
     polyline.map = self.mapView
     
     }
     })
     }catch let error as NSError{
     print("error:\(error)")
     }
     }
     }).resume()
     }
     */
    
    func getRouteSteps(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\("AIzaSyAVUPi_nxwfDShp4Oifg1foIAfvDy-ePZw")")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {
                
                print("error in JSONSerialization")
                return
                
            }
            
            guard let routes = jsonResult["routes"] as? [Any] else {
                return
            }
            
            guard let route = routes.first as? [String: Any] else {
                return
            }
            
            guard let legs = route["legs"] as? [Any] else {
                return
            }
            
            guard let leg = legs.first as? [String: Any] else {
                return
            }
            
            guard let steps = leg["steps"] as? [Any] else {
                return
            }
            for item in steps {
                
                guard let step = item as? [String: Any] else {
                    return
                }
                
                guard let polyline = step["polyline"] as? [String: Any] else {
                    return
                }
                
                guard let polyLineString = polyline["points"] as? String else {
                    return
                }
                
                //Call this method to draw path on map
                DispatchQueue.main.async {
                    //                    self.drawPath(from: polyLineString)
                    
                    self.drawPath(from: polyLineString,
                                  source: source,
                                  destination: destination)
                    //28.6011486,77.2502725,
                    //28.6527397,77.2962483
                    
                    //                    self.drawPath(from: polyLineString,
                    //                             source: CLLocationCoordinate2D(latitude: 28.6011486, longitude: 77.2502725),
                    //                             destination: CLLocationCoordinate2D(latitude: 28.6527397, longitude: 77.2962483))
                    
                }
                
            }
        })
        task.resume()
    }
    
    //MARK:- Draw Path line
    
    func drawPath(from polyStr: String, source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        guard let path = GMSPath(fromEncodedPath: polyStr) else {
            print("Error: Invalid polyline string")
            return
        }
        
        mapView.clear()
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor = .blue
        polyline.geodesic = true
        polyline.map = mapView
        
        let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
        let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        mapView.animate(with: cameraUpdate)
    }
    
    
    //    func drawPath(from polyStr: String){
    //        let path = GMSPath(fromEncodedPath: polyStr)
    //        let polyline = GMSPolyline(path: path)
    //        polyline.strokeWidth = 3.0
    //        polyline.map = mapView // Google MapView
    //
    //
    //        let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: sourceLocationCordinates, coordinate: destinationLocationCordinates))
    //        mapView.moveCamera(cameraUpdate)
    //        let currentZoom = mapView.camera.zoom
    //        mapView.animate(toZoom: currentZoom - 1.4)
    //    }
    
}
