//
//  ImageMessageSender.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import AVFoundation
import Firebase
import UIKit

class ImageMessageSender: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parentViewController: UIViewController!
    var receiverId: String!
    let imagePicker = UIImagePickerController()

    func handleSendingImage() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.imagePicker.sourceType = .camera
            self.parentViewController.present(self.imagePicker, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.parentViewController.present(self.imagePicker, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        }))
        parentViewController.present(ac, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        var image: UIImage?
        if let editedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            image = editedImage
        } else if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            image = originalImage
        }
        guard let imageToUplaod = image else { return }
        uploadImageToFirebase(image: imageToUplaod)
    }

    func uploadImageToFirebase(image: UIImage) {
        parentViewController.dismiss(animated: true, completion: nil)
        guard let data = image.jpegData(compressionQuality: 0.2) else {
            return
        }
        let imageName = NSUUID().uuidString

        let metaDataDictionary = ["width": image.size.width, "height": image.size.height]
        let metaData = StorageMetadata(dictionary: metaDataDictionary)

        let storageRef = Storage.storage().reference().child(imageName)

        storageRef.putData(data, metadata: metaData) { _, _ in
            storageRef.downloadURL(completion: { url, error in
                if error != nil {
                    print(error.debugDescription)
                }
                guard let imageUrl = url else { return }
                DataService.shared.sendImageMessage(imageUrl: imageUrl.absoluteString, imageWidth: image.size.width, imageHeight: image.size.height, receiverId: self.receiverId, completion: {

                })
            })
        }
    }

    func proceedWithCameraAccess() -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            return true
        } else {
            let alert = UIAlertController(title: "Allow Access to Camera", message: "Camera access is required for this feature.", preferredStyle: .alert)

            // Add "OK" Button to alert, pressing it will bring you to the settings app
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            // Show the alert with animation
            parentViewController.present(alert, animated: true)
            return false
        }
    }

    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
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
