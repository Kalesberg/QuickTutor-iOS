//
//  UploadImage.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseAuth
import CropViewController

class UploadImageVC: BaseRegistrationController {
    
    let profilePicker = UIImagePickerController()
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
        progressView.setProgress(5/5)
    }
    
    func setupAccessoryView() {
        contentView.addSubview(accessoryView)
        accessoryView.anchor(top: nil, left: contentView.leftAnchor, bottom: contentView.getBottomAnchor(), right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 80)
        accessoryView.nextButton.setTitle("SAVE", for: .normal)
        accessoryView.nextButton.isEnabled = false
        accessoryView.nextButton.backgroundColor = Colors.gray
    }
    
    func setupTargets() {
        contentView.imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapUserAvatar))
        contentView.imageView.addGestureRecognizer(tap)
        
        accessoryView.nextButton.addTarget(self, action: #selector(saveImageAndContinue), for: .touchUpInside)
    }
    
    @objc
    private func onTapUserAvatar() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Camera roll", style: .default) { _ in
            self.choosePhoto()
        })
        sheet.addAction(UIAlertAction(title: "Take a photo", style: .default) { _ in
            self.takePhoto()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(sheet, animated: true, completion: nil)
    }
    
    private func choosePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            profilePicker.sourceType = .photoLibrary
            profilePicker.allowsEditing = false
            present(profilePicker, animated: true, completion: nil)
        } else {
            AlertController.genericErrorAlert(self, title: "Oops", message: "Photo Library is not available")
        }
    }
    
    private func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            profilePicker.sourceType = .camera
            profilePicker.cameraCaptureMode = .photo
            profilePicker.modalPresentationStyle = .custom
            present(profilePicker, animated: true, completion: nil)
        } else {
            AlertController.genericErrorAlert(self, title: "Oops", message: "Camera is not available at this time.")
        }
    }
    
    @objc func saveImageAndContinue() {
        guard let image = chosenImage else { return }
        guard let data = FirebaseData.manager.getCompressedImageDataFor(image) else {
            AlertController.genericErrorAlert(self, title: "Error", message: "Please choose a new photo")
            return
        }
        Registration.imageData = data
        navigationController?.pushViewController(UserPolicyVC(), animated: true)
    }
    
}

extension UploadImageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        
        picker.dismiss(animated: false) {
            let cropViewController = CropViewController(croppingStyle: .circular, image: image)
            cropViewController.delegate = self
            cropViewController.aspectRatioPreset = .presetSquare
            self.present(cropViewController, animated: false, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UploadImageVC: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        chosenImage = image
        contentView.infoView.isHidden = true
        contentView.imageView.image = image
        contentView.imageView.layer.borderWidth = 0 // remove border
        accessoryView.nextButton.isEnabled = true
        accessoryView.nextButton.backgroundColor = Colors.purple
        
        if let viewController = cropViewController.children.first {
            viewController.modalTransitionStyle = .coverVertical
            viewController.dismiss(animated: true, completion: nil)
        }
    }
    
}
