//
//  Comments.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 15.03.2021.
//

import Foundation


struct Comments {
    
    let user: User
    let text: String
    //let creationDate: Date
    let userID: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.userID = dictionary["userID"] as? String ?? ""
    }
    
}
