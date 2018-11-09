//
//  signIn.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/16/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseAuth
import SnapKit

class PhoneTextFieldView: InteractableView, Interactable {
	
	var textField: NoPasteTextField = {
		let textField = NoPasteTextField()
		textField.font = Fonts.createSize(25)
		textField.keyboardAppearance = .dark
		textField.textColor = .white
		textField.tintColor = .white
		return textField
	}()
	
	var flag: UIImageView = {
		let imageView = UIImageView()
		
		imageView.image = UIImage(named: "flag")
		imageView.scaleImage()
		
		return imageView
	}()
	var plusOneLabel: UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.font = Fonts.createSize(25)
		label.text = "+1"
		label.textAlignment = .center
		
		return label
	}()
	var line = UIView()
	
	override func configureView() {
		addSubview(textField)
		addSubview(line)
		addSubview(flag)
		addSubview(plusOneLabel)
		super.configureView()
		
		line.backgroundColor = .white
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		flag.snp.makeConstraints { make in
			make.height.equalToSuperview().multipliedBy(0.6)
			make.width.equalTo(30)
			make.left.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		plusOneLabel.snp.makeConstraints { make in
			make.left.equalTo(flag.snp.right)
			make.bottom.equalToSuperview()
			make.width.equalTo(45)
			make.height.equalTo(flag)
		}
		
		textField.snp.makeConstraints { make in
			make.left.equalTo(plusOneLabel.snp.right)
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.6)
		}
		
		line.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview().offset(1)
			make.height.equalTo(1)
		}
	}
}

class FacebookButton: InteractableView, Interactable {
	
	var facebookIcon = UIImageView()
	var facebookLabel = LeftTextLabel()
	
	override func configureView() {
		addSubview(facebookIcon)
		addSubview(facebookLabel)
		super.configureView()
		
		facebookIcon.image = UIImage(named: "fb-signin")
		
		facebookLabel.label.text = "Continue with Facebook »"
		facebookLabel.label.font = Fonts.createSize(18)
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		facebookIcon.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		
		facebookLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().inset(30)
			make.right.equalToSuperview()
			make.centerY.equalToSuperview()
			make.height.equalTo(30)
		}
	}
	
	func touchStart() {
		facebookIcon.alpha = 0.6
		facebookLabel.alpha = 0.6
	}
	
	func didDragOff() {
		facebookIcon.alpha = 1.0
		facebookLabel.alpha = 1.0
	}
}


class SignInVC: BaseViewController {
	
	var verificationId: String!
	
	override var contentView: SignInView {
		return view as! SignInView
	}
	
	override func loadView() {
		view = SignInView()
	}
	
	var keyboardAnimationDuration: Double?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		hideKeyboardWhenTappedAround()
		contentView.phoneTextField.textField.delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
	}
	@objc func keyboardWillShow(_ notification: Notification) {
		if let _: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
			guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
			keyboardAnimationDuration = duration
		}
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if contentView.nextButton.isUserInteractionEnabled {
			contentView.phoneTextField.isUserInteractionEnabled = true
			contentView.phoneTextField.textField.becomeFirstResponder()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func handleNavigation() {
		if touchStartView is RegistrationBackButton {
			
			contentView.backButton.isUserInteractionEnabled = false
			contentView.nextButton.isUserInteractionEnabled = false
			
			contentView.backButton.fadeOut(withDuration: 0.2)
			contentView.nextButton.fadeOut(withDuration: 0.2)
			
			contentView.phoneTextField.snp.removeConstraints()
			contentView.quicktutorFlame.snp.removeConstraints()
			
			contentView.phoneTextField.snp.remakeConstraints { make in
				make.width.equalToSuperview()
				make.centerY.equalToSuperview()
				make.height.equalTo(60)
				make.centerX.equalToSuperview()
			}
			
			contentView.quicktutorFlame.snp.remakeConstraints { make in
				make.top.equalTo(contentView.learnAnythingLabel.snp.bottom).offset(30)
				make.centerX.equalToSuperview()
			}
			
			contentView.setNeedsUpdateConstraints()
			UIView.animate(withDuration: 0.7, delay: 0.2, options: [.curveEaseIn], animations: {
				self.contentView.layoutIfNeeded()
			}, completion: { _ in
				self.contentView.quicktutorText.fadeIn(withDuration: 0.2, alpha: 1.0)
				self.contentView.learnAnythingLabel.fadeIn(withDuration: 0.2, alpha: 1.0)
				self.contentView.infoLabel.fadeIn(withDuration: 0.2, alpha: 1.0)
			})
		} else if touchStartView is RegistrationNextButton {
			signIn()
			contentView.nextButton.isUserInteractionEnabled = false
		} else if touchStartView is FacebookButton {
			facebookSignIn()
		}
	}
	
	private func signIn() {
		let phoneNumber = contentView.phoneTextField.textField.text!
		displayLoadingOverlay()
		PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber.cleanPhoneNumber(), uiDelegate: nil) { verificationId, error in
			if let error = error {
				AlertController.genericErrorAlert(self, title: "Error:", message: error.localizedDescription)
			} else {
				UserDefaults.standard.set(verificationId, forKey: Constants.VRFCTN_ID)
				Registration.phone = phoneNumber.cleanPhoneNumber()
				self.navigationController?.pushViewController(VerificationVC(), animated: true)
			}
			self.contentView.nextButton.isUserInteractionEnabled = true
		}
		dismissOverlay()
	}
	
	private func facebookSignIn() {
	}
}
extension SignInVC: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		contentView.quicktutorText.fadeOut(withDuration: 0.2)
		contentView.learnAnythingLabel.fadeOut(withDuration: 0.2)
		contentView.infoLabel.fadeOut(withDuration: 0.2)
		
		contentView.phoneTextField.snp.remakeConstraints({ make in
			make.top.equalTo(self.contentView.backButton.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(60)
		})
		
		contentView.quicktutorFlame.snp.remakeConstraints({ make in
			make.centerX.equalToSuperview()
			make.top.equalTo(contentView.phoneTextField.snp.bottom).offset(30)
		})
		
		contentView.setNeedsUpdateConstraints()
		UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
			self.contentView.layoutIfNeeded()
		}, completion: { (true) in
			self.contentView.backButton.fadeIn(withDuration: 0.2, alpha: 1.0)
			self.contentView.backButton.isUserInteractionEnabled = true
			self.contentView.phoneTextField.textField.becomeFirstResponder()
			self.contentView.nextButton.fadeIn(withDuration: 0.2, alpha: 1.0)
		})
		
		contentView.nextButton.isUserInteractionEnabled = true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
		let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)
		
		let decimalString = components.joined(separator: "") as NSString
		let length = decimalString.length
		let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
		
		if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
			let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
			
			return (newLength > 10) ? false : true
		}
		var index = 0 as Int
		let formattedString = NSMutableString()
		
		if hasLeadingOne {
			formattedString.append("1 ")
			index += 1
		}
		if (length - index) > 3 {
			let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
			formattedString.appendFormat("(%@) ", areaCode)
			index += 3
		}
		if length - index > 3 {
			let prefix = decimalString.substring(with: NSMakeRange(index, 3))
			formattedString.appendFormat("%@-", prefix)
			index += 3
		}
		
		let remainder = decimalString.substring(from: index)
		formattedString.append(remainder)
		textField.text = formattedString as String
		return false
	}
}
