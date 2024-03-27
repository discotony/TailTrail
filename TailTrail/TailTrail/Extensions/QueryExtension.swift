//
//  QueryExtension.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/26/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        return try await getDocumentsWithSnapshot(as: type).documentsData
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (documentsData: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let documentsData = try snapshot.documents.map { document in
            try document.data(as: T.self)
        }
        
        return (documentsData, snapshot.documents.last)
    }
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return self.start(afterDocument: lastDocument)
    }
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T : Decodable {
        let publisher = PassthroughSubject<[T], Error>()
        
        let listener = self.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let results: [T] = documents.compactMap { try? $0.data(as: T.self) }
            publisher.send(results)
        }
        
        return (publisher.eraseToAnyPublisher(), listener)
    }
}
