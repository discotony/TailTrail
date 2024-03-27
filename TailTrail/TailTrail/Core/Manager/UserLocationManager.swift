//
//  LocationManager.swift
//  TailTrail
//
//  Created by Jesse Liao on 1/29/24.
//

import CoreLocation

class UserLocationManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var alertForPermission: Bool = false
    private let manager = CLLocationManager()
    static let shared = UserLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func sendAuthorizationRequest() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            alertForPermission = false
            manager.startUpdatingLocation()
        case .denied, .restricted:
            // Handle cases where user denied/restricted location services
            print("Location Denid / Restricted")
            alertForPermission = true
            break
        case .notDetermined:
            print("Location not Determined")
            alertForPermission = false
        @unknown default:
            fatalError("A new case was added that is not handled")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        userLocation = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error)")
    }
}
