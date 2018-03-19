//
//  ConversationCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class ConversationCell: UICollectionViewCell {
    
    var chatPartner: User!
    
    let profileImageView: UserImageView = {
        let iv = UserImageView(frame: CGRect.zero)
        iv.imageView.backgroundColor = .yellow
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(13)
        label.textColor = .white
        label.text = "Alex Zoltowski"
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(11)
        label.textColor = UIColor(hex: "999999")
        label.text = "Central Michigan University"
        return label
    }()
    
    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(11)
        label.textColor = .white
        label.text = "I'll be busy this week so..."
        return label
    }()
    
    let lastSessionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(7)
        label.textColor = UIColor(hex: "999999")
        label.text = "Last session: October 11th, 2017"
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(8)
        label.textColor = .white
        label.textAlignment = .right
        label.text = "2:08pm"
        return label
    }()
    
    let starRating
    
    let pastSessionsLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(7)
        label.textColor = UIColor(hex: "999999")
        label.text = "Past sessions: 2"
        label.textAlignment = .right
        return label
    }()
    
    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.lightGrey
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = UIColor(hex: "1E1E26")
        setupProfilePic()
        setupTimestampLabel()
        setupUsernameLabel()
        setupLocationLabel()
        setupLastMessageLabel()
        setupLastSessionLabel()
        setupPastSessionsLabel()
        setupLine()
    }
    
    private func setupProfilePic() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10.5, paddingBottom: 10, paddingRight: 0, width: 60, height: 60)
    }
    
    private func setupTimestampLabel() {
        addSubview(timestampLabel)
        timestampLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 11, paddingLeft: 0, paddingBottom: 0, paddingRight: 7, width: 60, height: 12)

    }
    
    private func setupUsernameLabel() {
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: timestampLabel.leftAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 12)
    }
    
    private func setupLocationLabel() {
        addSubview(locationLabel)
        locationLabel.anchor(top: usernameLabel.bottomAnchor, left: usernameLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 14)
    }
    
    private func setupLastMessageLabel() {
        addSubview(lastMessageLabel)
        lastMessageLabel.anchor(top: locationLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: timestampLabel.leftAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 14)
    }
    
    private func setupLastSessionLabel() {
        addSubview(lastSessionLabel)
        lastSessionLabel.anchor(top: lastMessageLabel.bottomAnchor, left: usernameLabel.leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 300, height: 7)
    }
    
    private func setupPastSessionsLabel() {
        addSubview(pastSessionsLabel)
        pastSessionsLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 8, width: 150, height: 8)
    }
    
    private func setupLine() {
        addSubview(separatorLine)
        separatorLine.anchor(top: nil, left: profileImageView.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    func updateUI(message: UserMessage) {
        DataService.shared.getUserWithUid(message.partnerId()) { (userIn) in
            guard let user = userIn else { return }
            self.chatPartner = user
            
            self.updateUsernameLabel()
            self.updateOnlineStatusIndicator()
            self.updateProfileImage()
            self.updateTimestampLabel(message: message)
            self.updateProfileImage()
            self.updateLastMessageLabel(message: message)
        }
    }
    
    private func updateUsernameLabel() {
        self.usernameLabel.text = chatPartner.username
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
        if message.meetupRequestId != nil {
            self.lastMessageLabel.text = "Meetup Request"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
