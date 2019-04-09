//
//  PauseSessionModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

protocol PauseSessionModalDelegate {
    func pauseSessionModalDidUnpause(_ pauseSessionModal: PauseSessionModal)
    func pauseSessionModalShouldEndSession(_ pauseSessionModal: PauseSessionModal)
}

class PauseSessionModal: BaseCustomModal {
    var pausedById: String?
    var delegate: PauseSessionModalDelegate?
    var partnerUsername: String?
    var isVisible = false

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

    let inPersonEndSessionButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("End Session", for: .normal)
        button.setTitleColor(UIColor(red: 178.0 / 255.0, green: 27.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0), for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 178.0 / 255.0, green: 27.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0).cgColor
        button.titleLabel?.font = Fonts.createSize(18)
        button.layer.cornerRadius = 4
        button.backgroundColor = Colors.navBarColor
        return button
    }()

    let videoEndSessionButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "endSessionButton"), for: .normal)
        return button
    }()

    func setupUnpauseButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        background.addSubview(unpauseButton)
        unpauseButton.anchor(top: titleLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 244, height: 45)
        window.addConstraint(NSLayoutConstraint(item: unpauseButton, attribute: .centerX, relatedBy: .equal, toItem: background, attribute: .centerX, multiplier: 1, constant: 0))
        unpauseButton.addTarget(self, action: #selector(unpauseSession), for: .touchUpInside)
    }

    override func setupBackgroundBlurView() {
        super.setupBackgroundBlurView()
        backgroundBlurView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
    }

    func setupVideoEndSessionButton() {
        backgroundBlurView.addSubview(videoEndSessionButton)
        videoEndSessionButton.anchor(top: nil, left: nil, bottom: backgroundBlurView.bottomAnchor, right: backgroundBlurView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 15, width: 169.75, height: 61.25)
        videoEndSessionButton.addTarget(self, action: #selector(endSession), for: .touchUpInside)
    }

    func setupInPersonEndSessionButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        backgroundBlurView.addSubview(inPersonEndSessionButton)
        inPersonEndSessionButton.anchor(top: nil, left: nil, bottom: backgroundBlurView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 52.5, paddingRight: 0, width: 270, height: 50)
        window.addConstraint(NSLayoutConstraint(item: inPersonEndSessionButton, attribute: .centerX, relatedBy: .equal, toItem: backgroundBlurView, attribute: .centerX, multiplier: 1, constant: 0))
        inPersonEndSessionButton.addTarget(self, action: #selector(endSession), for: .touchUpInside)
    }
    
    func setupAsLostConnection() {
        titleLabel.text = "Connection lost..."
        animateTitleLabel()
    }
    
    override func setupViews() {
        super.setupViews()
        background.backgroundColor = .clear
        setupUnpauseButton()
        backgroundBlurView.gestureRecognizers?.removeAll()
    }
    
    func setupEndSessionButtons(type: String) {
        type == "online" ? setupVideoEndSessionButton() : setupInPersonEndSessionButton()
    }
    
    func updateTitleLabel() {
		guard let username = partnerUsername?.split(separator: " ")[0] else { return }
        guard let uid = Auth.auth().currentUser?.uid, pausedById != "lostConnection" else { return }
        titleLabel.text = uid == pausedById ? "You paused the session." : "\(username) paused the session."
    }
    
    var timer: Timer?
    func animateTitleLabel() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
            if self.titleLabel.text == "Connection lost..." {
                self.titleLabel.text = "Connection lost"
            } else {
                self.titleLabel.text = self.titleLabel.text! + "."
            }
        })
        timer?.fire()
    }

    override func show() {
        super.show()
        isVisible = true
        updateTitleLabel()
    }

    override func dismiss() {
        super.dismiss()
        isVisible = false
    }

    @objc func endSession() {
        delegate?.pauseSessionModalShouldEndSession(self)
    }

    func pausedByCurrentUser() {
        unpauseButton.isHidden = false
    }

    @objc func unpauseSession() {
        delegate?.pauseSessionModalDidUnpause(self)
        dismiss()
    }
}
