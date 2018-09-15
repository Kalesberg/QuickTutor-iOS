//
//  TutorEditProfileCells.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI

class ProfileImagesTableViewCell : BaseTableViewCell {
	let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

	var image1 = ProfilePicImageView()
	var image2 = ProfilePicImageView()
	var image3 = ProfilePicImageView()
	var image4 = ProfilePicImageView()

	override func configureView() {
		contentView.addSubview(image1)
		contentView.addSubview(image2)
		contentView.addSubview(image3)
		contentView.addSubview(image4)
		super.configureView()
		
		selectionStyle = .none
		backgroundColor = .clear
		applyConstraints()
	}
	
	override func applyConstraints() {
		
		var height : Int
		
		if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
			height = 67
		} else {
			height = 75
		}
		
		image1.snp.makeConstraints { (make) in
			make.height.equalTo(height)
			make.width.equalToSuperview().multipliedBy(0.25)
			make.left.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		
		image2.snp.makeConstraints { (make) in
			make.height.equalTo(height)
			make.width.equalToSuperview().multipliedBy(0.25)
			make.left.equalTo(image1.snp.right)
			make.centerY.equalToSuperview()
		}
		
		image3.snp.makeConstraints { (make) in
			make.height.equalTo(height)
			make.width.equalToSuperview().multipliedBy(0.25)
			make.left.equalTo(image2.snp.right)
			make.centerY.equalToSuperview()
		}
		
		image4.snp.makeConstraints { (make) in
			make.height.equalTo(height)
			make.width.equalToSuperview().multipliedBy(0.25)
			make.right.equalToSuperview()
			make.centerY.equalToSuperview()
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		let imageViews : [ProfilePicImageView] = [image1, image2, image3, image4]
        for imageView in imageViews {
            imageView.buttonImageView.image = (imageView.picView.image != #imageLiteral(resourceName: "registration-image-placeholder")) ? UIImage(named: "remove-image") : UIImage(named: "add-image-profile")
        }
	}
	
	override func handleNavigation() {
		guard let current = UIApplication.getPresentedViewController() else { return }
		if touchStartView == image1 {
			image1.picView.growShrink()
			AlertController.cropImageAlert(current, imagePicker: imagePicker, allowsEditing: false)
			imageToChange = 1
		} else if touchStartView == image2 {
			image2.picView.growShrink()

			if image2.picView.image != #imageLiteral(resourceName: "registration-image-placeholder") {
				AlertController.cropImageWithRemoveAlert(current, imagePicker: imagePicker) { (shouldRemove) in
					if shouldRemove {
						FirebaseData.manager.removeUserImage("2")
						self.image2.picView.image = #imageLiteral(resourceName: "registration-image-placeholder")
						self.image2.buttonImageView.image = UIImage(named: "add-image-profile")
					}
				}
			} else {
				AlertController.cropImageAlert(current, imagePicker: imagePicker, allowsEditing: false)
			}
			imageToChange = 2
		} else if touchStartView == image3 {
			image3.picView.growShrink()

			if image3.picView.image != #imageLiteral(resourceName: "registration-image-placeholder") {
				AlertController.cropImageWithRemoveAlert(current, imagePicker: imagePicker) { (shouldRemove) in
					if shouldRemove {
						FirebaseData.manager.removeUserImage("3")
						self.image3.picView.image = #imageLiteral(resourceName: "registration-image-placeholder")
						self.image3.buttonImageView.image = UIImage(named: "add-image-profile")
					}
				}
			} else {
				AlertController.cropImageAlert(current, imagePicker: imagePicker, allowsEditing: false)
			}
			imageToChange = 3
		} else if touchStartView == image4 {
			image4.picView.growShrink()
			if image4.picView.image != #imageLiteral(resourceName: "registration-image-placeholder") {
				AlertController.cropImageWithRemoveAlert(current, imagePicker: imagePicker) { (shouldRemove) in
					if shouldRemove {
						FirebaseData.manager.removeUserImage("4")
						self.image4.picView.image = #imageLiteral(resourceName: "registration-image-placeholder")
						self.image4.buttonImageView.image = UIImage(named: "add-image-profile")
					}
				}
			} else {
				AlertController.cropImageAlert(current, imagePicker: imagePicker, allowsEditing: false)
			}
			imageToChange = 4
		}
	}
}

class EditProfileItemTableViewCell : BaseTableViewCell {
	
	var infoLabel = LeftTextLabel()
	var textField = NoPasteTextField()
	var sideLabel = RightTextLabel()
	var divider   = BaseView()
	var spacer    = BaseView()
	
