//
//  AuthenticationView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/7/24.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var viewModel = SignInViewModel()
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer().frame(height: 32)
                
                Text("Welcome to")
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
                
                Text("TailTrail")
                    .font(.system(size: 48))
                    .fontDesign(.rounded)
                    .fontWeight(.heavy)
                    .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
                
                Spacer()
                
                WelcomeText()
                    .frame(height: 60)
                    .padding(.horizontal)
                
                Image("welcomeCat1")
                    .customResize(widthScale: 0.8)
                    .aspectRatio(1, contentMode: .fit)
                
                Spacer()
                
                SignInButton(isInSetting: false) {
                    isLoading = true
                    Task {
                        do {
                            try await viewModel.signInAnonymously()
                            isLoading = false
                        } catch {
                            print(error)
                            isLoading = false
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(.launchScreen)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.45))
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
