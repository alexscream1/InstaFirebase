//
//  MainTabBarController.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 09.03.2021.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
                
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        setupViewControllers()
    }
    
    func setupViewControllers() {
        
        let layout = UICollectionViewFlowLayout()
        tabBar.tintColor = .black
        
        // Home page
        let homeNavController = templateNavController(image: "home", rootViewController: UserProfileCollectionViewController(collectionViewLayout: layout))
        
        // Search page
        let searchNavController = templateNavController(image: "search")
        
        // Add page
        let addNavController = templateNavController(image: "add")
        
        
        // Likes page
        let likesNavController = templateNavController(image: "heart")
        
        
        // User profile page
        
        let userProfileController = UserProfileCollectionViewController(collectionViewLayout: layout)
        let userNavController = UINavigationController(rootViewController: userProfileController)
        userNavController.tabBarItem.image = #imageLiteral(resourceName: "user")
        
        
        viewControllers = [homeNavController,
                           searchNavController,
                           addNavController,
                           likesNavController,
                           userNavController]
        
        
        // Adjust tab bar items insets
        guard let items = tabBar.items else { return }
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        }
    }
    
    fileprivate func templateNavController(image: String, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = UIImage(named: image)
        return navController
    }
    

}


extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            let layout = UICollectionViewFlowLayout()
            let photoSelectionController = PhotoSelectionController(collectionViewLayout: layout)
            let navController = UINavigationController(rootViewController: photoSelectionController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
}
