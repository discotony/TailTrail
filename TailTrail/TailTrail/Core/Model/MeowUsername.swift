//
//  MeowUsername.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/5/24.
//

import Foundation

struct MeowUsername {
    static let usernames: [String] = [
        "WhiskerWizard",
        "PurrfectPals",
        "TabbyTales",
        "MeowMentor",
        "CatCraze",
        "FluffyFables",
        "KittyChronicles",
        "PawsPlay",
    ]
    
    static func generateRandomUsername() -> String {
        guard let selectedUsername = usernames.randomElement() else { return "CatLover" }
        let randomNumber = Int.random(in: 1000...9999)
        return "\(selectedUsername)\(randomNumber)"
    }
}
