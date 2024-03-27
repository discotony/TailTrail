//
//  FeedViewModel.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/25/24.
//

import SwiftUI
import Firebase

enum FilterOption: String, CaseIterable {
    case allCats = "All Cats"
    case cheetoOnly = "Cheeto Only"
}

enum SortOption: String, CaseIterable {
    case recent = "Most Recent"
    case popular = "Most Popular"
}

@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts = [Post]()
    @Published var selectedFilter: FilterOption = .allCats
    @Published var selectedSort: SortOption = .recent
    @Published var isLoading: Bool = false
    @Published var hasMorePosts: Bool = true
    private var lastDocument: DocumentSnapshot? = nil
    private let fetchLimit: Int = 20
    
    init(posts: [Post], lastDocument: DocumentSnapshot?) {
        self.posts = posts
        self.lastDocument = lastDocument
        self.fetchPostsAtATime()
    }
    
    func refreshPostHistory() {
        self.lastDocument = nil
        self.posts = []
    }
    
    func fetchPostsAtATime() {
        Task {
            do {
                let (newPosts, lastDocument) = try await PostManager.fetchAllPostsByFilterAndSort(filter: selectedFilter,
                                                                                                  sort: selectedSort,
                                                                                                  fetchLimit: fetchLimit,
                                                                                                  lastDocument: lastDocument)
                self.posts.append(contentsOf: newPosts)
                if let lastDocument {
                    self.lastDocument = lastDocument
                } else {
                    self.hasMorePosts = false
                }
                
                self.hasMorePosts = newPosts.count < fetchLimit ? false : true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isLoading = false
                }
            } catch {
                print("Error fetching posts: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hasMorePosts = false
                }
            }
        }
    }
}
