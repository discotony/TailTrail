//
//  AuthenticationManager.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/7/24.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
    }
}

@MainActor
final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private init() {
        Task { try await loadUserData() }
    }
    
    @MainActor
    func loadUserData() async throws {
        let userSession = Auth.auth().currentUser
        UserManager.shared.userSession = userSession
        if userSession != nil {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            UserManager.shared.user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        }
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        // Checking authenticated user locally from SDK, thus not async (i.e. sync call) and not reaching out to server
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func signOut() {
        do {
            UserManager.shared.userSession = nil
            UserManager.shared.user = nil
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
}

// MARK: - Authentication Anonymously

extension AuthenticationManager {
    @discardableResult
    func signInAnonymously() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        UserManager.shared.userSession = authDataResult.user
        return AuthDataResultModel(user: authDataResult.user)
    }
}
