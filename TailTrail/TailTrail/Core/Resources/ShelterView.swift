//
//  ShelterView.swift
//  TailTrail
//
//  Created by Jesse Liao on 2/14/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct ShelterView: View {
    @EnvironmentObject var viewModel: ShelterViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text("Look Up Shelters")
                .font(.customTitle2)
            ZStack(alignment: .top) {
                ShelterResultContainer()
                    .onTapGesture {
                        viewModel.isFocus = false
                    }
                    .alert("Please enable shared location in setting", isPresented: $viewModel.shouldAlert) {
                        Button("Settings") {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                               UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                
                ShelterSearchBar()
                    .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ShelterView()
}
