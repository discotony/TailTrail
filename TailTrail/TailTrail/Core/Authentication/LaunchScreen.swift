//
//  TailTrail.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/8/24.
//

import SwiftUI

struct LaunchScreen: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Binding var isLaunched: Bool
    @State private var minimumDisplayTimePassed = false
    private let minimumDisplayTime: Double = 1.5
    
    var body: some View {
        ZStack {
            Image(.launchIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .transition(.opacity)
            VStack {
                Spacer()
                Text("TailTrail")
                    .font(.title2)
                    .fontDesign(.rounded)
                    .fontWeight(.heavy)
                    .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
                    .padding(.bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.launchScreen)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + minimumDisplayTime) {
                self.minimumDisplayTimePassed = true
                if !contentViewModel.isLoading {
                    isLaunched = true
                }
            }
        }
        .onChange(of: contentViewModel.isLoading) { _, isLoading in
            if !isLoading && minimumDisplayTimePassed {
                isLaunched = true
            }
        }
    }
}
