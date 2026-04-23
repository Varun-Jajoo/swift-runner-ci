//
//  LocationDetailsVC.swift
//  MyPT
//
//

import UIKit
import GooglePlaces
import CoreLocation
import GoogleMaps
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

class LocationDetailsVC: UIViewController {
    
    @IBOutlet weak var viewTextField: UIView!
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var viewCurrentLocation: UIView!
    @IBOutlet weak var tableViewLocations: UITableView!
    @IBOutlet weak var lblTextFieldHeading: UILabel!
    @IBOutlet weak var constTableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var lblCurrentLocationText: UILabel!
    
    var flowLocation: LocationFlow = .defaultLoc
    private let placesClient = GMSPlacesClient.shared()
    private var suggestions: [GMSAutocompleteSuggestion] = []
    private var sessionToken = GMSAutocompleteSessionToken()
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    var callBackSetLocation : ( (CLLocationCoordinate2D, String , String) -> ())?
    var currentBuildingName: String?
    var currentApartmentNumber: String?
    var currentStreetName: String?
    private var searchWorkItem: DispatchWorkItem?
    let tableViewRowHeight = 85
    var currentLocationCoordinates : [CLLocation] = []
    // For Location
    var currentAddress : String?
    var mainAddress : String?
    var subAddress : String?
    var getAddressData: AddressDataModel? = AddressDataModel()
    var callBackEditAddress : ( (String? , String? , String? , AddressDataModel? ) -> ())?
    var callBackNewAddressAdded : (() -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.isEnabled = false
        IQKeyboardToolbarManager.shared.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.isEnabled = true
    }
    
    private func uiSetup() {
        textFieldSearch.delegate = self
        textFieldSearch.textColor = .white
        textFieldSearch.setPlaceholder(text: "Search for area, street name...", font: .systemFont(ofSize: 18), color: .appLightGray)
        viewTextField.layer.borderWidth = 1.5
        viewTextField.layer.cornerRadius = 8
        viewTextField.layer.borderColor = UIColor(hex: "#2B2C2B").cgColor
        viewTextField.layer.borderWidth = 1
        tableViewLocations.register(UINib(nibName: "AvailableLocationsTVC", bundle: nil), forCellReuseIdentifier: "AvailableLocationsTVC")
        tableViewLocations.delegate = self
        tableViewLocations.dataSource = self
        tableViewLocations.layer.cornerRadius = 8
        viewCurrentLocation.layer.cornerRadius = 8
        tableViewLocations.layer.borderWidth = 0
        tableViewLocations.layer.borderColor = UIColor(hex: "#2B2C2B").cgColor
        viewCurrentLocation.layer.borderWidth = 1
        viewCurrentLocation.layer.borderColor = UIColor(hex: "#2B2C2B").cgColor
        viewCurrentLocation.backgroundColor = UIColor(hex: "#212122")
    }
    
    private func setup() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func CancelButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func userCurrentLocationAction(_ sender: UIButton) {
        if flowLocation == .fromReviewPackage {
            let vc: AddNewAddressVC = AddNewAddressVC.instantiate(appStoryboard: .purchase)
            vc.currentStreetName = self.currentStreetName
            vc.currentApartmentNumber = self.currentApartmentNumber
            vc.newAddressAddedCallBack = {
                self.dismiss(animated: true, completion: {
                    self.callBackNewAddressAdded?()
                })
            }
            vc.isModalInPresentation = true
            vc.modalPresentationStyle = .pageSheet
            self.present(vc, animated: true)
        }
    }
    
    
    
    //    func searchPlaces(query: String) {
    //        let request = GMSAutocompleteRequest(query: query)
    //        request.sessionToken = GMSAutocompleteSessionToken()
    //
    //        placesClient.fetchAutocompleteSuggestions(from: request, callback: {
    //            availableSuggestion, errors in
    //            if let value = availableSuggestion {
    //                self.suggestions = value
    //                self.tableViewLocations.reloadData()
    //            }
    //        })
    //    }
    //
    //    func locationManager(_ manager: CLLocationManager,
    //                             didUpdateLocations locations: [CLLocation]) {
    //        currentLocation = locations.last
    //        getCurrentAddr(location: locations.last)
    //        locationManager.stopUpdatingLocation()
    //        }
    
