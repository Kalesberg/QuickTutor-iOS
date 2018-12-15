//
//  NameVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class NameVCView: BaseRegistrationView {
    
    let firstNameTextField: RegistrationTextField = {
        let registrationTextField = RegistrationTextField()
        registrationTextField.placeholder.text = "First Name"
        registrationTextField.textField.autocapitalizationType = .words
        registrationTextField.textField.returnKeyType = .next
        return registrationTextField
    }()
    
    let lastNameTextField: RegistrationTextField = {
        let registrationTextField = RegistrationTextField()
        registrationTextField.placeholder.text = "Last Name "
        registrationTextField.textField.autocapitalizationType = .words
        registrationTextField.textField.returnKeyType = .next
        return registrationTextField
    }()
    
    override func setupViews() {
        super.setupViews()
        setupFirstNameTextField()
        setupLastNameTextField()
        updateTitleLabel()
    }
    
    func setupFirstNameTextField() {
        addSubview(firstNameTextField)
        firstNameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.height.equalTo(100)
        }
    }
    
    func setupLastNameTextField() {
        addSubview(lastNameTextField)
        lastNameTextField.snp.makeConstraints { make in
            make.top.equalTo(firstNameTextField.snp.bottom)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.height.equalTo(100)
        }
    }
    
    func updateTitleLabel() {
        titleLabel.text = "Hey, what's your name?"
    }
    
}

