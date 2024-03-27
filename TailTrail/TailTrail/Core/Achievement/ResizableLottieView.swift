//
//  ResizableLottieView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/1/2024.
//

import SwiftUI
import Lottie

struct ResizableLottieView: UIViewRepresentable {
    var fileName: String
    var onFinish: (LottieAnimationView)->()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        setupView(for: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    func setupView(for to: UIView){
        let LottieAnimationView = LottieAnimationView(name: fileName,bundle: .main)
        LottieAnimationView.backgroundColor = .clear
        LottieAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        LottieAnimationView.shouldRasterizeWhenIdle = true
        
        let constraints = [
            LottieAnimationView.widthAnchor.constraint(equalTo: to.widthAnchor),
            LottieAnimationView.heightAnchor.constraint(equalTo: to.heightAnchor),
        ]
        
        to.addSubview(LottieAnimationView)
        to.addConstraints(constraints)
        
        LottieAnimationView.play{_ in
            onFinish(LottieAnimationView)
        }
    }
}
