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

class CustomModal: BaseCustomModal {
    
    var delegate: CustomModalDelegate?
    var sessionId: String!
    
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
    
    override func setupViews() {
        super.setupViews()
        setupMessageLabel()
        setupNoteLabel()
        setupNevermindButton()
        setupConfirmButton()
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
    
    @objc func handleNevermindButton() {
        dismiss()
    }
    
    @objc func handleConfirmButton() {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
