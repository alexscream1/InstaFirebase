//
//  CommentsController.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 14.03.2021.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController {
    
    let cellID = "cellID"
    var post: Posts?
    var comments = [Comments]()
    
        
    lazy var containerView: CommentAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let inputAccessoryView = CommentAccessoryView(frame: frame)
        inputAccessoryView.delegate = self
        return inputAccessoryView
    }()
    
    
    // MARK: - CommentsController lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        collectionView.backgroundColor = .white
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellID)
        
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // Showing accessory view of container view
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    // Accessory view become first responder
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    fileprivate func fetchComments() {
        guard let postID = post?.id else { return }
        
        let ref = Database.database().reference().child("comments").child(postID)
        ref.observe(.childAdded) { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let userID = dictionary["userID"] as? String else { return }
            
            Database.fetchUserWithUID(uid: userID) { (user) in
                let comment = Comments(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
            }
        } withCancel: { (error) in
            print("Failed to fetch comments", error)
        }

    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        return cell
    }
     
}
// MARK: UICollectionViewDelegateFlowLayout

extension CommentsController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Create auto size comment cell
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let myCell = CommentCell(frame: frame)
        myCell.comment = comments[indexPath.item]
        
        // Lays out the subviews immediately, if layout updates are pending.
        myCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        
        // Returns the optimal size of the view based on its current constraints.
        let estimatedSize = myCell.systemLayoutSizeFitting(targetSize)
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
}

// MARK: UITextFieldDelegate

extension CommentsController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - CommentAccessoryViewDelegate

extension CommentsController: CommentAccessoryViewDelegate {
    func didSubmit(for comment: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let postID = post?.id else { return }
        
        let values = ["text": comment, "creationDate": Date().timeIntervalSince1970, "userID": userID] as [String : Any]
        
        Database.database().reference().child("comments").child(postID).childByAutoId().updateChildValues(values) { (error, ref) in
            
            if let error = error {
                print("Failed to insert comment", error)
                return
            }
            
            print("Succesfully insert comment")
            self.containerView.clearCommentTextfield()
        }
    }
}
