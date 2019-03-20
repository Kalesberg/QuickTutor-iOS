//
//  TutorBioVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/17/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorBioVCView: BaseRegistrationView {
    
    let textView: MessageTextView = {
        let field = MessageTextView()
        field.layer.borderColor = Colors.gray.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 4
        field.placeholderLabel.text = "Enter a bio..."
        field.tintColor = .white
        field.font = Fonts.createSize(14)
        field.textColor = .white
        field.keyboardAppearance = .dark
        return field
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "• What experience or expertise do you have?\n• Any certifications or awards?\n• What are you looking for in learners?"
        label.font = Fonts.createSize(16)
        label.textColor = Colors.registrationGray
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupTextView()
        setupInfoLabel()
        setupErrorLabel()
    }
    
    func setupTextView() {
        addSubview(textView)
        textView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 130)
    }
    
    func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.anchor(top: textView.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 80)
    }
    
    func setupErrorLabel() {
        addSubview(errorLabel)
        errorLabel.anchor(top: nil, left: textView.leftAnchor, bottom: textView.bottomAnchor, right: textView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 15)
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "Biography"
        titleLabelHeightAnchor?.constant = 30
        layoutIfNeeded()
    }
}

