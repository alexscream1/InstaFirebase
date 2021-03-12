//
//  CustomImageView.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 11.03.2021.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView : UIImageView {
    
    var lastURLUsedToLoadImage : String?
    
    func loadImage(imageURL: String) {
        self.lastURLUsedToLoadImage = imageURL
        
        if let cachedImage = imageCache[imageURL] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: imageURL) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("failed to get data", error)
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            
            guard let imageData = data else { return }
            guard let image = UIImage(data: imageData) else { return }
            
            imageCache[url.absoluteString] = image
            
            DispatchQueue.main.async {
                self.image = image
            }
            
        }.resume()
    }
    
}
