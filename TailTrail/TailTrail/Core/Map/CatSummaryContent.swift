//
//  CatSummaryContent.swift
//  TailTrail
//
//  Created by Jesse Liao on 3/8/24.
//

import SwiftUI

struct CatSummaryContent: View {
    @ObservedObject var viewModel: MapViewModel
    @Binding var isDetailedSummaryShown: Bool
    @State private var debounceTimer: Timer?
    var uniquePost: (String, Post)
    var scrollViewProxy: ScrollViewProxy
    
    var body: some View {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let summaryWidth = (350 / 397) * screenWidth
        
        GeometryReader { geometry in
            let currentOffset = geometry.frame(in: .global).midX
            let screenCenter = screenWidth / 2
            PostSummaryView(post: uniquePost.1)
                .frame(width: summaryWidth)
                .onChange(of: currentOffset) {
                    if abs(currentOffset - screenCenter) < summaryWidth / 2 {
                        handleScrolling()
                    }
                }
                .onTapGesture {
                    isDetailedSummaryShown = true
                }
        }
        .frame(width: summaryWidth)
    }
    
    private func handleScrolling() {
        debounceTimer?.invalidate()
        debounceTimer = nil
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: false) { _ in
            if uniquePost.0 == viewModel.infiniteCatPosts.first?.0 {
                handleInfiniteScrolling(post: viewModel.uniqueCatPosts.last?.1)
            } else if uniquePost.0 == viewModel.infiniteCatPosts.last?.0 {
                handleInfiniteScrolling(post: viewModel.uniqueCatPosts.first?.1)
            }else {
                viewModel.selectedPost = uniquePost.1
            }
        }
    }
    
    private func handleInfiniteScrolling(post: Post?) {
        viewModel.selectedPost = post
        guard let selectedCatId = viewModel.selectedPost?.id else {
            return
        }
        scrollViewProxy.scrollTo(selectedCatId, anchor: .leading)
    }
}
