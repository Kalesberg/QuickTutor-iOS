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
    
    let imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.mediaTypes = ["public.image", "public.movie"]
        return picker
    }()

    func handleSendingImage() {
        setupDelegates()
        showActionSheet()
    }
    
    private func setupDelegates() {
        imagePicker.delegate = self
    }
    
    private func showActionSheet() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Take Photo/Video", style: .default, handler: { _ in
            self.imagePicker.sourceType = .camera
            self.parentViewController.present(self.imagePicker, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Choose Media", style: .default, handler: { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.parentViewController.present(self.imagePicker, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        }))
        parentViewController.present(ac, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let url = info[.mediaURL] as? URL {
            uploadVideoToFirebase(url)
        }
        
        guard let imageToUplaod = getImageFromInfoKeys(info) else { return }
        uploadImageToFirebase(image: imageToUplaod) { (imageUrl) in
            self.sendMessage(imageToUplaod, imageUrl: imageUrl)
        }
    }
    
    private func getImageFromInfoKeys(_ info:[UIImagePickerController.InfoKey: Any]) -> UIImage? {
        var image: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        return image
    }

    func uploadImageToFirebase(image: UIImage, completion: @escaping(URL) -> Void) {
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
                completion(imageUrl)
            })
        }
    }
    
    func sendMessage(_ image: UIImage, imageUrl: URL, videoUrl: URL? = nil) {
        DataService.shared.sendImageMessage(imageUrl: imageUrl.absoluteString, imageWidth: image.size.width, imageHeight: image.size.height, receiverId: self.receiverId, completion: {
            
        })
    }
    
    
    func uploadVideoToFirebase(_ url: URL) {
        let childAutoId = NSUUID().uuidString
        let reference = Storage.storage().reference().child("videoMessages").child(childAutoId)
        reference.putFile(from: url, metadata: nil) { (metaData, error) in
            guard let metaData = metaData else { return }
            reference.downloadURL(completion: { (downloadUrl, error) in
                guard let downloadUrl = downloadUrl else { return }
                guard let image = self.getThumbnailForVideoUrl(url) else { return }
                self.uploadImageToFirebase(image: image, completion: { (thumbnailUrl) in
                    DataService.shared.sendVideoMessage(thumbnailUrl: thumbnailUrl, thumbnailWidth: image.size.width, thumbnailHeight: image.size.height, videoUrl: downloadUrl, receiverId: self.receiverId, completion: {
                        
                    })
                })
            })
        }
        
    }
    
    func getThumbnailForVideoUrl(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnail = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            let imageWithCorrectOrientation = fixOrientation(img: UIImage(cgImage: thumbnail))
            return imageWithCorrectOrientation
        } catch {
            return nil
        }
        
    }
    
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
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
