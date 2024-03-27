//
//  PhotoCameraView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/19/24.
//

import SwiftUI
import Photos
import CoreLocation

struct PhotoCameraView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    @Binding var dateMetadata: Date?
    @Binding var locationMetadata: CLLocationCoordinate2D?
    @Binding var isLoadingPhoto: Bool
    var sourceType: UIImagePickerController.SourceType = .camera
    
    // Creates a Coordinator instance which handles the delegation of UIImagePickerController
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // Creates a UIImagePickerController instance and sets its delegate and source type
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator  // Set the delegate to handle image picker events
        picker.sourceType = sourceType // Set the source type (camera or photo library)
        return picker
    }
    
    // Update the UIImagePickerController when SwiftUI view updates, but not used in this example
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    
    // Handle the delegate methods of UIImagePickerController
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent:PhotoCameraView  // Reference to the parent ImagePicker struct
        init(parent: PhotoCameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true) {
                if let uiImage = info[.originalImage] as? UIImage {
                    self.parent.selectedImage = uiImage
                    self.parent.isLoadingPhoto = true
                    
                    if picker.sourceType == .camera {
                        self.fetchMetaData(image: uiImage) {
                            DispatchQueue.main.async {
                                self.parent.isPresented = false
                                self.parent.isLoadingPhoto = false
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.parent.isPresented = false
                            self.parent.isLoadingPhoto = false
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.parent.isPresented = false
                        self.parent.isLoadingPhoto = false
                    }
                }
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false // Dismiss the image picker
        }
    }
}

// MARK: - Handle Image Saving and Metadata Fetching

extension PhotoCameraView.Coordinator {
    func fetchMetaData(image: UIImage, completion: @escaping () -> Void) {
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                if let currentLocation = ImageLocationManager.shared.currentLocation {
                    creationRequest.location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                }
                creationRequest.creationDate = Date()
            }) { success, error in
                if success {
                    self.fetchLastImageMetadata(completion: completion)
                } else {
                    print("Error saving image: \(String(describing: error))")
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }

        private func fetchLastImageMetadata(completion: @escaping () -> Void) {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 1
            
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            if let lastAsset = fetchResult.firstObject {
                DispatchQueue.main.async {
                    let creationDate = lastAsset.creationDate
                    let location = lastAsset.location
                    
                    self.parent.dateMetadata = creationDate
                    self.parent.locationMetadata = location?.coordinate
                    completion()
                }
            } else {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
}

// MARK: - Image Location Manager to Save Location Data

class ImageLocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = ImageLocationManager()
    private let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
