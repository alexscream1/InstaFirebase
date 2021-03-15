//
//  HomePageController.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 12.03.2021.
//

import UIKit
import Firebase

private let cellID = "cellID"

class HomePageController: UICollectionViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        self.collectionView?.register(HomePageCell.self, forCellWithReuseIdentifier: cellID)
        
        // Refresh control for updating home page
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        // Notification observer to observe when new photo added and update home page
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: SharePhotoViewController.updateFeedNotificationName, object: nil)
        
        setupNavigationItems()
        fetchAllPosts()
    }
    
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchPost()
        fetchFollowingUsersID()
    }
    
    var posts = [Posts]()
    fileprivate func fetchPost() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostWithUser(user: User) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            
            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }

            dictionaries.forEach { (key, value) in
                guard let dictionary = value as? [String: Any] else { return }

                var post = Posts(user: user, dictionary: dictionary)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value) { (snapshot) in
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLike = true
                    } else {
                        post.hasLike = false
                    }
                    self.posts.append(post)
                    
                    // Sort posts in home page by creation date
                    self.posts.sort { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    }
                    
                    self.collectionView?.reloadData()
                    
                } withCancel: { (error) in
                    print("Failed to fetch user likes")
                }
            }
        } withCancel: { (error) in
            print("Failed to fetch posts", error)
        }
    }
    
    fileprivate func fetchFollowingUsersID() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let usersDict = snapshot.value as? [String: Any] else { return }
            
            usersDict.forEach { (key, value) in
                Database.fetchUserWithUID(uid: key) { (user) in
                    self.fetchPostWithUser(user: user)
                }
            }
            
        } withCancel: { (error) in
            print("Failed")
        }

    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "camera3"), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    @objc func handleCamera() {
        let cameraController = CameraViewController()
        cameraController.modalPresentationStyle = .fullScreen
        present(cameraController, animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomePageCell
        
        if posts.count > 0 {
            cell.post = posts[indexPath.item]
        }
        
        cell.delegate = self
        
        return cell
    }

}


// MARK: - UICollectionViewDelegateFlowLayout

extension HomePageController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height :  CGFloat = 40 + 8 + 8
        height += view.frame.width
        height += 50
        height += 60
        return CGSize(width: view.frame.width, height: height)
    }
}

extension HomePageController: HomePageCellDelegate {
    func didTapComment(post: Posts) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didTapLike(for cell: HomePageCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        var post = posts[indexPath.item]
        guard let postID = post.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = [uid: post.hasLike == true ? 0 : 1]
        
        // Save like to database
        Database.database().reference().child("likes").child(postID).updateChildValues(values) { (error, _) in
            if let error = error {
                print("Failed to save like:", error)
            }
            
            post.hasLike = !post.hasLike
            self.posts[indexPath.item] = post
            self.collectionView?.reloadItems(at: [indexPath])
        }
        
    }
}
