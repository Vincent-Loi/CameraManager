//
//  ViewController.swift
//  camera
//
//  Created by Natalia Terlecka on 10/10/14.
//  Copyright (c) 2014 imaginaryCloud. All rights reserved.
//

import UIKit
import CameraManager

class ViewController: UIViewController {
    
    // MARK: - Constants

    let cameraManager = CameraManager()
    
    // MARK: - @IBOutlets

    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var flashModeButton: UIButton!
    
    @IBOutlet weak var askForPermissionsButton: UIButton!
    @IBOutlet weak var askForPermissionsLabel: UILabel!
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraManager.showAccessPermissionPopupAutomatically = false
        
        askForPermissionsButton.isHidden = true
        askForPermissionsLabel.isHidden = true

        let currentCameraState = cameraManager.currentCameraStatus()
        
        if currentCameraState == .notDetermined {
            askForPermissionsButton.isHidden = false
            askForPermissionsLabel.isHidden = false
        } else if (currentCameraState == .ready) {
            addCameraToView()
        }
        if !cameraManager.hasFlash {
            flashModeButton.isEnabled = false
            flashModeButton.setTitle("No flash", for: UIControl.State())
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        cameraManager.resumeCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopCaptureSession()
    }
    
    
    // MARK: - ViewController
    
    fileprivate func addCameraToView()
    {
        cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: CameraOutputMode.videoWithMic)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
        
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) -> Void in  }))
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - @IBActions

    @IBAction func changeFlashMode(_ sender: UIButton)
    {
        switch (cameraManager.changeFlashMode()) {
        case .off:
            sender.setTitle("Flash Off", for: UIControl.State())
        case .on:
            sender.setTitle("Flash On", for: UIControl.State())
        case .auto:
            sender.setTitle("Flash Auto", for: UIControl.State())
        }
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        
        switch (cameraManager.cameraOutputMode) {
        case .stillImage:
            cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
                if let errorOccured = error {
                    self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
                }
                else {
                    let vc: ImageViewController? = self.storyboard?.instantiateViewController(withIdentifier: "ImageVC") as? ImageViewController
                    if let validVC: ImageViewController = vc {
                        if let capturedImage = image {
                            validVC.image = capturedImage
                            self.navigationController?.pushViewController(validVC, animated: true)
                        }
                    }
                }
            })
        case .videoWithMic, .videoOnly:
            sender.isSelected = !sender.isSelected
            sender.setTitle(" ", for: .selected)
            sender.backgroundColor = sender.isSelected ? UIColor.red : UIColor.green
            if sender.isSelected {
                cameraManager.startRecordingVideo()
            } else {
                cameraManager.stopVideoRecording({ (videoURL, error) -> Void in
                    if let errorOccured = error {                        
                        self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
                    }
                })
            }
        }
    }
    
    @IBAction func outputModeButtonTapped(_ sender: UIButton) {
        
        cameraManager.cameraOutputMode = cameraManager.cameraOutputMode == CameraOutputMode.videoWithMic ? CameraOutputMode.stillImage : CameraOutputMode.videoWithMic
        switch (cameraManager.cameraOutputMode) {
        case .stillImage:
            cameraButton.isSelected = false
            cameraButton.backgroundColor = UIColor.green
            sender.setTitle("Image", for: UIControl.State())
        case .videoWithMic, .videoOnly:
            sender.setTitle("Video", for: UIControl.State())
        }
    }
    
    @IBAction func changeCameraDevice(_ sender: UIButton) {
        
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
        switch (cameraManager.cameraDevice) {
        case .front:
            sender.setTitle("Front", for: UIControl.State())
        case .back:
            sender.setTitle("Back", for: UIControl.State())
        }
    }
    
    @IBAction func askForCameraPermissions(_ sender: UIButton) {
        
        cameraManager.askUserForCameraPermission({ permissionGranted in
            self.askForPermissionsButton.isHidden = true
            self.askForPermissionsLabel.isHidden = true
            self.askForPermissionsButton.alpha = 0
            self.askForPermissionsLabel.alpha = 0
            if permissionGranted {
                DispatchQueue.main.async { [weak self] in
                    self?.addCameraToView()
                }
            }
        })
    }
    
    @IBAction func changeCameraQuality(_ sender: UIButton) {
        
        switch (cameraManager.changeQualityMode()) {
        case .preset1280:
            sender.setTitle("1280", for: UIControl.State())
        case .high:
            sender.setTitle("High", for: UIControl.State())
        case .low:
            sender.setTitle("Low", for: UIControl.State())
        case .medium:
            sender.setTitle("Medium", for: UIControl.State())
        }
    }
}


