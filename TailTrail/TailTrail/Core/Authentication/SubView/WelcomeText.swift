//
//  WelcomeText.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/8/24.
//

import SwiftUI

struct WelcomeText: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        Text("Join our community of cat lovers and make a difference.")
            .font(.callout)
            .fontDesign(.rounded)
            .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
            .foregroundStyle(Color.meowBlack)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    WelcomeText()
}
