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

    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Fonts.createSize(14)
        return label
    }()

    let noteLabel: UILabel = {
        let label = UILabel()
        label.text = "Canceling this session may violate your tutor's cancellation policy. You may be subject to a cancellation fee."
        label.textColor = .white
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
        button.backgroundColor = Colors.purple
        button.layer.cornerRadius = 4
        button.titleLabel?.font = Fonts.createSize(16)
        return button
    }()

    let confirmButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Ok, cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.purple
        button.titleLabel?.font = Fonts.createSize(16)
        button.layer.cornerRadius = 4
        return button
    }()

    override func setupViews() {
        super.setupViews()
        setupHeight()
        setupMessageLabel()
        setupNoteLabel()
        setupNevermindButton()
        setupConfirmButton()
    }

    func setupHeight() {
        backgroundHeightAnchor = background.heightAnchor.constraint(equalToConstant: 180)
        backgroundHeightAnchor?.isActive = true
        background.layoutIfNeeded()
    }

    func setupMessageLabel() {
        background.addSubview(messageLabel)
        messageLabel.anchor(top: titleBackground.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 12)
    }

    func setupNoteLabel() {
        background.addSubview(noteLabel)
        noteLabel.anchor(top: messageLabel.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 7, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 30)
        if AccountService.shared.currentUserType == .tutor {
            noteLabel.text = "We highly recommed tutors do not cancel scheduled sessions"
        }
    }

    func setupNevermindButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(nevermindButton)
        nevermindButton.anchor(top: noteLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 35)
        window.addConstraint(NSLayoutConstraint(item: nevermindButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: -75))
        nevermindButton.addTarget(self, action: #selector(handleNevermindButton), for: [.touchUpInside, .touchDragExit])
    }

    func setupConfirmButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(confirmButton)
        confirmButton.anchor(top: noteLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 122, height: 35)
        window.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 75))
        confirmButton.addTarget(self, action: #selector(handleConfirmButton), for: [.touchUpInside, .touchDragExit])
    }

    @objc func handleNevermindButton() {
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
        messageLabel.text = message
        noteLabel.text = note
        nevermindButton.setTitle(cancelText, for: .normal)
        confirmButton.setTitle(confirmText, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
