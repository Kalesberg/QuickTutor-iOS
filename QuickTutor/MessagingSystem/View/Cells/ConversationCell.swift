//
//  ConversationCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit

class ConversationCell: SwipeCollectionViewCell {
    
    var chatPartner: User!
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        contentView.backgroundColor = Colors.navBarColor
        setupProfilePic()
        setupTimestampLabel()
        setupUsernameLabel()
        setupLastMessageLabel()
        setupStarIcon()
        setupStarLabel()
        setupLine()
        setupNewMessageGradientLayer()
    }
    
    private func setupProfilePic() {
        contentView.addSubview(profileImageView)
        profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10.5, paddingBottom: 10, paddingRight: 0, width: 60, height: 60)
    }
    
    private func setupTimestampLabel() {
        contentView.addSubview(timestampLabel)
        timestampLabel.anchor(top: contentView.topAnchor, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 11, paddingLeft: 0, paddingBottom: 0, paddingRight: 7, width: 60, height: 12)
    }
    
    private func setupUsernameLabel() {
        contentView.addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: timestampLabel.leftAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    private func setupLastMessageLabel() {
        contentView.addSubview(lastMessageLabel)
        lastMessageLabel.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: timestampLabel.leftAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 0, height: 14)
    }
    
    private func setupStarIcon() {
        contentView.addSubview(starIcon)
        starIcon.anchor(top: nil, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 12, height: 12)
        addConstraint(NSLayoutConstraint(item: starIcon, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    private func setupStarLabel() {
        contentView.addSubview(starLabel)
        starLabel.anchor(top: nil, left: nil, bottom: nil, right: starIcon.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 60, height: 15)
        addConstraint(NSLayoutConstraint(item: starLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    private func setupLine() {
        contentView.addSubview(separatorLine)
        separatorLine.anchor(top: nil, left: profileImageView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    func setupNewMessageGradientLayer() {
        contentView.layer.insertSublayer(newMessageGradientLayer, at: 0)
        newMessageGradientLayer.frame = CGRect(x: 0, y: 0, width: 100, height: bounds.height)
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
    
    func checkConversationReadStatus(partnerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(partnerId).child("readBy").observeSingleEvent(of: .value) { snapshot in
            guard let readByIds = snapshot.value as? [String: Any] else { return }
            self.newMessageGradientLayer.isHidden = readByIds[uid] != nil

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
