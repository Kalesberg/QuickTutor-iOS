//
//  KeyboardAccessory.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class KeyboardAccessory: UIView, UITextViewDelegate {
    
    var delegate: KeyboardAccessoryViewDelegate?
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.navBarColor
        return view
    }()
    
    let submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.currentUserColor()
        button.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "checkIcon"), for: .normal)
        button.applyDefaultShadow()
        button.layer.cornerRadius = 17
        return button
    }()
    
    let lineSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.darkBackground
        return view
    }()
    
    let messageTextview: MessageTextView = {
        let textView = MessageTextView()
        textView.layer.cornerRadius = 6
        textView.tintColor = .white
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.clearsOnInsertion = false
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 17
        textView.layer.borderColor = Colors.border.cgColor
        textView.keyboardAppearance = .dark
        return textView
    }()
    
    let textViewCover: UILabel = {
        let label = UILabel()
        label.textColor = Colors.grayText
        label.textAlignment = .center
        label.text = "Unable to send message until\ntutor accepts connection request."
        label.font = Fonts.createBoldSize(14)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = Colors.navBarColor
        label.isHidden = true
        return label
    }()
    
    var leftAccessoryView: UIView = {
        let view = UIView()
        return view
    }()
    
    var actionViewBottomAnchor: NSLayoutConstraint?
    var messageFieldTopAnchor: NSLayoutConstraint?
    var leftAccessoryViewWidthAnchor: NSLayoutConstraint?
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    func setupViews() {
        setupMainView()
        setupLeftAccessoryView()
        setupSubmitButton()
        setupMessageTextfield()
        setupBackgroundView()
        setupSeparator()
        setupTextFieldCover()
    }
    
    func setupMainView() {
        frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        backgroundColor = .clear
        autoresizingMask = .flexibleHeight
    }
    
    func setupLeftAccessoryView() {
        addSubview(leftAccessoryView)
        leftAccessoryView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        leftAccessoryViewWidthAnchor = leftAccessoryView.widthAnchor.constraint(equalToConstant: 0)
        leftAccessoryViewWidthAnchor?.isActive = true
    }
    
    func setupSubmitButton() {
        addSubview(submitButton)
        submitButton.anchor(top: nil, left: nil, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 34, height: 34)
        submitButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    }

    func setupMessageTextfield() {
        addSubview(messageTextview)
        messageTextview.anchor(top: nil, left: leftAccessoryView.rightAnchor, bottom: getBottomAnchor(), right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 8, paddingRight: 12, width: 0, height: 0)
        addConstraint(NSLayoutConstraint(item: messageTextview, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: submitButton, attribute: .height, multiplier: 0.68, constant: 0))
        messageFieldTopAnchor = messageTextview.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        messageFieldTopAnchor?.isActive = true
    }
    
    func setupBackgroundView() {
        insertSubview(backgroundView, at: 0)
        backgroundView.anchor(top: messageTextview.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: -8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 300)
    }
    
    func setupSeparator() {
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: messageTextview.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: -8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    func setupTextFieldCover() {
        addSubview(textViewCover)
        textViewCover.anchor(top: nil, left: leftAnchor, bottom: messageTextview.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 80)
    }
    
    @objc func handleSend() {
        guard let text = messageTextview.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let message = UserMessage(dictionary: ["text": text, "timestamp": timestamp, "senderId": uid])
        messageTextview.text = nil
        messageTextview.placeholderLabel.isHidden = false
        delegate?.handleMessageSend(message: message)
    }
    
    func hideTextViewCover() {
        textViewCover.isHidden = true
    }
    
    func showTextViewCover() {
        if AccountService.shared.currentUserType == .tutor {
            textViewCover.text = "Unable to send message until\nyou accept connection request."
        }
        textViewCover.isHidden = false
    }
    
    convenience init(chatPartnerId: String) {
        self.init()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
