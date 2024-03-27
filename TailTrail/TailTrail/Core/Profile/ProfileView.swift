//
//  ProfileView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/22/24.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var viewModel: ProfileViewModel
    @State private var showSettingsView: Bool = false
    let user: MeowUser
    
    init(user: MeowUser, posts: [Post], lastDocument: DocumentSnapshot?) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user, posts: posts, lastDocument: lastDocument))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack {
                        Image(.badge7)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 100)
                        
                        Spacer().frame(maxWidth: 16)
                        
                        VStack {
                            Text("Welcome")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
                            Spacer().frame(height: 8)
                            Text("\(user.username ?? "Anonymous Cat Lover")")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
                        }
                        
                        .frame(height: 120)
                        .foregroundStyle(Color.meowBlack)
                        
                        .padding(.trailing)
                    }
                    
                    LazyVStack {
                        ForEach(viewModel.posts.indices, id: \.self) { index in
                            FeedCellImage(post: viewModel.posts[index])
                            
                            // Check if the current post is the # to last in the array
                            if index == viewModel.posts.count - 1 && viewModel.hasMorePosts {
                                ProgressView()
                                    .onAppear {
                                        viewModel.fetchUserPostsAtATime()
                                    }
                            }
                        }
                        .padding(.bottom)
                    }
                    .onChange(of: contentViewModel.didUploadOrDeletePost) { _, didUploadNewPost in
                        if didUploadNewPost {
                            reloadPosts()
                        }
                    }
                }
                .padding()
                
            }
            .scrollIndicators(.never)
            .refreshable { reloadPosts() }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showSettingsView) {
                SettingsView(user: user)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSettingsView = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        Image(systemName: "gearshape.circle.fill")
                            .font(.title2)
                            .fontDesign(.rounded)
                            .foregroundStyle(colorScheme == .light ?  Color.meowBlack : Color.meowWhite)
                    }
                    
                }
            }
        }
        
        if viewModel.posts.count == 0 && !viewModel.isLoading {
            Spacer()
            HStack {
                Spacer()
                Image(.welcomeCat1)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200)
            }
            .padding()
        }
    }
    
    private func reloadPosts() {
        viewModel.refreshPostHistory()
        viewModel.fetchUserPostsAtATime()
    }
}
