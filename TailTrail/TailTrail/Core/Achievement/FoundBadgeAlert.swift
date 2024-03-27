//
//  FoundBadgeAlert.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/22/24.
//

import SwiftUI

struct FoundBadgeAlert: View {
    let textArray: [String] = ["Meeoow-wooow!",
                               "Meowgical moment!",
                               "Pawsome!",
                               "Furrtastic achievement!",
                               "Purrfect!"]
    
    @State  var displayedText: String = ""
    
    var body: some View {
        Text(displayedText)
            .font(.title.bold())
            .fontDesign(.rounded)
            .foregroundStyle(Color.meowOrange)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .onAppear {
                let randomIndex = Int.random(in: 0..<self.textArray.count)
                self.displayedText = self.textArray[randomIndex]
            }
    }
}
