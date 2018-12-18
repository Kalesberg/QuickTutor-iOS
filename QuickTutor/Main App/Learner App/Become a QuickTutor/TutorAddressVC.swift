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
        guard let line1 = textFields[0].text, line1.streetRegex() else {
            contentView.addressLine1TextField.line.backgroundColor = Colors.qtRed
            validData = false
            return nil
        }
        contentView.addressLine1TextField.line.backgroundColor = Colors.green
        return line1
    }
    
    func validateCity() -> String? {
        guard let city = textFields[1].text, city.cityRegex() else {
            contentView.cityTextField.line.backgroundColor = Colors.qtRed
            validData = false
            return nil
        }
        contentView.cityTextField.line.backgroundColor = Colors.green
        return city
    }
    
    func validateState() -> String? {
        guard let state = textFields[2].text, state.stateRegex() else {
            contentView.stateTextField.line.backgroundColor = Colors.qtRed
            validData = false
            return nil
        }
        contentView.stateTextField.line.backgroundColor = Colors.green
        return state
    }
    
    func validateZip() -> String? {
        guard let zipcode = textFields[3].text, zipcode.zipcodeRegex() else {
            contentView.zipTextField.line.backgroundColor = Colors.qtRed
            validData = false
            return nil
        }
        contentView.zipTextField.line.backgroundColor = Colors.green
        return zipcode
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
}
