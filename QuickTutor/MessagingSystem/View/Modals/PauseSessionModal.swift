//
//  PauseSessionModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

protocol PauseSessionModalDelegate {
    func unpauseSession()
}

class PauseSessionModal: BaseCustomModal {
    
    var pausedById: String?
    var delegate: PauseSessionModalDelegate?
    var partnerUsername: String?
    
    let unpauseButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Unpause", for: .normal)
        button.setTitleColor(Colors.green, for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = Colors.green.cgColor
        button.layer.cornerRadius = 4
        button.titleLabel?.font = Fonts.createSize(20)
        button.backgroundColor = Colors.navBarColor
        button.isHidden = true
        return button
    }()
    
    func setupUnpauseButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(unpauseButton)
        unpauseButton.anchor(top: titleBackground.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 244, height: 45)
        window.addConstraint(NSLayoutConstraint(item: unpauseButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 0))
        unpauseButton.addTarget(self, action: #selector(unpauseSession), for: .touchUpInside)
    }
    
    override func setupTitleLabel() {
        super.setupTitleLabel()
        titleLabel.text = "Alex paused the session."
    }
    
    override func setupTitleBackground() {
        super.setupTitleBackground()
        titleBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    override func setupBackgroundBlurView() {
        super.setupBackgroundBlurView()
        backgroundBlurView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
    }
    
    override func setupViews() {
        super.setupViews()
        background.backgroundColor = .clear
        setupUnpauseButton()
        backgroundBlurView.gestureRecognizers?.removeAll()
    }
    
    func updateTitleLabel() {
        guard let uid = Auth.auth().currentUser?.uid, let username = partnerUsername else { return }
        titleLabel.text = uid == pausedById ? "You paused the session." : "\(username) paused the session."
    }
    
    override func show() {
        super.show()
        updateTitleLabel()
    }
    
    func pausedByCurrentUser() {
        unpauseButton.isHidden = false
    }
    
    @objc func unpauseSession() {
        delegate?.unpauseSession()
        dismiss()
    }
    
}
