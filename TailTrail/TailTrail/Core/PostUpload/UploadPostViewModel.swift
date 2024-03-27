//
//  UploadPostViewModel.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/22/24.
//

import SwiftUI
import Firebase
import Photos
import PhotosUI
import FirebaseFirestoreSwift
import CoreLocation
import Combine
import Vision
import VisionKit

@MainActor
class UploadPostViewModel: ObservableObject {
    @Published var didUploadPost = false
    @Published var error: Error?
    @Published var selectedPickerItem: PhotosPickerItem? {
        didSet {
            isLoadingPhoto = true
            Task {
                await loadImage(fromItem: selectedPickerItem)
                isLoadingPhoto = false
            }
        }
    }
    @Published var selectedUIImage: UIImage? 
    @Published var isCatDetectedInImage: Bool?
    @Published var location: CLLocationCoordinate2D?
    @Published var creationDate: Date?
    @Published var caption: String = ""
    @Published var contactInfo: String = ""
    @Published var isCheeto: Bool = false
    @Published var doesNeedHelp: Bool = false
    @Published var isCatLost: Bool = false
    
    @Published var isLoadingPhoto: Bool = false
    private var locationString: String?
    
    func uploadPost(caption: String?, contactInfo: String?) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let image = selectedUIImage else { return }
        
        do {
            self.locationString = await self.fetchLocationString()
            guard let imageUrl = try await ImageUploader.uploadImage(image: image, type: .post) else { return }
            let post = Post(ownerId: userId,
                            caption: caption,
                            imageUrl: imageUrl,
                            latitude: location?.latitude,
                            longitude: location?.longitude,
                            locationString: locationString,
                            isCheeto: isCheeto,
                            doesNeedHelp: doesNeedHelp
            )
            
            try await PostManager.uploadPost(post)
            self.didUploadPost = true
        } catch {
            print("DEBUG: Failed to upload image with error \(error.localizedDescription)")
            self.error = error
        }
    }
    
    private func fetchLocationString() async -> String? {
        guard let location = self.location else {
            return nil
        }
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
            if let placemark = placemarks.first {
                if let name = placemark.name,
                   let locality = placemark.locality,
                   let administrativeArea = placemark.administrativeArea,
                   let country = placemark.country {
                    return "\(name), \(locality), \(administrativeArea), \(country)"
                }
            }
        } catch {
            print("Reverse geocoding failed with error: \(error.localizedDescription)")
            return nil
        }
        return nil
    }
    
    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item,
              let itemId = item.itemIdentifier,
              let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) 
        else {
            return
        }
        self.fetchMetaData(with: itemId)
        self.selectedUIImage = uiImage
    }
    
    private func fetchMetaData(with itemId: String) {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [itemId], options: nil)
        guard let metaData = result.firstObject else { return }
        self.location = metaData.location?.coordinate
        self.creationDate = metaData.creationDate
    }
}
