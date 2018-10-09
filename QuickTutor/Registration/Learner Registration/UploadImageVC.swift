//
//  UploadImage.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseAuth

class UploadImageView: RegistrationNavBarView {
    let contentView = UIView()
	
	let imageViewButton : UIButton = {
		let button = UIButton()
		button.setImage(UIImage(named: "placeholder-square"), for: .normal)
		button.contentHorizontalAlignment = .fill
		button.contentVerticalAlignment = .fill
		button.clipsToBounds = true
		button.imageView?.layer.masksToBounds = false
		button.tag = 1
		if #available(iOS 11.0, *) {
			button.imageView?.adjustsImageSizeForAccessibilityContentSizeCategory = true
		}
		return button
	}()
	let addImageButton : UIButton = {
		let button = UIButton()
		button.imageView?.clipsToBounds = true
		button.imageView?.layer.masksToBounds = false
		button.setImage(UIImage(named: "add-image-profile"), for: .normal)
		button.contentHorizontalAlignment = .fill
		button.contentVerticalAlignment = .fill
		return button
	}()
	let info : LeftTextLabel = {
		let leftTextLabel = LeftTextLabel()
		leftTextLabel.label.text = "· Upload a photo of yourself.\n· You will be able to add more photos later."
		leftTextLabel.label.font = Fonts.createLightSize(18)
		return leftTextLabel
	}()
	let looksGoodButton : RegistrationBigButton = {
		let registrationBigButton = RegistrationBigButton()
		registrationBigButton.label.label.text = "Looks good!"
		return registrationBigButton
	}()
	let chooseNewButton : RegistrationBigButton = {
		let registrationBigButton = RegistrationBigButton()
		registrationBigButton.label.label.text = "Choose a different photo"
		return registrationBigButton
	}()
	
	let buttonContainer = UIView()

    override func configureView() {
        super.configureView()
        addSubview(contentView)
        addSubview(addImageButton)
        addSubview(buttonContainer)
        contentView.addSubview(imageViewButton)
        contentView.addSubview(info)
        buttonContainer.addSubview(looksGoodButton)
        buttonContainer.addSubview(chooseNewButton)
        
        progressBar.progress = 1
        progressBar.applyConstraints()
        progressBar.divider.isHidden = true
        
        titleLabel.label.text = "Alright, time to add a photo!"
        titleLabel.label.numberOfLines = 2
        titleLabel.label.textAlignment = .center
		
        buttonContainer.isHidden = true
		
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        titleLabel.snp.remakeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.12)
            make.top.equalTo(backButton.snp.bottom)
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(20)
        }
        contentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
        }
        imageViewButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(contentView.snp.width).multipliedBy(0.7)
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.centerX.equalToSuperview()
        }
        addImageButton.snp.makeConstraints { make in
            make.width.equalTo(imageViewButton).multipliedBy(0.25)
            make.centerY.equalTo(imageViewButton.snp.bottom).inset(10)
            make.centerX.equalTo(imageViewButton.snp.right).inset(10)
            make.height.equalTo(imageViewButton).multipliedBy(0.25)
        }
        info.snp.makeConstraints { make in
            make.top.equalTo(imageViewButton.snp.bottom)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.bottom.equalToSuperview()
        }
        info.label.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.right.equalToSuperview()
        }
        buttonContainer.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.3)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        looksGoodButton.snp.makeConstraints { make in
            make.height.equalTo(55)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        chooseNewButton.snp.makeConstraints { make in
            make.height.equalTo(55)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.4)
        }
    }
}

class UploadImageVC: BaseViewController {
    
    override var contentView: UploadImageView {
        return view as! UploadImageView
    }
    
    override func loadView() {
        view = UploadImageView()
    }
    
    let profilePicker = UIImagePickerController()
    var imagePicked: Bool = false
    
    var chosenImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicker.delegate = self
        profilePicker.allowsEditing = false
		contentView.addImageButton.addTarget(self, action: #selector(addImageButtonPressed(_:)), for: .touchUpInside)
		contentView.imageViewButton.addTarget(self, action: #selector(addImageButtonPressed(_:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.looksGoodButton.isUserInteractionEnabled = true
    }
	
	@objc private func addImageButtonPressed(_ sender: UIButton) {
		if sender.tag != 1 {
			UIView.animate(withDuration: 0.1, animations: {
				sender.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
			}) { (_) in
				UIView.animate(withDuration: 0.1) {
					sender.transform = .identity
				}
			}
		}
		AlertController.cropImageAlert(self, imagePicker: profilePicker, allowsEditing: false)
	}
	
    override func handleNavigation() {
        if touchStartView == contentView.backButton {
            let viewControllers: [UIViewController] = navigationController!.viewControllers
            for viewController in viewControllers {
                if viewController is BirthdayVC {
                    navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
                    navigationController!.popToViewController(viewController, animated: false)
                }
            }
        } else if touchStartView == contentView.looksGoodButton {
            if imagePicked {
                displayLoadingOverlay()
                contentView.looksGoodButton.isUserInteractionEnabled = false
                guard let image = chosenImage else { return }
                guard let data = FirebaseData.manager.getCompressedImageDataFor(image) else {
                    AlertController.genericErrorAlert(self, title: "Error", message: "Please choose a new photo")
                    return
                }
                Registration.imageData = data
                navigationController?.pushViewController(UserPolicyVC(), animated: true)
            } else {
                AlertController.genericErrorAlert(self, title: "Please Select A Photo", message: "")
                contentView.looksGoodButton.isUserInteractionEnabled = true
            }
        } else if touchStartView == contentView.chooseNewButton {
            AlertController.cropImageAlert(self, imagePicker: profilePicker, allowsEditing: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
		contentView.imageViewButton.imageView?.backgroundColor = .black
        contentView.imageViewButton.layer.cornerRadius = 30
    }
}

extension UploadImageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AACircleCropViewControllerDelegate {
    
    func circleCropDidCropImage(_ image: UIImage) {
        chosenImage = image
		contentView.imageViewButton.setImage(image, for: .normal)
        imagePicked = true
        contentView.info.isHidden = true
        contentView.addImageButton.isHidden = true
        contentView.buttonContainer.isHidden = false
    }
    
    func circleCropDidCancel() {
        imagePicked = false
        let image = UIImage(named: "placeholder-square")
		contentView.imageViewButton.setImage(image, for: .normal)
        contentView.info.isHidden = false
        contentView.addImageButton.isHidden = false
        contentView.buttonContainer.isHidden = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            imagePicked = true
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
