//
//  ConnectionRequestView.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/26/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class ConnectionRequestView: UIView {
    
    var userId: String!
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Connection Request"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.learnerPurple
        view.layer.cornerRadius = 2
        return view
    }()
    
    let messageView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tv.backgroundColor = Colors.lightGrey
        tv.layer.cornerRadius = 8
        return tv
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Add a message..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = Colors.lightGrey
        return label
    }()
    
    let sendButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.learnerPurple
        button.layer.cornerRadius = 20
        button.setTitle("Send", for: .normal)
        return button
    }()
    
    let backgroundBlurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let quickChatView = QuickChatView()
    
    func setupViews() {
        setupMainView()
        setupBackgroundBlurView()
        setupTitleLabel()
        setupSeparator()
        setupMessageView()
        setupPlaceholderLabel()
        setupSendButton()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
        layer.cornerRadius = 8
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        titleLabel.widthAnchor.constraint(equalToConstant: (titleLabel.text?.estimateFrameForFontSize(20).width)! + 10).isActive = true
    }
    
    func setupSeparator() {
        addSubview(separator)
        separator.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: nil, paddingTop: -5, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: 175, height: 4)
    }
    
    func setupMessageView() {
        addSubview(messageView)
        messageView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 150)
        quickChatView.delegate = self
        messageView.inputAccessoryView = quickChatView
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: .UITextViewTextDidChange, object: nil)
    }
    
    func setupPlaceholderLabel() {
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: messageView.topAnchor, left: messageView.leftAnchor, bottom: nil, right: messageView.rightAnchor, paddingTop: 7, paddingLeft: 6.5, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    func setupSendButton() {
        addSubview(sendButton)
        sendButton.anchor(top: messageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 40)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    }
    
    @objc func handleSend() {
        guard let uid = Auth.auth().currentUser?.uid, let text = messageView.text else { return }
        Database.database().reference().child("connectionRequests").child(userId).child(uid).setValue(text)
        dismiss()
    }
    
    func setupBackgroundBlurView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.insertSubview(backgroundBlurView, belowSubview: self)
        backgroundBlurView.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        dismissTap.numberOfTapsRequired = 1
        backgroundBlurView.addGestureRecognizer(dismissTap)
    }
    
    @objc func dismiss() {
        backgroundBlurView.removeFromSuperview()
        removeFromSuperview()
    }
    
    @objc func handleTextChange() {
        placeholderLabel.isHidden = !messageView.text.isEmpty
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ConnectionRequestView: QuickChatViewDelegate {
    func sendMessage(text: String) {
        placeholderLabel.text = ""
        messageView.text = text
        messageView.resignFirstResponder()
    }
    
    
}
