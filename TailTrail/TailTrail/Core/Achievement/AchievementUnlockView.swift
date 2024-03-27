//
//  AchievementUnlockView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/22/24.
//

import SwiftUI

struct AchievementUnlockView: View {
    @Environment(\.dismiss) var dismiss
    @State private var expandCard: Bool = false
    @State private var showContent: Bool = false
    @State private var showLottieAnimation: Bool = false
    @State private var showBadge: Bool = true
    @State private var isButtonVisible: Bool = false
    @State private var currentIndexAlert = 0
    @State private var currentIndexText = 0
    @Namespace var animation
    
    var body: some View {
        VStack{
            CardView()
            
            FoundBadgeAlert()
            
            FoundBadgeText()
                .frame(height: 60)
                .padding()
            
            Button(action: {
                dismiss()
            }){
                Text("Dismiss")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .fontDesign(.rounded)
                    .padding(.vertical,17)
                    .frame(width: UIScreen.main.bounds.width / 2)
            }
            .background(
                Capsule()
                    .fill(Color.meowOrange)
            )
            .cornerRadius(20)
            .padding(.top,50)
        }
        .padding(15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background (
            Rectangle()
                .fill(Color.meowOrangeSecondary)
                .opacity(0.4)
                .ignoresSafeArea()
        )
        .overlay(content: {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(showContent ? 1 : 0)
                .ignoresSafeArea()
        })
        .overlay(content: {
            GeometryReader{proxy in
                let size = proxy.size
                
                if expandCard{
                    GiftCardView(size: size)
                        .overlay(content: {
                            if showLottieAnimation{
                                ResizableLottieView(fileName: "Party") { view in
                                    withAnimation(.easeInOut){
                                        showLottieAnimation = false
                                        isButtonVisible = true
                                    }
                                }
                                .scaleEffect(1.4)
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            }
                        })
                        .matchedGeometryEffect(id: "Card", in: animation)
                        .transition(.asymmetric(insertion: .identity, removal: .offset(x: 1)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.35)){
                                showContent = true
                                showLottieAnimation = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showContent = false
                                        showLottieAnimation = false
                                        expandCard = false
                                    }
                                }
                            }
                        }
                }
            }
            .padding(30)
        })
    }
    
    @ViewBuilder
    func CardView()->some View{
        GeometryReader{proxy in
            let size = proxy.size
            
            HiddenCard(pointSize: 60) {
                if !expandCard{
                    GiftCardView(size: size)
                        .matchedGeometryEffect(id: "GIFTCARD", in: animation)
                }
            } overlay: {
                
                // MARK: - Replace scratch card here
                
                Image(.scratchCard)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width * 0.9, height: size.width * 0.9,alignment: .topLeading)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            } onFinish: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                        expandCard = true
                    }
                }
            }
            .frame(width: size.width, height: size.height, alignment: .center)
        }
        .padding(15)
    }
    
    @ViewBuilder
    func GiftCardView(size: CGSize)->some View{
        VStack(spacing: 4){
            
            // MARK: - Replace badge here
            
            Image(.badge7)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .fontDesign(.rounded)
                .frame(width: 200, height: 200)
            
            Text("You've Won an")
                .font(.callout)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(Color.meowLightOrange)
            
            HStack{
                Text("Orange Cat")
                    .fontDesign(.rounded)
            }
            .font(.title.bold())
            .foregroundColor(Color.meowOrange)
        }
        .padding(2)
        .frame(width: size.width * 0.9, height: size.width * 0.9)
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.white)
        }
    }
}
