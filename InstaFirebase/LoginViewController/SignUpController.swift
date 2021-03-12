//
//  ViewController.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 09.03.2021.
//

import UIKit
import Firebase

class SignUpController: UIViewController {
    
    // Create plusPhotoButton
    let plusPhotoButton : UIButton = {
        let button = UIButton(type: .system)
        let imageButton = UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal)
        button.contentMode = .scaleAspectFill
        button.setImage(imageButton, for: .normal)
        button.addTarget(self, action: #selector(choosePhoto), for: .touchUpInside)
        return button
    }()
    
    // Choose photo function
    @objc func choosePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // Email Textfield
    
    let emailTextField : UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.placeholder = "Email"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    // Username Textfield
    
    let usernameTextField : UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.placeholder = "Username"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    // Password Textfield
    
    let passwordTextField : UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        
        // AlreadyHaveAccountButton
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 50)
        
        // PlusPhotoButton
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 80, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupSignUpFields()
        
    }
    
    
    // Check if all text fields are filled up
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedText = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedText.append(NSAttributedString(string: "Log in.", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(alreadyHaveAccountButtonPressed), for: .touchUpInside)
        return button
    }()
    
    @objc func alreadyHaveAccountButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // Sign Up Button
    let signUpButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        button.isEnabled = false
        
        return button
    }()
    
    @objc func handleSignUp() {
        
        guard let email = emailTextField.text, email.count > 0 else { return }
        guard let password = passwordTextField.text, password.count > 0 else { return }
        guard let username = usernameTextField.text, username.count > 0 else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user: AuthDataResult?, error: Error?) in
            if let err = error {
                print("Failed to create user:", err)
                return
            }
            
            print("Succesfully create user:", user?.user.uid ?? "")
            
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
            
            
            let filename = NSUUID().uuidString
            let storageItem = Storage.storage().reference().child("profile_images").child(filename)
            storageItem.putData(uploadData, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("Failed to upload profile photo:", err)
                    return
                }
                print("Succesfully upload profile photo")
                storageItem.downloadURL { (url, error) in
                    if let error = error {
                        print("Error: ", error)
                        return
                    }
                    
                    guard let profileImageURL = url?.absoluteString else { return }
                        print("Profile image URL: ", profileImageURL)
                    
                    guard let uid = user?.user.uid else { return }
                    let dictValues = ["username": username, "profileImageURL": profileImageURL]
                    let values = [uid: dictValues]
                    Database.database().reference().child("users").updateChildValues(values) { (err, ref) in

                        if let err = err {
                            print("Failed to save user info into db", err)
                            return
                        }
                        print("Succesfully save user info to db")
                        guard let mainTabBarController = UIApplication.shared.windows[0].rootViewController as? MainTabBarController else { return }
                        mainTabBarController.setupViewControllers()
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                    
            }
        }
    }


    fileprivate func setupSignUpFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        // Stackview constraints
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }
}

// Extension for UIImagePickerController
extension SignUpController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        
        dismiss(animated: true, completion: nil)
    }
    
}


