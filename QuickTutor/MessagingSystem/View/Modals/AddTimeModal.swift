//
//  AddTimeModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class AddTimeModal: CustomTipModal {
    
    var delegate: AddTimeModalDelegate?
    
    override func setupTitleLabel() {
        super.setupTitleLabel()
        titleLabel.text = "ADD TIME"
    }
    
    override func setupInfoLabel() {
        super.setupInfoLabel()
        infoLabel.text = "Time is charged to payment method."
    }
    
    override func setupViews() {
        super.setupViews()
        priceInput.inputMode = .minutes
        priceInput.getFormattedMinutes()
    }
    
    override func setupCancelButton() {
        func setupCancelButton() {
            guard let window = UIApplication.shared.keyWindow else { return }
            background.addSubview(cancelTipButton)
            cancelTipButton.anchor(top: nil, left: nil, bottom: background.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 122, height: 35)
            window.addConstraint(NSLayoutConstraint(item: cancelTipButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: -75))
            cancelTipButton.addTarget(self, action: #selector(handleDecline), for: .touchUpInside)
        }
    }
    
    override func handleConfirm() {
        delegate?.addTimeModal(self, didAdd: Int(self.priceInput.currentPrice))
    }
    
    @objc func handleDecline() {
        delegate?.addTimeModalDidDecline(self)
        dismiss()
    }
}
