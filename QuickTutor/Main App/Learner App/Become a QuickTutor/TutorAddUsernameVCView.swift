//
//  TutorAddUsernameVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/17/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorAddUsernameVCView: BaseRegistrationView {
    
    let textField: RegistrationTextField = {
        let textField = RegistrationTextField()
        textField.placeholder.text = "Username"
        textField.textField.keyboardAppearance = .dark
        textField.textField.autocapitalizationType = .none
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
        setupErrorLabelBelow(textField)
        errorLabel.transform = CGAffineTransform(translationX: 0, y: -10)
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
