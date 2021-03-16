//
//  LikesCell.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 16.03.2021.
//

import UIKit

class LikesCell: UICollectionViewCell {
    
    
    var likedPost: Posts? {
        didSet {
            guard let post = likedPost else { return }
            postImageView.loadImage(imageURL: post.imageURL)
            profileImageView.loadImage(imageURL: post.user.profileImageURL)
            
            let attributedString = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedString.append(NSAttributedString(string: "  liked your post", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            likeLabel.attributedText = attributedString
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let likeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Username liked your post"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(postImageView)
        postImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
        
        addSubview(likeLabel)
        likeLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: postImageView.leftAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
