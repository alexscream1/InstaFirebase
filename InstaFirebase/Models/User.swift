//
//  User.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 12.03.2021.
//

import Foundation

struct User {
    var uid : String
    var username: String
    var profileImageURL: String
    
    init(uid: String, dict: [String: Any]) {
        self.uid = uid
        self.username = dict["username"] as? String ?? ""
        self.profileImageURL = dict["profileImageURL"] as? String ?? ""
    }
}
