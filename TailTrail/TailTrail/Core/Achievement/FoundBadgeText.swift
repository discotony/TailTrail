//
//  FoundBadgeAlert.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/8/24.
//

import SwiftUI

struct FoundBadgeText: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    let textArray: [String] = ["You've unlocked a new badge!",
                               "Look what you've found - a brand new badge, just for you!",
                               "Congratulations on unlocking an exciting new badge!",
                               "Wow! You've unearthed a charming new badge!",
                               "Aww, you've uncovered a darling new badge!"]
    
    @State var displayedText: String = ""
    
    var body: some View {
        Text(displayedText)
            .font(.callout)
            .fontDesign(.rounded)
            .fontWeight(.semibold)
            .foregroundStyle(colorScheme == .light ? .black : .white)
            .foregroundStyle(Color.meowBlack)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .transition(.move(edge: .bottom))
            .onAppear {
                let randomIndex = Int.random(in: 0..<self.textArray.count)
                self.displayedText = self.textArray[randomIndex]
            }
            .padding()
    }
}

#Preview {
    FoundBadgeText()
}
