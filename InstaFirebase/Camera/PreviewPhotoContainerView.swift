//
//  PreviewPhotoContainerView.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 14.03.2021.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {

    let previewImageView : UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .blue
        return iv
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "save_shadow"), for: .normal)
        button.addTarget(self, action: #selector(handleSaveImage), for: .touchUpInside)
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancel_shadow"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews() {
        // Preview image view
        addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        // Save button
        addSubview(saveButton)
        saveButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 0, width: 60, height: 60)
        
        // Cancel button
        addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
    }
    
    // Save taken picture to library
    @objc func handleSaveImage() {
        let library = PHPhotoLibrary.shared()
        
        guard let previewImage = previewImageView.image else { return }
        
        library.performChanges {
            
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
            
        } completionHandler: { (result, error) in
            if let error = error {
                print("Failed to save image to library: ", error)
                return
            }
            print("Succesfully saved image to library")
            
            // Label with animation when succesfully save image
            DispatchQueue.main.async {
                let saveLabel = UILabel()
                saveLabel.text = "Saved Succesfully"
                saveLabel.font = UIFont.boldSystemFont(ofSize: 17)
                saveLabel.textAlignment = .center
                saveLabel.numberOfLines = 0
                saveLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                saveLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                saveLabel.center = self.center
                self.addSubview(saveLabel)
                
                saveLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    
                    saveLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                } completion: { (completed) in
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                         
                        saveLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        
                    } completion: { (completed) in
                        saveLabel.removeFromSuperview()
                    }

                }
            }
        }

    }
    
    // Return back to camera view
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
