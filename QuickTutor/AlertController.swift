//
//  AlertController.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit
import EventKit
class AlertController : NSObject {
	
	class func cropImageAlert(_ viewController: UIViewController, imagePicker: UIImagePickerController, allowsEditing: Bool) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let chooseExisting = UIAlertAction(title: "Choose Exisiting", style: .default) { (alert) in
			if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
				imagePicker.sourceType = .photoLibrary
				imagePicker.allowsEditing = allowsEditing
				viewController.present(imagePicker, animated: true, completion: nil)
			} else {
				AlertController.genericErrorAlert(viewController, title: "Oops", message: "Photo Library is not available")
			}
		}
		let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert) in
			if UIImagePickerController.isSourceTypeAvailable(.camera) {
				imagePicker.sourceType = UIImagePickerControllerSourceType.camera
				imagePicker.cameraCaptureMode =  UIImagePickerControllerCameraCaptureMode.photo
				imagePicker.modalPresentationStyle = .custom
				
				viewController.present(imagePicker,animated: true, completion: nil)
			} else {
				AlertController.genericErrorAlert(viewController, title: "Oops", message: "Camera is not available at this time.")
			}
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
			alertController.dismiss(animated: true, completion: nil)
		}
		
		alertController.addAction(chooseExisting)
		alertController.addAction(takePhoto)
		alertController.addAction(cancel)
		
		viewController.present(alertController, animated: true, completion: nil)
	}
	class func cropImageWithRemoveAlert(_ viewController: UIViewController, imagePicker: UIImagePickerController,_ completion: @escaping (Bool) -> Void) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let chooseExisting = UIAlertAction(title: "Choose Exisiting", style: .default) { (alert) in
			if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
				imagePicker.sourceType = .photoLibrary
				imagePicker.allowsEditing = false
				viewController.present(imagePicker, animated: true, completion: nil)
			} else {
				AlertController.genericErrorAlert(viewController, title: "Oops", message: "Photo Library is not available")
			}
			completion(false)
		}
		let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert) in
			if UIImagePickerController.isSourceTypeAvailable(.camera) {
				imagePicker.sourceType = UIImagePickerControllerSourceType.camera
				imagePicker.cameraCaptureMode =  UIImagePickerControllerCameraCaptureMode.photo
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
	
	class func genericErrorAlert(_ viewController: UIViewController, title: String, message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		let remove = UIAlertAction(title: "Ok", style: .default) { (_) in }
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
		
		alertController.addAction(remove)
		alertController.addAction(cancel)
		
		viewController.present(alertController, animated: true, completion: nil)
	}
	
	class func genericErrorActionSheet(_ viewController: UIViewController, title: String, message: String?) {
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
	class func genericErrorAlertWithoutCancel(_ viewController: UIViewController, title: String, message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let remove = UIAlertAction(title: "Ok", style: .default) { (_) in }		
		alertController.addAction(remove)
		viewController.present(alertController, animated: true, completion: nil)
	}
}

