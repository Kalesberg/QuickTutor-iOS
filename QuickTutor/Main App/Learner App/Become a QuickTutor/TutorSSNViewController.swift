//
//  TutorSSNViewController.swift
//  QuickTutor
//
//  Created by Will Saults on 4/29/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

enum SSNTextFieldTag: Int {
    case areaNumber, groupNumber, serialNumber
}

class TutorSSNViewController: BaseRegistrationController {

    @IBOutlet weak var ssnAreaNumberTextField: BorderedTextField!
    @IBOutlet weak var ssnGroupNumberTextField: BorderedTextField!
    @IBOutlet weak var ssnSerialNumberTextField: BorderedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        hideKeyboardWhenTappedAround()
        progressView.setProgress(3/6)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTextFields()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)
    }
    
    func setupTargets() {
        nextButton(isEnabled: false)
        accessoryView.nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
    }
    
    func nextButton(isEnabled: Bool) {
        accessoryView.nextButton.isEnabled = isEnabled
        accessoryView.nextButton.backgroundColor = isEnabled ? Colors.purple : Colors.gray
    }
    
    func setupTextFields() {
        ssnAreaNumberTextField.becomeFirstResponder()
        ssnAreaNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        ssnGroupNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        ssnSerialNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        ssnAreaNumberTextField.inputAccessoryView = accessoryView
        ssnGroupNumberTextField.inputAccessoryView = accessoryView
        ssnSerialNumberTextField.inputAccessoryView = accessoryView
    }
    
    @objc func handleNext() {
        if checkForValidSSN() {
            TutorRegistration.ssn = ssnText(formatted: false) ?? ""
            let vc = TutorAddBank()
            vc.isRegistration = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        let length = textField.text?.utf16.count
        var maxLength = 3
        var nextField: BorderedTextField?
        if let ssnTag = SSNTextFieldTag(rawValue: textField.tag) {
            switch ssnTag {
            case .groupNumber:
                maxLength = 2
                nextField = ssnSerialNumberTextField
            case .serialNumber:
                maxLength = 4
            default:
                maxLength = 3
                nextField = ssnGroupNumberTextField
            }
        }
        
        if let nextField = nextField, length == maxLength {
            nextField.becomeFirstResponder()
        }
        
        nextButton(isEnabled: checkForValidSSN())
    }
    
    func checkForValidSSN() -> Bool {
        return isValidSSN(ssnText(formatted: true) ?? "")
    }
    
    func ssnText(formatted: Bool) -> String? {
        guard let area = ssnAreaNumberTextField?.text, let group = ssnGroupNumberTextField?.text, let serial = ssnSerialNumberTextField?.text else {
            return nil
        }
        
        let delimiter = formatted ? "-" : ""
        return "\(area)\(delimiter)\(group)\(delimiter)\(serial)"
    }
    
    func isValidSSN(_ ssn: String) -> Bool {
        let ssnRegext = "^(?!(000|666|9))\\d{3}-(?!00)\\d{2}-(?!0000)\\d{4}$"
        return ssn.range(of: ssnRegext, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

extension TutorSSNViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        guard let text = textField.text else { return true }
        let newLength = text.utf16.count + string.utf16.count - range.length

        var maxLength = 3
        if let ssnTag = SSNTextFieldTag(rawValue: textField.tag) {
            switch ssnTag {
            case .groupNumber:
                maxLength = 2
            case .serialNumber:
                maxLength = 4
            default:
                maxLength = 3
            }
        }
        
        return string == filtered && newLength <= maxLength
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
}

@IBDesignable
class BorderedTextField: NoPasteTextField {
    @IBInspectable var borderColor: UIColor = Colors.qtRed {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var placeHolderColor: UIColor? {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeHolderColor ?? UIColor.white])
        }
    }
}
