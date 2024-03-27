//
//  UploadPostView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/22/24.
//

import SwiftUI
import CoreLocation
import PhotosUI

struct UploadPostView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var viewModel = UploadPostViewModel()
    @State private var showUploadOptionAlert: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoLibrary: Bool = false
    @State private var showMaxCharLengthAlert: Bool = false
    @State private var isTaskRunning: Bool = false
    private let maxCharLength: Int = 100
    
    @State private var showCheetoDescription: Bool = false
    @FocusState private var captionTextFieldFocused: Bool
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private let bottomID = UUID()
    
    var onSuccessfulUpload: () -> Void = {}
    
    var body: some View {
        ScrollViewReader { scrollView in
            ZStack {
                ScrollView {
                    VStack {
                        Spacer().frame(height: 8)
                        PostImagePreview
                        Spacer().frame(height: 32)
                        CaptionTextField
                        Spacer().frame(minHeight: 32)
                        AdditionalInfoField
                        Spacer().frame(minHeight: 32)
                        PostButton(type: .primary,
                                   label: "Post",
                                   action: postButtonAction,
                                   hasPhoto: viewModel.selectedUIImage == nil,
                                   isFetchingLocation: $viewModel.isLoadingPhoto,
                                   isTaskRunning: $isTaskRunning)
                        
                        // Invisible view to mark the bottom
                        Color.clear.frame(height: 1).id(bottomID)
                            .id(bottomID)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .scrollIndicators(.never)
                .scrollDismissesKeyboard(.interactively)
                if showMaxCharLengthAlert {
                    UploadAlertView(alertType: .maxLengthReached, shouldShowAlert: showMaxCharLengthAlert)
                }
                if showCheetoDescription {
                    CheetoDescriptionPopUp
                }
                
            }
            // MARK: - Custom Navigation Bar
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Post")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.caption = ""
                        viewModel.selectedUIImage = nil
                        viewModel.selectedPickerItem = nil
                        dismiss()
                    }
                }
            }
            
            // MARK: - Camera
            
            .fullScreenCover(isPresented: $showCamera, content: {
                PhotoCameraView(isPresented: $showCamera,
                                selectedImage: $viewModel.selectedUIImage,
                                dateMetadata: $viewModel.creationDate,
                                locationMetadata: $viewModel.location,
                                isLoadingPhoto: $viewModel.isLoadingPhoto)
                .onAppear {
                    ImageLocationManager.shared.requestLocationAuthorization()
                    ImageLocationManager.shared.startUpdatingLocation()
                }
                .background(.black)
            })
            
            // MARK: - Photo Library
            
            .photosPicker(isPresented: $showPhotoLibrary, selection: $viewModel.selectedPickerItem, matching: .images, photoLibrary: .shared())
            
            // MARK: - Scroll to Bottom When Textfields are Focused
            
            .onChange(of: captionTextFieldFocused) { _, isFocused in
                if isFocused {
                    // Scroll to the bottom when the TextField is focused
                    withAnimation {
                        scrollView.scrollTo(bottomID, anchor: .bottom)
                    }
                }
            }
            
            // MARK: - Clear Images on Disappear
            
            .onDisappear {
                viewModel.selectedUIImage = nil
                viewModel.selectedPickerItem = nil
            }
        }
    }
    
    // MARK: - Helper Function(s)
    
    private func postButtonAction() {
        contentViewModel.didUploadOrDeletePost = false
        captionTextFieldFocused = false
        isTaskRunning = true
        Task {
            do {
                try await viewModel.uploadPost(caption: viewModel.caption,
                                               contactInfo: viewModel.contactInfo)
                DispatchQueue.main.async {
                    contentViewModel.didUploadOrDeletePost = true
                }
                viewModel.caption = ""
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isTaskRunning = false
                    onSuccessfulUpload()
                }
            } catch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isTaskRunning = false
                }
            }
        }
    }
}

// MARK: - SubViews

