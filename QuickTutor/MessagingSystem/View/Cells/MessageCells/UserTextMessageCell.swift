//
//  UserTextMessageCell.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/8/6.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

class UserTextMessageCell: BaseMessageCell {
    var chatPartner: User?
    var userMessage: UserMessage?
    
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.clipsToBounds = false
        view.backgroundColor = Colors.newScreenBackground
        view.applyDefaultShadow()
        return view
    }()
    
    var textLabel: ActiveLabel = {
        let label = ActiveLabel ()
        label.numberOfLines = 0
//        label.enabledTypes = [.url]
        label.textColor = .white
        label.font = Fonts.createSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        /*label.handleURLTap { url in
            guard UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        label.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            if type == .url {
                atts[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            return atts
        }*/
        return label
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
        configureTextLabel (message)
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
        bubbleView.backgroundColor = Colors.purple
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor?.isActive = false
        profileImageView.isHidden = true
        guard let profilePicUrl = chatPartner?.profilePicUrl else { return }
        profileImageView.sd_setImage(with: profilePicUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
    }
    
    func setupBubbleViewAsReceivedMessage() {
        if #available(iOS 11.0, *) {
            bubbleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if message?.type == .text {
            bubbleView.backgroundColor = Colors.gray
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
        setupTextLabel()
        setupTimeLabel()
        sharedInit()
    }
    
    private func setupTextLabel() {
        bubbleView.addSubview(textLabel)
        bubbleView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 9, paddingLeft: 9, paddingBottom: 9, paddingRight: 9, width: 0, height: 0)
        textLabel.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 9, width: 0, height: 0)
    }
    
    private func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 60, height: 0)
    }
    
    private func configureTextLabel (_ message: UserMessage) {
//        textLabel.URLColor = message.senderId == uid ? Colors.gray : Colors.purple
        textLabel.text = message.text
        var links = [String]()
        var enableTypes = [ActiveType]()
        
        // get link strings
        guard let input = message.text else { return }
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        // set link urls
        for match in matches {
            guard let range = Range(match.range, in: input) else { continue }
            let url = input[range]
            let urlType = ActiveType.custom(pattern: String(url))
            
            // link configuration
            guard let uid = Auth.auth().currentUser?.uid else { return }
            textLabel.customColor[urlType] = message.senderId == uid ? Colors.gray : Colors.purple
            
            // enable types
            enableTypes.append(urlType)
            links.append(String(url))
        }
        
        textLabel.enabledTypes = enableTypes
        
        // link configuration
        textLabel.customize { (label) in
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                for urlType in self.textLabel.enabledTypes {
                    if type == urlType {
                        atts[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
                    }
                }
                return atts
            }
        }
        
        // link action
        for index in 0..<enableTypes.count {
            textLabel.handleCustomTap(for: enableTypes[index]) { (_) in
                var urlString = links[index]
                if !urlString.contains("http") {
                    urlString = "http://" + urlString
                }
                
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = textLabel.text
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
        resignFirstResponder()
    }
    
    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu(sender:))))
    }
    
    @objc func showMenu(sender: AnyObject?) {
        guard let messageType = message?.type, messageType == .text else {
            return
        }
        
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bubbleView.frame, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
}
