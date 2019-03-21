//
//  CreatePasswordVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class CreatePasswordVCView: BaseRegistrationView {
    
    let createPasswordTextfield: RegistrationTextField = {
        let registrationTextField = RegistrationTextField()
        registrationTextField.placeholder.text = "PASSWORD"
        registrationTextField.textField.isSecureTextEntry = true
        registrationTextField.textField.autocorrectionType = .no
        registrationTextField.textField.returnKeyType = .next
        return registrationTextField
    }()
    
    let passwordInfoLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = Colors.registrationGray
        label.text = "Your password must be at least 8 characters long"
        label.numberOfLines = 0
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupCreatePasswordField()
        setupPasswordInfoLabel()
        setupErrorLabelBelow(createPasswordTextfield)
    }
    
    func setupCreatePasswordField() {
        addSubview(createPasswordTextfield)
        createPasswordTextfield.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.height.equalTo(100)
        }
        
        if #available(iOS 12, *) {
            createPasswordTextfield.textField.textContentType = .oneTimeCode
        } else {
            createPasswordTextfield.textField.textContentType = .init(rawValue: "")
        }
        
    }
    
    func setupPasswordInfoLabel() {
        addSubview(passwordInfoLabel)
        passwordInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(createPasswordTextfield.snp.bottom).offset(40)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview()
            make.height.equalTo(22)
        }
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "Let's create a password"
        errorLabel.text = "Password is less than 8 characters"
        titleLabelHeightAnchor?.constant = 30
        layoutIfNeeded()
    }
}
