//
//  AdaptiveImage.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/21/24.
//

import SwiftUI

struct AdaptiveImage: View {
    @Environment(\.colorScheme) var colorScheme
    let light: String
    let dark: String
    let width: CGFloat
    let height: CGFloat
    
    @ViewBuilder var body: some View {
        if colorScheme == .light {
            Image(light)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
        } else {
            Image(dark)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
        }
    }
}

