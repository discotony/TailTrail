//
//  PostMapView.swift
//  TailTrail
//
//  Created by Devin Studdard on 2/17/24.
//

import SwiftUI
import MapKit

struct PostMapView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var cameraPosition: MapCameraPosition
    @State private var showAlert = false
    @State private var timer: Timer?
    @State private var alertMessage: String = ""
    private var coordinates: CLLocationCoordinate2D
    var post: Post
    
    init(post: Post, coordinates: CLLocationCoordinate2D) {
        self.coordinates = coordinates
        self.post = post
        let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        _cameraPosition = State(initialValue: .region(region))
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                Marker("", coordinate: coordinates)
                    .tint(Color.meowOrange)
            }
            .mapControls {
                MapCompass()
            }
            VStack {
                HStack {
                    ZStack {
                        Circle()
                            .frame(width: 42)
                            .foregroundStyle(Color.meowWhite)
                            .shadow(radius: 3)
                        Image(systemName: "location.fill")
                            .foregroundStyle(Color.meowBlack)
                    }
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        cameraPosition = .region(MKCoordinateRegion(center: coordinates, span: (MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))))
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .allowsHitTesting(!showAlert)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("\(convertDate(for: post))")
                        .font(.customCaption)
                        .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
                    Text("\(convertTime(for: post))")
                        .font(.customText2)
                        .foregroundStyle(colorScheme == .light ? Color.meowBlack : Color.meowWhite)
                }
                .padding(.horizontal, 0)
                .padding(.top, 0)
            }
            ToolbarItem(placement: .topBarLeading) {
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
        }
    }
    
    private func convertDate(for post: Post) -> String {
        let date = post.timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    private func convertTime(for post: Post) -> String {
        let date = post.timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // Format for "12:47 PM"
        
        let formattedTime = dateFormatter.string(from: date)
        return formattedTime
    }
}
