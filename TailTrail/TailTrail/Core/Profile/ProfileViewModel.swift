//
//  ProfileViewModel.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/26/24.
//

import Foundation
import Firebase

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: MeowUser
    @Published var posts = [Post]()
    @Published var isLoading: Bool = false
    @Published var hasMorePosts: Bool = true
    private var lastDocument: DocumentSnapshot? = nil
    private let fetchLimit: Int = 20
    
    init(user: MeowUser, posts: [Post], lastDocument: DocumentSnapshot?) {
        self.user = user
        self.posts = posts
        self.lastDocument = lastDocument
        self.fetchUserPostsAtATime()
    }
    
    func refreshPostHistory() {
        self.lastDocument = nil
        self.posts = []
    }
    
    func fetchUserPostsAtATime() {
        isLoading = true
        Task {
            let (newPosts, lastDocument) = try await PostManager.fetchUserPosts(user: user,
                                                                                fetchLimit: fetchLimit,
                                                                                lastDocument: lastDocument)
            self.posts.append(contentsOf: newPosts)
            if let lastDocument {
                self.lastDocument = lastDocument
            } else {
                self.hasMorePosts = false
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.hasMorePosts = newPosts.count < self.fetchLimit ? false : true
            }
            
        }
    }
}
