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
    func handleConfirm()
}

extension CustomModalDelegate {
    func handleNevermind() {}
    func handleConfirm() {}
    func handleCancel(id: String) {}
}

class CustomModal: BaseCustomModal {
    var delegate: CustomModalDelegate?
    var sessionId: String!

    let noteLabel: UILabel = {
        let label = UILabel()
        label.text = "Be sure to check with your tutor before cancelling a session request."
        label.textColor = Colors.grayText
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(14)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let nevermindButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Never mind", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.titleLabel?.font = Fonts.createBoldSize(16)
        return button
    }()
    
    let buttonDivider: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.backgroundColor = Colors.gray
        return view
    }()

    let confirmButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Ok, cancel", for: .normal)
        button.setTitleColor(Colors.purple, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(16)
        button.layer.cornerRadius = 4
        return button
    }()

    override func setupViews() {
        super.setupViews()
        setupHeight()
        setupNoteLabel()
        setupNevermindButton()
        setupButtonDivider()
        setupConfirmButton()
    }
    
    func setupHeight() {
        setHeightTo(130)
    }

    func setupNoteLabel() {
        background.addSubview(noteLabel)
        noteLabel.anchor(top: titleLabel.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 15, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 15)
        if AccountService.shared.currentUserType == .tutor {
            noteLabel.text = "We highly recommed tutors do not cancel scheduled sessions"
        }
    }

    func setupNevermindButton() {
        guard let window = lastWindow else { return }
        background.addSubview(nevermindButton)
        nevermindButton.anchor(top: noteLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 30)
        window.addConstraint(NSLayoutConstraint(item: nevermindButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: -75))
        nevermindButton.addTarget(self, action: #selector(handleNevermindButton), for: [.touchUpInside, .touchDragExit])
    }
    
    func setupButtonDivider() {
        guard let window = lastWindow else { return }
        background.addSubview(buttonDivider)
        buttonDivider.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 2, height: 12)
        window.addConstraint(NSLayoutConstraint(item: buttonDivider, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: -1))
        window.addConstraint(NSLayoutConstraint(item: buttonDivider, attribute: .centerY, relatedBy: .equal, toItem: nevermindButton, attribute: .centerY, multiplier: 1, constant: 0))
    }

    func setupConfirmButton() {
        guard let window = lastWindow else { return }
        background.addSubview(confirmButton)
        confirmButton.anchor(top: noteLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 30)
        window.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 75))
        confirmButton.addTarget(self, action: #selector(handleConfirmButton), for: [.touchUpInside, .touchDragExit])
    }

    @objc func handleNevermindButton() {
        delegate?.handleNevermind()
        dismiss()
    }

    @objc func handleConfirmButton() {
        delegate?.handleConfirm()
        dismiss()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    init(title: String, message: String, note: String, cancelText: String, confirmText: String) {
        super.init(frame: .zero)
        setupViews()
        titleLabel.text = title
//        messageLabel.text = message
        noteLabel.text = note
        nevermindButton.setTitle(cancelText, for: .normal)
        confirmButton.setTitle(confirmText, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
