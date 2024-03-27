//
//  ShelterCatImage.swift
//  TailTrail
//
//  Created by Jesse Liao on 3/10/24.
//

import SwiftUI

struct ShelterCatImage: View {
    var body: some View {
        let randomIndex = Int.random(in: 1...6)
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Spacer()
                Image("welcomeCat\(randomIndex)")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 200, maxHeight: 200)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        
    }
}

#Preview {
    ShelterCatImage()
}
