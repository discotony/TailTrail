//
//  SettingsViewModel.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/11/24.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var user: MeowUser
    @Published var authUser: AuthDataResultModel? = nil
    @Published var username = ""
    
    init(user: MeowUser) {
        self.user = user
    }
    
    func reloadUserData() async throws {
        guard let user = try await UserManager.shared.fetchCurrentUser() else { return }
        self.user = user
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func deleteAccount() async throws {
        try await PostManager.deleteAllUserPosts(user: user)
        try await AuthenticationManager.shared.deleteAccount()
    }
}
