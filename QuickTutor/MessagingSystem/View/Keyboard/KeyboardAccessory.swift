//
//  KeyboardAccessory.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase
import UIKit

class KeyboardAccessory: UIView, UITextViewDelegate {
    var delegate: KeyboardAccessoryViewDelegate?

    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.navBarColor
        return view
    }()

    let submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.gray
        button.contentMode = .scaleAspectFit
        button.applyDefaultShadow()
        button.layer.cornerRadius = 4
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = Fonts.createSize(14)
        return button
    }()

    let lineSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray
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
        textView.keyboardAppearance = .dark
        return textView
    }()

    let textViewCover: UILabel = {
        let label = UILabel()
        label.textColor = Colors.grayText
        label.textAlignment = .center
        label.text = "You are unable to message this tutor until\n they accept your connection request."
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
    
    let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 5
        return view
    }()
    
    let uploadFileButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "fileIcon-1"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.tintColor = Colors.lightGrey
        return button
    }()
    
    let expandLeftViewButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "expandActionViewIcon"), for: .normal)
        button.backgroundColor = Colors.darkBackground
        button.alpha = 0
        return button
    }()

    var actionViewBottomAnchor: NSLayoutConstraint?
    var messageFieldTopAnchor: NSLayoutConstraint?
    var leftAccessoryViewWidthAnchor: NSLayoutConstraint?
    var leftAccessoryViewLeftAnchor: NSLayoutConstraint?

    override var intrinsicContentSize: CGSize {
        return .zero
    }

    func setupViews() {
        setupMainView()
        setupLeftAccessoryView()
        setupButtonStackView()
        setupExpandLeftViewButton()
        setupSubmitButton()
        setupMessageTextfield()
        setupSeparator()
        setupTextFieldCover()
        setupBackgroundView()
    }

    func setupMainView() {
        frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        backgroundColor = .clear
        autoresizingMask = .flexibleHeight
    }

    func setupLeftAccessoryView() {
        addSubview(leftAccessoryView)
        leftAccessoryView.anchor(top: nil, left: nil, bottom: getBottomAnchor(), right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 48)
        leftAccessoryViewWidthAnchor = leftAccessoryView.widthAnchor.constraint(equalToConstant: 0)
        leftAccessoryViewWidthAnchor?.isActive = true
        leftAccessoryViewLeftAnchor = leftAccessoryView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8)
        leftAccessoryViewLeftAnchor?.isActive = true
    }

    
    func setupButtonStackView() {
        leftAccessoryView.addSubview(buttonStackView)
        addConstraint(NSLayoutConstraint(item: uploadFileButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 25))
        addConstraint(NSLayoutConstraint(item: uploadFileButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 25))
        buttonStackView.anchor(top: leftAccessoryView.topAnchor, left: leftAccessoryView.leftAnchor, bottom: leftAccessoryView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
        buttonStackView.addArrangedSubview(uploadFileButton)
        uploadFileButton.addTarget(self, action: #selector(uploadFile), for: .touchUpInside)
        leftAccessoryViewWidthAnchor?.constant = 60
    }
    
    func setupExpandLeftViewButton() {
        leftAccessoryView.addSubview(expandLeftViewButton)
        expandLeftViewButton.anchor(top: leftAccessoryView.topAnchor, left: nil, bottom: leftAccessoryView.bottomAnchor, right: leftAccessoryView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 30, height: 0)
        expandLeftViewButton.addTarget(self, action: #selector(showLeftView), for: .touchUpInside)
    }

    func setupSubmitButton() {
        addSubview(submitButton)
        submitButton.anchor(top: nil, left: nil, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 67, height: 34)
        submitButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    }

    func setupMessageTextfield() {
        addSubview(messageTextview)
        messageTextview.anchor(top: nil, left: leftAccessoryView.rightAnchor, bottom: getBottomAnchor(), right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 12, width: 0, height: 0)
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
    
    @objc func uploadFile() {
        delegate?.handleFileUpload()
    }
    
    func hideTextViewCover() {
        textViewCover.isHidden = true
    }
    
    func showTextViewCover() {
        if AccountService.shared.currentUserType == .tutor {
            textViewCover.text = "You are unable to send messages until\nyou accept the connection request."
        }
        textViewCover.isHidden = false
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc func handleTextChange(_ sender: UITextView) {
        let textViewIsEmpty = messageTextview.text.isEmpty
        textViewIsEmpty ? showLeftView() : hideLeftView()
    }
    
    func enterEditingMode() {
        leftAccessoryViewLeftAnchor?.constant =  -24
        UIView.animate(withDuration: 0.25) {
            self.expandLeftViewButton.alpha = 1
            self.layoutIfNeeded()
        }
        guard submitButton.backgroundColor != Colors.purple else { return }
        changeSendButtonColor(Colors.purple)
    }
    
    func changeSendButtonColor(_ color: UIColor) {
        UIView.animate(withDuration: 0.125) {
            self.submitButton.backgroundColor = color
        }
    }
    
    func hideLeftView() {
        leftAccessoryViewLeftAnchor?.constant = -24
        UIView.animate(withDuration: 0.25) {
            self.expandLeftViewButton.alpha = 1
            self.buttonStackView.alpha = 0
            self.layoutIfNeeded()
        }
        guard submitButton.backgroundColor != Colors.purple else { return }
        changeSendButtonColor(Colors.purple)
    }
    
    @objc func showLeftView() {
        leftAccessoryViewLeftAnchor?.constant = 8
        UIView.animate(withDuration: 0.25) {
            self.expandLeftViewButton.alpha = 0
            self.buttonStackView.alpha = 1
            self.layoutIfNeeded()
        }
        changeSendButtonColor(Colors.gray)
        changeSendButtonColor(Colors.gray)
    }
    
    convenience init(chatPartnerId: String) {
        self.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