    //    func fetchPlaceDetails(placeID: String) -> String {
    //
    //        let fields: GMSPlaceField = [.coordinate, .formattedAddress, .name]
    //        var distance = ""
    //        placesClient.fetchPlace(
    //            fromPlaceID: placeID,
    //            placeFields: fields,
    //            sessionToken: nil
    //        ) { [weak self] place, error in
    //            guard let self = self, let place = place else { return }
    //            let placeLocation = CLLocation(
    //                latitude: place.coordinate.latitude,
    //                longitude: place.coordinate.longitude
    //            )
    //            currentLocationCoordinate = place.coordinate
    //            print("📍 Place Coordinate:", place.coordinate)
    //            distance = calculateDistance(to: placeLocation)
    //        }
    //        return distance
    //    }
    //    func fetchPlaceDetails(placeID: String) {
    //        let fields: GMSPlaceField = [.coordinate, .formattedAddress, .name]
    //        var distance = ""
    //        placesClient.fetchPlace(
    //            fromPlaceID: placeID,
    //            placeFields: fields,
    //            sessionToken: nil
    //        ) { [weak self] place, error in
    //            guard let self = self, let place = place else {
    //                self?.currentLocationCoordinates.append(CLLocation(latitude: CLLocationDegrees(), longitude: CLLocationDegrees()))
    //                return }
    //            let placeLocation = CLLocation(
    //                latitude: place.coordinate.latitude,
    //                longitude: place.coordinate.longitude
    //            )
    //            currentLocationCoordinates.append(placeLocation)
    //        }
    //    }
    
    //    func calculateDistance(to destination: CLLocation) -> String {
    //        guard let currentLocation = currentLocation else {
    //            print("Current location not available")
    //            return ""
    //        }
    //        let distanceInMeters = currentLocation.distance(from: destination)
    //        let distanceInKm = distanceInMeters / 1000
    //        print("Distance: \(String(format: "%.2f km", distanceInKm))")
    //        return  String(format: "%.2f km", distanceInKm)
    //    }
    
    //    private func setTabelViewBottomConst() {
    //        let maxHeight = Int((self.view.bounds.height * 60.0) / 100)
    //        let requiredHeight = self.suggestions.count * tableViewRowHeight
    //        if requiredHeight >= maxHeight {
    //            self.constTableViewBottom.constant = 25
    //        } else {
    //            self.constTableViewBottom.constant = (CGFloat(maxHeight - requiredHeight) + 25.0)
    //        }
    //    }
    
    //        func getCurrentAddr(location:CLLocation?){
    //            if let getLcation = location {
    //                let geocoder = GMSGeocoder()
    //                geocoder.reverseGeocodeCoordinate((CLLocationCoordinate2DMake((getLcation.coordinate.latitude), (getLcation.coordinate.longitude)))) { response, error in
    //                    if error != nil {
    //                        print("reverse geodcode fail: \(error!.localizedDescription)")
    //                    } else {
    //                        if let places = response?.results() {
    //                            if let place = places.first {
    //                                if let lines = place.lines {
    //                                    print("GEOCODE: Formatted Address: \(lines)")
    //                                    self.lblCurrentLocationText.text = lines.first
    //                                }
    //                            } else {
    //                                print("GEOCODE: nil first in places")
    //                            }
    //                        } else {
    //                            print("GEOCODE: nil in places")
    //                        }
    //                    }
    //                }
    //            }
    //        }
    
