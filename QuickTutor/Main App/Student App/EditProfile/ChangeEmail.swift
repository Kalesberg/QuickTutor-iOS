//
//  ChangeEmail.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
//TODO: Backend
//  - first letter not capitalized


import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

class ChangeEmailView : MainLayoutTitleBackButton, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	
	var textField = NoPasteTextField()
    var line = UIView()
	fileprivate var subtitle = LeftTextLabel()
	fileprivate var updateEmailButton = UpdateEmailButton()
	
	override func configureView() {
		addSubview(textField)
		addSubview(subtitle)
		addSubview(updateEmailButton)
		addKeyboardView()
        textField.addSubview(line)
		super.configureView()
		
		title.label.text = "Change E-mail"
		
		subtitle.label.text = "Enter new e-mail adress"
		subtitle.label.font = Fonts.createBoldSize(18)
		subtitle.label.numberOfLines = 2
        
        textField.tintColor = Colors.learnerPurple
        textField.font = Fonts.createSize(20)
        textField.isEnabled = true
        textField.textColor = Colors.grayText
        
        line.backgroundColor = Colors.registrationDark
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		subtitle.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.85)
			make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
			make.height.equalTo(30)
		}
		textField.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.85)
			make.top.equalTo(subtitle.snp.bottom).inset(-20)
			make.centerX.equalToSuperview()
		}
        
        line.snp.makeConstraints { (make) in
            make.bottom.equalTo(textField).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(1)
            make.centerX.equalToSuperview()
        }
		
		updateEmailButton.snp.makeConstraints { (make) in
			make.bottom.equalTo(keyboardView.snp.top)
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.08)
			make.centerX.equalToSuperview()
		}
	}
}
fileprivate class ChangeEmailTextField : InteractableView, Interactable {
	
	var textField = NoPasteTextField()
	var line = UIView()
	
	override func configureView() {
		addSubview(textField)
		addSubview(line)
		super.configureView()
		
		textField.isEnabled = true
		textField.font = Fonts.createSize(18)
		textField.keyboardAppearance = .dark
		textField.textColor = .white
		textField.tintColor = .white
		textField.keyboardType = .emailAddress
		line.backgroundColor = .white
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		textField.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
			make.height.equalTo(30)
		}
		
		line.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
			make.height.equalTo(1)
		}
	}
}

fileprivate class UpdateEmailButton : InteractableView, Interactable {
	
	var title = UILabel()
	
	override func configureView(){
		addSubview(title)
		super.configureView()
		
		isUserInteractionEnabled = true
		
		title.text = "Update Email"
		title.textColor = UIColor.white
		title.font = Fonts.createSize(20)
		title.textAlignment = .center
		title.adjustsFontSizeToFitWidth = true
		
		backgroundColor = UIColor(red: 0.3308961987, green: 0.2544008791, blue: 0.4683592319, alpha: 1)
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		title.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalToSuperview()
		}
	}
}

class ChangeEmail : BaseViewController {
	
	override var contentView: ChangeEmailView{
		return view as! ChangeEmailView
	}
	
	override func loadView() {
		view = ChangeEmailView()
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		contentView.textField.delegate = self
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.textField.becomeFirstResponder()
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		contentView.textField.resignFirstResponder()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func handleNavigation() {
		if (touchStartView is UpdateEmailButton) {
			verifyUpdate()
		}
	}
	private func verifyUpdate() {
		let emailText = contentView.textField.text
		guard let email = emailText, email.emailRegex() else {
			print("bad email")
			return
		}
		let password : String? = KeychainWrapper.standard.string(forKey: "emailAccountPassword")
		Auth.auth().signIn(withEmail: UserData.userData.email!, password: password!) { (user, error) in
			if let error = error {
				print(error)
			} else {
				user?.updateEmail(to: emailText!, completion: { (error) in
					if let error = error {
						print(error)
					} else {
						UserData.userData.email = emailText!
						FirebaseData.manager.updateValue(value: ["email" : emailText!])
						self.navigationController?.popViewController(animated: true)
					}
				})
			}
		}
	}
}
extension ChangeEmail : UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let maxlength = 40
		guard let text = textField.text else {return true}
		let length = text.count + string.count - range.length
		
		if length <= maxlength { return true }
		else { return false }
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		verifyUpdate()
		return false
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		contentView.textField.becomeFirstResponder()
	}
}


