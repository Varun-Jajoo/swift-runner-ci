//
//  GetLocationManager.swift
//  MyPT
//
//  Created by techsaga corp on 11/03/25.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class GetLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = GetLocationManager()
    
    private let locationManager = CLLocationManager()
    private var completion: ((CLLocation?) -> Void)?
    private var addressCompletion: ((CLLocation?, (String?, String?, String?)) -> Void)?
    private var currentAddr: (String?, String?, String?) = ("", "", "")
    private var placeCompletion: ((GMSPlace) -> Void)?
    
    var getCurrentAddr: (String?, String?, String?) {
        return currentAddr
    }
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    /// Request current location with address
    func requestLocationWithAddress(completion: @escaping (CLLocation?, (String?, String?, String?)) -> Void) {
        self.addressCompletion = completion
        requestLocation { [weak self] location in
            guard let self = self, let location = location else {
                completion(nil, ("", "", ""))
                return
            }
            self.getCurrentAddr(location: location) { address in
                completion(location, address)
            }
        }
    }
    
    /// Request current location only
    func requestLocation(completion: @escaping (CLLocation?) -> Void) {
        self.completion = completion
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location access restricted or denied")
            AlertHelper.shared.showCustomeAlert(
                title: AppAlertStrings.location_permission,
                message: AppAlertStrings.loaction_access,
                actions: ["Open Settings"],
                withCancel: false
            ) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            completion(nil)
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        @unknown default:
            completion(nil)
        }
    }
    
    private func startUpdatingLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        case .restricted, .denied:
            completion?(nil)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            completion?(nil)
            return
        }
        locationManager.stopUpdatingLocation()
        self.completion?(location)
        self.completion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        completion?(nil)
    }
    
    // MARK: - Reverse Geocoding
    
    private func getCurrentAddr(location: CLLocation?, completion: @escaping ((String?, String?, String?)) -> Void) {
        guard let location = location else {
            completion(("", "", ""))
            return
        }
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location.coordinate) { response, error in
            if let error = error {
                print("Reverse geocode failed: \(error.localizedDescription)")
                completion(("", "", ""))
                return
            }
            
            guard let place = response?.firstResult(), let lines = place.lines else {
                print("No address found")
                completion(("", "", ""))
                return
            }
            
            let mainAddrStr = lines.first
            var subAddrStr = ""
            
            if let subLocality = place.subLocality {
                subAddrStr += "\(subLocality), "
            }
            if let locality = place.locality {
                subAddrStr += "\(locality), "
            }
            if let area = place.administrativeArea {
                subAddrStr += "\(area), "
            }
            if let postalCode = place.postalCode {
                subAddrStr += "\(postalCode), "
            }
            if let country = place.country {
                subAddrStr += "\(country)"
            }
            
            let components = lines.joined(separator: ", ").components(separatedBy: ", ")
            let building = components.count > 0 ? components[0] : ""
            let street = components.count > 1 ? components[1] : ""
            let landmark = components.count > 2 ? components[2] : ""
            let addrsPartStr = "\(building) \(street) \(landmark)".trimmingCharacters(in: .whitespaces)
            
            let result = (mainAddrStr, subAddrStr, addrsPartStr)
            self.currentAddr = result
            completion(result)
        }
    }
    
    // MARK: - Google Places Autocomplete
    func presentSearchPlace(from viewController: UIViewController, completion: @escaping (GMSPlace) -> Void) {
        self.placeCompletion = completion
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        viewController.present(autocompleteController, animated: true, completion: nil)
    }
}

extension GetLocationManager: GMSAutocompleteViewControllerDelegate{
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
           viewController.dismiss(animated: true) {
               self.placeCompletion?(place)
           }
       }

       func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
           print("Error: \(error.localizedDescription)")
           viewController.dismiss(animated: true, completion: nil)
       }

       func wasCancelled(_ viewController: GMSAutocompleteViewController) {
           viewController.dismiss(animated: true, completion: nil)
       }
}


