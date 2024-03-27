//
//  FeedView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/4/24.
//

import SwiftUI
import Firebase

struct FeedView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject private var viewModel: FeedViewModel
    
    init(posts: [Post], lastDocument: DocumentSnapshot?) {
        self._viewModel = StateObject(wrappedValue: FeedViewModel(posts: posts, lastDocument: lastDocument))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                CustomStack(columns: 2, spacing: 8) {
                    ForEach(viewModel.posts.indices, id: \.self) { index in
                        LazyVStack {
                            NavigationLink(destination: PostDetailView(post: viewModel.posts[index])) {
                                FeedCellImage(post: viewModel.posts[index])
                            }
                            
                            if index == viewModel.posts.count - 3 && viewModel.hasMorePosts {
                                ProgressView()
                                    .onAppear {
                                        print("Fetching more posts")
                                        viewModel.fetchPostsAtATime()
                                    }
                            }
                        }
                        
                    }
                }
                .padding(.all, 8)
                .padding(.bottom, 16)
            }
            .refreshable { reloadPosts() }
            .scrollIndicators(.never)
            
            if viewModel.isLoading {
                loadingProgressView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            filterToolBarItem
            logoToolBarItem
        }
        .onChange(of: contentViewModel.didUploadOrDeletePost) { _, didUploadNewPost in
            if didUploadNewPost {
                reloadPosts()
            }
        }
        .onChange(of: viewModel.selectedSort) { oldValue, newValue in
            reloadPostsOnChange(oldValue, newValue)
        }
        .onChange(of: viewModel.selectedFilter) { oldValue, newValue in
            reloadPostsOnChange(oldValue, newValue)
        }
    }
    
    // MARK: - UI Components
    
    private var logoToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Tail Trail")
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.heavy)
                .foregroundStyle(colorScheme == .light ? Color.meowBlack :  Color.meowWhite)
        }
    }
    
    private var filterToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                sortSection
                filterSection
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
            }
        }
    }
    
    private var filterSection: some View {
        Section(header: Text("Filter By")) {
            filterButton(for: .allCats, label: "All Cats")
            filterButton(for: .cheetoOnly, label: "Cheeto Only")
        }
    }
    
    private var sortSection: some View {
        Section(header: Text("Sort By")) {
            sortButton(for: .recent, label: "Most Recent")
            sortButton(for: .popular, label: "Most Popular")
        }
    }
    
    private var loadingProgressView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(1.5)
            .tint(Color.meowOrange)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme == .light ? Color.meowWhite : Color.meowBlack)
            .edgesIgnoringSafeArea(.all)
    }
    
    
    // MARK: - Helpers
    
    private func sortButton(for sort: SortOption, label: String) -> some View {
        Button {
            viewModel.selectedSort = sort
        } label: {
            Label(label, systemImage: viewModel.selectedSort == sort ? "checkmark.circle.fill" : "circle.dotted")
        }
    }
    
    private func filterButton(for filter: FilterOption, label: String) -> some View {
        Button {
            viewModel.selectedFilter = filter
        } label: {
            Label(label, systemImage: viewModel.selectedFilter == filter ? "checkmark.circle.fill" : "circle.dotted")
        }
    }
    
    private func reloadPosts() {
        viewModel.isLoading = true
        viewModel.refreshPostHistory()
        viewModel.fetchPostsAtATime()
    }
    
    private func reloadPostsOnChange(_ oldValue: Any, _ newValue: Any) {
        if oldValue as? FilterOption != newValue as? FilterOption ||
            oldValue as? SortOption != newValue as? SortOption {
            reloadPosts()
        }
    }
}
