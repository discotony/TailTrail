//
//  AlertButtonTintColor.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/3/24.
//

import SwiftUI

struct AlertButtonTintColor: ViewModifier {
    let color: Color
    @State private var previousTintColor: UIColor?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                previousTintColor = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor
                UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(color)
            }
            .onDisappear {
                UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = previousTintColor
            }
    }
}
