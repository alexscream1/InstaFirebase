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

                let post = Posts(user: user, dictionary: dictionary)
                
                self.posts.append(post)
            }
            
            // Sort posts in home page by creation date
            self.posts.sort { (p1, p2) -> Bool in
                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
            }
            
            self.collectionView?.reloadData()

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
