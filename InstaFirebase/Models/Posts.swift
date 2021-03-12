//
//  Posts.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 11.03.2021.
//

import Foundation


struct Posts {
    
    let user: User
    let imageURL: String
    let postText: String

    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageURL = dictionary["imageURL"] as? String ?? ""
        self.postText = dictionary["text"] as? String ?? ""
    }
}
