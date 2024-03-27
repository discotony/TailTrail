//
//  FontExtension.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/26/24.
//

import SwiftUI

extension Font {
    static var customTitle1: Font {
        .system(size: 32, weight: .bold, design: .rounded)
    }
    
    static var customTitle2: Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    
    static var customSubtitle: Font {
        .system(size: 18, weight: .bold, design: .rounded)
    }
    
    static var customSubtitle2: Font {
        .system(size: 16, weight: .bold, design: .rounded)
    }
    
    static var customCaption: Font {
        .system(size: 16, weight: .semibold, design: .rounded)
    }
    
    static var customText: Font {
        .system(size: 16, weight: .regular, design: .rounded)
    }
    
    static var customText2: Font {
        .system(size: 14, weight: .regular, design: .rounded)
    }
}
