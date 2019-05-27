//
//  ConnectionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SessionRequestTutorCell: ConnectionCell {
    
    override func setupViews() {
        super.setupViews()
        separatorLine.removeFromSuperview()
    }
    override func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
    }
    
    override func setupMessageButton() {
        addSubview(messageButton)
        messageButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 35, height: 35)
        addConstraint(NSLayoutConstraint(item: messageButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        messageButton.addTarget(self, action: #selector(removeSelectedTutor), for: .touchUpInside)
        messageButton.setImage(UIImage(named: "deleteCellIcon"), for: .normal)
    }
    
    @objc func removeSelectedTutor() {
        UIView.animate(withDuration: 0.25) {
            self.isHidden = true
        }
    }
}

protocol ConnectionCellDelegate {
    func connectionCell(_ connectionCell: ConnectionCell, shouldShowConversationWith user: User)
    func connectionCell(_ connectionCell: ConnectionCell, shouldRequestSessionWith user: User)
}

class ConnectionCell: UICollectionViewCell {
    var user: User!
    var delegate: ConnectionCellDelegate?

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Colors.darkBackground.darker(by: 30) : Colors.darkBackground
        }
    }

    let profileImageView: UserImageView = {
        let iv = UserImageView()
        iv.imageView.contentMode = .scaleAspectFill
        iv.imageView.layer.cornerRadius = 25
        iv.imageView.clipsToBounds = true
        return iv
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBlackSize(14)
        return label
    }()

    let featuredSubject: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Colors.purple
        label.font = Fonts.createBoldSize(12)
        label.text = "Auburn, AL"
        return label
    }()

    let messageButton: DimmableButton = {
        let button = DimmableButton()
        button.setImage(UIImage(named: "messageIconCircle"), for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(12)
        return button
    }()
    
    let requestSessionButton: DimmableButton = {
        let button = DimmableButton()
        button.setImage(UIImage(named: "sessionIcon"), for: .normal)
        button.isHidden = true
        return button
    }()

    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundDark
        return view
    }()
    
    var messageButtonWidthAnchor: NSLayoutConstraint?
    var messageButtonHeightAnchor: NSLayoutConstraint?

    func setupViews() {
        setupProfileImageView()
        setupNameLabel()
        setupFeaturedSubject()
        setupMessageButton()
        setupRequestSessionButton()
        setupSeparatorLine()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 10.5, paddingBottom: 5, paddingRight: 0, width: 50, height: 50)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 100, height: 18)
    }
    
    func setupFeaturedSubject() {
        addSubview(featuredSubject)
        featuredSubject.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 150, height: 0)
    }
    
    func setupMessageButton() {
        addSubview(messageButton)
        messageButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 35)
        messageButtonWidthAnchor = messageButton.widthAnchor.constraint(equalToConstant: 35)
        messageButtonWidthAnchor?.isActive = true
        messageButtonHeightAnchor = messageButton.heightAnchor.constraint(equalToConstant: 35)
        messageButtonHeightAnchor?.isActive = true
        messageButton.layoutIfNeeded()
        addConstraint(NSLayoutConstraint(item: messageButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        messageButton.addTarget(self, action: #selector(showConversation), for: .touchUpInside)
    }
    
    func setupRequestSessionButton() {
        addSubview(requestSessionButton)
        requestSessionButton.anchor(top: nil, left: nil, bottom: nil, right: messageButton.leftAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 20, width: 35, height: 35)
        addConstraint(NSLayoutConstraint(item: requestSessionButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        requestSessionButton.addTarget(self, action: #selector(requestSession), for: .touchUpInside)
    }
    
     func setupSeparatorLine() {
        addSubview(separatorLine)
        separatorLine.anchor(top: nil, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
    }
    
    func updateUI(user: User) {
        self.user = user
        profileImageView.imageView.sd_setImage(with: user.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
        nameLabel.text = user.formattedName
        if let zfUser = user as? ZFTutor {
            let subject = zfUser.featuredSubject == "" ? zfUser.subjects?.first : zfUser.featuredSubject
            featuredSubject.text = subject
        } else if let awUser = user as? AWTutor {
            let subject = awUser.featuredSubject == "" ? awUser.subjects?.first : awUser.featuredSubject
            featuredSubject.text = subject
        }
        updateOnlineStatusIndicator()
    }
    
    private func updateOnlineStatusIndicator() {
        UserStatusService.shared.getUserStatus(self.user.uid) { (status) in
            let online = status?.status == UserStatusType.online
            self.profileImageView.onlineStatusIndicator.backgroundColor = online ? Colors.purple : Colors.gray
        }
    }
    
    func updateAsLearnerCell() {
        featuredSubject.removeFromSuperview()
        nameLabel.removeFromSuperview()
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 250, height: 0)
    }
    
    func updateToMainFeedLayout() {
        messageButton.setImage(nil, for: .normal)
        messageButtonWidthAnchor?.constant = 75
        messageButtonHeightAnchor?.constant = 30
        messageButton.layoutIfNeeded()
        messageButton.setTitle("Message", for: .normal)
        messageButton.backgroundColor = Colors.purple
        messageButton.layer.cornerRadius = 4
        separatorLine.isHidden = true
    }
    
    @objc func showConversation() {
        let userInfo: [AnyHashable: Any] = ["uid": user.uid]
        NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.activeTutorMessageButtonTapped, object: nil, userInfo: userInfo)
        delegate?.connectionCell(self, shouldShowConversationWith: user)
    }
    
    @objc func requestSession() {
        delegate?.connectionCell(self, shouldRequestSessionWith: user)
    }
    
    func handleTouchDown() {
        contentView.backgroundColor = Colors.darkBackground.darker(by: 30)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.contentView.backgroundColor = Colors.darkBackground
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
