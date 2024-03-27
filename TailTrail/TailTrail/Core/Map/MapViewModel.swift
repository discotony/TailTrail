//
//  MapViewModel.swift
//  TailTrail
//
//  Created by Jesse Liao on 2/26/24.
//

import SwiftUI
import MapKit

@MainActor
class MapViewModel: ObservableObject {
    @Published var catCollections: [[Post]]
    @Published var catPosts: [Post]
    @Published var uniqueCatPosts: [(String, Post)]
    @Published var infiniteCatPosts: [(String, Post)]
    @Published var catsThatNeedHelp: [Post]
    @Published var selectedPost: Post?
    @Published var mostRecentCat: Post?
    @Published var cameraPosition: MapCameraPosition
    @Published var isSummaryShown: Bool
    @Published var shouldAlert: Bool
    @Published var vetAndShelters: [MKMapItem]
    var mode = "AllCatsPosts"
    let locationManager = UserLocationManager.shared
    let shelterViewModel = ShelterViewModel()
    
    init() {
        self.catCollections = []
        self.catPosts = []
        self.uniqueCatPosts = []
        self.infiniteCatPosts = []
        self.catsThatNeedHelp = []
        self.cameraPosition = .automatic
        self.isSummaryShown = false
        self.shouldAlert = false
        self.vetAndShelters = []
    }
    
    func initMap() {
        Task {
            isSummaryShown = false
            await self.fetchPosts()
            self.centerCamera()
            self.detectCatNeedHelp()
            await self.locateShelterAndVets()
        }
    }
    
    func fetchPosts() async {
        do {
            if mode == "AllCatsPosts" {
                let allCatsPosts = try await PostManager.fetchAllPostsWithLocationWithinTimeFrame(filter: .allCats)
                self.catCollections = self.groupByLocation(post: allCatsPosts, range: 20)
            } else if mode == "CheetoOnly" {
                let cheetoPosts = try await PostManager.fetchAllPostsWithLocationWithinTimeFrame(filter: .cheetoOnly)
                self.catCollections = self.groupByLocation(post: cheetoPosts, range: 20)
            } else {
                print("Error: Unknown Mode")
                return
            }
            
            self.catPosts = self.catCollections.compactMap{ $0.first }
            self.uniqueCatPosts = formUniquePost(posts: self.catPosts)
            self.mostRecentCat = self.uniqueCatPosts.first?.1
            constructInfinitePost(for: self.uniqueCatPosts)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func centerCamera() {
        if self.mode == "cheetoOnly" {
            self.cameraPosition = .region(self.calculateBoundingCenter(for: self.catPosts))
        } else if self.mode == "AllCatsPosts" {
            if let userLocation = locationManager.userLocation {
                self.cameraPosition = .region(MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
            } else {
                if locationManager.alertForPermission {
                    self.shouldAlert = true
                } else {
                    locationManager.sendAuthorizationRequest()
                }
            }
        }
    }
    
    func locateShelterAndVets() async {
        let distanceFromCenter = CLLocationDistance(10000.0)
        guard let center = locationManager.userLocation else {
            return
        }
        let shelterResults = await shelterViewModel.searchNearbyLocations(for: "animal shelters", near: center, range: distanceFromCenter)
        let vetResults = await shelterViewModel.searchNearbyLocations(for: "veterinary", near: center, range: distanceFromCenter)
        self.vetAndShelters = shelterResults + vetResults
    }
    
    func detectCatNeedHelp() {
        self.catsThatNeedHelp = []
        for area in self.catCollections {
            guard !area.isEmpty else { continue }
            for post in area {
                if post.doesNeedHelp ?? false {
                    self.catsThatNeedHelp.append(post)
                    break
                }
            }
        }
    }
    
    func calculateBoundingCenter(for catPosts: [Post]) -> MKCoordinateRegion {
        let latitudes = catPosts.map {$0.latitude ?? 0}
        let longitudes = catPosts.map {$0.longitude ?? 0}
        
        let maxLatitude = latitudes.max() ?? 0
        let minLatitude = latitudes.min() ?? 0
        let maxLongitude = longitudes.max() ?? 0
        let minLongitude = longitudes.min() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2)
        let span = MKCoordinateSpan(
            latitudeDelta: maxLatitude - minLatitude + 0.0006,
            longitudeDelta: maxLongitude - minLongitude + 0.0006)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func groupByLocation(post posts: [Post], range maxDistance: CLLocationDistance) -> [[Post]] {
        var postCollection = [[Post]]()
        
        for post in posts {
            let postLocation = CLLocation(latitude: post.latitude ?? 0, longitude: post.longitude ?? 0)
            var isGrouped = false
            
            for (index, group) in postCollection.enumerated() {
                guard let firstPostInGroup = group.first else {
                    print("Error: uninitialized group")
                    break
                }
                let groupLocation = CLLocation(latitude: firstPostInGroup.latitude ?? 0, longitude: firstPostInGroup.longitude ?? 0)
                if postLocation.distance(from: groupLocation) < maxDistance {
                    postCollection[index].append(post)
                    isGrouped = true
                    break
                }
            }
            if !isGrouped {
                postCollection.append([post])
            }
        }
        return postCollection
    }
    
    func constructInfinitePost(for uniqueCatPosts: [(String, Post)]) {
        self.infiniteCatPosts = uniqueCatPosts.map{ $0 }
        
        if let lastPhoto = self.uniqueCatPosts.last {
            self.infiniteCatPosts.insert(lastPhoto, at: 0)
            self.infiniteCatPosts[0].0 = "-1"
        }
        if let firstPhoto = self.uniqueCatPosts.first {
            self.infiniteCatPosts.append(firstPhoto)
            self.infiniteCatPosts[self.infiniteCatPosts.count-1].0 = "-2"
        }
        
    }
    
    func formUniquePost(posts: [Post]) -> [(String, Post)]  {
        let taggingPosts = posts.map { post -> (String, Post) in
            let identifier = post.id ?? UUID().uuidString
            return (identifier, post)
        }
        return taggingPosts
    }
}
