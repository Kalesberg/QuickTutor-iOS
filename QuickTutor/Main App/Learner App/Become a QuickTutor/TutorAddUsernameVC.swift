//
//  TutorAddUsername.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import Foundation
import UIKit

class TutorAddUsernameVC: BaseRegistrationController {

    let contentView: TutorAddUsernameVCView = {
        let view = TutorAddUsernameVCView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupTargets()
        progressView.setProgress(6/6)
    }

    override func loadView() {
        view = contentView
    }
    
    func setupTextField() {
        contentView.textField.textField.delegate = self
        contentView.textField.textField.becomeFirstResponder()
        contentView.textField.textField.inputAccessoryView = accessoryView
    }
    
    func setupTargets() {
        accessoryView.nextButton.addTarget(self, action: #selector(handleNext(_:)), for: .touchUpInside)
    }
    
    @objc func handleNext(_ sender: UIButton) {
        guard let username = contentView.textField.textField.text else { return }
        if isValidUsername(username: username) && endsWithSpecial(username: username) {
            displayLoadingOverlay()
            checkIfUsernamAlreadyExists(text: username) { success in
                if success {
                    TutorRegistration.username = username
                    self.navigationController?.pushViewController(TutorPolicyVC(), animated: true)
                    self.contentView.errorLabel.isHidden = true
                } else {
                    self.contentView.errorLabel.isHidden = false
                    self.contentView.errorLabel.text = "username already exists."
                }
                self.dismissOverlay()
            }
        } else {
            contentView.errorLabel.isHidden = false
            contentView.errorLabel.text = "Something went wrong. Please try again."
        }
    }
    
    func isValidUsername(username: String) -> Bool {
        let regex = "\\A\\w{3,15}\\z"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: username)
    }

    func endsWithSpecial(username: String) -> Bool {
        let lastChar = username.last!
        return lastChar != "_"
    }

    func checkIfUsernamAlreadyExists(text: String, completion: @escaping (Bool) -> Void) {
        Database.database().reference().child("tutor-info").queryOrdered(byChild: "usr").queryLimited(toFirst: 1).queryEqual(toValue: text).observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot.childrenCount == 0)
        })
    }
    
}

extension TutorAddUsernameVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn: "0123456789qwertyuioplkjhgfdsazxcvbnm_").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        if let _ = string.rangeOfCharacter(from: .uppercaseLetters) {
            return false
        }
        if textField.text!.count == 0 {
            return (string.rangeOfCharacter(from: .letters) != nil)
        }

        if textField.text!.count <= 15 {
            if string == "" {
                return true
            }
            return string == filtered
        } else {
            if string == "" {
                return true
            }
            return false
        }
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        return true
    }
}
