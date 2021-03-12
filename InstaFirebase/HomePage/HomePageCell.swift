//
//  HomePageCell.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 12.03.2021.
//

import UIKit

class HomePageCell: UICollectionViewCell {
    
    var post : Posts? {
        didSet {
            guard let postImageURL = post?.imageURL else { return }
            postImageView.loadImage(imageURL: postImageURL)
            
            usernameLabel.text = post?.user.username
            
            guard let profileImageURL = post?.user.profileImageURL else { return }
            profileImageView.loadImage(imageURL: profileImageURL)
            
            setupAttributedText()
        }
    }
    
    // Post image view
    let postImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    // Top side of post image
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let optionsButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("•••", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    // Bottom side of post image
    
    let likeButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let commentButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "comment")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let sendButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "send")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let bookmarkButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "mark")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let postTextLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        addSubview(postImageView)
        
        // Profile image view
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        
        // Username label
        usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: postImageView.topAnchor, right: optionsButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        // Options button
        optionsButton.anchor(top: topAnchor, left: nil, bottom: postImageView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 0)
        

        // Post image view
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
    
        setupActionButtons()
        
        // Post text label
        addSubview(postTextLabel)
        postTextLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
    }
    
    fileprivate func setupAttributedText() {
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: "\(post.user.username) ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: post.postText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: "1 week ago", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        postTextLabel.attributedText = attributedText
    }
    
    fileprivate func setupActionButtons() {
        
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        addSubview(bookmarkButton)
        bookmarkButton.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 50)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
