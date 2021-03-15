//
//  Posts.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 11.03.2021.
//

import Foundation


struct Posts {
    
    var id: String?
    let user: User
    let imageURL: String
    let postText: String
    let creationDate: Date
    
    var hasLike = false

    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageURL = dictionary["imageURL"] as? String ?? ""
        self.postText = dictionary["text"] as? String ?? ""
        
        let seconds = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: seconds)
    }
}
