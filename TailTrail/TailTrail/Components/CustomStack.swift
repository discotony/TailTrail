//
//  MeowStack.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/4/24.
//

import SwiftUI

public struct CustomStack: Layout {
    private var columns: Int
    private var spacing: Double
    
    public init(columns: Int = 2, spacing: Double = 8.0) {
        self.columns = max(1, columns)
        self.spacing = max(0, spacing)
    }
    
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        return calculateSize(for: subviews, in: proposal)
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        _ = calculateSize(for: subviews, in: proposal, placeInBounds: bounds)
    }
    
    @discardableResult
    private func calculateSize(
        for subviews: Subviews,
        in proposal: ProposedViewSize,
        placeInBounds bounds: CGRect? = nil
    ) -> CGSize {
        guard let maxWidth = proposal.width else { return .zero }
        let itemWidth = (maxWidth - spacing * Double(columns - 1)) / Double(columns)
        
        var columnsHeights = Array(repeating: 0.0, count: columns)
        
        for view in subviews {
            let column = columnsHeights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            let xPosition = Double(column) * (itemWidth + spacing)
            let yPosition = columnsHeights[column]
            
            let proposedSize = ProposedViewSize(width: itemWidth, height: nil)
            let viewSize = view.sizeThatFits(proposedSize)
            
            if let bounds = bounds {
                view.place(at: CGPoint(x: xPosition + bounds.minX, y: yPosition + (bounds.minY)), anchor: .topLeading, proposal: proposedSize)
            }
            
            columnsHeights[column] += viewSize.height + spacing
        }
        
        let maxHeight = columnsHeights.max() ?? 0
        return CGSize(width: maxWidth, height: max(0, maxHeight - spacing))
    }
    
    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .vertical
        return properties
    }
}
