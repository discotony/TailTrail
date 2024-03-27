//
//  PostSummaryView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/17/24.
//

import SwiftUI
import Kingfisher

struct PostSummaryView: View {
    var post: Post
    
    var body: some View {
        let numAwws = post.likeCount
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 210)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 0)
            
            HStack(spacing: 16) {
                KFImage(URL(string: post.imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140)
                    .frame(maxHeight: 180)
                    .cornerRadius(15)
                
                VStack(alignment: .leading, spacing: 16) {
                    Spacer().frame(height: 1)
                    if let caption = post.caption, !caption.isEmpty {
                        Text(caption)
                            .font(.customSubtitle)
                            .foregroundStyle(Color.meowBlack)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(nil)
                    }
                    HStack(alignment: .top) {
                        Image(systemName: "hand.thumbsup.circle.fill")
                            .foregroundStyle(post.didLike ?? false ? Color.meowOrange : Color.meowBlack)
                        Text(numAwws == 1 ? "\(numAwws) Aww" : "\(numAwws) Awws")
                            .font(.customCaption)
                            .foregroundStyle(Color.meowBlack)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack(alignment: .top) {
                        Image(systemName: "camera.circle.fill")
                            .foregroundStyle(Color.meowBlack)
                        Text(post.user?.username ?? "Anonymous")
                            .foregroundStyle(Color.meowBlack)
                            .font(.customCaption)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                Spacer()
            }
            .padding()
        }
    }
}
