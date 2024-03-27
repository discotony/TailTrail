//
//  MainTabView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/2/24.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case feed = "photo.on.rectangle"
    case map = "map"
    case camera = "camera"
    case resource = "rectangle.and.text.magnifyingglass"
    case profile = "person"
    
    var selected: String {
        switch self {
        case .feed:
            return "photo.fill.on.rectangle.fill"
        case .map:
            return "map.fill"
        case .camera:
            return "camera.fill"
        case .resource:
            return "mail.and.text.magnifyingglass"
        case .profile:
            return "person.fill"
        }
    }
}

struct CustomTab: Identifiable {
    var id: UUID = .init()
    var tab: Tab
}

struct MainTabView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var mapViewModel = MapViewModel()
    @StateObject var shelterViewModel = ShelterViewModel()
    @State private var activeTab: Tab = .feed
    @State private var allTabs: [CustomTab] = Tab.allCases.compactMap { tab -> CustomTab? in
        return .init(tab: tab)
    }
    @State private var bouncesDown: Bool = true
    @State private var isCameraSelected: Bool = false
    @State private var unlockAchievement: Bool = false
    private let unlockAchievementKey = "unlockAchievementKey"
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                TabView(selection: $activeTab) {
                    NavigationStack {
                        FeedView(posts: contentViewModel.feedPosts, lastDocument: contentViewModel.feedLastDoc)
                            .tint(.meowOrange)
                    }
                    .setUpTab(.feed)
                    
                    NavigationStack {
                        MapView(viewModel: mapViewModel)
                            .tint(.meowOrange)
                            
                    }
                    .setUpTab(.map)
                    
                    Color.white
                        .setUpTab(.camera)
                    
                    NavigationStack {
                        ShelterView()
                            .environmentObject(shelterViewModel)
                    }
                    .setUpTab(.resource)
                    
                    NavigationStack {
                        if let user = contentViewModel.user {
                            ProfileView(user: user, posts: contentViewModel.userPosts, lastDocument: contentViewModel.userLastDoc)
                                .tint(.meowOrange)
                        }
                    }
                    .setUpTab(.profile)
                }
                CustomTabBar(geometry: geometry)
            }
            .ignoresSafeArea(.keyboard)
            
            .sheet(isPresented: $isCameraSelected) {
                NavigationView {
                    UploadPostView(onSuccessfulUpload: {
                        if !UserDefaults.standard.bool(forKey: unlockAchievementKey) {
                            unlockAchievement = true
                            UserDefaults.standard.set(true, forKey: unlockAchievementKey)
                        }
                    })
                    .tint(.meowOrange)
                }
            }
            
            .fullScreenCover(isPresented: $unlockAchievement) {
                AchievementUnlockView()
            }
            
        }
    }
    
    @ViewBuilder
    func CustomTabBar(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach($allTabs) { $tab in
                let tab = tab.tab
                
                ZStack {
                    if tab == .camera {
                        Circle()
                            .foregroundColor(Color.meowOrange)
                            .frame(width: 50, height: 50)
                    }
                    
                    VStack(spacing: 4) {
                        Image(systemName: tab == .camera ? tab.selected :
                                activeTab == tab ? tab.selected : tab.rawValue)
                        .font(.title2)
                        .foregroundColor(tab == .camera ? .white :
                                            activeTab == tab ? Color.meowOrange : .gray)
                    }
                }
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    if tab == .camera {
                        isCameraSelected.toggle()
                    } else {
                        activeTab = tab
                    }
                    if tab == .map {
                        mapViewModel.initMap()
                    } else if tab == .resource {
                        shelterViewModel.initShelter()
                    }
                }
            }
        }
        .padding(.top, 4)
        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 4)
        .background()
        .clipped()
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.2) : Color.white.opacity(0.15), radius: 8, y: -2)
        .mask(Rectangle().padding(.top, -24))
    }
}

extension View {
    @ViewBuilder
    func setUpTab(_ tab: Tab) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tag(tab)
    }
}
