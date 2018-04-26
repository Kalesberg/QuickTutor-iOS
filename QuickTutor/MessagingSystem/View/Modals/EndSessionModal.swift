//
//  EndSessionModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class EndSessionModal: BaseCustomModal {
    
    let endSessionButton: UIButton = {
        let button = UIButton()
        button.setTitle("End Session", for: .normal)
        button.setTitleColor(Colors.qtRed, for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = Colors.qtRed.cgColor
        button.layer.cornerRadius = 4
        button.titleLabel?.font = Fonts.createSize(16)
        return button
    }()
    
    let nevermindButton: UIButton = {
        let button = UIButton()
        button.setTitle("Nevermind", for: .normal)
        button.setTitleColor(Colors.green, for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = Colors.green.cgColor
        button.layer.cornerRadius = 4
        button.titleLabel?.font = Fonts.createSize(16)
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        setupEndSessionButton()
        setupNevermindButton()
    }
    
    override func setupTitleLabel() {
        super.setupTitleLabel()
        titleLabel.text = "END THIS SESSION?"
    }
    
    override func setupBackground() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(background)
        background.anchor(top: nil, left: window.leftAnchor, bottom: nil, right: window.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 125)
        window.addConstraint(NSLayoutConstraint(item: background, attribute: .centerY, relatedBy: .equal, toItem: window, attribute: .centerY, multiplier: 1, constant: 0))
        background.alpha = 0
        background.layer.cornerRadius = 8
    }
    
    func setupEndSessionButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(endSessionButton)
        endSessionButton.anchor(top: nil, left: nil, bottom: background.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 122, height: 35)
        window.addConstraint(NSLayoutConstraint(item: endSessionButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: -75))
        endSessionButton.addTarget(self, action: #selector(endSession), for: .touchUpInside)
    }
    
    @objc func endSession() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "com.qt.showHomePage"), object: nil)
        dismiss()
        removeFromSuperview()
    }
    
    func setupNevermindButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(nevermindButton)
        nevermindButton.anchor(top: nil, left: nil, bottom: background.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 122, height: 35)
        window.addConstraint(NSLayoutConstraint(item: nevermindButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 75))
        nevermindButton.addTarget(self, action: #selector(handleNevermind), for: .touchUpInside)
    }
    
    @objc func handleNevermind() {
        dismiss()
        removeFromSuperview()
    }
    
}
