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
            self.alpha = 0
        }
    }
}

protocol ConnectionCellDelegate {
    func connectionCell(_ connectionCell: ConnectionCell, shouldShowConversationWith user: User)
}

class ConnectionCell: UICollectionViewCell {
    var user: User!
    var delegate: ConnectionCellDelegate?

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Colors.darkBackground.darker(by: 30) : Colors.darkBackground
        }
    }

    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        return iv
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBlackSize(14)
        return label
    }()

    let locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Colors.grayText
        label.font = Fonts.createBoldSize(12)
        label.text = "Auburn, AL"
        return label
    }()

    let messageButton: DimmableButton = {
        let button = DimmableButton()
        button.setImage(UIImage(named: "messageIconCircle"), for: .normal)
        return button
    }()

    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundDark
        return view
    }()

    func setupViews() {
        setupProfileImageView()
        setupNameLabel()
        setupLocationLabel()
        setupMessageButton()
        setupSeparatorLine()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 10.5, paddingBottom: 5, paddingRight: 0, width: 50, height: 50)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 100, height: 15)
    }
    
    func setupLocationLabel() {
        addSubview(locationLabel)
        locationLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 150, height: 0)
    }
    
    func setupMessageButton() {
        addSubview(messageButton)
        messageButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 35, height: 35)
        addConstraint(NSLayoutConstraint(item: messageButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        messageButton.addTarget(self, action: #selector(showConversation), for: .touchUpInside)
    }
    
     func setupSeparatorLine() {
        addSubview(separatorLine)
        separatorLine.anchor(top: nil, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
    }
    
    func updateUI(user: User) {
        self.user = user
        profileImageView.sd_setImage(with: user.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
        nameLabel.text = user.formattedName
    }
    
    @objc func showConversation() {
        delegate?.connectionCell(self, shouldShowConversationWith: user)
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
