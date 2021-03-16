//
//  LikesController.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 16.03.2021.
//

import UIKit
import Firebase

private let cellID = "cellID"

class LikesController: UICollectionViewController {

    var likedPosts = [Posts]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .white

        // Register cell classes
        self.collectionView!.register(LikesCell.self, forCellWithReuseIdentifier: cellID)
        
        // Allows to scroll collection view even with small amount of items
        collectionView.alwaysBounceVertical = true
        
        navigationItem.title = "Likes"
        
        fetchCurrentUserPosts()
        
        
        // Refresh control for updating likes page
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        likedPosts.removeAll()
        fetchCurrentUserPosts()
    }
    
    
    fileprivate func fetchCurrentUserPosts() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: userID) { (user) in
            let ref = Database.database().reference().child("posts").child(userID)
            ref.observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionaries = snapshot.value as? [String: Any] else { return }

                dictionaries.forEach { (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    
                    self.fetchLikes(key: key, dictionary: dictionary)
                }
            } withCancel: { (error) in
                print("Failed to fetch posts", error)
            }
        }
        
    }
    
    fileprivate func fetchLikes(key: String, dictionary: [String: Any]) {
        Database.database().reference().child("likes").child(key).observeSingleEvent(of: .value) { (snapshot) in
            
            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let dict = snapshot.value as? [String: Int] else { return }
            dict.forEach { (key, value) in
                if value == 1 {
                    Database.fetchUserWithUID(uid: key) { (user) in
                        let post = Posts(user: user, dictionary: dictionary)
                        self.likedPosts.append(post)
    
                        self.collectionView?.reloadData()
                    }
                }
            }
        } withCancel: { (error) in
            print("Error", error)
        }

    }
    


    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedPosts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! LikesCell
        
        cell.likedPost = likedPosts[indexPath.item]
        
        return cell
    }


}

// MARK: - UICollectionViewDelegateFlowLayout

extension LikesController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
