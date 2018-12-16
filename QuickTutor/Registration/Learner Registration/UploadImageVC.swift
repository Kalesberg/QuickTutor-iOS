//
//  UploadImage.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseAuth

class UploadImageVC: BaseRegistrationController {
    
    let profilePicker = UIImagePickerController()
    var imagePicked: Bool = false
    var chosenImage: UIImage?
    
    let contentView: UploadImageVCView = {
        let view = UploadImageVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        setupAccessoryView()
        profilePicker.delegate = self
        profilePicker.allowsEditing = false
    }
    
    func setupAccessoryView() {
        contentView.addSubview(accessoryView)
        accessoryView.anchor(top: nil, left: contentView.leftAnchor, bottom: contentView.getBottomAnchor(), right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 80)
    }
    
    func setupTargets() {
        contentView.choosePhotoButton.addTarget(self, action: #selector(choosePhoto), for: .touchUpInside)
        contentView.takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        accessoryView.nextButton.addTarget(self, action: #selector(saveImageAndContinue), for: .touchUpInside)
    }
    
    @objc func choosePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            profilePicker.sourceType = .photoLibrary
            profilePicker.allowsEditing = true
            self.present(profilePicker, animated: true, completion: nil)
        } else {
            AlertController.genericErrorAlert(self, title: "Oops", message: "Photo Library is not available")
        }
    }
    
    @objc func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            profilePicker.sourceType = UIImagePickerController.SourceType.camera
            profilePicker.cameraCaptureMode =  UIImagePickerController.CameraCaptureMode.photo
            profilePicker.modalPresentationStyle = .custom
            self.present(profilePicker,animated: true, completion: nil)
        } else {
            AlertController.genericErrorAlert(self, title: "Oops", message: "Camera is not available at this time.")
        }
    }
    
    @objc func saveImageAndContinue() {
        if imagePicked {
            displayLoadingOverlay()
            guard let image = chosenImage else { return }
            guard let data = FirebaseData.manager.getCompressedImageDataFor(image) else {
                AlertController.genericErrorAlert(self, title: "Error", message: "Please choose a new photo")
                return
            }
            Registration.imageData = data
            navigationController?.pushViewController(UserPolicyVC(), animated: true)
        } else {
            AlertController.genericErrorAlert(self, title: "Please Select A Photo", message: "")
        }
    }
    
}

extension UploadImageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            imagePicked = true
            chosenImage = image
            contentView.imageView.image = image
            imagePicked = true
            
            profilePicker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicked = false
        let image = UIImage(named: "uploadImageDefaultImage")
        contentView.imageView.image = image
        DispatchQueue.main.async {
            self.profilePicker.dismiss(animated: true, completion: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
