//
//  ConnectionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

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
        iv.layer.cornerRadius = 30
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(14)
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(10)
        label.text = "Auburn, AL"
        return label
    }()
    
    let starIcon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "filledStar"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let starLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(12)
        label.textColor = Colors.gold
        label.text = "5.0"
        return label
    }()
    
    let ratingsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(9)
        label.textColor = Colors.gold
        label.text = "(22 ratings)"
        return label
    }()
    
    let messageButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.currentUserColor()
        button.setTitle("Message", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(13)
        button.layer.cornerRadius = 15
        button.applyDefaultShadow()
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
        setupMessageButton()
        setupStarLabel()
        setupStarIcon()
        setupRatingsLabel()
        setupSeparatorLine()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 10.5, paddingBottom: 5, paddingRight: 0, width: 60, height: 60)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 100, height: 15)
    }
    
    func setupLocationLabel() {
        addSubview(locationLabel)
        locationLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 150, height: 0)
    }
    
    func setupStarLabel() {
        contentView.addSubview(starLabel)
        starLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 20, height: 10)
    }
    
    func setupStarIcon() {
        contentView.addSubview(starIcon)
        starIcon.anchor(top: nil, left: starLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 12, height: 12)
        addConstraint(NSLayoutConstraint(item: starIcon, attribute: .centerY, relatedBy: .equal, toItem: starLabel, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func setupRatingsLabel() {
        addSubview(ratingsLabel)
        ratingsLabel.anchor(top: starLabel.topAnchor, left: starIcon.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 50, height: 10)
    }
    func setupMessageButton() {
        addSubview(messageButton)
        messageButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 90, height: 30)
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
        guard let rating = user.rating else { return }
        starLabel.text = "\(rating)"
        user.getNumberOfReviews { (reviewCount) in
            guard let count = reviewCount else { return }
            self.ratingsLabel.text = "(\(count) ratings)"
        }
    }
    
    @objc func showConversation() {
        delegate?.connectionCell(self, shouldShowConversationWith: user)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
