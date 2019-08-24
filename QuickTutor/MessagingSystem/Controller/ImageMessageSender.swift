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
import CropViewController

class ImageMessageSender: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parentViewController: UIViewController!
    var receiverId: String!
    
    let imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
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
        ac.addAction(UIAlertAction(title: "Take Photo/Video", style: .default) { _ in
            self.imagePicker.sourceType = .camera
//            self.imagePicker.videoQuality = .typeHigh
            self.parentViewController.present(self.imagePicker, animated: true, completion: nil)
        })
        ac.addAction(UIAlertAction(title: "Choose Media", style: .default) { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.parentViewController.present(self.imagePicker, animated: true, completion: nil)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        parentViewController.present(ac, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            picker.dismiss(animated: false) {
                let cropViewController = CropViewController(image: image)
                cropViewController.delegate = self
                cropViewController.aspectRatioPreset = .presetSquare
                self.parentViewController.present(cropViewController, animated: true, completion: nil)
            }
        } else if let url = info[.mediaURL] as? URL {
            uploadVideoToFirebase(url)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        self.parentViewController.dismiss(animated: true, completion: nil)
    }

    func uploadImageToFirebase(image: UIImage, completion: @escaping(URL) -> Void) {
        parentViewController.dismiss(animated: true, completion: nil)
        guard let data = image.jpegData(compressionQuality: 0.7) else {
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
        MessageService.shared.sendImageMessage(imageUrl: imageUrl.absoluteString, imageWidth: image.size.width, imageHeight: image.size.height, receiverId: self.receiverId, completion: {
            
        })
    }
    
    
    func uploadVideoToFirebase(_ url: URL) {
        let childAutoId = NSUUID().uuidString
        let reference = Storage.storage().reference().child("videoMessages").child(childAutoId)
        reference.putFile(from: url, metadata: nil) { (metaData, error) in
            guard let _ = metaData else { return }
            reference.downloadURL(completion: { (downloadUrl, error) in
                guard let downloadUrl = downloadUrl else { return }
                guard let image = self.getThumbnailForVideoUrl(url) else { return }
                self.uploadImageToFirebase(image: image, completion: { (thumbnailUrl) in
                    MessageService.shared.sendVideoMessage(thumbnailUrl: thumbnailUrl, thumbnailWidth: image.size.width, thumbnailHeight: image.size.height, videoUrl: downloadUrl, receiverId: self.receiverId, completion: {
                        
                    })
                })
            })
        }
        
    }
    
    func getThumbnailForVideoUrl(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnail = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let imageWithCorrectOrientation = fixOrientation(img: UIImage(cgImage: thumbnail))
            return imageWithCorrectOrientation
        } catch {
            return nil
        }
        
    }
    
    func fixOrientation(img: UIImage) -> UIImage {
        if img.imageOrientation == .up {
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

extension ImageMessageSender: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        uploadImageToFirebase(image: image) { (imageUrl) in
            self.sendMessage(image, imageUrl: imageUrl)
        }
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
