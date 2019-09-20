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
import SkeletonView

class ConversationCell: SwipeCollectionViewCell {
    var chatPartner: User!
    
    let profileImageView: UserImageView = {
        let iv = UserImageView(frame: .zero)
        iv.onlineStatusIndicator.backgroundColor = Colors.gray
        iv.isSkeletonable = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Collin V."
        label.font = Fonts.createBlackSize(16)
        label.textColor = .white
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        return label
    }()
    
    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Let's have a call in this app"
        label.font = Fonts.createBoldSize(12)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(12)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .right
        label.isSkeletonable = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isSkeletonable = true
        setupViews()
    }
    
    func setupViews() {
        contentView.backgroundColor = Colors.newScreenBackground
        setupProfilePic()
        setupUsernameLabel()
        setupLastMessageLabel()
        setupTimestampLabel()
    }
    
    private func setupProfilePic() {
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
    }
    
    private func setupTimestampLabel() {
        contentView.addSubview(timestampLabel)
        timestampLabel.snp.makeConstraints { make in
            make.centerY.equalTo(usernameLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-10)
            make.leading.greaterThanOrEqualTo(usernameLabel.snp.trailing)
        }
    }
    
    private func setupUsernameLabel() {
        contentView.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top).offset(12)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
    }
    
    private func setupLastMessageLabel() {
        contentView.addSubview(lastMessageLabel)
        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(5)
            make.leading.equalTo(usernameLabel.snp.leading)
            make.trailing.lessThanOrEqualToSuperview().offset(-10)
        }
    }
    
    func updateAsUnread() {
        usernameLabel.font = Fonts.createBlackSize(16)
        lastMessageLabel.font = Fonts.createBlackSize(12)
        lastMessageLabel.textColor = UIColor.white
        timestampLabel.font = Fonts.createBlackSize(12)
    }
    
    func updateAsRead() {
        usernameLabel.font = Fonts.createBoldSize(16)
        lastMessageLabel.font = Fonts.createSize(12)
        lastMessageLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        timestampLabel.font = Fonts.createSize(12)
    }
    
    func updateUI(metadata: ConversationMetaData) {
        guard let partner = metadata.partner,
            let partnerId = partner.uid,
            let message = metadata.message else { return }
        
        chatPartner = partner
        updateUsernameLabel()
        updateOnlineStatusIndicator()
        updateProfileImage()
        updateTimestampLabel(message: message)
        updateProfileImage()
        updateLastMessageLabel(message: message)
        checkConversationReadStatus(partnerId: partnerId)
    }
    
    func clearData() {
        profileImageView.imageView.image = nil
        usernameLabel.text = nil
        timestampLabel.text = nil
        lastMessageLabel.text = nil
    }
    
    private func updateUsernameLabel() {
        usernameLabel.text = chatPartner.formattedName.capitalized
        usernameLabel.textColor = .white
    }
    
    private func updateOnlineStatusIndicator() {
        profileImageView.onlineStatusIndicator.backgroundColor = chatPartner.isOnline ? Colors.statusActiveColor : Colors.gray
    }
    
    private func updateProfileImage() {
        profileImageView.imageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
    }
    
    private func updateTimestampLabel(message: UserMessage) {
        let timestampDate = Date(timeIntervalSince1970: message.timeStamp.doubleValue)
        timestampLabel.text = timestampDate.formatRelativeString()
        timestampLabel.textColor = .white
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
        guard let uid = Auth.auth().currentUser?.uid else {
            self.updateAsUnread()
            return
        }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(partnerId).child("readBy").observeSingleEvent(of: .value) { snapshot in
            guard let readByIds = snapshot.value as? [String: Any] else {
                self.updateAsUnread()
                return
            }
            let isRead = readByIds[uid] != nil
            isRead ? self.updateAsRead() : self.updateAsUnread()
        }
    }
    
    func handleTouchDown() {
        contentView.backgroundColor = Colors.newScreenBackground.darker(by: 30)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.contentView.backgroundColor = Colors.newScreenBackground
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
