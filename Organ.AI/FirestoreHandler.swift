//
//  FirestoreHandler.swift
//  Organ.AI
//
//  Created by Ben on 2020/3/27.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FirestoreHandler{
    
    let db = Firestore.firestore()
    
    func setNewData(collection: String, data: [String: Any])
    {
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection(collection).addDocument(data: data) {
            err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func getData(collection: String)
    {
        db.collection(collection).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    print(document.data()["email"])
                }
            }
        }
    }
    
    
    
}
