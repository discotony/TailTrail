//
//  AuthenticationViewModel.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/11/24.
//

import Foundation

@MainActor
final class SignInViewModel: ObservableObject {
    func signInAnonymously() async throws {
        let authDataResult = try await AuthenticationManager.shared.signInAnonymously()
        let user = MeowUser(authUser: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
}
