//
//  UserSearchController.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 13.03.2021.
//

import UIKit
import Firebase

private let cellID = "cellID"

class UserSearchController: UICollectionViewController {

    var filteredUsers = [User]()
    var users = [User]()
    
    lazy var searchBar : UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.searchTextField.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        sb.delegate = self
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .white
        
        self.collectionView!.register(UserSearchCell.self, forCellWithReuseIdentifier: cellID)
        
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(searchBar)
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        // Allows to scroll collection view even with small amount of items
        collectionView.alwaysBounceVertical = true
        
        collectionView.keyboardDismissMode = .onDrag
        
        fetchUsers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchBar.isHidden = false
    }
    
    fileprivate func fetchUsers() {
        
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach { (key, value) in
                guard let userDict = value as? [String: Any] else { return }
                
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                
                let user = User(uid: key, dict: userDict)
                self.users.append(user)
            }
            
            self.users = self.users.sorted(by: { (u1, u2) -> Bool in
                return u1.username < u2.username
            })
            self.filteredUsers = self.users
            self.collectionView.reloadData()
            
        } withCancel: { (error) in
            print("Failed to fetch users", error)
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filteredUsers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserSearchCell
        
        cell.user = filteredUsers[indexPath.item]
    
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let user = filteredUsers[indexPath.item]
        
        let userProfileController = UserProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userID = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
        
    }

}


// MARK: - UICollectionViewDelegateFlowLayout

extension UserSearchController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}

extension UserSearchController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter({ (user) -> Bool in
                user.username.lowercased().contains(searchText.lowercased())
            })
        }
        collectionView.reloadData()
    }
}
