//
//  ImageMessageSender.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class ImageMessageSender: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var parentViewController: UIViewController!
    var receiverId: String!
    
    func handleSendingImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            imagePicker.sourceType = .camera
            self.parentViewController.present(imagePicker, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            imagePicker.sourceType = .photoLibrary
            self.parentViewController.present(imagePicker, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        }))
        parentViewController.present(ac, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var image: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = originalImage
        }
        guard let imageToUplaod = image else { return }
        DataService.shared.uploadImageToFirebase(image: imageToUplaod) { imageUrl in
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let timestamp = Date().timeIntervalSince1970
            let message = UserMessage(dictionary: ["imageUrl": imageUrl, "timestamp": timestamp, "senderId": uid, "receiverId": self.receiverId])
            message.data["imageWidth"] = image?.size.width
            message.data["imageHeight"] = image?.size.width
            self.sendMessage(message: message)
        }
    }
    
    func sendMessage(message: UserMessage) {
        if let url = message.imageUrl {
            DataService.shared.sendImageMessage(imageUrl: url, imageWidth: message.data["imageWidth"] as! CGFloat, imageHeight: message.data["imageHeight"] as! CGFloat, receiverId: receiverId, completion: {
            })
            return
        }
    }
    
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
    
}
