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

class CreatePasswordView: RegistrationNavBarKeyboardView {
    
	let createPasswordTextfield : RegistrationTextField = {
		let registrationTextField = RegistrationTextField()
		registrationTextField.placeholder.text = "PASSWORD"
		registrationTextField.textField.isSecureTextEntry = true
		registrationTextField.textField.autocorrectionType = .no
		registrationTextField.textField.returnKeyType = .next
		return registrationTextField
	}()
	let passwordInfo : LeftTextLabel = {
		let leftTextLabel = LeftTextLabel()
		leftTextLabel.label.font = Fonts.createSize(20)
		leftTextLabel.label.text = "Your password must be at least 8 characters long"
		return leftTextLabel
	}()
    
    override func configureView() {
        super.configureView()
        contentView.addSubview(createPasswordTextfield)
        contentView.addSubview(passwordInfo)
        
        progressBar.progress = 0.6
        progressBar.applyConstraints()
        
        titleLabel.label.text = "Let's create a password"
        titleLabel.label.adjustsFontSizeToFitWidth = true
        titleLabel.label.adjustsFontForContentSizeCategory = true
		
		errorLabel.text = "Password is less than 8 characters"
		
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        createPasswordTextfield.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.47)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        passwordInfo.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}

class CreatePasswordVC: BaseViewController {
    
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
        contentView.createPasswordTextfield.textField.becomeFirstResponder()
        contentView.nextButton.isUserInteractionEnabled = true
        
    }
    
    override func handleNavigation() {
        if touchStartView == contentView.backButton {
            navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
            navigationController!.popViewController(animated: false)
        } else if touchStartView == contentView.nextButton {
            contentView.nextButton.isUserInteractionEnabled = false
            if checkPasswordValidity() {
                contentView.errorLabel.isHidden = true
                createEmailAccount()
            } else {
                contentView.errorLabel.isHidden = false
                contentView.nextButton.isUserInteractionEnabled = true
            }
        }
    }
    private func createEmailAccount() {
        let password: String? = KeychainWrapper.standard.string(forKey: "emailAccountPassword")
        displayLoadingOverlay()
        let emailCredential = EmailAuthProvider.credential(withEmail: Registration.email, password: password!)
        Registration.emailCredential = emailCredential
        dismissOverlay()
        navigationController!.pushViewController(BirthdayVC(), animated: true)
        contentView.createPasswordTextfield.textField.text = ""
        
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
            return KeychainWrapper.standard.set(contentView.createPasswordTextfield.textField.text!, forKey: "emailAccountPassword")
        }
        return false
    }
}
extension CreatePasswordVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxlength = 32
        guard let text = textField.text else { return true }
        let length = (text.count + string.count) - range.length
        if length <= maxlength {
            return true
        } else {
            return false
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case contentView.createPasswordTextfield.textField:
            keyboardNextWasPressed()
            return false
        default:
            contentView.createPasswordTextfield.textField.becomeFirstResponder()
            return false
        }
    }
}
