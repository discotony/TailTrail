//
//  ViewExtension.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/26/24.
//

import SwiftUI

extension View {
    func onFirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstAppearViewModifier(perform: perform))
    }
    
    func alertButtonTint(color: Color) -> some View {
        modifier(AlertButtonTintColor(color: color))
    }
}
