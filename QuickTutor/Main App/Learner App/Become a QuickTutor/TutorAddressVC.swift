//
//  TutorAddress.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/20/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit
import SnapKit

class TutorAddressVC: BaseRegistrationController {

    let contentView: TutorAddressVCView = {
        let view = TutorAddressVCView()
        return view
    }()

    override func loadView() {
        view = contentView
    }

    private var textFields: [UITextField] = []
    private var addressString = ""
    private var validData: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        setupTextFields()
        progressView.setProgress(5/6)
        accessoryView.nextButton.setTitle("NEXT", for: .normal)
    }
    
    func setupTargets() {
        accessoryView.nextButton.addTarget(self, action: #selector(handleNext(_:)), for: .touchUpInside)
    }
    
    func setupTextFields() {
        textFields = [contentView.addressLine1TextField.textField, contentView.cityTextField.textField, contentView.stateTextField.textField, contentView.zipTextField.textField]
        
        for textField in textFields {
            textField.delegate = self
            textField.returnKeyType = .next
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            textField.inputAccessoryView = accessoryView
        }
        textFields[0].becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.resignFirstResponder()
    }
    
    @objc private func textFieldDidChange(_: UITextField) {
        guard let line1 = validateAddress() else { return }
        guard let city = validateCity() else { return }
        guard let state = validateState() else { return }
        guard let zipcode = validateZip() else { return }
        addressString = line1 + " " + city + " " + state + ", " + zipcode
        validData = true
    }
    
    func validateAddress() -> String? {
        let registrationTextField = contentView.addressLine1TextField
        return validateRegex(registrationTextField, regex: registrationTextField.textField.text?.streetRegex() ?? false)
    }
    
    func validateCity() -> String? {
        let registrationTextField = contentView.cityTextField
        return validateRegex(registrationTextField, regex: registrationTextField.textField.text?.cityRegex() ?? false)
    }
    
    func validateState() -> String? {
        let registrationTextField = contentView.stateTextField
        return validateRegex(registrationTextField, regex: registrationTextField.textField.text?.stateRegex() ?? false)
    }
    
    func validateZip() -> String? {
        let registrationTextField = contentView.zipTextField
        return validateRegex(registrationTextField, regex: registrationTextField.textField.text?.zipcodeRegex() ?? false)
    }
    
    private func validateRegex(_ registrationTextField: RegistrationTextField, regex: Bool) -> String? {
        guard let text = registrationTextField.textField.text, regex else {
            invalidateFor(textField: registrationTextField)
            return nil
        }
        validateFor(textField: registrationTextField)
        return text
    }
    
    private func invalidateFor(textField: RegistrationTextField) {
        if let text = textField.textField.text, !text.isEmpty {
            updateTextFieldUI(textField: textField, isValid: false)
        }
        validData = false
    }
    
    private func validateFor(textField: RegistrationTextField) {
        updateTextFieldUI(textField: textField, isValid: true)
    }
    
    private func updateTextFieldUI(textField: RegistrationTextField, isValid: Bool) {
        let lineColor = isValid ? Colors.green : Colors.qtRed
        let fileName = isValid ? "circleCheck" : "attention"
        let tintColor = isValid ? nil : Colors.qtRed
        
        textField.line.backgroundColor = lineColor
        textField.textField.rightView = rightView(named: fileName, tintColor: tintColor)
        textField.textField.rightViewMode = .unlessEditing
    }
    
    private func setTextFieldPlaceholderColor(_ textField: RegistrationTextField, isValid: Bool) {
        textField.placeholder.textColor = isValid ? UIColor.white : Colors.qtRed
    }
    
    private func rightView(named name: String, tintColor: UIColor? = nil) -> UIImageView {
        let rightView = UIImageView(image: UIImage(named: name))
        rightView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        
        if let color = tintColor {
            rightView.overlayTintColor(color: color)
        }
        
        return rightView
    }
    
    @objc func handleNext(_ sender: UIButton) {
        if textFields[0].isFirstResponder {
            textFields[1].becomeFirstResponder()
        } else if textFields[1].isFirstResponder {
            textFields[2].becomeFirstResponder()
        } else if textFields[2].isFirstResponder {
            textFields[3].becomeFirstResponder()
            accessoryView.nextButton.setTitle("CONTINUE", for: .normal)
        } else if textFields[3].isFirstResponder {
            continueToNextScreen()
        }
    }
    
    func continueToNextScreen() {
        guard validData else { return }
        displayLoadingOverlay()
        TutorLocationFormatter.convertAddressToLatLong(addressString: addressString) { error in
            if error != nil {
                AlertController.genericErrorAlertWithoutCancel(self, title: "Unable to Find Address", message: "Please make sure your information is correct.")
            } else {
                self.navigationController?.pushViewController(TutorAddUsernameVC(), animated: true)
            }
            self.dismissOverlay()
        }
    }

}

extension TutorAddressVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn: "0123456789-").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if newLength == 0 {
            updatePlaceholderColorIfNeeded(textField)
        } else {
            resetPlaceholderColor(textField)
        }

        switch textField {
        case textFields[0]:
            return newLength < 30
        case textFields[1]:
            if string == "" { return true }
            return !(string == filtered)
        case textFields[2]:
            if string == "" { return true }
            if newLength > 2 {
                return false
            } else {
                return !(string == filtered)
            }
        case textFields[3]:
            if newLength <= 10 {
                return string == filtered
            }
            return false
        default:
            break
        }
        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case textFields[0]:
            textFields[1].becomeFirstResponder()
        case textFields[1]:
            textFields[2].becomeFirstResponder()
        case textFields[2]:
            textFields[3].becomeFirstResponder()
            accessoryView.nextButton.setTitle("CONTINUE", for: .normal)
        default:
            break
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else { return }
        resetPlaceholderColor(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updatePlaceholderColorIfNeeded(textField)
    }
    
    func updatePlaceholderColorIfNeeded(_ textField: UITextField) {
        guard let rightView = textField.rightView else { return }
        if rightView.tintColor == Colors.qtRed {
            findAndUpdatePlaceholderColor(textField)
        }
    }
    
    func findAndUpdatePlaceholderColor(_ textField: UITextField) {
        switch textField {
        case textFields[0]:
            let isValid = textField.text?.streetRegex()
            setTextFieldPlaceholderColor(contentView.addressLine1TextField, isValid: isValid ?? false)
        case textFields[1]:
            let isValid = textField.text?.cityRegex()
            setTextFieldPlaceholderColor(contentView.cityTextField, isValid: isValid ?? false)
        case textFields[2]:
            let isValid = textField.text?.stateRegex()
            setTextFieldPlaceholderColor(contentView.stateTextField, isValid: isValid ?? false)
        case textFields[3]:
            let isValid = textField.text?.zipcodeRegex()
            setTextFieldPlaceholderColor(contentView.zipTextField, isValid: isValid ?? false)
        default:
            break
        }
    }
    
    func resetPlaceholderColor(_ textField: UITextField) {
        switch textField {
        case textFields[0]:
            contentView.addressLine1TextField.placeholder.textColor = UIColor.white
        case textFields[1]:
            contentView.cityTextField.placeholder.textColor = UIColor.white
        case textFields[2]:
            contentView.stateTextField.placeholder.textColor = UIColor.white
        case textFields[3]:
            contentView.zipTextField.placeholder.textColor = UIColor.white
        default:
            break
        }
    }
}
