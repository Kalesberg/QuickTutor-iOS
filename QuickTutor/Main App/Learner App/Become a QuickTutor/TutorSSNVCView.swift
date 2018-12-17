//
//  TutorSSNVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/16/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorSSNView: BaseRegistrationView {
    
    let textField: RegistrationTextField = {
        let textField = RegistrationTextField()
        textField.placeholder.text = "Your SSN"
        textField.textField.keyboardType = .numberPad
        textField.textField.keyboardAppearance = .dark
        textField.textField.isSecureTextEntry = true
        return textField
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "For authentication and safety purposes, we'll need your social security number."
        label.numberOfLines = 0
        label.font = Fonts.createBoldSize(14)
        label.textColor = .white
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "· Your SSN remains private.\n· No credit check - credit won't be affected.\n· Your information is safe and secure."
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
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 30, width: 0, height: 35)
    }
    
    func setupTextField() {
        addSubview(textField)
        textField.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: titleLabel.rightAnchor, paddingTop: 75, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
    }
    
    func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.anchor(top: textField.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 80)
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "SSN"
    }
    
}
