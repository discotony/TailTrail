//
//  DescriptionLabel.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/6/24.
//

import SwiftUI

struct DescriptionLabel: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var imageName: String
    var text: String
    var color: Color
    @State var size = UIScreen.main.bounds
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
            Text(text)
                .listRowSeparator(.hidden)
                .foregroundStyle(color)
                .font(Font.customCaption)
        }
    }
}
