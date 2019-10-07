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
        messageButton.setImage(UIImage(named: "ic_payment_del"), for: .normal)
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
            backgroundColor = isHighlighted ? Colors.newScreenBackground.darker(by: 30) : Colors.newScreenBackground
        }
    }

    static var reuseIdentifier: String {
        return String(describing: ConnectionCell.self)
    }
    
    let profileImageView: UserImageView = {
        let iv = UserImageView()
        iv.imageView.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.imageView.layer.cornerRadius = 25
        iv.imageView.clipsToBounds = true
        iv.isSkeletonable = true
        iv.imageView.isSkeletonable = true
        
        return iv
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBlackSize(14)
        label.text = "JH Lee"
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        
        return label
    }()

    let featuredSubject: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Colors.purple
        label.font = Fonts.createBoldSize(12)
        label.text = "Auburn, AL"
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        return stackView
    }()

    let messageButton: DimmableButton = {
        let button = DimmableButton()
        button.setImage(UIImage(named: "messageIconCircle"), for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(12)
        button.isHidden = true
        
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
        view.isHidden = true
        return view
    }()
    
    func setupViews() {
        setupProfileImageView()
        setupNameLabel()
        setupFeaturedSubject()
        setupStackView()
        setupSeparatorLine()
    }
    
    func setupProfileImageView() {
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
    }
    
    func setupNameLabel() {
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top).offset(10)
            make.left.equalTo(profileImageView.snp.right).offset(10)
        }
    }
    
    func setupFeaturedSubject() {
        contentView.addSubview(featuredSubject)
        featuredSubject.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(nameLabel.snp.left)
        }
    }
    
    func setupStackView() {
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
        setupRequestSessionButton()
        setupMessageButton()
    }
        
    func setupMessageButton() {
        let messageButtonContainer = UIView(frame: .zero)
        messageButtonContainer.backgroundColor = .clear
        stackView.addArrangedSubview(messageButtonContainer)
        messageButtonContainer.snp.makeConstraints { make in
            make.height.equalTo(35)
        }
        messageButtonContainer.addSubview(messageButton)
        messageButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.width.equalTo(35)
            make.centerY.equalToSuperview()
            make.height.equalTo(35)
        }
        messageButton.addTarget(self, action: #selector(showConversation), for: .touchUpInside)
    }
    
    func setupRequestSessionButton() {
        stackView.addArrangedSubview(requestSessionButton)
        requestSessionButton.snp.makeConstraints { make in
            make.width.equalTo(35)
            make.height.equalTo(35)
        }
        requestSessionButton.addTarget(self, action: #selector(requestSession), for: .touchUpInside)
    }
    
     func setupSeparatorLine() {
        contentView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(profileImageView.snp.right)
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func updateUI(user: User) {
        self.user = user
        profileImageView.imageView.sd_setImage(with: user.profilePicUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        nameLabel.text = user.formattedName
        if let zfUser = user as? ZFTutor {
            let subject = zfUser.featuredSubject == "" ? zfUser.subjects?.first : zfUser.featuredSubject
            featuredSubject.text = subject
        } else if let awUser = user as? AWTutor {
            let subject = awUser.featuredSubject == "" ? awUser.subjects?.first : awUser.featuredSubject
            featuredSubject.text = subject
            if let isConnected = awUser.isConnected, isConnected {
                messageButton.setTitle("Message", for: .normal)
            } else {
                messageButton.setTitle("Connect", for: .normal)
            }
        }
        messageButton.isHidden = false
        updateOnlineStatusIndicator()
    }
    
    private func updateOnlineStatusIndicator() {
        UserStatusService.shared.getUserStatus(self.user.uid) { (status) in
            let online = status?.status == UserStatusType.online
            self.profileImageView.onlineStatusIndicator.backgroundColor = online ? Colors.statusActiveColor : Colors.gray
        }
    }
    
    func updateAsLearnerCell() {
        featuredSubject.removeFromSuperview()
        nameLabel.removeFromSuperview()
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.bottom.equalToSuperview()
        }
    }
    
    func updateToMainFeedLayout() {
        messageButton.setImage(nil, for: .normal)
        messageButton.snp.updateConstraints { make in
            make.width.equalTo(70)
            make.height.equalTo(30)
        }
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
        contentView.backgroundColor = Colors.newScreenBackground.darker(by: 30)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.contentView.backgroundColor = Colors.newScreenBackground
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isSkeletonable = true
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class QTRecentlyActiveCollectionViewCell: ConnectionCell {
    
    override func setupProfileImageView() {
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
