//
//  TutorSSN.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import SnapKit
import UIKit

class TutorSSNVC: BaseRegistrationController {
    let contentView: TutorSSNView = {
        let view = TutorSSNView()
        return view
    }()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        hideKeyboardWhenTappedAround()
        setupTextField()
    }
    
    func setupTargets() {
        accessoryView.nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
    }
    
    func setupTextField() {
        contentView.textField.textField.delegate = self
        contentView.textField.becomeFirstResponder()
        contentView.textField.textField.inputAccessoryView = accessoryView
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.resignFirstResponder()
    }
    
    @objc func handleNext() {
        if let tutorSSN = checkForValidSSN() {
            TutorRegistration.ssn = tutorSSN
            navigationController?.pushViewController(TutorRegPaymentVC(), animated: true)
        }
    }

    func checkForValidSSN() -> String? {
        guard let ssn = contentView.textField.textField.text,
            ssn.count == 9,
            CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: ssn))
        else {
            return nil
        }
        return ssn
    }

    
}

extension TutorSSNVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        guard let text = textField.text else { return true }
        let newLength = text.utf16.count + string.utf16.count - range.length

        return string == filtered && newLength <= 9
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
}