extension UploadPostView {
    private var PostTypePicker: some View {
        HStack(spacing: 0) {
            Button(action: {
                viewModel.isCatLost = false
                captionTextFieldFocused = false
            }) {
                Text("Share Cat Photo")
                    .padding()
                    .font(.customSubtitle2)
                    .frame(maxWidth: .infinity, maxHeight: 39)
                    .foregroundColor(Color.meowWhite)
                    .background(Color.meowOrange)
            }
        }
        .background(Color.meowGray.opacity(0.6))
        .cornerRadius(12)
    }
    
    private var PostImagePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 2)
                .foregroundStyle(Color.meowGray)
            Image(systemName: "plus")
                .font(.system(size: 48,
                              weight: .none,
                              design: .rounded))
                .foregroundStyle(Color.meowGray)
        }
        .aspectRatio(1, contentMode: .fill)
        .frame(maxWidth: .infinity)
    }
    
    private var PostImagePreview: some View {
        ZStack {
            if viewModel.isLoadingPhoto {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(Color.meowGray)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                }
                .aspectRatio(1, contentMode: .fill)
                .frame(maxWidth: .infinity)
            } else if let image = viewModel.selectedUIImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                PostImagePlaceholder
                    .background()
            }
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            showUploadOptionAlert.toggle()
        }
        .confirmationDialog("Choose an upload option", isPresented: $showUploadOptionAlert) {
            Button("Camera") {
                showCamera.toggle()
            }
            Button("Photo Library") {
                showPhotoLibrary.toggle()
            }
        }
        .alertButtonTint(color: Color.meowOrange)
    }
    
    private var CaptionTextField: some View {
        VStack {
            HStack {
                Text("Post Caption")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.meowOrange)
                Spacer()
            }
            .padding(.horizontal)
            Spacer().frame(height: 12)
            TextField("Caption",
                      text: $viewModel.caption,
                      prompt: Text("Write a caption...")
                .foregroundStyle(Color.meowBlack.opacity(0.5)),
                      axis: .vertical)
            .font(.system(size: 16, weight: .none, design: .rounded))
            .foregroundStyle(Color.meowBlack)
            .multilineTextAlignment(.leading)
            .padding()
            .background(Color.meowOrangeBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .focused($captionTextFieldFocused)
            .onChange(of: viewModel.caption) { _, newValue in
                if newValue.count > maxCharLength {
                    viewModel.caption = String(newValue.prefix(maxCharLength))
                    if showCheetoDescription { showCheetoDescription = false }
                    showMaxCharLengthAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            showMaxCharLengthAlert = false
                        }
                    }
                } else {
                    showMaxCharLengthAlert = newValue.count == maxCharLength
                }
            }
        }
    }
    
    private var AdditionalInfoField: some View {
        VStack {
            VStack {
                Toggle(isOn: $viewModel.isCheeto) {
                    Button {
                        captionTextFieldFocused = false
                        showCheetoDescription = true
                        if showMaxCharLengthAlert { showMaxCharLengthAlert = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showCheetoDescription = false
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Is this Cheeto?")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(Color.meowOrange)
                    }
                }
                .tint(Color.meowOrange)
                
                Toggle(isOn: $viewModel.doesNeedHelp) {
                    HStack(spacing: 4) {
                        Text("Does this cat need help?")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(Color.meowOrange)
                }
                .tint(Color.meowOrange)
            }
            .padding(.horizontal)
            
            .onChange(of: viewModel.isCheeto) {
                captionTextFieldFocused = false
            }
            .onChange(of: viewModel.doesNeedHelp) {
                captionTextFieldFocused = false
                
            }
        }
    }
    
    private var CheetoDescriptionPopUp: some View {
        ZStack {
            Color.black.opacity(0.6)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.meowBlack.opacity(0.1), radius: 60, x: 0.0, y: 16)
            
            VStack {
                Image(.cheeto)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Spacer().frame(height: 16)
                Text("Cheeto is an orange tabby cat that lives in University of California, Davis campus.")
                    .multilineTextAlignment(.center)
                    .lineSpacing(6.0)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.meowWhite)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .padding(.horizontal, 32)
        .transition(.opacity)
        .animation(.easeInOut, value: showCheetoDescription)
        .zIndex(1)
    }
}
