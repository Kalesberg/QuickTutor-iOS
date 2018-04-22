//
//  CreatePassword.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper


class CreatePasswordView : RegistrationNavBarKeyboardView {
	
	var createPasswordTextfield = RegistrationTextField()
	var passwordInfo            = LeftTextLabel()
	
	override func configureView() {
		super.configureView()
		contentView.addSubview(createPasswordTextfield)
		contentView.addSubview(passwordInfo)
		
		navBar.progressBar.progress = 0.571
		navBar.applyConstraints()
		
		titleLabel.label.text = "Let's create a password"
		titleLabel.label.adjustsFontSizeToFitWidth = true
		titleLabel.label.adjustsFontForContentSizeCategory = true
        errorLabel.text = "Password is less than 8 characters"
		
		createPasswordTextfield.placeholder.text = "PASSWORD"
		
		createPasswordTextfield.textField.isSecureTextEntry = true
		createPasswordTextfield.textField.autocorrectionType = .no
		createPasswordTextfield.textField.returnKeyType = .next
		
		passwordInfo.label.font = Fonts.createSize(20)
		passwordInfo.label.text = "Your password must be at least 8 characters long"
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		createPasswordTextfield.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.5)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
		
		passwordInfo.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.5)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
	}
}

class CreatePassword: BaseViewController {
	
	override var contentView: CreatePasswordView {
		return view as! CreatePasswordView
	}
	
	override func loadView() {
		view = CreatePasswordView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		contentView.createPasswordTextfield.textField.delegate = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.contentView.createPasswordTextfield.textField.becomeFirstResponder()
	}
	
	override func handleNavigation() {
		if (touchStartView == contentView.backButton) {
			navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
			navigationController!.popViewController(animated: false)
		} else if (touchStartView == contentView.nextButton) {
			if checkPasswordValidity() {
                contentView.errorLabel.isHidden = true
				createEmailAccount()
			} else {
				contentView.errorLabel.isHidden = false
			}
		}
	}
	private func createEmailAccount() {
		let password : String? = KeychainWrapper.standard.string(forKey: "emailAccountPassword")
		let emailCredential = EmailAuthProvider.credential(withEmail: Registration.email, password: password!)
		
		Auth.auth().currentUser?.link(with: emailCredential, completion: { (user, error) in
			if let error = error {
				print(error.localizedDescription)
				self.navigationController!.pushViewController(Birthday(), animated: true)
			} else {
				print("user is good.")
				self.navigationController!.pushViewController(Birthday(), animated: true)
				self.contentView.createPasswordTextfield.textField.text = ""
			}
		})
	
	}
	
	private func keyboardNextWasPressed() {
		if checkPasswordValidity() {
            contentView.errorLabel.isHidden = true
			createEmailAccount()
		} else {
			contentView.errorLabel.isHidden = false
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	private func checkPasswordValidity() -> Bool {
		if contentView.createPasswordTextfield.textField.text!.count >= 8 {
			return KeychainWrapper.standard.set(self.contentView.createPasswordTextfield.textField.text!, forKey: "emailAccountPassword")
		}
		print("error message")
		return false
	}
}
extension CreatePassword : UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let maxlength = 32
		guard let text = textField.text else { return true }
		let length = (text.count + string.count) - range.length
		if length <= maxlength {
			return true
		} else {
			print("Password is too long!")
			return false
		}
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch(textField){
		case contentView.createPasswordTextfield.textField:
			keyboardNextWasPressed()
			return false
		default:
			contentView.createPasswordTextfield.textField.becomeFirstResponder()
			return false
		}
	}
}
