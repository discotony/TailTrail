//
//  CatSummarySlider.swift
//  TailTrail
//
//  Created by Jesse Liao on 3/8/24.
//

import SwiftUI
import MapKit

struct CatSummarySlider: View {
    @ObservedObject var viewModel: MapViewModel
    @State var isDetailedSummaryShown = false
    
    var body: some View {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let summaryWidth = (350 / 397) * screenWidth
        let summarySpacing = (screenWidth - summaryWidth) / 2
        
        if viewModel.isSummaryShown {
            ScrollViewReader { scrollViewProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(viewModel.infiniteCatPosts, id: \.0) { (id, post) in
                            CatSummaryContent(viewModel: viewModel, isDetailedSummaryShown: $isDetailedSummaryShown, uniquePost: (id, post), scrollViewProxy: scrollViewProxy)
                                .tag(id)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, summarySpacing)
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollTargetBehavior(.paging)
                .onChange(of: viewModel.selectedPost) {
                    handleCameraChange(scrollViewProxy: scrollViewProxy)
                }
                .onAppear {
                    handleCameraChange(scrollViewProxy: scrollViewProxy)
                }
                .frame(maxHeight: 220)
                .padding(.bottom, 30)
                .navigationDestination(isPresented: $isDetailedSummaryShown) {
                    if let selectedCatPosts = viewModel.catCollections.first(where: {$0.first == viewModel.selectedPost}) {
                        MultiPostDetailView(posts: selectedCatPosts)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
        }
    }
    
    private func handleCameraChange(scrollViewProxy: ScrollViewProxy) {
        withAnimation {
            let latitude = viewModel.selectedPost?.latitude ?? 0
            let longitude = viewModel.selectedPost?.longitude ?? 0
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            viewModel.cameraPosition = .region(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        }
        guard let selectedCatId = viewModel.selectedPost?.id else {
            return
        }
        scrollViewProxy.scrollTo(selectedCatId, anchor: .leading)
    }
}
