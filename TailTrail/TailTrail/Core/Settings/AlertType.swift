//
//  AlertType.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/22/24.
//

import Foundation

enum AlertType {
    case maxCharLength
    case whitespaceNotAllowed
    
    var message: String {
        switch self {
        case .maxCharLength:
            return "Oops! \n Caption length limit reached!"
        case .whitespaceNotAllowed:
            return "Oops! \n White space is not allowed!"
        }
    }
}
