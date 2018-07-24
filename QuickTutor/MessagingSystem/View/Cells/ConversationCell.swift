//
//  ConversationCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

protocol ConversationCellDelegate {
    func conversationCellShouldDeleteMessages(_ conversationCell: ConversationCell)
    func conversationCellShouldDisconnect(_ conversationCell: ConversationCell)
}

class ConversationCell: UICollectionViewCell {
    
    var chatPartner: User!
    var delegate: ConversationCellDelegate?
    
    let background: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.navBarColor
        return view
    }()
    
    let profileImageView: UserImageView = {
        let iv = UserImageView(frame: CGRect.zero)
        iv.onlineStatusIndicator.backgroundColor = Colors.navBarGreen
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(13)
        label.textColor = .white
        return label
    }()
    
    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(11)
        label.textColor = .white
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(8)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    let starLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = Fonts.createBoldSize(9)
        label.textColor = UIColor(hex: "FFDA02")
        return label
    }()
    
    let starIcon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "yellow-star"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.lightGrey
        return view
    }()
    
    let newMessageGradientLayer: CAGradientLayer = {
        let firstColor = Colors.learnerPurple.cgColor
        let secondColor = Colors.navBarColor.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = 1
        gradientLayer.colors = [firstColor, secondColor]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0, 0.7]
        
        gradientLayer.isHidden = true
        
        return gradientLayer
    }()
    
    let disconnectButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#851537")
        return view
    }()
    
    let deleteMessagesButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#AF1C49")
        return view
    }()
    
    let disconnectButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "disconnectButton"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let deleteMessagesButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "deleteMessagesButton"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor(hex: "#AF1C49")
        return button
    }()
    
    var backgroundRightAnchor: NSLayoutConstraint?
    var animator: UIViewPropertyAnimator?
    var disconnectButtonWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        setupBackground()
        setupDisconnectButtonView()
        setupDisconnectButton()
        setupDeleteMessagesButtonView()
        setupDeleteMessagesButton()
        setupProfilePic()
        setupTimestampLabel()
        setupUsernameLabel()
        setupLastMessageLabel()
        setupStarIcon()
        setupStarLabel()
        setupLine()
        setupNewMessageGradientLayer()
        animateButtons()
    }
    
    private func setupBackground() {
        addSubview(background)
        background.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addConstraint(NSLayoutConstraint(item: background, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
        backgroundRightAnchor = background.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        backgroundRightAnchor?.isActive = true
        backgroundColor = Colors.backgroundDark.darker(by: 2)
    }
    
    private func setupProfilePic() {
        background.addSubview(profileImageView)
        profileImageView.anchor(top: background.topAnchor, left: background.leftAnchor, bottom: background.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10.5, paddingBottom: 10, paddingRight: 0, width: 60, height: 60)
    }
    
    private func setupTimestampLabel() {
        background.addSubview(timestampLabel)
        timestampLabel.anchor(top: background.topAnchor, left: nil, bottom: nil, right: background.rightAnchor, paddingTop: 11, paddingLeft: 0, paddingBottom: 0, paddingRight: 7, width: 60, height: 12)
    }
    
    private func setupUsernameLabel() {
        background.addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: timestampLabel.leftAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    private func setupLastMessageLabel() {
        background.addSubview(lastMessageLabel)
        lastMessageLabel.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: timestampLabel.leftAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 0, height: 14)
    }
    
    private func setupStarIcon() {
        background.addSubview(starIcon)
        starIcon.anchor(top: nil, left: nil, bottom: nil, right: background.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 12, height: 12)
        addConstraint(NSLayoutConstraint(item: starIcon, attribute: .centerY, relatedBy: .equal, toItem: background, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    private func setupStarLabel() {
        background.addSubview(starLabel)
        starLabel.anchor(top: nil, left: nil, bottom: nil, right: starIcon.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 60, height: 15)
        addConstraint(NSLayoutConstraint(item: starLabel, attribute: .centerY, relatedBy: .equal, toItem: background, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    private func setupLine() {
        background.addSubview(separatorLine)
        separatorLine.anchor(top: nil, left: profileImageView.leftAnchor, bottom: background.bottomAnchor, right: background.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    func setupNewMessageGradientLayer() {
        background.layer.insertSublayer(newMessageGradientLayer, at: 0)
        newMessageGradientLayer.frame = CGRect(x: 0, y: 0, width: 100, height: bounds.height)
    }
    
    func setupDisconnectButtonView() {
        insertSubview(disconnectButtonView, belowSubview: background)
        disconnectButtonView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        disconnectButtonWidthAnchor = disconnectButtonView.widthAnchor.constraint(equalToConstant: 75)
        disconnectButtonWidthAnchor?.isActive = true
    }
    
    func setupDisconnectButton() {
        disconnectButtonView.addSubview(disconnectButton)
        disconnectButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 18, paddingLeft: 0, paddingBottom: 18, paddingRight: 0, width: 30, height: 30)
        addConstraint(NSLayoutConstraint(item: disconnectButton, attribute: .centerX, relatedBy: .equal, toItem: disconnectButtonView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: disconnectButton, attribute: .centerY, relatedBy: .equal, toItem: disconnectButtonView, attribute: .centerY, multiplier: 1, constant: 0))
        disconnectButton.addTarget(self, action: #selector(handleDisconnect), for: .touchUpInside)
    }
    
    func setupDeleteMessagesButtonView() {
        insertSubview(deleteMessagesButtonView, belowSubview: background)
        deleteMessagesButtonView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: disconnectButtonView.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 75, height: 0)
    }
    
    func setupDeleteMessagesButton() {
        deleteMessagesButtonView.addSubview(deleteMessagesButton)
        deleteMessagesButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 18, paddingLeft: 0, paddingBottom: 18, paddingRight: 0, width: 30, height: 30)
        addConstraint(NSLayoutConstraint(item: deleteMessagesButton, attribute: .centerX, relatedBy: .equal, toItem: deleteMessagesButtonView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: deleteMessagesButton, attribute: .centerY, relatedBy: .equal, toItem: deleteMessagesButtonView, attribute: .centerY, multiplier: 1, constant: 0))
        deleteMessagesButton.addTarget(self, action: #selector(handleDeleteMessages), for: .touchUpInside)
    }
    
    func updateUI(message: UserMessage) {
        guard let user = message.user else { return }
        chatPartner = user
        updateUsernameLabel()
        updateOnlineStatusIndicator()
        updateProfileImage()
        updateTimestampLabel(message: message)
        updateProfileImage()
        updateLastMessageLabel(message: message)
        updateRating()
        checkConversationReadStatus(partnerId: message.partnerId())
    }
    
    func clearData() {
        profileImageView.imageView.image = nil
        usernameLabel.text = nil
        timestampLabel.text = nil
        lastMessageLabel.text = nil
    }
    
    private func updateUsernameLabel() {
        usernameLabel.text = chatPartner.formattedName.capitalized
    }
    
    private func updateOnlineStatusIndicator() {
        profileImageView.onlineStatusIndicator.backgroundColor = chatPartner.isOnline ? Colors.navBarGreen : Colors.qtRed
//        profileImageView.onlineStatusIndicator.layer.borderColor = Colors.backgroundDark.darker(by: 2)?.cgColor
//        profileImageView.onlineStatusIndicator.layer.borderWidth = 2
    }
    
    private func updateProfileImage() {
        profileImageView.imageView.loadImage(urlString: chatPartner.profilePicUrl)
    }
    
    private func updateTimestampLabel(message: UserMessage) {
        let timestampDate = Date(timeIntervalSince1970: message.timeStamp.doubleValue)
        timestampLabel.text = timestampDate.formatRelativeString()
    }
    
    private func updateLastMessageLabel(message: UserMessage) {
        if let text = message.text {
            lastMessageLabel.text = text
        }
        if message.imageUrl != nil {
            lastMessageLabel.text = "Attachment: 1 image"
        }
        if message.sessionRequestId != nil {
            lastMessageLabel.text = "Session Request"
        }
    }
    
    private func updateRating() {
        guard let tutor = chatPartner as? ZFTutor, let rating = tutor.rating else { return }
        starLabel.text = "\(rating)"
    }
    
    @objc func handleDisconnect() {
        closeSwipeActions()
        delegate?.conversationCellShouldDisconnect(self)
    }
    
    @objc func handleDeleteMessages() {
        closeSwipeActions()
        delegate?.conversationCellShouldDeleteMessages(self)
    }
    
    func showAccessoryButtons(distance: CGFloat) {
        if disconnectButtonWidthAnchor?.constant == 0 {
            guard distance > -75 else { return }
            guard backgroundRightAnchor?.constant != -75 else { return }
            backgroundRightAnchor?.constant = distance
            animator?.fractionComplete = abs(distance / 75)
            layoutIfNeeded()
        } else {
            guard distance > -150 else { return }
            guard backgroundRightAnchor?.constant != -150 else { return }
            backgroundRightAnchor?.constant = distance
            animator?.fractionComplete = abs(distance / 150)
            layoutIfNeeded()
        }
    }
    
    func closeSwipeActions() {
        backgroundRightAnchor?.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    func animateButtons() {
        animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            self.disconnectButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.deleteMessagesButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }
    
    func checkConversationReadStatus(partnerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("readReceipts").child(partnerId).child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? Bool else { return }
            self.newMessageGradientLayer.isHidden = value
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
