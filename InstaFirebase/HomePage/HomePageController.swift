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
    
    var posts = [Posts]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        self.collectionView!.register(HomePageCell.self, forCellWithReuseIdentifier: cellID)
        
        
        setupNavigationItems()
        
        fetchPost()
    }
    
    
    fileprivate func fetchPost() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostWithUser(user: user)
        }
    }

    fileprivate func fetchPostWithUser(user: User) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }

            dictionaries.forEach { (key, value) in
                guard let dictionary = value as? [String: Any] else { return }

                let post = Posts(user: user, dictionary: dictionary)
                
                self.posts.append(post)
            }
            self.collectionView.reloadData()

        } withCancel: { (error) in
            print("Failed to fetch posts", error)
        }
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomePageCell
    
        cell.post = posts[indexPath.item]
    
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
