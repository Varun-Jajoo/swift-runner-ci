//
//  GetLocationManager.swift
//  MyPT
//
//  Created by techsaga corp on 11/03/25.
//

import UIKit
import CoreLocation


class GetLocationManager: NSObject, CLLocationManagerDelegate {
   
    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    private var completion: ((CLLocation?) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            self.location = location
//            locationManager.stopUpdatingLocation()
//            completion?(location)
//        }
//    }

//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Failed to get location: \(error.localizedDescription)")
//        completion?(nil)
//    }

    // 3. Request Authorization and Location
//    func requestLocation(completion: @escaping (CLLocation?) -> Void) {
//        self.completion = completion
//
//        // Check if location services are enabled
//            if CLLocationManager.locationServicesEnabled() {
//                // Check authorization status
//                switch CLLocationManager.authorizationStatus() {
//                case .notDetermined:
//                    self.locationManager.requestWhenInUseAuthorization()
//                case .restricted, .denied:
//                    print("Location access restricted or denied")
//                    completion(nil)
//                case .authorizedAlways, .authorizedWhenInUse:
//                    self.locationManager.delegate = self
//                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//                    self.locationManager.startUpdatingLocation()
//                @unknown default:
//                    break
//                }
//            } else {
//                print("Location services are disabled")
//                completion(nil)
//            }
//    }
    
    
    func requestLocation(completion: @escaping (CLLocation?) -> Void) {
          self.completion = completion
          locationManager.delegate = self

          switch CLLocationManager.authorizationStatus() {
          case .notDetermined:
              locationManager.requestWhenInUseAuthorization()
          case .restricted, .denied:
              print("Location access restricted or denied")
              completion(nil)
          case .authorizedAlways, .authorizedWhenInUse:
              locationManager.desiredAccuracy = kCLLocationAccuracyBest
              locationManager.startUpdatingLocation()
          @unknown default:
              completion(nil)
          }
      }
    
    
    // MARK: - CLLocationManager Delegate
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
        if let location = locations.last {
            self.location = location
            locationManager.stopUpdatingLocation()
            completion?(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        completion?(nil)
    }

    private func startUpdatingLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
}


