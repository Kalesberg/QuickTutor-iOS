//
//  UploadImage.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseAuth
import AAPhotoCircleCrop

class UploadImageView : RegistrationNavBarView {
    
    var contentView     = UIView()
    var imageView       = UIImageView()
    var addImageButton  = AddImageButton()
    var info            = LeftTextLabel()
    var buttonView      = UIView()
    var looksGoodButton = RegistrationBigButton()
    var chooseNewButton = RegistrationBigButton()
    
    override func configureView() {
        super.configureView()
        
        addSubview(contentView)
        addSubview(addImageButton)
        addSubview(buttonView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(info)
    
        buttonView.addSubview(looksGoodButton)
        buttonView.addSubview(chooseNewButton)
        
        progressBar.progress = 1
        progressBar.applyConstraints()
        progressBar.divider.isHidden = true
        
        titleLabel.label.text = "Alright, time to add a photo!"
        titleLabel.label.numberOfLines = 2
        titleLabel.label.textAlignment = .center
        
        imageView.image = UIImage(named: "registration-image-placeholder")
        if #available(iOS 11.0, *) {
            imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        } else {
            // Fallback on earlier versions
        }
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        info.label.text = "· Upload a photo of yourself.\n· You will be able to add more photos later."
        info.label.font = Fonts.createLightSize(18)
        
        buttonView.isHidden = true
        
        looksGoodButton.label.label.text = "Looks good!"

        chooseNewButton.label.label.text = "Choose a different photo"

        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        titleLabel.snp.remakeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.12)
            make.top.equalTo(backButton.snp.bottom)
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(20)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(contentView.snp.width).multipliedBy(0.7)
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.centerX.equalToSuperview()
        }
        
        addImageButton.snp.makeConstraints { (make) in
            make.width.equalTo(imageView).multipliedBy(0.25)
            make.bottom.equalTo(imageView)
            make.right.equalTo(imageView)
            make.height.equalTo(imageView).multipliedBy(0.25)
        }
        
        info.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.bottom.equalToSuperview()
        }
        
        info.label.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.right.equalToSuperview()
        }
        
        buttonView.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.3)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        looksGoodButton.snp.makeConstraints { (make) in
            make.height.equalTo(55)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        chooseNewButton.snp.makeConstraints { (make) in
            make.height.equalTo(55)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.4)
        }
    }
}

//Interactables
class AddImageButton : InteractableView, Interactable {
    
    var imageView = UIImageView()
    
    override func configureView() {
        addSubview(imageView)
        
        imageView.image = UIImage(named: "registration-add-image")
    
        applyConstraints()
    }
    
    override func applyConstraints() {
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    
    func touchStart() {
        imageView.snp.updateConstraints { (make) in
            make.width.equalToSuperview().inset(-5)
            make.height.equalToSuperview().inset(-5)
        }
        
        needsUpdateConstraints()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
    }
    
    func didDragOff() {
        imageView.snp.updateConstraints { (make) in
            make.width.equalToSuperview().inset(5)
            make.height.equalToSuperview().inset(5)
        }
        
        needsUpdateConstraints()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
    }
}

class UploadImage: BaseViewController {
    
    override var contentView: UploadImageView {
        return view as! UploadImageView
    }
    
    override func loadView() {
        view = UploadImageView()
    }

    let profilePicker = UIImagePickerController()
    var imagePicked : Bool = false
	
	var chosenImage: UIImage?
	
	override func viewDidLoad() {
        super.viewDidLoad()
        profilePicker.delegate = self
		profilePicker.allowsEditing = false
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.looksGoodButton.isUserInteractionEnabled = true
	}
	
    override func handleNavigation() {
        if (touchStartView == contentView.backButton) {
			let viewControllers: [UIViewController] = self.navigationController!.viewControllers
			for viewController in viewControllers {
				if (viewController is Birthday) {
					self.navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
					self.navigationController!.popToViewController(viewController, animated: false)
				}
			}
        } else if (touchStartView == contentView.addImageButton) {
			AlertController.cropImageAlert(self, imagePicker: profilePicker, allowsEditing: false)
        } else if (touchStartView == contentView.looksGoodButton) {
			if imagePicked {
				self.displayLoadingOverlay()
				contentView.looksGoodButton.isUserInteractionEnabled = false
				guard let image = chosenImage else { return }
				guard let data = FirebaseData.manager.getCompressedImageDataFor(image) else {
					AlertController.genericErrorAlert(self, title: "Error", message: "Please choose a new photo")
					return
				}
				Registration.imageData = data
				self.navigationController?.pushViewController(UserPolicy(), animated: true)
			} else {
				AlertController.genericErrorAlert(self, title: "Please Select A Photo", message: "")
				contentView.looksGoodButton.isUserInteractionEnabled = true
			}
        } else if (touchStartView == contentView.chooseNewButton) {
			AlertController.cropImageAlert(self, imagePicker: profilePicker, allowsEditing: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UploadImage : UIImagePickerControllerDelegate, UINavigationControllerDelegate, AACircleCropViewControllerDelegate {
	
	func circleCropDidCropImage(_ image: UIImage) {
		chosenImage = image
		contentView.imageView.image = image.circleMasked
		imagePicked = true
		contentView.info.isHidden = true
		contentView.addImageButton.isHidden = true
		contentView.buttonView.isHidden = false
	}
	
	func circleCropDidCancel() {
		imagePicked = false
		let image = UIImage(named: "registration-image-placeholder")
		contentView.imageView.image = image
		contentView.info.isHidden = false
		contentView.addImageButton.isHidden = false
		contentView.buttonView.isHidden = true
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePicked = true
			let circleCropController = AACircleCropViewController()
			circleCropController.delegate = self
			circleCropController.image = image
			circleCropController.selectTitle = NSLocalizedString("Done", comment: "select")
			
			profilePicker.dismiss(animated: true, completion: nil)
			DispatchQueue.main.async {
				self.present(circleCropController, animated: true, completion: nil)
			}
		}
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		DispatchQueue.main.async {
			self.dismiss(animated: true, completion: nil)
		}
	}
}
