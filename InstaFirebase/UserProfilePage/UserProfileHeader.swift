//
//  UserProfileCollectionViewCell.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 10.03.2021.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate {
    func didChangeToGridView()
    func didChangeToListView()
}

class UserProfileHeader: UICollectionViewCell {
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            guard let profileImageURL = user?.profileImageURL else { return }
            profileImageView.loadImage(imageURL: profileImageURL)
            
            usernameLabel.text = user?.username
            
            setupEditFollowButton()
        }
    }
    
    // Profile ImageView
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        
        return iv
    }()
    
    // Grid Button in Toolbar
    lazy var gridButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        btn.addTarget(self, action: #selector(changeToGridView), for: .touchUpInside)
        return btn
    }()
    
    // List Button in Toolbar
    lazy var listButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        btn.addTarget(self, action: #selector(changeToListView), for: .touchUpInside)
        return btn
    }()
    
    // Bookmark Button in Toolbar
    let bookmarkButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "mark"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        return btn
    }()
    
    // Username Label
    let usernameLabel : UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    // Posts label in Statistic bar
    let postsLabel : UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // Followers label in Statistic bar
    let followersLabel : UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // Following label in Statistic bar
    let followingLabel : UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // Edit profile Button
    lazy var editProfileFollowButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(profileImageView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 18, paddingLeft: 18, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
        
        setupToolbar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 30, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        setupStatsBar()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 4, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
    }
    
    // Change collection view style to GRID view
    @objc func changeToGridView() {
        gridButton.tintColor = .customBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        self.delegate?.didChangeToGridView()
    }
    
    // Change collection view style to LIST view
    @objc func changeToListView() {
        listButton.tintColor = .customBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        self.delegate?.didChangeToListView()
    }
    
    // Action for editing profile/following/unfollowing user
    @objc func handleEditProfileOrFollow() {
        
        guard let loggedUserID = Auth.auth().currentUser?.uid else { return }
        guard let userID = user?.uid else { return }
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            
            // Unfollow user
            Database.database().reference().child("following").child(loggedUserID).child(userID).removeValue { (error, ref) in
                if let error = error {
                    print("Failed to unfollow", error)
                    return
                }
                print("Succesfully unfollow", self.user?.username ?? "")
                self.setupFollowStyle()
            }
        } else {
            // Follow user
            let ref = Database.database().reference().child("following").child(loggedUserID)
            let values = [userID: 1]
            ref.updateChildValues(values) { (error, ref) in
                if let error = error {
                    print("Failed to follow:", error)
                    return
                }
                print("Succesfully followed", self.user?.username ?? "")
                self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                self.editProfileFollowButton.backgroundColor = .white
                self.editProfileFollowButton.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    
    
    fileprivate func setupStatsBar() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        addSubview(stackView)
        
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    // Setup edit profile button or follow/unfollow button
    fileprivate func setupEditFollowButton() {
        guard let loggedUserID = Auth.auth().currentUser?.uid else { return }
        guard let userID = user?.uid else { return }
        
        if loggedUserID == userID {
            
        } else {
            // Check if current user already followed or not
            Database.database().reference().child("following").child(loggedUserID).child(userID).observeSingleEvent(of: .value) { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    
                } else {
                    self.setupFollowStyle()
                }
                
            } withCancel: { (error) in
                print("Error:", error)
            }
        }
    }
    
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    // MARK: - Setup Toolbar
    fileprivate func setupToolbar() {
        
        // Stack view
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        addSubview(stackView)
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        // Top divider line
        let topDividerLine = UIView()
        topDividerLine.backgroundColor = .lightGray
        addSubview(topDividerLine)
        topDividerLine.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        // Bottom divider line
        let bottomDividerLine = UIView()
        bottomDividerLine.backgroundColor = .lightGray
        addSubview(bottomDividerLine)
        bottomDividerLine.anchor(top: nil, left: leftAnchor, bottom: stackView.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
