//
//  ImageUploader.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/25/24.
//

import UIKit
import Firebase
import FirebaseStorage

enum UploadType {
    case profile
    case post
    
    var filePath: StorageReference {
        let filename = NSUUID().uuidString
        let userId = UserManager.shared.user?.userId ?? "non_existent_users"
        switch self {
        case .profile:
            return Storage.storage().reference(withPath: "/Users/\(userId)/profile_images/\(filename).jpg")
        case .post:
            return Storage.storage().reference(withPath: "/Users/\(userId)/post_images/\(filename).jpg")
        }
    }
}

struct ImageUploader {
    static func uploadImage(image: UIImage, type: UploadType) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return nil }
        let ref = type.filePath
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        do {
            let _ = try await ref.putDataAsync(imageData, metadata: metaData)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("DEBUG: Failed to upload image \(error.localizedDescription)")
            return nil
        }
    }
}
