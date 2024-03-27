//
//  ColorExtension.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/26/24.
//

import SwiftUI

extension Color {
    // MARK: - Color Conversion
    
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    // MARK: - Accent Color
    
    static var meowOrange: Color {
        return Color(hex: "FFAA47")
    }
    
    static var meowOrangeBackground: Color {
        return Color(hex: "FFECCB")
    }
    
    static var meowBlueBackground: Color {
        return Color(hex: "D3EEFF")
    }
    
    static var meowBackgroundLight: Color {
        return Color(hex: "FFFFFF")
    }
    
    static var meowBackgroundDark: Color {
        //        return Color(hex: "222426")
        return Color(hex: "222222")
    }
    
    static var meowLightOrange: Color {
        return Color(hex: "#FFDFA3")
    }
    
    static var meowOrangeSecondary: Color {
        return Color(hex: "FFDFA3")
    }
    
    // MARK: - Primary Color
    
    static var meowBlack: Color {
        return Color(hex: "222222")
    }
    
    static var meowWhite: Color {
        return Color(hex: "FFFFFF")
    }
    
    // MARK: - Secondary Color
    
    static var meowGray: Color {
        return Color(hex: "C3C3C3")
    }
    
    // MARK: - Adaptive Color for Dark Mode
    
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        @Environment(\.colorScheme) var colorScheme
        return colorScheme == .dark ? dark : light
    }
    
    // MARK: - components
    
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
}
