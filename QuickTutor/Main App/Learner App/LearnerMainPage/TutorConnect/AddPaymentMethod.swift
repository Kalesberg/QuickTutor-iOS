//
//  AddPaymentMethod.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

protocol AddPaymentButtonPress {
    func dismissPaymentModal()
}

class AddPaymentModal: CustomModal {
    
    let icon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "addPaymentIcon")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.backgroundColor = Colors.gray
        return view
    }()
    
    override func setupViews() {
        setupIcon()
        super.setupViews()
        setupSeparator()
        background.backgroundColor = Colors.modalBackground
        buttonDivider.removeFromSuperview()
        nevermindButton.removeFromSuperview()
        noteLabel.text = "QuickTutor is a cashless payment experience. You must have a payment method on file to enter a session with a tutor. There are no subscription fees or upfront payments. You will only be charged after your session"
        titleLabel.text = "Wait a minute"
    }
    
    func setupIcon() {
        background.addSubview(icon)
        icon.anchor(top: background.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 70, height: 50)
        background.addConstraint(NSLayoutConstraint(item: icon, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: -5))
    }
    
    func setupSeparator() {
        background.addSubview(separator)
        separator.anchor(top: noteLabel.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 1)
    }
    
    override func setupTitleLabel() {
        background.addSubview(titleLabel)
        titleLabel.anchor(top: icon.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    override func setupHeight() {
        setHeightTo(280)
    }
    
    override func setupNoteLabel() {
        background.addSubview(noteLabel)
        noteLabel.anchor(top: titleLabel.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 7, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 80)
    }
    
    override func setupConfirmButton() {
        confirmButton.setTitle("Add Payment Method!", for: .normal)
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(confirmButton)
        confirmButton.anchor(top: noteLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 180, height: 35)
        window.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 0))
        confirmButton.addTarget(self, action: #selector(handleConfirmButton), for: [.touchUpInside, .touchDragExit])
    }
    
}
