//
//  ConversationCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase
import SwipeCellKit
import UIKit

class ConversationCell: SwipeCollectionViewCell {
    var chatPartner: User!
    
    let profileImageView: UserImageView = {
        let iv = UserImageView(frame: CGRect.zero)
        iv.onlineStatusIndicator.backgroundColor = Colors.darkBackground
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBlackSize(16)
        label.textColor = .white
        return label
    }()
    
    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(12)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(12)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .right
        return label
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
    }
    
    private func setupProfilePic() {
        contentView.addSubview(profileImageView)
        profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10.5, paddingBottom: 10, paddingRight: 0, width: 60, height: 60)
    }
    
    private func setupTimestampLabel() {
        contentView.addSubview(timestampLabel)
        timestampLabel.anchor(top: contentView.topAnchor, left: nil, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 7, width: 60, height: 12)
    }
    
    private func setupUsernameLabel() {
        contentView.addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: timestampLabel.leftAnchor, paddingTop: 13, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    private func setupLastMessageLabel() {
        contentView.addSubview(lastMessageLabel)
        lastMessageLabel.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: timestampLabel.leftAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 0, height: 14)
    }
    
    func updateAsUnread() {
        usernameLabel.font = Fonts.createBlackSize(16)
        lastMessageLabel.font = Fonts.createBlackSize(12)
        timestampLabel.font = Fonts.createBlackSize(12)
    }
    
    func updateAsRead() {
        usernameLabel.font = Fonts.createBoldSize(16)
        lastMessageLabel.font = Fonts.createSize(12)
        timestampLabel.font = Fonts.createSize(12)
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
        self.profileImageView.onlineStatusIndicator.backgroundColor = chatPartner.isOnline ? Colors.purple : Colors.gray
    }
    
    private func updateProfileImage() {
        profileImageView.imageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
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
        if message.videoUrl != nil {
            lastMessageLabel.text = "Attachment: 1 video"
        }
        if message.sessionRequestId != nil {
            lastMessageLabel.text = "Session Request"
        }
        if message.documenUrl != nil {
            lastMessageLabel.text = "Attachment: 1 document"
        }
    }
    
    func checkConversationReadStatus(partnerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(partnerId).child("readBy").observeSingleEvent(of: .value) { snapshot in
            guard let readByIds = snapshot.value as? [String: Any] else { return }
            let isRead = readByIds[uid] != nil
            isRead ? self.updateAsRead() : self.updateAsUnread()
        }
    }
    
    func handleTouchDown() {
        contentView.backgroundColor = Colors.navBarColor.darker(by: 30)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.contentView.backgroundColor = Colors.navBarColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
