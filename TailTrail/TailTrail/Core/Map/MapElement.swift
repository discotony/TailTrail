//
//  MapElement.swift
//  TailTrail
//
//  Created by Jesse Liao on 3/8/24.
//

import SwiftUI
import MapKit
import Kingfisher

struct MapElement: View {
    @ObservedObject var viewModel: MapViewModel
    @State var isHospitalTapped = false
    
    var body: some View {
        Map(position: $viewModel.cameraPosition) {
            UserAnnotation()
            ForEach(viewModel.uniqueCatPosts, id: \.0) { (id, post) in
                let latitude = post.latitude ?? 0
                let longitude = post.longitude ?? 0
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                Annotation("", coordinate: location) {
                    CatAnnotationImage(viewModel: viewModel, post: post)
                }
            }
            ForEach(viewModel.vetAndShelters, id: \.self) { location in
                let placemark = location.placemark
                Annotation(placemark.name ?? "", coordinate: placemark.coordinate) {
                    Image(systemName: "cross.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 25, height: 25)
                        .foregroundStyle(Color.red)
                        .onTapGesture {
                            isHospitalTapped = true
                        }
                }
            }
        }
        .mapControls {
            MapCompass()
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    viewModel.isSummaryShown = false
                }
        )
    }
}

struct CatAnnotationImage: View {
    @ObservedObject var viewModel: MapViewModel
    @State var isGlowing = false
    var post: Post
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 58, height: 58)
                .foregroundStyle(viewModel.catsThatNeedHelp.contains(post) ? . red : Color.meowOrange)

            KFImage(URL(string: post.imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
        .onTapGesture {
            viewModel.isSummaryShown = true
            viewModel.selectedPost = post
        }
    }
}
