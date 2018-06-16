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
        iv.onlineStatusIndicator.backgroundColor = .green
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
        
        
        let x: Double! = 90 / 360.0
        let a = pow(sinf(Float(2.0 * .pi * ((x + 0.75) / 2.0))),2.0);
        let b = pow(sinf(Float(2 * .pi * ((x+0.0)/2))),2);
        let c = pow(sinf(Float(2 * .pi * ((x+0.25)/2))),2);
        let d = pow(sinf(Float(2 * .pi * ((x+0.5)/2))),2);

        gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
        gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
        gradientLayer.locations = [0, 0.7, 0.9, 1]
        return gradientLayer
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
        return button
    }()
    
    var backgroundRightAnchor: NSLayoutConstraint?
    var animator: UIViewPropertyAnimator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        setupBackground()
        setupDisconnectButton()
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
    
    func setupDisconnectButton() {
        insertSubview(disconnectButton, belowSubview: background)
        disconnectButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 18, paddingLeft: 0, paddingBottom: 18, paddingRight: 0, width: 65, height: 0)
        disconnectButton.addTarget(self, action: #selector(handleDisconnect), for: .touchUpInside)
    }
    
    func setupDeleteMessagesButton() {
        insertSubview(deleteMessagesButton, belowSubview: background)
        deleteMessagesButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: disconnectButton.leftAnchor, paddingTop: 18, paddingLeft: 0, paddingBottom: 18, paddingRight: 0, width: 65, height: 0)
        deleteMessagesButton.addTarget(self, action: #selector(handleDeleteMessages), for: .touchUpInside)
    }
    
    func updateUI(message: UserMessage) {
        guard let user = message.user else { return }
        self.chatPartner = user
        self.updateUsernameLabel()
        self.updateOnlineStatusIndicator()
        self.updateProfileImage()
        self.updateTimestampLabel(message: message)
        self.updateProfileImage()
        self.updateLastMessageLabel(message: message)
        self.updateRating()
    }
    
    func clearData() {
        profileImageView.imageView.image = nil
        usernameLabel.text = nil
        timestampLabel.text = nil
        lastMessageLabel.text = nil
    }
    
    private func updateUsernameLabel() {
        self.usernameLabel.text = chatPartner.formattedName.capitalized
    }
    
    private func updateOnlineStatusIndicator() {
        self.profileImageView.onlineStatusIndicator.backgroundColor = chatPartner.isOnline ? .green : .red
    }
    
    private func updateProfileImage() {
        self.profileImageView.imageView.loadImage(urlString: chatPartner.profilePicUrl)
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
            self.lastMessageLabel.text = "Attachment: 1 image"
        }
        if message.sessionRequestId != nil {
            self.lastMessageLabel.text = "Session Request"
        }
    }
    
    private func updateRating() {
        guard let tutor = chatPartner as? ZFTutor, let rating = tutor.rating else { return }
        self.starLabel.text = "\(rating)"
    }
    
    @objc func handleDisconnect() {
        closeSwipeActions()
        delegate?.conversationCellShouldDisconnect(self)
    }
    
    @objc func handleDeleteMessages() {
        closeSwipeActions()
        delegate?.conversationCellShouldDeleteMessages(self)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

