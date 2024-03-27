//
//  ActionButton.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/3/24.
//

import SwiftUI

enum ActionButtonType: String {
    case primary = "primary"
    case secondary = "secondary"
    
    var labelColor: Color {
        switch self {
        case .primary:
            return Color.meowWhite
        case .secondary:
            return Color.meowWhite
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color.meowOrange
        case .secondary:
            return Color.meowGray
        }
    }
}

struct PostButton: View {
    let type: ActionButtonType
    let label: String
    let action: () -> Void
    var hasPhoto: Bool
    @Binding var isFetchingLocation: Bool
    @Binding var isTaskRunning: Bool
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isTaskRunning {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: type.labelColor))
                        .frame(width: 44, height: 44)
                        .background(type.backgroundColor)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 60, x: 0.0, y: 16)
                } else {
                    Text(label)
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .foregroundStyle(type.labelColor)
                }
            }
            .frame(maxWidth: isTaskRunning ? 44 : .infinity)
            .frame(height: 44)
            .background(hasPhoto || isFetchingLocation ? Color.meowGray : type.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: isTaskRunning ? 22 : 20))
            .shadow(color: Color.black.opacity(0.1), radius: 60, x: 0.0, y: 16)
        }
        .disabled(hasPhoto || isFetchingLocation || isTaskRunning)
        .animation(.snappy, value: isTaskRunning)
    }
}
