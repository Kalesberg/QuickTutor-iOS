//
//  Email.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth


class EmailView: RegistrationNavBarKeyboardView {
	
	var emailTextField    = RegistrationTextField()
	var checkboxLabel     = LeftTextLabel()
	var checkbox          = RegistrationCheckbox()
	
	override func configureView() {
		super.configureView()

		contentView.addSubview(emailTextField)
		contentView.addSubview(checkboxLabel)
		contentView.addSubview(checkbox)
		
		navBar.progressBar.progress = 0.429
		navBar.applyConstraints()
		
		titleLabel.label.text = "Your email?"
		
		emailTextField.placeholder.text = "EMAIL"
		emailTextField.textField.returnKeyType = .next
		emailTextField.textField.keyboardType = .emailAddress
		emailTextField.textField.autocapitalizationType = .none
		
		checkboxLabel.label.font = Fonts.createLightSize(14.5)
		checkboxLabel.label.text = "I'd like to recieve promotional content, including events, surveys, motivation, and goodies from QuickTutor via email."
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		emailTextField.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.5)
			make.right.equalToSuperview()
			make.left.equalToSuperview()
		}
		
		checkboxLabel.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.5)
			make.width.equalToSuperview().multipliedBy(0.8)
			make.left.equalToSuperview()
		}
		
		checkbox.snp.makeConstraints { (make) in
			make.top.equalTo(checkboxLabel).inset(10)
			make.bottom.equalTo(checkboxLabel).inset(10)
			make.width.equalToSuperview().multipliedBy(0.2)
			make.left.equalTo(checkboxLabel.snp.right)
		}
	}
}


class Email: BaseViewController {
	
	override var contentView: EmailView {
		return view as! EmailView
	}
	
	override func loadView() {
		view = EmailView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		contentView.emailTextField.textField.delegate = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.contentView.emailTextField.textField.becomeFirstResponder()
	}
	
	override func handleNavigation() {
		if (touchStartView == contentView.backButton) {
			navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
			self.navigationController!.popViewController(animated: false)
		
		} else if(touchStartView == contentView.nextButton) {
			
			if (contentView.emailTextField.textField.text!).emailRegex() {
				Registration.email = contentView.emailTextField.textField.text!
				navigationController!.pushViewController(CreatePassword(), animated: true)
			
			} else {
				print("Error: bad email")
			}
		}
	}
	private func keyboardNextWasPressed() {
		if (contentView.emailTextField.textField.text!).emailRegex() {
			Registration.email = contentView.emailTextField.textField.text!
			navigationController?.pushViewController(CreatePassword(), animated: true)
		} else {
			print("Email Error")
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}
extension Email : UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let maxlength = 40
		guard let text = textField.text else {return true}
		let length = text.count + string.count - range.length
		
		if length <= maxlength { return true }
		else { return false }
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch(textField){
		case contentView.emailTextField.textField:
			keyboardNextWasPressed()
			return false
		default:
			contentView.emailTextField.textField.becomeFirstResponder()
			return false
		}
	}
}

