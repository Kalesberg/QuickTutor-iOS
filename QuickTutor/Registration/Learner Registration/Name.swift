//
//  NameView.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/20/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//
import UIKit

class NameView : RegistrationNavBarKeyboardView {
	
	var firstNameTextField = RegistrationTextField()
	var lastNameTextField  = RegistrationTextField()
	
	override func configureView() {
		super.configureView()
		contentView.addSubview(firstNameTextField)
		contentView.addSubview(lastNameTextField)
		
        progressBar.progress = 0.2
        progressBar.applyConstraints()
		
		titleLabel.label.text = "Hey, what's your name?"
		firstNameTextField.placeholder.text = "FIRST NAME"
		lastNameTextField.placeholder.text = "LAST NAME"
        errorLabel.text = "Must fill out both fields"
		
		let textFields = [firstNameTextField.textField, lastNameTextField.textField]
		for textField in textFields{
			textField.autocapitalizationType = .words
			textField.returnKeyType = .next
		}
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		firstNameTextField.snp.makeConstraints { (make) in
			make.top.equalTo(titleLabel.snp.bottom)
			make.left.equalTo(titleLabel)
			make.right.equalTo(titleLabel)
			make.height.equalToSuperview().multipliedBy(0.47)
		}
		
		lastNameTextField.snp.makeConstraints { (make) in
			make.top.equalTo(firstNameTextField.snp.bottom)
			make.left.equalTo(titleLabel)
			make.right.equalTo(titleLabel)
			make.height.equalToSuperview().multipliedBy(0.47)
		}
	}
}

class Name : BaseViewController {
	
	override var contentView : NameView {
		return view as! NameView
	}
	
	override func loadView() {
		view = NameView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		contentView.firstNameTextField.textField.delegate = self
		contentView.lastNameTextField.textField.delegate = self
		
		contentView.firstNameTextField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		contentView.lastNameTextField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.firstNameTextField.textField.becomeFirstResponder()
	}
	
	@objc private func textFieldDidChange(_ sender : UITextField) {
		
		guard checkNameValidity() else { return }
		
		//show animation/UI-ish here.

	}
	
	override func handleNavigation() {
		if(touchStartView == contentView.backButton) {
			navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
			navigationController!.popToRootViewController(animated: false)
		} else if(touchStartView == contentView.nextButton) {
			if checkNameValidity() {
                contentView.errorLabel.isHidden = true
				Registration.name = "\(contentView.firstNameTextField.textField.text!) \(contentView.lastNameTextField.textField.text!)"

				navigationController?.pushViewController(Email(), animated: true)
			} else {
				contentView.errorLabel.isHidden = false
			}
		}
	}
	
	private func keyboardNextWasPressed() {
		if checkNameValidity() {
            contentView.errorLabel.isHidden = true
			Registration.name = "\(contentView.firstNameTextField.textField.text!) \(contentView.lastNameTextField.textField.text!)"
			navigationController?.pushViewController(Email(), animated: true)
		} else {
            contentView.errorLabel.isHidden = false
		}
	}
	
	private func checkNameValidity() -> Bool {
		if contentView.firstNameTextField.textField.text!.count >= 1
			&& contentView.lastNameTextField.textField.text!.count >= 1 {
			return true
		}
		return !true //LOL
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
extension Name : UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

		let inverseSet = NSCharacterSet(charactersIn:"0123456789@#$%^&*()_=+<>?,[]{}/;'~!").inverted //Add any extra characters here..
		let components = string.components(separatedBy: inverseSet)
		let filtered = components.joined(separator: "")
		
		if string == " " {
			return false
		}
		
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
		switch(textField){
		case contentView.firstNameTextField.textField:
			contentView.lastNameTextField.textField.becomeFirstResponder()
			return false
		case contentView.lastNameTextField.textField:
			keyboardNextWasPressed()
			return false
		default:
			contentView.lastNameTextField.textField.becomeFirstResponder()
			return false
		}
	}
}

