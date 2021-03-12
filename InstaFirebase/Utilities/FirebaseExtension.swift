//
//  FirebaseExtension.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 12.03.2021.
//

import Foundation
import Firebase

extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dict: dict)
            completion(user)
            
        } withCancel: { (error) in
            print("Failed to fetch user:", error)
        }
    }
    
}
