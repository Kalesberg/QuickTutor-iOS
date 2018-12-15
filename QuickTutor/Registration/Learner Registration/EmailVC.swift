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

class EmailVC: BaseRegistrationController {
    
    let contentView: EmailVCView = {
        let view = EmailVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        contentView.emailTextField.textField.delegate = self
        contentView.emailTextField.textField.becomeFirstResponder()
        contentView.emailTextField.textField.inputAccessoryView = accessoryView
    }
    
    @objc func nextButtonPress() {
        guard (contentView.emailTextField.textField.text!).emailRegex() else {
            showErrorMessage()
            return
        }
        
        displayLoadingOverlay()
        Auth.auth().fetchProviders(forEmail: contentView.emailTextField.textField.text!, completion: { response, error in
            guard error == nil else {
                self.dismissOverlay()
                return
            }
            
            if response == nil {
                self.dismissOverlay()
                self.contentView.errorLabel.isHidden = true
                Registration.email = self.contentView.emailTextField.textField.text!
                self.navigationController?.pushViewController(CreatePasswordVC(), animated: true)
            } else {
                self.dismissOverlay()
                self.contentView.errorLabel.isHidden = false
                self.contentView.errorLabel.text = "Email already in use."
            }
        })

    }
    
    func showErrorMessage() {
        contentView.errorLabel.isHidden = false
        contentView.errorLabel.text = "The provided Email is not valid"
    }
    
    func setupTargets() {
        accessoryView.nextButton.addTarget(self, action: #selector(nextButtonPress), for: .touchUpInside)
    }
    
    private func keyboardNextWasPressed() {
        nextButtonPress()
    }
    
}
extension EmailVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxlength = 40
        guard let text = textField.text else { return true }
        let length = text.count + string.count - range.length
        
        if length <= maxlength { return true }
        else { return false }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case contentView.emailTextField.textField:
            keyboardNextWasPressed()
            return false
        default:
            contentView.emailTextField.textField.becomeFirstResponder()
            return false
        }
    }
}
