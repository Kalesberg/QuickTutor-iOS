//
//  AlertController.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit
import EventKit
import MobileCoreServices

class AlertController : NSObject {
	
	class func cropImageAlert(_ viewController: UIViewController, imagePicker: UIImagePickerController, allowsEditing: Bool) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let takePhoto = UIAlertAction(title: "Camera roll", style: .default) { _ in
			if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePicker.sourceType = .photoLibrary
				imagePicker.allowsEditing = allowsEditing
                imagePicker.mediaTypes = [kUTTypeImage as String]
				viewController.present(imagePicker, animated: true, completion: nil)
			} else {
				AlertController.genericErrorAlert(viewController, title: "Oops", message: "Camera is not available at this time.")
			}
		}
        let chooseExisting = UIAlertAction(title: "Take a photo", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                viewController.present(imagePicker, animated: true, completion: nil)
            } else {
                AlertController.genericErrorAlert(viewController, title: "Oops", message: "Photo Library is not available")
            }
        }
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		alertController.addAction(chooseExisting)
		alertController.addAction(takePhoto)
		alertController.addAction(cancel)
		
		viewController.present(alertController, animated: true, completion: nil)
	}
	class func cropImageWithRemoveAlert(_ viewController: UIViewController, imagePicker: UIImagePickerController,_ completion: @escaping (Bool) -> Void) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let chooseExisting = UIAlertAction(title: "Choose Existing", style: .default) { (alert) in
			if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
				imagePicker.sourceType = .photoLibrary
				imagePicker.allowsEditing = false
                imagePicker.mediaTypes = [kUTTypeImage as String]
				viewController.present(imagePicker, animated: true, completion: nil)
			} else {
				AlertController.genericErrorAlert(viewController, title: "Oops", message: "Photo Library is not available")
			}
			completion(false)
		}
		let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert) in
			if UIImagePickerController.isSourceTypeAvailable(.camera) {
				imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
				imagePicker.modalPresentationStyle = .custom
				
				viewController.present(imagePicker,animated: true, completion: nil)
			} else {
				AlertController.genericErrorAlert(viewController, title: "Oops", message: "Camera is not available at this time.")
			}
			completion(false)
		}
		
		let remove = UIAlertAction(title: "Remove", style: .destructive) { (alert) in
			completion(true)
		}
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
			completion(false)
		}
		
		alertController.addAction(chooseExisting)
		alertController.addAction(takePhoto)
		alertController.addAction(remove)
		alertController.addAction(cancel)
		
		viewController.present(alertController, animated: true, completion: nil)
	}
	
	class func genericErrorAlert(_ viewController: UIViewController, title: String = "Error", message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		let remove = UIAlertAction(title: "Ok", style: .default) { (_) in }
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
		
		alertController.addAction(remove)
		alertController.addAction(cancel)
		
		viewController.present(alertController, animated: true, completion: nil)
	}
	
	class func genericErrorActionSheet(_ viewController: UIViewController, title: String = "Error", message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		
		let remove = UIAlertAction(title: "Ok", style: .destructive) { (_) in }
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
		
		alertController.addAction(remove)
		alertController.addAction(cancel)
		
		viewController.present(alertController, animated: true, completion: nil)
	}
	
	class func genericSavedAlert(_ viewController: UIViewController, title: String, message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		viewController.present(alertController, animated: true, completion: nil)
		
		let when = DispatchTime.now() + 1
		DispatchQueue.main.asyncAfter(deadline: when) {
			alertController.dismiss(animated: true) {
				viewController.navigationController?.popViewController(animated: true)
			}
		}
	}
    
    class func genericAlertWithoutCancel(_ viewController: UIViewController, title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let remove = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(remove)
        viewController.present(alertController, animated: true, completion: nil)
    }
	
	class func genericErrorAlertWithoutCancel(_ viewController: UIViewController, title: String = "Error", message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let remove = UIAlertAction(title: "Ok", style: .default, handler: nil)
		alertController.addAction(remove)
		viewController.present(alertController, animated: true, completion: nil)
	}

	class func requestPermissionFromSettingsAlert(_ viewController: UIViewController, title: String?, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
			UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		viewController.present(alert, animated: true, completion: nil)
	}
	class func addToCalendarSaved(_ viewController: UIViewController) {
		let alertController = UIAlertController(title: "Event Saved to Calendar!", message: nil, preferredStyle: .alert)
		viewController.present(alertController, animated: true, completion: nil)
		
		let when = DispatchTime.now() + 2
		DispatchQueue.main.asyncAfter(deadline: when) {
			alertController.dismiss(animated: true, completion: nil)
		}
	}
}