	override func configureView() {
		contentView.addSubview(infoLabel)
		contentView.addSubview(textField)
		textField.addSubview(sideLabel)
		contentView.addSubview(divider)
		contentView.addSubview(spacer)
		
		backgroundColor = .clear
		selectionStyle = .none;
		
		textField.delegate = self
		
		divider.backgroundColor = Colors.divider
		infoLabel.label.font = Fonts.createBoldSize(15)
		textField.font = Fonts.createSize(18)
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		infoLabel.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview().inset(3)
			make.right.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.3)
		}
		
		spacer.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.2)
			make.left.equalTo(infoLabel)
			make.right.equalTo(infoLabel)
		}
		
		divider.snp.makeConstraints { (make) in
			make.top.equalTo(spacer.snp.top)
			make.height.equalTo(1)
			make.left.equalTo(infoLabel)
			make.right.equalTo(infoLabel)
		}
		
		textField.snp.makeConstraints { (make) in
			make.bottom.equalTo(divider.snp.top)
			make.height.equalToSuperview().multipliedBy(0.5)
			make.left.equalTo(infoLabel)
			make.right.equalTo(infoLabel)
		}
		
		sideLabel.snp.makeConstraints { (make) in
			make.right.equalTo(infoLabel)
			make.height.equalToSuperview()
			make.top.equalToSuperview()
			make.width.equalTo(15)
		}
	}
}
extension EditProfileItemTableViewCell : UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let inverseSet = NSCharacterSet(charactersIn:"0123456789@#$%^&*()_=+<>?,[]{};'~!").inverted //Add any extra characters here..
		let components = string.components(separatedBy: inverseSet)
		let filtered = components.joined(separator: "")
		
		if textField.text!.count <= 24 {
			if string == "" {
				return true
			}
			return !(string == filtered)
		} else {
			if string == "" {
				return true
			}
			return false
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return true
	}
}
class EditProfileDotItemTableViewCell : EditProfileItemTableViewCell {
	override func configureView() {
		super.configureView()
		
		sideLabel.label.font = Fonts.createSize(16)
		textField.textColor = Colors.grayText
		sideLabel.label.text = "•"
	}
}

class EditProfileArrowItemTableViewCell : EditProfileItemTableViewCell {
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		if (selected) {
			//navigation
		}
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		if (highlighted) {
			UIView.animate(withDuration: 0.2) {
				self.divider.backgroundColor = .white
			}
		} else {
			UIView.animate(withDuration: 0.2) {
				self.divider.backgroundColor = Colors.divider
			}
		}
	}
	
	override func configureView() {
		super.configureView()
		
		textField.isUserInteractionEnabled = false
		sideLabel.label.font = Fonts.createBoldSize(25)
		sideLabel.label.text = "›"
	}
}

class EditProfilePolicyTableViewCell : EditProfileDotItemTableViewCell {
	
	let label : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createSize(13)
		label.textColor = Colors.grayText
		label.sizeToFit()
		label.numberOfLines = 0
		
		return label
	}()
	
	override func configureView() {
		contentView.addSubview(label)
		super.configureView()
		
	}
	
	override func applyConstraints() {
		infoLabel.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview().inset(3)
			make.right.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.3)
		}
		
		label.snp.makeConstraints { (make) in
			make.top.equalTo(infoLabel.snp.bottom).inset(4)
			make.left.equalToSuperview().inset(3)
			make.right.equalToSuperview()
		}
		
		textField.snp.makeConstraints { (make) in
			make.top.equalTo(label.snp.bottom).inset(-6)
			make.height.equalTo(30)
			make.left.equalTo(infoLabel)
			make.right.equalTo(infoLabel)
		}
		
		sideLabel.snp.makeConstraints { (make) in
			make.right.equalTo(infoLabel)
			make.height.equalToSuperview()
			make.top.equalToSuperview()
			make.width.equalTo(15)
		}
		
		divider.snp.makeConstraints { (make) in
			make.top.equalTo(textField.snp.bottom).inset(-5)
			make.height.equalTo(1)
			make.left.equalTo(infoLabel)
			make.right.equalTo(infoLabel)
			make.bottom.equalToSuperview().inset(8)
		}
	}
}

class EditProfileHeaderTableViewCell : BaseTableViewCell {
	
	let label : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.font = Fonts.createSize(20)
		label.sizeToFit()
		
		return label
	}()
	
	override func configureView() {
		contentView.addSubview(label)
		
		selectionStyle = .none
		backgroundColor = .clear
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
}

class EditProfilePreferencesTableViewCell : BaseTableViewCell {
	
	let header : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.font = Fonts.createBoldSize(15)
		label.sizeToFit()
		label.text = "Preferences"
		
		return label
	}()
	
	let inSessionLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.font = Fonts.createBoldSize(16)
		label.sizeToFit()
		label.text = "Tutoring In-Person Sessions"
		
		return label
	}()
	
	override func configureView() {
		contentView.addSubview(header)
		contentView.addSubview(inSessionLabel)
		
		backgroundColor = .black
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		header.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview().inset(3)
			make.height.equalTo(20)
		}
		
		inSessionLabel.snp.makeConstraints { (make) in
			make.top.equalTo(header.snp.bottom)
			make.left.equalTo(header)
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
			make.height.equalTo(20)
		}
	}
}

