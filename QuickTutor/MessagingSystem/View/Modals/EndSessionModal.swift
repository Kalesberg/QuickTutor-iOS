//
//  EndSessionModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol EndSessionModalDelegate {
    func endSessionModalDidConfirm(_ endSessionModal: EndSessionModal)
}

class EndSessionModal: BaseCustomModal {
    let endSessionButton: DimmableButton = {
        let button = DimmableButton()
        if AccountService.shared.currentUserType == .tutor {
            button.setTitle("End Session?", for: .normal)
        } else {
            button.setTitle("End Session", for: .normal)
        }
        button.setTitleColor(Colors.purple, for: .normal)
        button.titleLabel?.font = Fonts.createSize(16)
        return button
    }()
    
    let buttonDivider: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.backgroundColor = Colors.gray
        return view
    }()


    let nevermindButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Never mind", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createSize(16)
        return button
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        
        if AccountService.shared.currentUserType == .tutor {
            label.text = "Please make sure that your learner is ready to end the session."
        } else {
            label.text = "Are you sure you’d like to end the session early?"
        }
        
        
        label.textColor = Colors.grayText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Fonts.createSize(16)
        return label
    }()

    var delegate: EndSessionModalDelegate?

    override func setupViews() {
        super.setupViews()
        setupMessageLabel()
        setupEndSessionButton()
        setupButtonDivider()
        setupNevermindButton()
        setHeightTo(160)
    }

    override func setupTitleLabel() {
        super.setupTitleLabel()
        titleLabel.text = "End Session"
    }

    func setupMessageLabel() {
        background.addSubview(messageLabel)
        messageLabel.anchor(top: titleLabel.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 8, paddingLeft: 50, paddingBottom: 0, paddingRight: 50, width: 0, height: 50)
    }

    override func setupBackground() {
        super.setupBackground()
        background.layer.cornerRadius = 8
    }

    func setupEndSessionButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(endSessionButton)
        endSessionButton.anchor(top: nil, left: nil, bottom: background.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 25, paddingRight: 0, width: 122, height: 30)
        window.addConstraint(NSLayoutConstraint(item: endSessionButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 75))
        endSessionButton.addTarget(self, action: #selector(endSession), for: .touchUpInside)
    }
    
    func setupButtonDivider() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(buttonDivider)
        buttonDivider.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 2, height: 12)
        window.addConstraint(NSLayoutConstraint(item: buttonDivider, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: -1))
        window.addConstraint(NSLayoutConstraint(item: buttonDivider, attribute: .centerY, relatedBy: .equal, toItem: endSessionButton, attribute: .centerY, multiplier: 1, constant: 0))
    }

    @objc func endSession() {
        delegate?.endSessionModalDidConfirm(self)
        dismiss()
        removeFromSuperview()
    }

    func setupNevermindButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(nevermindButton)
        nevermindButton.anchor(top: nil, left: nil, bottom: background.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 25, paddingRight: 0, width: 122, height: 30)
        window.addConstraint(NSLayoutConstraint(item: nevermindButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: -75))
        nevermindButton.addTarget(self, action: #selector(handleNevermind), for: .touchUpInside)
    }

    @objc func handleNevermind() {
        dismiss()
        removeFromSuperview()
    }
}
