//
//  SignInButton.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/8/24.
//

import SwiftUI

struct SignInButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    let isInSetting: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            HStack(alignment: .center, spacing: 4) {
                Text("Join Tail Trail")
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(isInSetting ? colorScheme == .dark ? .black : .white : .black)
            }
        })
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(isInSetting ? colorScheme == .dark ? .white : .black : .white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.1), radius: 60, x: 0.0, y: 16)
    }
}