class BaseSlider : UISlider {
	override func trackRect(forBounds bounds: CGRect) -> CGRect {
		
		var width : Int
		
		if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
			width = 230
		} else {
			width = 280
		}
		
		let rect:CGRect = CGRect(x: 0, y: 0, width: width, height: 20)
		
		return rect
	}
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		var bounds: CGRect = self.bounds
		bounds = bounds.insetBy(dx: -20, dy: -20)
		return bounds.contains(point)
	}
}

class EditProfileSliderTableViewCell : BaseTableViewCell {
	
	let header : UILabel = {
		let label = UILabel()
		
		label.numberOfLines = 0
		
		return label
	}()
	
	let slider : BaseSlider = {
		let slider = BaseSlider()
		
		slider.maximumTrackTintColor = Colors.registrationDark
		slider.minimumTrackTintColor = Colors.tutorBlue
		slider.isContinuous = true
		
		return slider
	}()
	
	let valueLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.font = Fonts.createBoldSize(16)
		label.textAlignment = .center
		
		return label
	}()
	
	override func configureView() {
		contentView.addSubview(header)
		contentView.addSubview(slider)
		contentView.addSubview(valueLabel)
		
		backgroundColor = .clear
		selectionStyle = .none
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		
		var width : Int
		
		if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
			width = 230
		} else {
			width = 290
		}
		
		header.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview().inset(3)
		}
		
		valueLabel.snp.makeConstraints { (make) in
			make.centerY.equalTo(slider).inset(-14)
			make.left.equalTo(slider.snp.right)
			make.right.equalToSuperview()
		}
		
		slider.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(4)
			make.top.equalTo(header.snp.bottom).inset(-25)
			make.width.equalTo(width)
			make.height.equalTo(40)
			make.bottom.equalToSuperview()
		}
	}
}

class EditProfileHourlyRateTableViewCell : BaseTableViewCell {
	
	let header : UILabel = {
		let label = UILabel()
		
		label.numberOfLines = 0
		
		return label
	}()
	
	let container : UIView = {
		let view = UIView()

		view.backgroundColor = Colors.registrationDark
		view.layer.cornerRadius = 6
		
		return view
	}()
	
	var textField = NoPasteTextField()
	
