//
//  CancelSessionModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol CancelModalDelegate {
    func handleNevermind()
    func handleCancel(id: String)
}

class CancelSessionModal: UIView {
    
    var delegate: CancelModalDelegate?
    var sessionId: String!
    
    let titleBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 76.0/255.0, green: 94.0/255.0, blue: 141.0/255.0, alpha: 1.0)
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 8
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
        button.setTitleColor(UIColor(red: 91.0/255.0, green: 81.0/255.0, blue: 162.0/255.0, alpha: 1.0), for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 91.0/255.0, green: 81.0/255.0, blue: 162.0/255.0, alpha: 1.0).cgColor
        button.layer.cornerRadius = 4
        button.titleLabel?.font = Fonts.createSize(16)
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ok, cancel", for: .normal)
        button.setTitleColor(UIColor(red: 91.0/255.0, green: 81.0/255.0, blue: 162.0/255.0, alpha: 1.0), for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 91.0/255.0, green: 81.0/255.0, blue: 162.0/255.0, alpha: 1.0).cgColor
        button.titleLabel?.font = Fonts.createSize(16)
        button.layer.cornerRadius = 4
        return button
    }()
    
    func setupViews() {
        setupMainView()
        setupTitleBackground()
        setupTitleLabel()
        setupMessageLabel()
        setupNoteLabel()
        setupNevermindButton()
        setupConfirmButton()
    }
    
    func setupMainView() {
        backgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setupTitleBackground() {
        addSubview(titleBackground)
        titleBackground.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
    }
    
    func setupMessageLabel() {
        addSubview(messageLabel)
        messageLabel.anchor(top: titleBackground.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 17)
    }
    
    func setupNoteLabel() {
        addSubview(noteLabel)
        noteLabel.anchor(top: messageLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 7, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 45)
    }
    
    func setupNevermindButton() {
        addSubview(nevermindButton)
        nevermindButton.anchor(top: noteLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 11, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 35)
        addConstraint(NSLayoutConstraint(item: nevermindButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: -75))
        nevermindButton.addTarget(self, action: #selector(handleNevermindButton), for: .touchUpInside)
    }
    
    func setupConfirmButton() {
        addSubview(confirmButton)
        confirmButton.anchor(top: noteLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 11, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 35)
        addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 75))
        confirmButton.addTarget(self, action: #selector(handleConfirmButton), for: .touchUpInside)
    }
    
    @objc func handleNevermindButton() {
        delegate?.handleNevermind()
    }
    
    @objc func handleConfirmButton() {
        delegate?.handleCancel(id: sessionId)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
