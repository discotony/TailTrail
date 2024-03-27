//
//  Post.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/22/24.
//

import FirebaseFirestoreSwift
import Firebase

struct Post: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let ownerId: String
    let caption: String?
    var likeCount: Int
    let imageUrl: String
    let timestamp: Timestamp
    let latitude: Double?
    let longitude: Double?
    let locationString: String?
    var isCheeto: Bool?
    var doesNeedHelp: Bool?
    
    var user: MeowUser?
    
    var didLike: Bool? = false
    
    init(id: String? = nil,
         ownerId: String,
         caption: String?,
         likeCount: Int = 0,
         imageUrl: String,
         timestamp: Timestamp = Timestamp(),
         latitude: Double?,
         longitude: Double?,
         locationString: String?,
         isCheeto: Bool?,
         doesNeedHelp: Bool?,
         
         user: MeowUser? = nil,
         didLike: Bool? = nil
    ) {
        self.id = id
        self.ownerId = ownerId
        self.caption = caption
        self.likeCount = likeCount
        self.imageUrl = imageUrl
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.locationString = locationString
        self.isCheeto = isCheeto
        self.doesNeedHelp = doesNeedHelp
        
        self.user = user
        self.didLike = didLike
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner_id"
        case caption = "caption"
        case likeCount = "like_count"
        case imageUrl = "image_url"
        case timestamp = "timestamp"
        case latitude = "latitude"
        case longitude = "longitude"
        case locationString = "location_string"
        case isCheeto = "is_cheeto"
        case doesNeedHelp = "does_need_help"
        
        case user = "user"
        case didLike = "did_like"
        
        case postLikes = "post_likes"
        case userLikes = "user_likes"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(DocumentID<String>.self, forKey: .id)
        self.ownerId = try container.decode(String.self, forKey: .ownerId)
        self.caption = try container.decodeIfPresent(String.self, forKey: .caption)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        self.locationString = try container.decodeIfPresent(String.self, forKey: .locationString)
        self.isCheeto = try container.decodeIfPresent(Bool.self, forKey: .isCheeto)
        self.doesNeedHelp = try container.decodeIfPresent(Bool.self, forKey: .doesNeedHelp)
        self.user = try container.decodeIfPresent(MeowUser.self, forKey: .user)
        self.didLike = try container.decodeIfPresent(Bool.self, forKey: .didLike)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.ownerId, forKey: .ownerId)
        try container.encodeIfPresent(self.caption, forKey: .caption)
        try container.encode(self.likeCount, forKey: .likeCount)
        try container.encode(self.imageUrl, forKey: .imageUrl)
        try container.encode(self.timestamp, forKey: .timestamp)
        try container.encodeIfPresent(self.latitude, forKey: .latitude)
        try container.encodeIfPresent(self.longitude, forKey: .longitude)
        try container.encodeIfPresent(self.locationString, forKey: .locationString)
        try container.encodeIfPresent(self.isCheeto, forKey: .isCheeto)
        try container.encodeIfPresent(self.doesNeedHelp, forKey: .doesNeedHelp)
        try container.encodeIfPresent(self.user, forKey: .user)
        try container.encodeIfPresent(self.didLike, forKey: .didLike)
    }
}
