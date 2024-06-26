//
//  PhotoLibraryView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/19/24.
//

import SwiftUI
import PhotosUI

struct PhotoLibraryView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var date: Date?
    @Binding var location: CLLocationCoordinate2D?
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    
    func makeCoordinator() -> PhotoLibraryView.Coordinator {
        return Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            guard !results.isEmpty else {
                return
            }
            
            let imageResult = results[0]
            
            if let assetId = imageResult.assetIdentifier {
                let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
                DispatchQueue.main.async {
                    self.parent.date = assetResults.firstObject?.creationDate
                    self.parent.location = assetResults.firstObject?.location?.coordinate
                }
            }
            if imageResult.itemProvider.canLoadObject(ofClass: UIImage.self) {
                imageResult.itemProvider.loadObject(ofClass: UIImage.self) { (selectedImage, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        DispatchQueue.main.async {
                            self.parent.selectedImage = selectedImage as? UIImage
                        }
                    }
                }
            }
        }
        
        private let parent: PhotoLibraryView
        init(_ parent: PhotoLibraryView) {
            self.parent = parent
        }
    }
}

struct CustomPhotoPicker_Previews: PreviewProvider {
    static var previews: some View {
        PhotoLibraryView(selectedImage: Binding.constant(nil), date: Binding.constant(nil), location: Binding.constant(nil))
    }
}
