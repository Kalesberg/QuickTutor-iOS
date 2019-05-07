//
//  MessageCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/8/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase
import UIKit

enum MessageCellType {
    case system, text, image, sessionRequest, connectionRequest
}

class CopyableTextView: UITextView {
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = text
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
        resignFirstResponder()
    }
    
    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu(sender:))))
    }
    
    @objc func showMenu(sender: AnyObject?) {
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
}

class UserMessageCell: BaseMessageCell {
    var chatPartner: User?
    var userMessage: UserMessage?

    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.clipsToBounds = false
        view.backgroundColor = Colors.darkBackground
        view.layer.borderColor = Colors.gray.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    var textView: UITextView = {
        let tv = UITextView()
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
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(10)
        label.textAlignment = .center
        label.text = "3:58 PM"
        return label
    }()

    private(set) var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?

    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        userMessage = message
        textView.text = message.text
        guard let uid = Auth.auth().currentUser?.uid else { return }
        message.senderId == uid ? setupBubbleViewAsSentMessage() : setupBubbleViewAsReceivedMessage()
        updateTimeLabel(message: message)
    }
    
    private func updateTimeLabel(message: UserMessage) {
        let timestampDate = Date(timeIntervalSince1970: message.timeStamp.doubleValue)
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        timeLabel.text = dateFormatter.string(from: timestampDate)
    }

    private func setupBubbleView() {
        addSubview(bubbleView)
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8)
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -68)
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
    }

    func setupBubbleViewAsSentMessage() {
        if #available(iOS 11.0, *) {
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor?.isActive = false
        profileImageView.isHidden = true
        guard let profilePicUrl = chatPartner?.profilePicUrl else { return }
        profileImageView.sd_setImage(with: profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
    }

    func setupBubbleViewAsReceivedMessage() {
        if #available(iOS 11.0, *) {
            bubbleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
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
        setupTimeLabel()
        setupGestureRecognizers()
    }

    private func setupTextView() {
        bubbleView.addSubview(textView)
        bubbleView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 9, paddingLeft: 9, paddingBottom: 9, paddingRight: 9, width: 0, height: 0)
        textView.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 9, width: 0, height: 0)
    }
    
    private func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 60, height: 0)
    }
    
    func setupGestureRecognizers() {
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(copyText))
//        addGestureRecognizer(longPress)
    }
    
    @objc func copyText() {
//        if let text = textView.text {
//            UIPasteboard.general.string = text
//        }
    }
}
