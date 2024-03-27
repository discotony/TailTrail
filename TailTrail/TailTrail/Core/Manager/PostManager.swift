//
//  PostManager.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/25/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

struct PostManager {
        
    static func uploadPost(_ post: Post) async throws {
        guard let postData = try? Firestore.Encoder().encode(post) else { return }
        try await FirestoreConstants.PostsCollection.addDocument(data: postData)
    }
        
    static func fetchPost(withId id: String) async throws -> Post {
        let postSnapshot = try await FirestoreConstants.PostsCollection.document(id).getDocument()
        let post = try postSnapshot.data(as: Post.self)
        return post
    }
        
    static func fetchAllPostsByFilterAndSort(filter: FilterOption,
                                             sort: SortOption,
                                             fetchLimit: Int = 10,
                                             lastDocument: DocumentSnapshot?)
    async throws -> (documentsData: [Post], lastDocument: DocumentSnapshot?) {
        let query = PostQueryByFilterAndSort(filter: filter, sort: sort)
        
        let (documents, lastDocument) = try await query
            .startOptionally(afterDocument: lastDocument)
            .limit(to: fetchLimit)
            .getDocumentsWithSnapshot(as: Post.self)
        
        let postsWithUsers = await withTaskGroup(of: (Int, MeowUser?).self, returning: [Post].self) { group in
            var posts = documents
            
            for (index, post) in documents.enumerated() {
                group.addTask {
                    let user = try? await UserManager.shared.fetchUser(userId: post.ownerId)
                    return (index, user)
                }
            }
            
            for await (index, user) in group {
                posts[index].user = user
            }
            return posts
        }
        
        return (postsWithUsers, lastDocument)
    }
    
    static func PostQueryByFilterAndSort(filter: FilterOption, sort: SortOption) -> Query {
        let sortID = sort == .recent ? Post.CodingKeys.timestamp.rawValue : Post.CodingKeys.likeCount.rawValue
        let query = FirestoreConstants.PostsCollection
        
        if filter == .cheetoOnly {
            return query
                .whereField(Post.CodingKeys.isCheeto.rawValue, isEqualTo: true)
                .order(by: sortID, descending: true)
        } else {
            return query
                .order(by: sortID, descending: true)
        }
    }
    
    // MARK: - Fetch All Posts within Timeframe
    
    static func fetchAllPostsWithLocationWithinTimeFrame(filter: FilterOption) async throws -> [Post] {
        guard let timeFrame = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return []
        }
        
        let snapshot: QuerySnapshot
        
        // Start with filtering by valid locations and timestamp.
        var query = FirestoreConstants.PostsCollection
            .whereField(Post.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: timeFrame)
        
        if filter == .cheetoOnly {
            query = query.whereField(Post.CodingKeys.isCheeto.rawValue, isEqualTo: true)
        }
        
        // Sort by timestamp in descending order and fetch the documents.
        snapshot = try await query
            .order(by: Post.CodingKeys.timestamp.rawValue, descending: true)
            .getDocuments()
        
        let postsWithIDs = snapshot.documents.compactMap { document -> Post? in
            return try? document.data(as: Post.self) // Firestore automatically assigns the documentID to the `id` property
        }
        
        let filteredPostsWithIDs = postsWithIDs.filter { post in
            return post.latitude != nil && post.longitude != nil
        }
        
        // Concurrently fetch user data for all posts
        let postsWithUsers = await withTaskGroup(of: (Int, MeowUser?).self, returning: [Post].self) { group in
            var posts = filteredPostsWithIDs
            
            for (index, post) in filteredPostsWithIDs.enumerated() {
                group.addTask {
                    let user = try? await UserManager.shared.fetchUser(userId: post.ownerId)
                    return (index, user)
                }
            }
            
            for await (index, user) in group {
                posts[index].user = user
            }
            return posts
        }
        
        return postsWithUsers
    }
    // MARK: - Fetch Posts from a User
    
    static func fetchUserPosts(user: MeowUser,
                               fetchLimit: Int = 20,
                               lastDocument: DocumentSnapshot?)
    async throws -> (documentsData: [Post], lastDocument: DocumentSnapshot? ) {
        let (documents, lastDocument) = try await FirestoreConstants.PostsCollection
            .whereField(Post.CodingKeys.ownerId.rawValue, isEqualTo: user.userId)
            .order(by: Post.CodingKeys.timestamp.rawValue, descending: true)
            .startOptionally(afterDocument: lastDocument)
            .limit(to: fetchLimit)
            .getDocumentsWithSnapshot(as: Post.self)
        
        // Concurrently fetch user data for all posts
        let postsWithUsers = await withTaskGroup(of: (Int, MeowUser?).self, returning: [Post].self) { group in
            var posts = documents
            
            for (index, post) in documents.enumerated() {
                group.addTask {
                    let user = try? await UserManager.shared.fetchUser(userId: post.ownerId)
                    return (index, user)
                }
            }
            
            for await (index, user) in group {
                posts[index].user = user
            }
            return posts
        }
        
        return (postsWithUsers, lastDocument)
    }
    
    private static func fetchAllUserPosts(user: MeowUser) async throws -> [Post] {
        return try await FirestoreConstants.PostsCollection
            .whereField(Post.CodingKeys.ownerId.rawValue, isEqualTo: user.userId)
            .order(by: Post.CodingKeys.timestamp.rawValue, descending: true)
            .getDocuments(as: Post.self)
    }
}

// MARK: - Likes

extension PostManager {
    static func likePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        guard let postId = post.id else {
            return
        }
        
        async let _ = try await FirestoreConstants.PostsCollection.document(postId).collection(Post.CodingKeys.postLikes.rawValue).document(uid).setData([:])
        async let _ = try await FirestoreConstants.PostsCollection.document(postId).updateData([Post.CodingKeys.likeCount.rawValue: post.likeCount + 1])
        async let _ = try await FirestoreConstants.UserCollection.document(uid).collection(Post.CodingKeys.userLikes.rawValue).document(postId).setData([:])
    }
    
    static func unlikePost(_ post: Post) async throws {
        guard post.likeCount > 0 else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = post.id else { return }
        
        async let _ = try await FirestoreConstants.PostsCollection.document(postId).collection(Post.CodingKeys.postLikes.rawValue).document(uid).delete()
        async let _ = try await FirestoreConstants.UserCollection.document(uid).collection(Post.CodingKeys.userLikes.rawValue).document(postId).delete()
        async let _ = try await FirestoreConstants.PostsCollection.document(postId).updateData([Post.CodingKeys.likeCount.rawValue: post.likeCount - 1])
    }
    
    static func checkIfUserLikedPost(_ post: Post) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        guard let postId = post.id else { return false }
        
        let snapshot = try await FirestoreConstants.UserCollection.document(uid).collection(Post.CodingKeys.userLikes.rawValue).document(postId).getDocument()
        return snapshot.exists
    }
}

// MARK: - Delete Post

extension PostManager {
    static func deletePost(post: Post) async throws {
        // Delete from Firestore Database
        guard let postId = post.id else { return }
        do {
            try await FirestoreConstants.PostsCollection.document(postId).delete()
            print("Document successfully removed!")
        } catch {
            print("Error removing document: \(error)")
        }
    }
    
    static func deleteAllUserPosts(user: MeowUser) async throws {
        let posts = try await self.fetchAllUserPosts(user: user)
        for post in posts {
            try await self.deletePost(post: post)
        }
    }
}
