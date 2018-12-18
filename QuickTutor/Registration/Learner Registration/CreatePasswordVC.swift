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

class CreatePasswordVC: BaseRegistrationController {
    
    let contentView: CreatePasswordVCView = {
        let view = CreatePasswordVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        setupPasswordField()
        progressView.setProgress(3/5)
    }
    
    func setupTargets() {
        accessoryView.nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
    }

    @objc func handleNext() {
        keyboardNextWasPressed()
    }
    
    func setupPasswordField() {
        contentView.createPasswordTextfield.textField.delegate = self
        contentView.createPasswordTextfield.textField.becomeFirstResponder()
        contentView.createPasswordTextfield.textField.inputAccessoryView = accessoryView
    }
    
    func createEmailAccount() {
        let password: String? = KeychainWrapper.standard.string(forKey: "emailAccountPassword")
        displayLoadingOverlay()
        let emailCredential = EmailAuthProvider.credential(withEmail: Registration.email, password: password!)
        Registration.emailCredential = emailCredential
        dismissOverlay()
        navigationController?.pushViewController(BirthdayVC(), animated: true)
        contentView.createPasswordTextfield.textField.text = ""
    }
    
    func keyboardNextWasPressed() {
        if checkPasswordValidity() {
            contentView.errorLabel.isHidden = true
            createEmailAccount()
        } else {
            contentView.errorLabel.isHidden = false
        }
    }
    
    func checkPasswordValidity() -> Bool {
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
        
        return length <= maxlength
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
