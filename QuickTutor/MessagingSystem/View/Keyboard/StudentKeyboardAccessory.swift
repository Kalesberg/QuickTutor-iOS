//
//  StudentKeyboardAccessory.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class StudentKeyboardAccessory: KeyboardAccessory {
    var actionViewShown = false
    var quickChatViewShown = true

    override var delegate: KeyboardAccessoryViewDelegate? {
        didSet {
            actionView.delegate = delegate
        }
    }

    let actionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "actionButtonIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.applyDefaultShadow()
        button.adjustsImageWhenDisabled = true
        button.imageView?.contentMode = .center
        button.imageView?.tintColor = .white
        return button
    }()
    
    let uploadImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "mediaIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = .white
        return button
    }()

    let actionView: KeyboardActionView = {
        let view = KeyboardActionView()
        return view
    }()

    let backgroundBlurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = true
        view.alpha = 0
        return view
    }()

    let chatView: QuickChatView = {
        let chat = QuickChatView()
        return chat
    }()

    var quickChatBottomAnchor: NSLayoutConstraint?

    override func setupViews() {
        super.setupViews()
        setupBackgroundBlurView()
        setupActionView()
        setupQuickChatView()
        toggleQuickChatView()
    }
    
    override func setupButtonStackView() {
        super.setupButtonStackView()
        setupActionButton()
        setupUploadImageButton()
        leftAccessoryViewWidthAnchor?.constant = 90
    }
    
    private func setupActionButton() {
        buttonStackView.insertArrangedSubview(actionButton, at: 0)
        addConstraint(NSLayoutConstraint(item: actionButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 25))
        addConstraint(NSLayoutConstraint(item: actionButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 25))
    }
    
    private func setupUploadImageButton() {
        buttonStackView.insertArrangedSubview(uploadImageButton, at: 1)
        addConstraint(NSLayoutConstraint(item: uploadImageButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 25))
        addConstraint(NSLayoutConstraint(item: uploadImageButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 25))
        uploadImageButton.addTarget(self, action: #selector(handleImageUpload), for: .touchUpInside)
    }
    
    @objc func handleImageUpload() {
        actionView.delegate?.handleSendingImage()
    }
    
    private func setupActionView() {
        actionButton.addTarget(self, action: #selector(toggleActionView), for: .touchUpInside)
        insertSubview(actionView, at: 0)
        actionView.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        actionViewBottomAnchor = actionView.bottomAnchor.constraint(equalTo: messageTextview.topAnchor, constant: 100)
        actionViewBottomAnchor?.isActive = true
    }

    private func setupBackgroundBlurView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(backgroundBlurView)
        backgroundBlurView.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(toggleActionView))
        dismissTap.numberOfTapsRequired = 1
        backgroundBlurView.addGestureRecognizer(dismissTap)
    }

    @objc func toggleActionView() {
        actionViewShown ? hideActionView() : showActionView()
        hideQuickChatView()
    }

    func showActionView() {
        actionViewBottomAnchor?.constant = -8
        let animator = UIViewPropertyAnimator(duration: 0.15, curve: .easeOut, animations: nil)
        animator.addAnimations {
            self.backgroundBlurView.alpha = 1
            self.layoutIfNeeded()
        }
        animator.addCompletion { (position) in
            self.messageFieldTopAnchor?.constant = 108
            self.layoutIfNeeded()
        }
        animator.startAnimation()
        self.actionButton.imageView?.tintColor = Colors.purple
        UIViewPropertyAnimator(duration: 0.15, curve: .linear, animations: {
            self.layoutIfNeeded()
        }).startAnimation()
        actionViewShown = true
    }

    func hideActionView() {
        messageFieldTopAnchor?.constant = 8
        layoutIfNeeded()
        actionViewBottomAnchor?.constant = 100
        UIViewPropertyAnimator(duration: 0.15, curve: .easeOut, animations: {
            self.backgroundBlurView.alpha = 0
            self.layoutIfNeeded()
        }).startAnimation()
        self.actionButton.imageView?.tintColor = .white
        UIViewPropertyAnimator(duration: 0.15, curve: .linear, animations: {
            self.layoutIfNeeded()
        }).startAnimation()
        actionViewShown = false
    }

    private func setupQuickChatView() {
        insertSubview(chatView, belowSubview: backgroundView)
        chatView.delegate = self
        chatView.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        quickChatBottomAnchor = chatView.bottomAnchor.constraint(equalTo: messageTextview.topAnchor, constant: 45)
        quickChatBottomAnchor?.isActive = true
    }
    
    @objc func toggleQuickChatView() {
        quickChatViewShown ? hideQuickChatView() : showQuickChatView()
    }
    
    func showQuickChatView() {
        quickChatViewShown = true
        messageFieldTopAnchor?.constant = 45
        self.layoutIfNeeded()
        quickChatBottomAnchor?.constant = -8
        UIViewPropertyAnimator(duration: 0.15, curve: .easeOut, animations: {
            self.layoutIfNeeded()
        }).startAnimation()
        
    }
    
    func hideQuickChatView() {
        quickChatViewShown = false
//        chatView.isHidden = true
        messageFieldTopAnchor?.constant = 8
        self.layoutIfNeeded()
        quickChatBottomAnchor?.constant = 45
        UIViewPropertyAnimator(duration: 0.15, curve: .easeOut, animations: {
            self.layoutIfNeeded()
        }).startAnimation()
        
    }
    
    func removeBackgroundBlurView() {
        backgroundBlurView.removeFromSuperview()
    }
    
    override func hideLeftView() {
        leftAccessoryViewLeftAnchor?.constant = -54
        UIView.animate(withDuration: 0.25) {
            self.expandLeftViewButton.alpha = 1
            self.buttonStackView.alpha = 0
            self.layoutIfNeeded()
        }
        guard submitButton.backgroundColor != Colors.purple else { return }
        changeSendButtonColor(Colors.purple)
    }
}

extension StudentKeyboardAccessory: QuickChatViewDelegate {
    func sendMessage(text: String) {
        
    }
}

