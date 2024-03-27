//
//  ShelterResultList.swift
//  TailTrail
//
//  Created by Jesse Liao on 3/2/24.
//

import SwiftUI
import MapKit

struct ShelterResultContainer: View {
    @EnvironmentObject var viewModel: ShelterViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if (viewModel.searchResults.isEmpty || viewModel.isFocus) {
            Spacer()
            ShelterCatImage()
                .background(colorScheme == .light ? Color.meowWhite : .black)
        } else {
            ShelterResultList()
                .background(colorScheme == .light ? Color.meowWhite : .black)
        }
    }
}

struct ShelterResultList: View {
    @EnvironmentObject var viewModel: ShelterViewModel
    private let searchBarHeight: CGFloat = 18
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(viewModel.searchResults, id: \.self) { result in
                    ShelterResult(result: result)
                }
            }
            // Adjust shelter result height from top
            .padding(.top, 50)
            
            .padding(.horizontal)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .offset(y: searchBarHeight)
    }
}


#Preview {
    ShelterResultContainer()
}
