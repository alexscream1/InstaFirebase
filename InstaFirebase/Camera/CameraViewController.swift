//
//  CameraViewController.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 14.03.2021.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    // A capture output for still image, Live Photo, and other photography workflows.
    let output = AVCapturePhotoOutput()
    
    
    // Create photo button
    let photoButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "capture_photo"), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    // Create return button
    let returnButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "right_arrow_shadow"), for: .normal)
        button.addTarget(self, action: #selector(handleReturn), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupButtons()
        setupCaptureSession()
    }
    
    // Return to home page action
    @objc func handleReturn() {
        dismiss(animated: true, completion: nil)
    }
    
    // Make photo action
    @objc func handleCapturePhoto() {
        
        // A specification of the features and settings to use for a single photo capture request.
        let settings = AVCapturePhotoSettings()
        
        // An array of available PixelFormatTypeKeys to specify a preview photo format.
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
        
        // A dictionary describing the format for delivery of preview-sized images
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        
        // Initiates a photo capture using the specified settings.
        output.capturePhoto(with: settings, delegate: self)
    }
    
    fileprivate func setupButtons() {
        // Return to home page button
        view.addSubview(returnButton)
        returnButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 60, height: 60)
        
        // Make photo button
        view.addSubview(photoButton)
        photoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 25, paddingRight: 0, width: 80, height: 80)
        photoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    
    // Create Capture session
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        // Setup input
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            // Wrap the device in a capture device input.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // If the input can be added, add it to the session.
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let error {
            // Configuration failed. Handle error.
            print("Could not setup camera input", error)
        }
        
    
        // Setup output
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        // Setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
    
        captureSession.startRunning()
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        // Generates and returns a flat data representation of the photo and its attachments.
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        // Save received image data
        let previewImage = UIImage(data: imageData)
        
        let containerView = PreviewPhotoContainerView()
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        containerView.previewImageView.image = previewImage
        
    }
}
