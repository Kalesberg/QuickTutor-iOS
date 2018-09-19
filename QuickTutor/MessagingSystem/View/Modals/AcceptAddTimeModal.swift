//
//  AcceptAddTimeModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol AcceptAddTimeDelegate {
    func didAccept()
    func didDecline()
}

class AcceptAddTimeModal: BaseCustomModal {
    
    override func setupTitleLabel() {
        super.setupTitleLabel()
        titleLabel.text = "Learner requests to add time."
    }
    
    var delegate: AcceptAddTimeDelegate?
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(18)
        label.numberOfLines = 0
        label.text = "Collin would like to add 60 minutes to session."
        return label
    }()
    
    let paymentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(14)
        label.text = "You'll receive $20.00 for this session"
        return label
    }()
    
    let nevermindButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Decline", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.qtRed
        button.layer.cornerRadius = 4
        button.titleLabel?.font = Fonts.createSize(16)
        return button
    }()
    
    let confirmButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.green
        button.titleLabel?.font = Fonts.createSize(16)
        button.layer.cornerRadius = 4
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        setupInfoLabel()
        setupPaymentLabel()
        setupConfirmButton()
        setupNevermindButton()
    }
    
    func setupConfirmButton() {
        background.addSubview(confirmButton)
        confirmButton.anchor(top: paymentLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 11, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 35)
        background.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 75))
        confirmButton.addTarget(self, action: #selector(handleConfirmButton), for: .touchUpInside)
    }
    
    func setupNevermindButton() {
        background.addSubview(nevermindButton)
        nevermindButton.anchor(top: paymentLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 11, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 35)
        background.addConstraint(NSLayoutConstraint(item: nevermindButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: -75))
        nevermindButton.addTarget(self, action: #selector(handleNevermindButton), for: .touchUpInside)
    }
    
    func setupInfoLabel() {
        background.addSubview(infoLabel)
        infoLabel.anchor(top: titleBackground.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
    }
    
    func setupPaymentLabel() {
        background.addSubview(paymentLabel)
        paymentLabel.anchor(top: infoLabel.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 40)
    }
    
    @objc func handleNevermindButton() {
        dismiss()
        delegate?.didDecline()
    }
    
    @objc func handleConfirmButton() {
        dismiss()
        delegate?.didAccept()
    }
}
