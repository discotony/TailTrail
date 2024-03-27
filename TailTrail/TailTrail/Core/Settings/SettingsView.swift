//
//  SettingsView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/7/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: SettingsViewModel
    
    @State private var showConfirmationAlert: Bool = false
    @State private var showSuccessAlert = false
    @State private var successMessage = ""
    
    let user: MeowUser
    private let maxCharLength: Int = 20
    
    init(user: MeowUser) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: SettingsViewModel(user: user))
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    AccountAction
                    Spacer()
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward.circle.fill")
                        .font(.title2)
                        .fontDesign(.rounded)
                        .foregroundStyle(colorScheme == .light ?  Color.meowBlack : Color.meowWhite)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                    .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
            }
        }
        
        .onAppear {
            viewModel.loadAuthUser()
        }
        
        .alert(isPresented: $showConfirmationAlert) {
            getAlert()
        }
    }
}

// MARK: - Edit Profile and Account Actions

extension SettingsView {
    @ViewBuilder
    private var AccountAction: some View {
        Button(role: .destructive) {
            showConfirmationAlert = true
        } label: {
            Text("Delete Account")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.red)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
    }
}

// MARK: - Settings Alert

extension SettingsView {
    private func getAlert() -> Alert {
        return Alert(
            title: Text("Confirm Account Deletion"),
            message: Text("Do you really want to delete an account?"),
            primaryButton: .destructive(Text("Delete Account")) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        contentViewModel.resetSubscribers()
                        successMessage = "Your account has been successfully deleted."
                        showSuccessAlert = true
                    } catch {
                        print(error)
                    }
                }
            },
            secondaryButton: .cancel()
        )
    }
}
