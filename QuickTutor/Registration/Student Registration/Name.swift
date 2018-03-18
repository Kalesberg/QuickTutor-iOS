//
//  NameView.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/20/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//
// TODO: fix KeyboardShouldReturn -KeyboardPressed() - I AM A DINGUS
import UIKit

class NameView : RegistrationNavBarKeyboardView {
	
	var firstNameTextField = RegistrationTextField()
	var lastNameTextField  = RegistrationTextField()
	
	override func configureView() {
		super.configureView()
		print("name")
		contentView.addSubview(firstNameTextField)
		contentView.addSubview(lastNameTextField)
		
		navBar.progress = 0.286
		navBar.applyConstraints()
		
		titleLabel.label.text = "Hey, what's your name?"
		firstNameTextField.placeholder.text = "FIRST NAME"
		lastNameTextField.placeholder.text = "LAST NAME"
		
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
			make.height.equalToSuperview().multipliedBy(0.5)
		}
		
		lastNameTextField.snp.makeConstraints { (make) in
			make.top.equalTo(firstNameTextField.snp.bottom)
			make.left.equalTo(titleLabel)
			make.right.equalTo(titleLabel)
			make.height.equalToSuperview().multipliedBy(0.5)
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
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.firstNameTextField.textField.becomeFirstResponder()
	}
	
	override func handleNavigation() {
		if(touchStartView == contentView.backButton) {
			navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
			navigationController!.popToRootViewController(animated: false)
		} else if(touchStartView == contentView.nextButton) {
			if checkNameValidity() {
				Registration.firstName = contentView.firstNameTextField.textField.text!
				Registration.lastName = contentView.lastNameTextField.textField.text!
				navigationController?.pushViewController(Email(), animated: true)
			} else {
				print("Name Error")
			}
		}
	}
	
	private func keyboardNextWasPressed() {
		if checkNameValidity() {
			Registration.firstName = contentView.firstNameTextField.textField.text!
			Registration.lastName = contentView.lastNameTextField.textField.text!
			navigationController?.pushViewController(Email(), animated: true)
		} else {
			print("Name Error")
		}
	}
	
	private func checkNameValidity() -> Bool {
		if contentView.firstNameTextField.textField.text!.count < 2
			|| contentView.lastNameTextField.textField.text!.count < 2 {
			return false
		}
		return true
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
extension Name : UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let char = string.cString(using: String.Encoding.utf8)!
		let isBackSpace = strcmp(char, "\\b")
		
		if isBackSpace == Constants.BCK_SPACE {
			textField.text!.removeLast()
		}
		
		if textField.text!.count <= 24 {
			switch textField {
			case contentView.firstNameTextField.textField:
				if string.rangeOfCharacter(from: .letters) != nil {return true}
				return false
			case contentView.lastNameTextField.textField:
				if string.rangeOfCharacter(from: .letters) != nil {return true}
				return false
			default:
				contentView.lastNameTextField.textField.becomeFirstResponder()
				return false
			}
		} else {
			print("Your name is too long!")
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

