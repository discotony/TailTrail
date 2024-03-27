//
//  OnFirstAppearViewModifier.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/18/24.
//

import SwiftUI

struct OnFirstAppearViewModifier: ViewModifier {
    @State private var didAppear: Bool = false
    let perform: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !didAppear {
                    perform?()
                    didAppear = true
                }
            }
    }
}
