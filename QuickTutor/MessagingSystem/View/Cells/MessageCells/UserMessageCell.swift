//
//  MessageCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/8/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class UserMessageCell: BaseMessageCell {
    
    var chatPartner: User?
    
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = false
        view.clipsToBounds = false
        view.applyDefaultShadow()
        view.backgroundColor = UIColor(hex: "ecf0f1")
        return view
    }()
    
    var textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.textColor = .white
        tv.isUserInteractionEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = Fonts.createSize(14)
        tv.backgroundColor = .clear
        tv.contentInset = UIEdgeInsets(top: -3, left: 4, bottom: 0, right: -4)
        return tv
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 15
        iv.clipsToBounds = true
        return iv
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        textView.text = message.text
        guard let uid = Auth.auth().currentUser?.uid else { return }
        message.senderId == uid ? setupBubbleViewAsSentMessage() : setupBubbleViewAsReceivedMessage()
    }
    
    
    private func setupBubbleView() {
        addSubview(bubbleView)
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8)
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
    }
    
    private func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
    }
    
    func setupBubbleViewAsSentMessage() {
        if #available(iOS 11.0, *) {
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
        bubbleView.backgroundColor = Colors.sentMessage
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor?.isActive = false
        profileImageView.isHidden = true
        guard let profilePicUrl = chatPartner?.profilePicUrl else { return }
        profileImageView.loadImage(urlString: profilePicUrl)
    }
    
    func setupBubbleViewAsReceivedMessage() {
        if #available(iOS 11.0, *) {
            bubbleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        bubbleView.backgroundColor = Colors.receivedMessage
        bubbleViewLeftAnchor?.constant = 52
        bubbleViewLeftAnchor?.isActive = true
        bubbleViewRightAnchor?.isActive = false
        profileImageView.isHidden = false
    }
    
    override func setupViews() {
        super.setupViews()
        setupProfileImageView()
        setupBubbleView()
        setupTextView()
    }
    
    private func setupTextView() {
        bubbleView.addSubview(textView)
        bubbleView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        textView.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 0, height: 0)
    }

}


