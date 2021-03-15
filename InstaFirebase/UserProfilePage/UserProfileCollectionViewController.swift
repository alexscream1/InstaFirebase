//
//  UserProfileCollectionViewController.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 09.03.2021.
//

import UIKit
import Firebase


class UserProfileCollectionViewController: UICollectionViewController {

    let headerID = "headerID"
    let cellID = "cellID"
    let homePageCellID = "homePageCellID"
    var user: User?
    var posts = [Posts]()
    var userID: String?
    
    var isGridView = true
    var isFinishPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        self.collectionView!.register(UserProfileCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)
        collectionView.register(HomePageCell.self, forCellWithReuseIdentifier: homePageCellID)
        
        collectionView.backgroundColor = .white
        
        fetchUser()
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout))
    }
    
    
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Log out", style: .destructive) { (logout) in
            do {
                // Sign out
                try Auth.auth().signOut()
                // Present LoginViewController
                let loginController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
            } catch let errorSignOut {
                print("Failed to sign out:", errorSignOut)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Get username for User Profile Title
    fileprivate func fetchUser() {
        
        guard let uid = userID ?? Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
    
            self.paginatePosts()
        }
    }
    
    fileprivate func paginatePosts() {
       
        guard let uid = self.user?.uid else { return }
        
        let ref = Database.database().reference().child("posts").child(uid)
        
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0 {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in
    
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < 4 {
                self.isFinishPaging = true
            }
            
            if self.posts.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                
                guard let dict = snapshot.value as? [String: Any] else { return }
                guard let user = self.user else { return }
                
                var post = Posts(user: user, dictionary: dict)
                post.id = snapshot.key
                
                self.posts.append(post)
                
            })
            
            self.posts.forEach { (post) in
                print(post.id ?? "")
            }
            
            self.collectionView.reloadData()
            
        } withCancel: { (error) in
            print("Failed to paginate posts", error)
        }

        
    }
    
    fileprivate func fetchOrderedPosts() {
        
        guard let uid = self.user?.uid else { return }
        
        let ref = Database.database().reference().child("posts").child(uid)
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            guard let user = self.user else { return }
            let post = Posts(user: user, dictionary: dictionary)
            self.posts.insert(post, at: 0)
            self.collectionView.reloadData()
            
        } withCancel: { (error) in
            print("failed to fetch posts:", error)
        }

    }
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == posts.count - 1 && !isFinishPaging {
            paginatePosts()
        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserProfileCell
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePageCellID, for: indexPath) as! HomePageCell
            cell.post = posts[indexPath.item]
            return cell
        }
        
    }
    
    // Create user profile header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.delegate = self
        return header
    }
    
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UserProfileCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            var height :  CGFloat = 40 + 8 + 8
            height += view.frame.width
            height += 50
            height += 60
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // Header size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
}

// MARK: - UserProfileHeaderDelegate

extension UserProfileCollectionViewController: UserProfileHeaderDelegate {
    func didChangeToGridView() {
        isGridView = true
        self.collectionView.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        self.collectionView.reloadData()
    }
}


