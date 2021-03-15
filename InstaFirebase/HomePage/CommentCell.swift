//
//  CommentCell.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 14.03.2021.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comments? {
        didSet {
            guard let comment = comment else { return }
            
            let attributedString = NSMutableAttributedString(string: comment.user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedString.append(NSAttributedString(string: "  " + comment.text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            
            textView.attributedText = attributedString
            profileImageView.loadImage(imageURL: comment.user.profileImageURL)
        }
    }
    
    let textView : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(textView)
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
