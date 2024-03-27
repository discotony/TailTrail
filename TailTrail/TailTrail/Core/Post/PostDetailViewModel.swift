//
//  PostDetailViewModel.swift
//  TailTrail
//
//  Created by Devin Studdard on 3/4/24.
//

import SwiftUI
import CoreLocation

@MainActor
class PostDetailViewModel: ObservableObject {
    @Published var post: Post
    
    init(post: Post) {
        self.post = post
        Task { try await checkIfUserLikedPost() }
    }
    
    var convertedDate: String {
        let date = post.timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        // Format the Date object using the DateFormatter
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    var convertedTime: String {
        let date = post.timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // Format for "12:47 PM"
        
        let formattedTime = dateFormatter.string(from: date)
        return formattedTime
    }
    
    func like() async throws {
        DispatchQueue.main.async {
            self.post.didLike = true
        }
        Task {
            try await PostManager.likePost(post)
            self.post.likeCount += 1
        }
    }
    
    func unlike() async throws {
        DispatchQueue.main.async {
            self.post.didLike = false
        }
        Task {
            try await PostManager.unlikePost(post)
            self.post.likeCount -= 1
        }
    }
    
    func checkIfUserLikedPost() async throws {
        self.post.didLike = try await PostManager.checkIfUserLikedPost(post)
    }
}
