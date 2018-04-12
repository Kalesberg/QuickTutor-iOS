//
//  CustomModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol CustomModalDelegate {
    func handleNevermind()
    func handleCancel(id: String)
}

class CustomModal: UIView {
    
    var delegate: CustomModalDelegate?
    var sessionId: String!
    
    let backgroundBlurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    let background: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 30.0 / 255.0, green: 30.0 / 255.0, blue: 38.0 / 255.0, alpha: 1.0)
        return view
    }()
    
    let titleBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 76.0 / 255.0, green: 94.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ARE YOU SURE?"
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(18)
        label.numberOfLines = 0
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Are you sure you want to cancel this session?"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Fonts.createSize(12)
        return label
    }()
    
    let noteLabel: UILabel = {
        let label = UILabel()
        label.text = "NOTE: IF YOU CANCEL THIS TUTOR'S CANCELLATION POLICY, YOU MAY BE SUBJECT TO A CANCELLATION FEE"
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(12)
        label.numberOfLines = 0
        return label
    }()
    
    let nevermindButton: UIButton = {
        let button = UIButton()
        button.setTitle("Nevermind", for: .normal)
        button.setTitleColor(UIColor(red: 91.0 / 255.0, green: 81.0 / 255.0, blue: 162.0 / 255.0, alpha: 1.0), for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 91.0 / 255.0, green: 81.0 / 255.0, blue: 162.0 / 255.0, alpha: 1.0).cgColor
        button.layer.cornerRadius = 4
        button.titleLabel?.font = Fonts.createSize(16)
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ok, cancel", for: .normal)
        button.setTitleColor(UIColor(red: 91.0 / 255.0, green: 81.0 / 255.0, blue: 162.0 / 255.0, alpha: 1.0), for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 91.0 / 255.0, green: 81.0 / 255.0, blue: 162.0 / 255.0, alpha: 1.0).cgColor
        button.titleLabel?.font = Fonts.createSize(16)
        button.layer.cornerRadius = 4
        return button
    }()
    
    func setupViews() {
        setupBackgroundBlurView()
        setupBackground()
        setupTitleBackground()
        setupTitleLabel()
        setupMessageLabel()
        setupNoteLabel()
        setupNevermindButton()
        setupConfirmButton()
    }
    
    func setupBackground() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(background)
        background.anchor(top: nil, left: window.leftAnchor, bottom: nil, right: window.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 207)
        window.addConstraint(NSLayoutConstraint(item: background, attribute: .centerY, relatedBy: .equal, toItem: window, attribute: .centerY, multiplier: 1, constant: 0))
        background.alpha = 0
    }
    
    func setupBackgroundBlurView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(backgroundBlurView)
        backgroundBlurView.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backgroundBlurView.addGestureRecognizer(dismissTap)
        window.bringSubview(toFront: backgroundBlurView)
    }
    
    func setupTitleBackground() {
        background.addSubview(titleBackground)
        titleBackground.anchor(top: background.topAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
    }
    
    func setupTitleLabel() {
        background.addSubview(titleLabel)
        titleLabel.anchor(top: background.topAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
    }
    
    func setupMessageLabel() {
        background.addSubview(messageLabel)
        messageLabel.anchor(top: titleBackground.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 17)
    }
    
    func setupNoteLabel() {
        background.addSubview(noteLabel)
        noteLabel.anchor(top: messageLabel.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 7, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 45)
    }
    
    func setupNevermindButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(nevermindButton)
        nevermindButton.anchor(top: noteLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 11, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 35)
        window.addConstraint(NSLayoutConstraint(item: nevermindButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: -75))
        nevermindButton.addTarget(self, action: #selector(handleNevermindButton), for: .touchUpInside)
    }
    
    func setupConfirmButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(confirmButton)
        confirmButton.anchor(top: noteLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 11, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 35)
        window.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 75))
        confirmButton.addTarget(self, action: #selector(handleConfirmButton), for: .touchUpInside)
    }
    
    func show() {
        background.alpha = 1
    }
    
    @objc func dismiss() {
        background.alpha = 0
        backgroundBlurView.alpha = 0
    }
    
    @objc func handleNevermindButton() {
        dismiss()
    }
    
    @objc func handleConfirmButton() {
        
    }
    
    init(title: String, message: String, note: String, cancelText: String, confirmText: String) {
        super.init(frame: .zero)
        setupViews()
        titleLabel.text = title
        messageLabel.text = message
        noteLabel.text = note
        nevermindButton.setTitle(cancelText, for: .normal)
        confirmButton.setTitle(confirmText, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
