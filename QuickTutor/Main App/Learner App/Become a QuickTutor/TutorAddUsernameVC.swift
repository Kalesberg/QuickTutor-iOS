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

class TutorAddUsernameView: BaseRegistrationView {
    
    let textField: RegistrationTextField = {
        let textField = RegistrationTextField()
        textField.placeholder.text = "Username"
        textField.textField.keyboardAppearance = .dark
        return textField
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Having a unique username will help learners find you."
        label.font = Fonts.createBoldSize(14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Must not be londer than 15 characters."
        label.font = Fonts.createSize(16)
        label.textColor = Colors.registrationGray
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupSubtitleLabel()
        setupTextField()
        setupInfoLabel()
    }
    
    func setupSubtitleLabel() {
        addSubview(subtitleLabel)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 30, width: 0, height: 35)
    }
    
    func setupTextField() {
        addSubview(textField)
        textField.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: titleLabel.rightAnchor, paddingTop: 75, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
    }
    
    func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.anchor(top: textField.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "Create a username"
        titleLabelHeightAnchor?.constant = 30
        layoutIfNeeded()
    }
}

class TutorAddUsernameVC: BaseRegistrationController {

    let contentView: TutorAddUsernameView = {
        let view = TutorAddUsernameView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupTargets()
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

//    override func handleNavigation() {
//        if touchStartView is NavbarButtonNext {
//            let username = contentView.textField.textField.text!
//
//            if isValidUsername(username: username) && endsWithSpecial(username: username) {
//                displayLoadingOverlay()
//                checkIfUsernamAlreadyExists(text: username) { success in
//                    if success {
//                        TutorRegistration.username = username
//                        self.navigationController?.pushViewController(TutorPolicyVC(), animated: true)
//                        self.contentView.errorLabel.isHidden = true
//                    } else {
//                        self.contentView.errorLabel.isHidden = false
//                        self.contentView.errorLabel.text = "username already exists."
//                    }
//                    self.dismissOverlay()
//                }
//            } else {
//                contentView.errorLabel.isHidden = false
//                contentView.errorLabel.text = "Soemthing went wrong. Please try again."
//            }
//        }
//    }
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
