//
//  MapHeaderBar.swift
//  TailTrail
//
//  Created by Jesse Liao on 3/8/24.
//

import SwiftUI

struct MapHeaderBar: View {
    @ObservedObject var viewModel: MapViewModel
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: 42)
                    .foregroundStyle(Color.meowWhite)
                    .shadow(radius: 3)
                Image(systemName: "location.fill")
                    .foregroundStyle(Color.meowBlack)
            }
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                viewModel.isSummaryShown = false
                withAnimation {
                    viewModel.centerCamera()
                }
            }
            Spacer()
        }
        .padding()
    }
}