	let decreaseButton: UIButton = {
		let button = UIButton()
		button.setImage(#imageLiteral(resourceName: "decreaseButton"), for: .normal)
		return button
	}()
	
	let increaseButton: UIButton = {
		let button = UIButton()
		button.setImage(#imageLiteral(resourceName: "increaseButton"), for: .normal)
		return button
	}()
	
	var increasePriceTimer: Timer?
	var decreasePriceTimer: Timer?
	
	var currentPrice = 5
	var amount : String = "5"
	var textFieldObserver : AmountTextFieldDidChange?

	override func configureView() {
		contentView.addSubview(header)
		contentView.addSubview(container)
		container.addSubview(textField)
		container.addSubview(increaseButton)
		container.addSubview(decreaseButton)
		
		textField.delegate = self
		textField.font = Fonts.createBoldSize(32)
		textField.textColor = .white
		textField.textAlignment = .left
		textField.keyboardType = .numberPad
		textField.keyboardAppearance = .dark
		textField.tintColor = Colors.tutorBlue
		
		backgroundColor = .clear
		selectionStyle = .none
		
		decreaseButton.addTarget(self, action: #selector(decreasePrice), for: .touchDown)
		decreaseButton.addTarget(self, action: #selector(endDecreasePrice), for: [.touchUpInside, .touchUpOutside])
		increaseButton.addTarget(self, action: #selector(increasePrice), for: .touchDown)
		increaseButton.addTarget(self, action: #selector(endIncreasePrice), for: [.touchUpInside, .touchUpOutside])
		
		applyConstraints()
	}
	
	private func updateTextField(_ amount: String) {
		guard let this = Int(amount) else { return }
		guard let number = this as NSNumber? else {
			return
		}
		currentPrice = this
		textField.text = "$\(number)"
		textFieldObserver?.amountTextFieldDidChange(amount: this)
	}
	
	@objc func decreasePrice() {
		guard currentPrice > 0 else {
			self.amount = ""
			return
		}
		decreasePriceTimer =  Timer.scheduledTimer(withTimeInterval: 0.085, repeats: true) { (timer) in
			guard self.currentPrice > 0 else {
				self.amount = String(self.currentPrice)
				return
			}
			self.currentPrice -= 1
			self.textField.text = "$\(self.currentPrice)"
			self.amount = String(self.currentPrice)
			self.textFieldObserver?.amountTextFieldDidChange(amount: self.currentPrice)
		}
		decreasePriceTimer?.fire()
	}
	
	@objc func endDecreasePrice() {
		decreasePriceTimer?.invalidate()
	}
	
	@objc func increasePrice() {
		guard currentPrice < 1000 else {
			self.amount = String(currentPrice)
			return
		}
		currentPrice += 1
		textField.text = "$\(self.currentPrice)"
		amount = String(currentPrice)
		textFieldObserver?.amountTextFieldDidChange(amount: currentPrice)
		increasePriceTimer = Timer.scheduledTimer(withTimeInterval: 0.085, repeats: true, block: { (timer) in
			guard self.currentPrice < 1000 else {
				self.amount = String(self.currentPrice)
				return
			}
			self.currentPrice += 1
			self.textField.text = "$\(self.currentPrice)"
			self.amount = String(self.currentPrice)
			self.textFieldObserver?.amountTextFieldDidChange(amount: self.currentPrice)
		})
	}
	
	@objc func endIncreasePrice() {
		increasePriceTimer?.invalidate()
	}
	
	override func applyConstraints() {
		
		header.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview().inset(3)
		}
		
		container.snp.makeConstraints { (make) in
			make.top.equalTo(header.snp.bottom).inset(-20)
			make.width.centerX.bottom.equalToSuperview()
			make.height.equalTo(70)
		}
		
		textField.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(25)
            make.width.equalToSuperview().multipliedBy(0.4)
			make.centerY.equalToSuperview()
		}
		
		increaseButton.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(17)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(40)
		}
		
		decreaseButton.snp.makeConstraints { (make) in
			make.right.equalTo(increaseButton.snp.left).inset(-17)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(40)
		}
	}
}

extension EditProfileHourlyRateTableViewCell : UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
		let compSepByCharInSet = string.components(separatedBy: aSet)
		let numberFiltered = compSepByCharInSet.joined(separator: "")
		
		if string == "" && amount.count == 1 {
			textField.text = "$5"
			amount = ""
			currentPrice = 0
			return false
		}
		if string == "" && amount.count > 0 {
			amount.removeLast()
			updateTextField(amount)
		}
		
		if string == numberFiltered {
			let temp = (amount + string)
			guard let number = Int(temp), number < 1001 else {
				//showError
				return false
			}
			amount = temp
			updateTextField(amount)
		}
		return false
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return true
	}
}

class EditProfileCheckboxTableViewCell : BaseTableViewCell {
	
	let label : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createSize(15)
		label.textColor = .white
		
		return label
	}()
	
	var checkbox = RegistrationCheckbox() {
		didSet {
			print("changed")
		}
	}
	
	override func configureView() {
		addSubview(label)
		contentView.addSubview(checkbox)
		super.configureView()
		
		selectionStyle = .none
		backgroundColor = .clear
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.height.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		
		checkbox.snp.makeConstraints { (make) in
			make.right.equalToSuperview()
			make.height.equalToSuperview()
			make.centerY.equalToSuperview()
			make.width.equalTo(40)
		}
	}
}

class EditProfileVideoCheckboxTableViewCell : BaseTableViewCell {
	
	let label : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createSize(15)
		label.textColor = .white
		
		return label
	}()
	
	var delegate : TutorPreferenceChange?
	
	let checkbox = RegistrationCheckbox()
	
	override func configureView() {
		addSubview(label)
		contentView.addSubview(checkbox)
		super.configureView()
		
		selectionStyle = .none
		backgroundColor = .clear
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.height.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		
		checkbox.snp.makeConstraints { (make) in
			make.right.equalToSuperview()
			make.height.equalToSuperview()
			make.centerY.equalToSuperview()
			make.width.equalTo(40)
		}
	}
	override func handleNavigation() {
		if touchStartView is RegistrationCheckbox {
			delegate?.inVideoPressed()
		}
	}
}
class EditProfilePersonCheckboxTableViewCell : BaseTableViewCell {
	
	let label : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createSize(15)
		label.textColor = .white
		
		return label
	}()
	
	var delegate : TutorPreferenceChange?
	
	let checkbox = RegistrationCheckbox()
	
	override func configureView() {
		addSubview(label)
		contentView.addSubview(checkbox)
		super.configureView()
		
		selectionStyle = .none
		backgroundColor = .clear
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.height.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		
		checkbox.snp.makeConstraints { (make) in
			make.right.equalToSuperview()
			make.height.equalToSuperview()
			make.centerY.equalToSuperview()
			make.width.equalTo(40)
		}
	}
	override func handleNavigation() {
		if touchStartView is RegistrationCheckbox {
			delegate?.inPersonPressed()
		}
	}
}

extension LearnerFilters : UIScrollViewDelegate {
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.view.endEditing(true)
	}
}
