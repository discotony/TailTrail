//
//  ShelterSearchBar.swift
//  TailTrail
//
//  Created by Jesse Liao on 3/2/24.
//

import SwiftUI
import MapKit

struct ShelterSearchBar: View {
    @EnvironmentObject var viewModel: ShelterViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                SearchTextField()
                    .onTapGesture {
                        viewModel.isFocus = true
                    }
                
                if viewModel.isFocus {
                    Divider()
                        .frame(height: 2)
                        .background(Color.meowWhite)
                        .padding(.horizontal)
                    SuggestionExpansion()
                }
            }
            .background(Color.meowOrange)
            .foregroundColor(Color.meowWhite)
            .font(.customCaption)
            .cornerRadius(12)
            .shadow(color: viewModel.isFocus ? .black.opacity(0.5) : .clear, radius: 4, x: 0, y: 4)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

struct SearchTextField: View {
    @EnvironmentObject var viewModel: ShelterViewModel
    @FocusState var isFocused
    @State private var debounceTimer: Timer?
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 20, height: 20)
            
            TextField("", text: $viewModel.inputtedAddress, prompt: Text("Search shelters and vet clinic...")
                .foregroundColor(Color.meowWhite))
            .accentColor(Color.meowWhite)
            .padding(.horizontal, 10)
            .focused($isFocused)
            .onChange(of: viewModel.isFocus) {
                isFocused = viewModel.isFocus
            }
            .onChange(of: viewModel.inputtedAddress) {
                debounceTimer?.invalidate()
                debounceTimer = nil
                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    viewModel.generateSuggestions(for: viewModel.inputtedAddress)
                }
            }
            .onTapGesture {
                viewModel.isFocus = true
                viewModel.generateSuggestions(for: viewModel.inputtedAddress)
            }
            .onDisappear {
                debounceTimer?.invalidate()
                debounceTimer = nil
            }
            
            DeleteButton()
        }
        .padding()
    }
}

struct DeleteButton: View {
    @EnvironmentObject var viewModel: ShelterViewModel
    
    var body: some View {
        Image(systemName: "x.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 20, height: 20)
            .foregroundColor(Color.meowWhite)
            .onTapGesture {
                viewModel.inputtedAddress = ""
                viewModel.isFocus = true
            }
    }
}

struct SuggestionExpansion: View {
    @EnvironmentObject var viewModel: ShelterViewModel
    @State var selectedSuggestionId = UUID()
    @State var distanceFromCenter = CLLocationDistance(10000.0)
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.locationSuggestions, id: \.id) { suggestion in
                HStack(spacing: 0) {
                    Image(systemName: "mappin.and.ellipse")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("\(suggestion.string)")
                        .padding(.horizontal, 10)
                }
                .padding(.horizontal)
                .padding(.vertical, selectedSuggestionId == suggestion.id ? 10 : 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(selectedSuggestionId == suggestion.id ? Color.meowOrangeSecondary : Color.meowOrange)
                .cornerRadius(12)
                .onTapGesture {
                    selectedSuggestionId = suggestion.id
                    viewModel.generateSheltersAndVets(near: suggestion.coordinate, range: distanceFromCenter)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.isFocus = false
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ShelterSearchBar()
}
