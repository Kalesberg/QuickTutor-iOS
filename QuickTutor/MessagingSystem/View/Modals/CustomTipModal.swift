//
//  CustomTipModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class CustomTipModal: BaseCustomModal {
    
    var parent: CustomTipPresenter?
    
    let priceInput: PriceInputView = {
        let view = PriceInputView()
        return view
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Tips are charged to payment method."
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(14)
        return label
    }()
    
    let cancelTipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(Colors.qtRed, for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = Colors.qtRed.cgColor
        button.layer.cornerRadius = 4
        button.titleLabel?.font = Fonts.createSize(16)
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(Colors.green, for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = Colors.green.cgColor
        button.layer.cornerRadius = 4
        button.titleLabel?.font = Fonts.createSize(16)
        return button
    }()
    
    func setupPriceInput() {
        background.addSubview(priceInput)
        priceInput.anchor(top: titleBackground.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 60)
    }
    
    func setupInfoLabel() {
        background.addSubview(infoLabel)
        infoLabel.anchor(top: priceInput.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    func setupCancelButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(cancelTipButton)
        cancelTipButton.anchor(top: nil, left: nil, bottom: background.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 122, height: 35)
        window.addConstraint(NSLayoutConstraint(item: cancelTipButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: -75))
        cancelTipButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }
    
    func setupConfirmButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(confirmButton)
        confirmButton.anchor(top: nil, left: nil, bottom: background.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 122, height: 35)
        window.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 75))
        confirmButton.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
    }
    
    @objc func handleConfirm() {
        parent?.amountToTip = priceInput.currentPrice
        dismiss()
    }
    
    override func setupTitleLabel() {
        super.setupTitleLabel()
        titleLabel.text = "Custom Tip"
    }
    
    override func setupViews() {
        super.setupViews()
        setupPriceInput()
        setupInfoLabel()
        setupCancelButton()
        setupConfirmButton()
    }
    
}

