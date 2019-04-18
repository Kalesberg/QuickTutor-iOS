//
//  ReportSuccessfulModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class ReportSuccessfulModal: BaseCustomModal {
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "We're sorry you've had this experience. \nWe'll be reviewing the report you've filed,\nand will update you on the status of the report."
        label.textColor = Colors.grayText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Fonts.createSize(14)
        return label
    }()

    let confirmButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Okay", for: .normal)
        button.setTitleColor(Colors.purple, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(16)
        button.layer.cornerRadius = 4
        return button
    }()

    override func setupViews() {
        super.setupViews()
        setupMessageLabel()
        setupConfirmButton()
        setHeightTo(160)
    }

    override func setupTitleLabel() {
        super.setupTitleLabel()
        titleLabel.text = "Report Successful"
    }

    func setupMessageLabel() {
        background.addSubview(messageLabel)
        messageLabel.anchor(top: titleLabel.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 75)
    }

    func setupConfirmButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(confirmButton)
        confirmButton.anchor(top: messageLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 35)
        window.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 0))
        confirmButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }
}
