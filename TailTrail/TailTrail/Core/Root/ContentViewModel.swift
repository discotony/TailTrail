//
//  ContentViewModel.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/24/24.
//

import Foundation
import Combine
import FirebaseAuth
import Firebase

@MainActor
class ContentViewModel: ObservableObject {
    private let service = AuthenticationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var userSession: FirebaseAuth.User?
    @Published var user: MeowUser?
    @Published var feedPosts = [Post]()
    @Published var feedLastDoc: DocumentSnapshot?
    @Published var userPosts = [Post]()
    @Published var userLastDoc: DocumentSnapshot?
    @Published var isLoading: Bool = false
    
    @Published var didUploadOrDeletePost: Bool = false
    
    init() {
        setUpSubscribers()
        fetchInitialFeedPosts()
    }
    
    func setUpSubscribers() {
        UserManager.shared.$userSession.sink { [weak self] userSession in
            self?.userSession = userSession
        }
        .store(in: &cancellables)
        
        UserManager.shared.$user.sink { [weak self] user in
            self?.user = user
        }.store(in: &cancellables)
    }
    
    func fetchInitialFeedPosts() {
        isLoading = true
        Task {
            let (feedPosts, feedLastDoc) = try await PostManager.fetchAllPostsByFilterAndSort(filter: .allCats,
                                                                                              sort: .recent,
                                                                                              lastDocument: feedLastDoc)
            
            self.feedPosts.append(contentsOf: feedPosts)
            if let feedLastDoc { self.feedLastDoc = feedLastDoc }
            
            guard let userId = try await UserManager.shared.fetchCurrentUser() else {
                self.isLoading = false
                return
            }
            let (userPosts, userLastDoc) = try await PostManager.fetchUserPosts(user: userId,
                                                                                fetchLimit: 4,
                                                                                lastDocument: userLastDoc)
            self.userPosts.append(contentsOf: userPosts)
            if let userLastDoc { self.userLastDoc = userLastDoc }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func resetSubscribers() {
        self.userSession = nil
        self.user = nil
        self.feedPosts = []
        self.feedLastDoc = nil
        self.userPosts = []
        self.userLastDoc = nil
    }
}
