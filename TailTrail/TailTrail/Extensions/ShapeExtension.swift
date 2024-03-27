//
//  ShapeExtension.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/26/24.
//

import SwiftUI

struct TopRoundedRectangle: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        
        path.move(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
        path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + radius))
        path.addArc(center: CGPoint(x: topLeft.x + radius, y: topLeft.y + radius), radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: CGPoint(x: topRight.x - radius, y: topRight.y))
        path.addArc(center: CGPoint(x: topRight.x - radius, y: topRight.y + radius), radius: radius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
        
        path.closeSubpath()
        
        return path
    }
}
