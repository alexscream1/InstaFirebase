//
//  PhotoSelectionController.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 11.03.2021.
//

import UIKit
import Photos

class PhotoSelectionController : UICollectionViewController {
    
    let cellID = "cellID"
    let headerID = "headerID"
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage : UIImage?
    var header : PhotoSelectionHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        
        collectionView.register(PhotoSelectionCell.self, forCellWithReuseIdentifier: cellID)
        
        collectionView.register(PhotoSelectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)
        
        
        setupNavBarItems()
        fetchPhotos()
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Setup navigation bar items
    fileprivate func setupNavBarItems() {
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    // Left button selector
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // Right button selector
    @objc func handleNext() {
        let sharePhotoVC = SharePhotoViewController()
        sharePhotoVC.selectedImage = self.header?.photoImageView.image
        navigationController?.pushViewController(sharePhotoVC, animated: true)
    }
    
    
    // Fetch photos options function
    fileprivate func fetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 10
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    // Fetch photos function
    fileprivate func fetchPhotos() {
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions())
        
        // Request photos in background async thread with low resolution
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    // MARK: - UICollectionViewDelegate
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Add selected image to selectedImage variable and reload collection view to show it on header
        self.selectedImage = images[indexPath.item]
        self.collectionView.reloadData()
        
        // Scroll to the top when selected image
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    // Number of sections
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Number of items
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    // Create colletion view items
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoSelectionCell
    
        cell.photoImageView.image = images[indexPath.item]
        
        return cell
    }
    
    // Create section header for showing selected image
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! PhotoSelectionHeader
        
        // Save header to variable header for passing to the next screen
        self.header = header
        
        // Showing selected image in header with low resolution
        header.photoImageView.image = selectedImage
        
        // Request only selected image with high resolution, to reduce time of downloading all images
        if let selectedImage = self.selectedImage {
            if let index = self.images.firstIndex(of: selectedImage) {
                let selectedAsset = assets[index]
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
            
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    
                    // Showing selected image in header with high resolution
                    header.photoImageView.image = image
                }
            }
        }
        return header
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoSelectionController: UICollectionViewDelegateFlowLayout {
    // Size for section header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    // Size for each collection view item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    // Line Spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // InterItem Spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // Inset for section to create indent from top
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
}
