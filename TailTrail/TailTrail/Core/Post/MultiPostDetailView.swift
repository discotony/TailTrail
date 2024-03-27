//
//  MultiPostDetailView.swift
//  TailTrail
//
//  Created by Devin Alan Studdard on 2/12/24.
//

import SwiftUI

struct MultiPostDetailView: View {
    @State var posts: [Post]
    @State var currPos = 0
    var geometry: CGSize = UIScreen.main.bounds.size
    
    var body: some View {
        ZStack {
            PostDetailView(post: posts[currPos])
            VStack {
                if(posts.count > 1) {
                    ProgressBarView(posts: posts, currPos: currPos)
                        .shadow(radius: 3)
                        .padding(.bottom, 685)
                }
            }
            
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.00000001))
                    .frame(width: geometry.width - ((350/397) * geometry.width), height: geometry.height * (4/10))
                    .onTapGesture { location in
                        if currPos == 0 {}
                        else {
                            currPos -= 1
                        }
                    }
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.000001))
                    .frame(width: geometry.width - ((312/397) * geometry.width), height: geometry.height * (4/10))
                    .onTapGesture { location in
                        if currPos == posts.count-1 {}
                        else {
                            currPos += 1
                        }
                    }
            }
        }
        // OnTapGesture only sides, if currPos = 0, cant tap left, if currPos = photos.count-1 cant tap right
    }
}

struct ProgressBarView: View {
    var posts: [Post]
    var currPos: Int
    var geometrySize: CGSize = UIScreen.main.bounds.size
    var body: some View {
        HStack(alignment: .center){
            ForEach(posts.indices, id: \.self) { index in
                let fill: Color = currPos == index ? .meowOrangeSecondary : .meowGray
                Rectangle()
                    .fill(fill)
                    .frame(width: geometrySize.height * (120/397) / CGFloat(posts.count), height: (6/852) * geometrySize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing, (51/397) * geometrySize.width / CGFloat(posts.count))
            }
        }
        .padding(.leading, (51/397) * geometrySize.width / CGFloat(posts.count))
    }
}
