//
//  UploadAlertView.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/14/24.
//

import SwiftUI

enum AlertTextType {
    case maxLengthReached
    case catNotDetected
    
    var text: String {
        switch self {
        case .maxLengthReached:
            return "Oops! \n Caption length limit reached!"
        case .catNotDetected:
            return "Our app checks for cat(s) in photos. Make sure to upload a cat photo!"
        }
    }
}

struct UploadAlertView: View {
    var alertType: AlertTextType
    var shouldShowAlert: Bool
    
    var body: some View {
        Text(alertType.text)
            .multilineTextAlignment(.center)
            .lineSpacing(6.0)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.meowWhite)
            .padding()
            .frame(width: 300, height: 100)
            .background(Color.black.opacity(0.6))
            .cornerRadius(20)
            .shadow(color: Color.meowBlack.opacity(0.1), radius: 60, x: 0.0, y: 16)
            .transition(.opacity)
            .animation(.easeInOut, value: shouldShowAlert)
            .zIndex(1)
            .padding(.bottom, 16)
    }
}

#Preview {
    UploadAlertView(alertType: .catNotDetected, shouldShowAlert: true)
}
