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
    
    override func setupViews() {
        super.setupViews()
        buttonDivider.removeFromSuperview()
        nevermindButton.removeFromSuperview()
        noteLabel.text = "You must have a payment method on file to continue. You won't be charged until you have a session."
        titleLabel.text = "Payment method"
    }
    
    override func setupHeight() {
        setHeightTo(140)
    }
    
    override func setupNoteLabel() {
        background.addSubview(noteLabel)
        noteLabel.anchor(top: titleLabel.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 7, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 35)
    }
    
    override func setupConfirmButton() {
        confirmButton.setTitle("Add Payment", for: .normal)
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(confirmButton)
        confirmButton.anchor(top: noteLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 35)
        window.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 0))
        confirmButton.addTarget(self, action: #selector(handleConfirmButton), for: [.touchUpInside, .touchDragExit])
    }
    
}
