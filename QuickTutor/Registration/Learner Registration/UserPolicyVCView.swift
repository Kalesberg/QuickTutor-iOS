//
//  UserPolicyVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/16/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class UserPolicyVCView: BaseRegistrationView {
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(16)
        label.numberOfLines = 0
        label.textColor = Colors.registrationGray
        label.text = "Whether it's your first time on QuickTutor or you've been with us from the very beginning, please commit to respecting and loving everyone in the QuickTutor community.\n\nI agree to treat everyone on QuickTutor regardless of their race, physical features, national origin, ethnicity, religion, sex, disability, gender identity, sexual orientation or age with respect and love, without judgement or bias."
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        return label
    }()
    
    let buttonView = UIView()
    
    let learnMoreButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Fonts.createSize(16)
        button.setTitle("Learn More", for: .normal)
        button.setTitleColor(Colors.purple, for: .normal)
        button.titleLabel?.textAlignment = .left
        return button
    }()
    
    let acceptButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Accept", for: .normal)
        button.backgroundColor = Colors.purple
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.layer.cornerRadius = 4
        return button
    }()
    
    let declineButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Decline", for: .normal)
        button.layer.borderColor = Colors.gray.cgColor
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        setupTextLabel()
        setupLearnMoreButton()
        setupAcceptButton()
        setupDeclineButton()
    }
    
    func setupTextLabel() {
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(250)
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalToSuperview().inset(30)
        }
    }
    
    func setupLearnMoreButton() {
        addSubview(learnMoreButton)
        learnMoreButton.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom)
            make.height.equalTo(20)
            make.width.equalTo(90)
            make.left.equalTo(textLabel.snp.left)
        }
    }
    
    func setupAcceptButton() {
        addSubview(acceptButton)
        acceptButton.snp.makeConstraints { make in
            make.height.equalTo(45)
            make.width.equalTo(145)
            make.centerX.equalToSuperview()
            make.top.equalTo(learnMoreButton.snp.bottom).offset(100)
        }
    }
    
    func setupDeclineButton() {
        addSubview(declineButton)
        declineButton.snp.makeConstraints { make in
            make.height.equalTo(45)
            make.width.equalTo(145)
            make.centerX.equalToSuperview()
            make.top.equalTo(acceptButton.snp.bottom).offset(20)
        }
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "Before you join"
        titleLabelHeightAnchor?.constant = 30
        layoutIfNeeded()
    }
}