    func searchPlaces(query: String) {
        let request = GMSAutocompleteRequest(query: query)
        request.sessionToken = GMSAutocompleteSessionToken()
        self.suggestions = []
        self.currentLocationCoordinates = []
        placesClient.fetchAutocompleteSuggestions(from: request, callback: {
            availableSuggestion, errors in
            if let value = availableSuggestion {
                self.suggestions = value
                for i in 0...(value.count - 1) {
                    self.fetchPlaceDetails(placeID: value[i].placeSuggestion?.placeID ?? "")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    self.tableViewLocations.reloadData()
                })
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        getCurrentAddr(location: locations.last)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }
    
    func fetchPlaceDetails(placeID: String) {
        let fields: GMSPlaceField = [.coordinate, .formattedAddress, .name]
        var distance = ""
        placesClient.fetchPlace(
            fromPlaceID: placeID,
            placeFields: fields,
            sessionToken: nil
        ) { [weak self] place, error in
            guard let self = self, let place = place else {
                self?.currentLocationCoordinates.append(CLLocation(latitude: CLLocationDegrees(), longitude: CLLocationDegrees()))
                return }
            let placeLocation = CLLocation(
                latitude: place.coordinate.latitude,
                longitude: place.coordinate.longitude
            )
            currentLocationCoordinates.append(placeLocation)
        }
    }
    
    func calculateDistance(to destination: CLLocation) -> String {
        guard let currentLocation = currentLocation else {
            print("Current location not available")
            return ""
        }
        let distanceInMeters = currentLocation.distance(from: destination)
        let distanceInKm = distanceInMeters / 1000
        print("Distance: \(String(format: "%.2f km", distanceInKm))")
        return  String(format: "%.2f km", distanceInKm)
    }
    
    private func setTabelViewBottomConst() {
        let maxHeight = Int((self.view.bounds.height * 60.0) / 100)
        let requiredHeight = self.suggestions.count * tableViewRowHeight
        if requiredHeight >= maxHeight {
            self.constTableViewBottom.constant = 25
        } else {
            self.constTableViewBottom.constant = (CGFloat(maxHeight - requiredHeight) + 25.0)
        }
    }
    
}

extension LocationDetailsVC : UITableViewDelegate , UITableViewDataSource, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if suggestions.count == 0 {
            self.tableViewLocations.backgroundColor = .clear
            tableViewLocations.layer.borderWidth = 0
        } else {
            self.tableViewLocations.backgroundColor = UIColor(hex: "#212122")
            tableViewLocations.layer.borderWidth = 1
            setTabelViewBottomConst()
        }
        if #available(iOS 15.0, *) {
            self.sheetPresentationController?.selectedDetentIdentifier = suggestions.count == 0 ? .medium : .large
        } else {
            // Fallback on earlier versions
        }
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableLocationsTVC", for: indexPath) as? AvailableLocationsTVC else {
            return UITableViewCell()
        }
        let value = suggestions[indexPath.row].placeSuggestion
        cell.lblArea.attributedText = value?.attributedPrimaryText
        cell.lblDescription.attributedText = value?.attributedSecondaryText
        cell.lblLocationDuration.text = calculateDistance(to: self.currentLocationCoordinates[indexPath.row]) + " away"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = suggestions[indexPath.row].placeSuggestion
        if flowLocation == .fromReviewPackage {
            getCurrentSelectedLocationDetails(placeID: place?.placeID ?? "")
        } else {
            self.callBackSetLocation?(self.currentLocationCoordinates[indexPath.row].coordinate , place?.attributedPrimaryText.text ?? "", place?.attributedSecondaryText?.text ?? "" )
            self.dismiss(animated: true)
        }
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 70
    //    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lblTextFieldHeading.isHidden = false
        textFieldSearch.placeholder = nil
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return true
        }
        
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        // Cancel previous pending search
        searchWorkItem?.cancel()
        
        if updatedText.isEmpty {
            suggestions = []
            tableViewLocations.reloadData()
            return true
        }
        
        // Create new work item
        let workItem = DispatchWorkItem { [weak self] in
            self?.searchPlaces(query: updatedText)
        }
        
        searchWorkItem = workItem
        
        // Execute after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
        
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty == true {
            lblTextFieldHeading.isHidden = true
            textFieldSearch.setPlaceholder(text: "Search for area, street name...", font: .systemFont(ofSize: 18), color: .appLightGray)
        }
    }
}

extension LocationDetailsVC :  CLLocationManagerDelegate {
    
    func getCurrentAddr(location:CLLocation?){
        if let getLcation = location {
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate((CLLocationCoordinate2DMake((getLcation.coordinate.latitude), (getLcation.coordinate.longitude)))) { response, error in
                if error != nil {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                } else {
                    if let places = response?.results() {
                        if let place = places.first {
                            if let lines = place.lines {
                                print("GEOCODE: Formatted Address: \(lines)")
                                self.lblCurrentLocationText.text = lines.first
                            }
                            if let subLocality = places.first?.locality  {
                                self.currentStreetName = subLocality
                            }
                            if let placeslocality = places.first?.thoroughfare  {
                                self.currentBuildingName = placeslocality
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
    
    func getCurrentSelectedLocationDetails(placeID: String) {
        let fields: GMSPlaceField = [
            .name,
            .coordinate,
            .addressComponents
        ]
        
        placesClient.fetchPlace(fromPlaceID: placeID,
                                 placeFields: fields,

                                sessionToken: nil) { (place, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                print("Name: \(place.name ?? "")")
                print("Lat: \(place.coordinate.latitude)")
                print("Lng: \(place.coordinate.longitude)")
                
                let vc: AddNewAddressVC = AddNewAddressVC.instantiate(appStoryboard: .purchase)
                vc.suggestedPlace = place
                vc.newAddressAddedCallBack = {
                    self.dismiss(animated: true, completion: {
                        self.callBackNewAddressAdded?()
                    })
                }
                vc.isModalInPresentation = true
                vc.modalPresentationStyle = .pageSheet
                self.present(vc, animated: true)
                
            }
        }
    }
}
