//
//  AlertView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/22/24.
//

import SwiftUI

struct AlertView: View {
    var type: AlertType
    var isVisible: Bool
    
    var body: some View {
        if isVisible {
            Text(type.message)
                .multilineTextAlignment(.center)
                .lineSpacing(6.0)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.meowWhite)
                .padding()
                .frame(width: 300, height: 100)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
                .shadow(color: Color.meowBlack.opacity(0.1), radius: 60, x: 0.0, y: 16)
                .transition(.opacity)
                .animation(.easeInOut, value: isVisible)
                .zIndex(1)
                .padding(.bottom, 16)
        }
    }
}
