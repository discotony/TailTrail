//
//  MapView.swift
//  TailTrail
//
//  Created by Jesse Liao on 1/29/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @ObservedObject var viewModel: MapViewModel
    
    var body: some View {
        ZStack {
            MapElement(viewModel: viewModel)
            VStack {
                MapHeaderBar(viewModel: viewModel)
                Spacer()
                CatSummarySlider(viewModel: viewModel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .onChange(of: contentViewModel.didUploadOrDeletePost) { _, didUploadOrDeletePost in
            viewModel.initMap()
        }
    }
}

#Preview {
    NavigationStack {
        MapView(viewModel: MapViewModel())
    }
}
