//
//  FirestoreConstants.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/24/24.
//

import Firebase

struct FirestoreConstants {
    private static let Root = Firestore.firestore()
    static let UserCollection = Root.collection("users")
    static let PostsCollection = Root.collection("posts")
}
