//
//  PostDetailView.swift
//  TailTrail
//
//  Created by Antony Bluemel Studdard on 1/24/24.
//

import SwiftUI
import MapKit
import Kingfisher

struct PostDetailView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var viewModel: PostDetailViewModel
    @State private var isSelected = true
    @State private var navigateToMap: Bool = false
    @State private var showAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var didLike: Bool = false
    @State private var showLike: Bool = false
    
    init(post: Post) {
        self.viewModel = PostDetailViewModel(post: post)
    }
    
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .center) {
                    ZStack {
                        KFImage(URL(string: viewModel.post.imageUrl))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .navigationBarBackButtonHidden(true)
                            .onTapGesture(count: 2) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                if !didLike {
                                    withAnimation { showLike = true }
                                }
                                Task {
                                    didLike ? try await viewModel.unlike() : try await viewModel.like()
                                    DispatchQueue.main.async {
                                        self.didLike = viewModel.post.didLike ?? false
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showLike = false
                                }
                                
                            }
                        
                        Image(systemName: "heart.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.meowOrange)
                            .frame(width: 100, height: 100)
                            .opacity(showLike ? 1 : 0)
                            .animation(.linear(duration: 0.5), value: showLike)
                    }
                }
                
                if let caption = viewModel.post.caption, !caption.isEmpty {
                    Text(caption)
                        .font(.customSubtitle)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                likeText
                    .padding(.horizontal)
                
                DescriptionLabel(imageName: "camera.circle.fill", text: viewModel.post.user?.username ?? "Anonymous", color: colorScheme == .light ?  .meowBlack : .meowWhite)
                    .padding(.horizontal, 16)
                
                if let latitude = viewModel.post.latitude,
                   let longitude = viewModel.post.longitude {
                    if let address = viewModel.post.locationString {
                        DescriptionLabel(imageName: "map.circle.fill", text: address, color: colorScheme == .light ?  .meowBlack : .meowWhite)
                            .padding(.horizontal, 16)
                    }
                    
                    let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    ZStack {
                        Map(initialPosition: .region(MKCoordinateRegion(center: coordinates, span: (MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))))) {
                            Marker("", coordinate: coordinates)
                                .tint(Color.meowOrange)
                        }
                        .disabled(true)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1.5, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        Rectangle()
                            .fill(Color.white.opacity(0.00000001))
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1.5, contentMode: .fill)
                            .onTapGesture() {
                                navigateToMap = true
                            }
                    }
                    .padding(.horizontal)
                    .navigationDestination(isPresented: $navigateToMap) {
                        PostMapView( post: viewModel.post, coordinates: coordinates)
                            .navigationBarBackButtonHidden()
                    }
                }
            }
            .padding(.bottom, 32)
            
            .onAppear {
                Task {
                    try await viewModel.checkIfUserLikedPost()
                    DispatchQueue.main.async {
                        didLike = viewModel.post.didLike ?? false
                    }
                }
            }
            
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            // Allow interaction with the rest of the screen while the alert is visible
            .allowsHitTesting(!showAlert)
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        timeStampView
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    optionButton
                }
            }
        }
        .scrollIndicators(.never)
    }
    
    func saveImageToPhotos(urlString: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let imageResult):
                let image = imageResult.image
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                completion(true)
            case .failure:
                completion(false)
            }
        }
        
    }
    
    var likeText: some View {
        HStack {
            Image(systemName: "hand.thumbsup.circle.fill")
                .foregroundStyle(didLike ? Color.meowOrange :
                                    colorScheme == .light ? Color.meowBlack : Color.meowWhite)
                .animation(.linear(duration: 0.01), value: viewModel.post.likeCount)
            
            let label = viewModel.post.likeCount == 1 ? "Aww" : "Awws"
            Text("\(viewModel.post.likeCount) \(label)")
                .listRowSeparator(.hidden)
                .font(Font.customCaption)
                .animation(.linear(duration: 0.01), value: viewModel.post.likeCount)
        }
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            Task {
                didLike ? try await viewModel.unlike() : try await viewModel.like()
                DispatchQueue.main.async {
                    self.didLike = viewModel.post.didLike ?? false
                }
            }
            
        }
    }
    
    var timeStampView: some View {
        VStack {
            Text("\(viewModel.convertedDate)")
                .font(.customCaption)
                .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
            Text("\(viewModel.convertedTime)")
                .font(.customText2)
                .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
            
        }
    }
    
    var backButton: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            dismiss()
        }) {
            Image(systemName: "chevron.left.circle.fill")
                .font(.title2)
                .fontDesign(.rounded)
                .foregroundStyle(colorScheme == .light ?  Color.meowBlack : Color.meowWhite)
        }
    }
    
    var optionButton: some View {
        Menu {
            Button("Save") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                saveImageToPhotos(urlString: viewModel.post.imageUrl) { success in
                    if success {
                        alertTitle = "Yay!"
                        alertMessage = "Image successfully saved in your photo library."
                        showAlert = true
                    } else {
                        alertTitle = "Oops!"
                        alertMessage = "Save Failed. Check you Photo Library Permissions in Settings App."
                        showAlert = true
                    }
                }
            }
            
            if let currentUserId = UserManager.shared.user?.userId, currentUserId == viewModel.post.ownerId {
                Button("Delete", role: .destructive) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    contentViewModel.didUploadOrDeletePost = false
                    Task {
                        do {
                            try await PostManager.deletePost(post: viewModel.post)
                            DispatchQueue.main.async {
                                contentViewModel.didUploadOrDeletePost = true
                                dismiss()
                            }
                        } catch {
                            contentViewModel.didUploadOrDeletePost = false
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .fontDesign(.rounded)
                .foregroundStyle(colorScheme == .light ?  Color.meowBlack : Color.meowWhite)
        }
    }
}
