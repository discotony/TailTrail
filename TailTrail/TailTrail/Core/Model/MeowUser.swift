//
//  MeowUser.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/26/24.
//

import FirebaseFirestoreSwift
import Firebase

struct MeowUser: Codable, Hashable {
    let userId: String
    let timestamp: Date?
    var isAnonymous: Bool?
    var username: String?
    
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == userId }
    
    init(authUser: AuthDataResultModel) {
        self.userId = authUser.uid
        self.timestamp = Date()
        self.isAnonymous = authUser.isAnonymous
        self.username = MeowUsername.generateRandomUsername()
    }
    
    init(userId: String,
         timestamp: Date?,
         isAnonymous: Bool? = nil,
         username: String?
    ) {
        self.userId = userId
        self.timestamp = timestamp
        self.isAnonymous = isAnonymous
        self.username = MeowUsername.generateRandomUsername()
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case timestamp = "timestamp"
        case isAnonymous = "is_anonymous"
        case username = "username"
        case email = "email"
        case profileImageUrl = "profile_image_url"
        case bio = "bio"
        case isPremium = "is_premium"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.timestamp, forKey: .timestamp)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.username, forKey: .username)
    }
}
