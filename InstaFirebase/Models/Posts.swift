//
//  Posts.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 11.03.2021.
//

import Foundation


struct Posts {
    let imageURL: String
    
    
    init(dictionary: [String: Any]) {
        self.imageURL = dictionary["imageURL"] as? String ?? ""
    }
}
