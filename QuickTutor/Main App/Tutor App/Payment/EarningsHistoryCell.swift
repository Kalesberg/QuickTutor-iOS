//
//  EarningsHistoryCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class EarningsHistoryCell: UICollectionViewCell {
    
    let profilePicImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBlackSize(12)
        label.textColor = .white
        return label
    }()
    
    let amountLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBlackSize(10)
        label.textColor = Colors.purple
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(10)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .right
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupProfilePicImageView()
        setupUsernameLabel()
        setupAmountLabel()
        setupTimeLabel()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupProfilePicImageView() {
        addSubview(profilePicImageView)
        profilePicImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 0)
    }
    
    func setupUsernameLabel() {
        addSubview(usernameLabel)
        usernameLabel.anchor(top: topAnchor, left: profilePicImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 150, height: 15)
    }
    
    func setupAmountLabel() {
        addSubview(amountLabel)
        amountLabel.anchor(top: usernameLabel.bottomAnchor, left: profilePicImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 250, height: 14)
    }
    
    func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 14)
    }
    
    func updateUI(_ session: Session) {
        UserFetchService.shared.getStudentWithId(session.senderId) { (user) in
            guard let user = user else { return }
            self.updateTimestampLabel(session: session)
            self.amountLabel.text = "$\(String(format: "%.2f", session.cost))"
            self.usernameLabel.text = user.formattedName
            self.profilePicImageView.sd_setImage(with: user.profilePicUrl)
        }
    }
    
    private func updateTimestampLabel(session: Session) {
        let timestampDate = Date(timeIntervalSince1970: session.date)
        timeLabel.text = timestampDate.formatRelativeString()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
