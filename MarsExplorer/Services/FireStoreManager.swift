//
//  FireStoreManager.swift
//  MarsExplorer
//
//  Created by Muhammed Kocabas on 2023-03-27.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage


class FirestoreManager: ObservableObject {

    @Published var userPhotos: [Photo] = []
    
    var userid:String = ""
//    var viewModel: AuthenticationViewModel
    
//    init(viewModel:AuthenticationViewModel) {
//        self.viewModel = viewModel
//    }
    

    
    func fetchUserPhotos() {
        
        guard let currentUser = Auth.auth().currentUser else {
            
            // No user is currently signed in 
            return
        }
        print(currentUser.uid.description)
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document("\(currentUser.uid.description)").collection("photos")
        print(docRef)
            
            docRef.getDocuments() { (querySnapshot, error) in
                guard error == nil else {
                    print("error", error ?? "")
                    return
                }
                
                if let data = querySnapshot?.documents, !data.isEmpty {
                    self.userPhotos = data as? [Photo] ?? []
                    for photo in self.userPhotos {
                        print("\(photo.id): \(photo.rover)")
                    }
                }
                
            }
      
    }
    
    
}
