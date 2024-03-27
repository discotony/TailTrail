//
//  UserManager.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/11/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class UserManager {
    @Published var user: MeowUser?
    @Published var userSession: FirebaseAuth.User?
    
    static let shared = UserManager()
    
    private init() { }
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    @MainActor
    func createNewUser(user: MeowUser) async throws {
        do {
            try userDocument(userId: user.userId).setData(from: user, merge: false)
            self.user = try await fetchUser(userId: user.userId)
        } catch {
            print("DEBUG: Failed to create user with error: \(error.localizedDescription)")
        }
    }
    
    func fetchUser(userId: String) async throws -> MeowUser {
        let snapshot = try await FirestoreConstants.UserCollection.document(userId).getDocument()
        let user = try snapshot.data(as: MeowUser.self)
        return user
    }
    
    @MainActor
    func fetchCurrentUser() async throws -> MeowUser? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        let currentUser = try await FirestoreConstants.UserCollection.document(uid).getDocument(as: MeowUser.self)
        self.user = currentUser
        return currentUser
    }
}
