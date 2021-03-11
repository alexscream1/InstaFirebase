//
//  SharePhotoViewController.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 11.03.2021.
//

import UIKit
import Firebase

class SharePhotoViewController: UIViewController {
    
    
    var selectedImage : UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(sharePhoto))
        
        setupImageAndTextViews()
    }
    
    @objc func sharePhoto() {
        guard let text = textView.text, text.count > 0 else { return }
        guard let image = selectedImage else { return }
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        let storageItem = Storage.storage().reference().child("posts").child(filename)
        storageItem.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload data", error)
                return
            }
            
            storageItem.downloadURL { (url, error) in
                if let error = error {
                    print("Failed to get URL", error)
                    return
                }
                
                guard let uploadImageURL = url?.absoluteString else { return }
                
                print("Succesfully upload data", uploadImageURL)
                
                self.saveToDatabaseWithImageURL(imageURL: uploadImageURL)
            }
        }
    }
    
    fileprivate func saveToDatabaseWithImageURL(imageURL: String) {
        
        guard let text = textView.text else { return }
        guard let postImage = selectedImage else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostsRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostsRef.childByAutoId()
        
        let values = ["imageURL": imageURL, "text": text, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (error, ref) in
            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("failed to add to db", error)
                return
            }
            print("Succesfully add to db")
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    
    let imageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    // Setup view with selected image and text view to fill up, before sharing photo
    fileprivate func setupImageAndTextViews() {
        
        // Container view
        let containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        // Image view
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        // Text view
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    

}
