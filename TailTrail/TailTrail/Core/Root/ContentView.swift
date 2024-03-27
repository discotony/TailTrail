//
//  ContentView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/21/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    @State private var isLaunched: Bool = false
    
    var body: some View {
        Group {
            if !isLaunched {
                LaunchScreen(isLaunched: $isLaunched)
                
            } else if viewModel.userSession == nil {
                SignInView()
                
            } else {
                MainTabView()
            }
        }
        .frame(maxHeight: .infinity)
        .environmentObject(viewModel)
        .transition(.opacity)
        .animation(.easeInOut, value: isLaunched)
        .animation(.easeInOut, value: viewModel.userSession)
    }
}
