//
//  FeedCellImage.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/4/24.
//

import SwiftUI
import Kingfisher

struct FeedCellImage: View {
    var post: Post
    var body: some View {
        KFImage(URL(string: post.imageUrl))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(12)
    }
}
