//
//  ShelterViewModel.swift
//  TailTrail
//
//  Created by Jesse Liao on 3/3/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct Suggestion {
    let id = UUID()
    let string: String
    let coordinate: CLLocationCoordinate2D?
}

class ShelterViewModel: ObservableObject {
    @Published var inputtedAddress: String
    @Published var locationSuggestions: [Suggestion]
    @Published var searchResults: [MKMapItem]
    @Published var isFocus: Bool
    @Published var shouldAlert: Bool
    let locationManager = UserLocationManager.shared
    
    init() {
        self.inputtedAddress = ""
        self.locationSuggestions = [Suggestion(string: "Your Current Location", coordinate: nil)]
        self.searchResults = []
        self.isFocus = false
        self.shouldAlert = false
    }
    
    func initShelter() {
        self.inputtedAddress = ""
        self.locationSuggestions = [Suggestion(string: "Your Current Location", coordinate: nil)]
        self.searchResults = []
        self.isFocus = false
        self.shouldAlert = false
    }
    
    func generateSuggestions(for inputtedAddress: String) {
        Task { @MainActor in
            let suggestion = Suggestion(string: "Your Current Location", coordinate: locationManager.userLocation)
            self.locationSuggestions = [suggestion]
            
            var suggestedLocations = await generateRelevantLocations(for: inputtedAddress)
            suggestedLocations = Array(suggestedLocations.prefix(5))
            
            for suggestion in suggestedLocations {
                if let location = suggestion.placemark.location {
                    let addressString = constructAddressString(for: suggestion)
                    let coordinate = location.coordinate
                    let suggestion = Suggestion(string: addressString, coordinate: coordinate)
                    self.locationSuggestions.append(suggestion)
                }
            }
        }
    }
    
    func generateSheltersAndVets(near selectedLocation: CLLocationCoordinate2D?, range distanceFromCenter: CLLocationDistance) {
        Task { @MainActor in
            guard let center = selectedLocation else {
                if locationManager.alertForPermission {
                    self.shouldAlert = true
                } else {
                    locationManager.sendAuthorizationRequest()
                }
                return
            }
            let shelterResults = await self.searchNearbyLocations(for: "animal shelters", near: center, range: distanceFromCenter)
            let vetResults = await self.searchNearbyLocations(for: "veterinary", near: center, range: distanceFromCenter)
            let results = shelterResults + vetResults
            
            let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            self.searchResults = results.sorted { (item1, item2) -> Bool in
                let distance1 = item1.placemark.location?.distance(from: centerLocation) ?? 0
                let distance2 = item2.placemark.location?.distance(from: centerLocation) ?? 0
                return distance1 < distance2
            }
            self.shouldAlert = false
        }
    }
    
    func constructAddressString(for locationSuggestion: MKMapItem) -> String {
        var address: String
        
        let placemark = locationSuggestion.placemark
        
        var apartment = placemark.subThoroughfare ?? ""
        if !apartment.isEmpty {
            apartment += " "
        }
        var street = placemark.thoroughfare ?? ""
        if !street.isEmpty {
            street += ", "
        }
        var city = placemark.locality ?? ""
        if !city.isEmpty {
            city += ", "
        }
        var state = placemark.administrativeArea ?? ""
        if !state.isEmpty {
            state += " "
        }
        let postalCode = placemark.postalCode ?? ""
        
        address = apartment + street + city  + state  + postalCode
        return address
    }
    
    func generateRelevantLocations(for addressInput: String) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = addressInput
        
        do {
            let localSearch = MKLocalSearch(request: request)
            let response = try await localSearch.start()
            return response.mapItems
        } catch {
            print("Local Search Error: \(error)")
        }
        return []
    }
    
    func searchNearbyLocations(for queryType: String, near centerLocation: CLLocationCoordinate2D, range distanceFromCenter: CLLocationDistance) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = queryType
        request.region = MKCoordinateRegion(center: centerLocation, latitudinalMeters: distanceFromCenter, longitudinalMeters: distanceFromCenter)
        request.resultTypes = .pointOfInterest
        
        do {
            let localSearch = MKLocalSearch(request: request)
            let response = try await localSearch.start()
            
            // Ensure accurate animal shelters are located
            let filteredResults = response.mapItems.filter { result in
                // Refine results for animal shelters near the center
                let distance = result.placemark.location?.distance(from: CLLocation(latitude: centerLocation.latitude, longitude: centerLocation.longitude))
                let isWithinCenterDistance = (distance ?? 0) < distanceFromCenter
                
                let isResultShelter = result.name?.lowercased().contains("shelter") ?? false
                let isResultVets = result.name?.lowercased().contains("vet") ?? false
                
                let isRelevantResult = isWithinCenterDistance && (isResultShelter || isResultVets)
                
                return isRelevantResult
            }
            
            return filteredResults
            
        } catch {
            print("Local Search Error: \(error)")
        }
        return []
    }
}
