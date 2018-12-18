//
//  NameView.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/20/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//
import UIKit

class NameVC: BaseRegistrationController {
    
    var contentView: NameVCView {
        return view as! NameVCView
    }
    
    override func loadView() {
        view = NameVCView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        setupTextFields()
        progressView.setProgress(1/5)
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField) {
        guard checkNameValidity() else { return }
    }
    
    func setupTextFields() {
        setupFirstNameTextField()
        setupLastNameTextField()
    }
    
    func setupFirstNameTextField() {
        contentView.firstNameTextField.textField.delegate = self
        contentView.firstNameTextField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        contentView.firstNameTextField.textField.inputAccessoryView = accessoryView
        contentView.firstNameTextField.textField.becomeFirstResponder()
    }
    
    func setupLastNameTextField() {
        contentView.lastNameTextField.textField.delegate = self
        contentView.lastNameTextField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        contentView.lastNameTextField.textField.inputAccessoryView = accessoryView
    }
    
    func setupTargets() {
        accessoryView.nextButton.addTarget(self, action: #selector(next(_:)), for: .touchUpInside)
    }
    
    @objc func next(_ sender: UIButton) {
        keyboardNextWasPressed()
    }
    
    private func keyboardNextWasPressed() {
        if checkNameValidity() {
            //            contentView.errorLabel.isHidden = true
            Registration.name = "\(contentView.firstNameTextField.textField.text!) \(contentView.lastNameTextField.textField.text!)"
            navigationController?.pushViewController(EmailVC(), animated: true)
        } else {
            //            contentView.errorLabel.isHidden = false
        }
    }
    
    private func checkNameValidity() -> Bool {
        return contentView.firstNameTextField.textField.text!.count >= 1
            && contentView.lastNameTextField.textField.text!.count >= 1
    }
    
}
extension NameVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let inverseSet = NSCharacterSet(charactersIn: "0123456789@#$%^&*()_=+<>?,[]{}/;'~!").inverted // Add any extra characters here..
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")
        
        guard string != " " else { return false }

        if textField.text!.count <= 24 {
            if string == "" {
                return true
            }
            return !(string == filtered)
        } else {
            return string == ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
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
