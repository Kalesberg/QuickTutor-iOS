//
//  EarningsHistoryTableViewCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class EarningsHistoryTaleViewCell: UITableViewCell {
    
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
        backgroundColor = Colors.darkBackground
        selectionStyle = .none
    }
    
    func setupProfilePicImageView() {
        addSubview(profilePicImageView)
        profilePicImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.left.equalTo(20)
        }
    }
    
    func setupUsernameLabel() {
        addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(profilePicImageView.snp.top).offset(4)
            make.left.equalTo(profilePicImageView.snp.right).offset(10)
        }
    }
    
    func setupAmountLabel() {
        addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.left.equalTo(usernameLabel.snp.left)
            make.top.equalTo(usernameLabel.snp.bottom).offset(5)
        }
    }
    
    func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(usernameLabel.snp.top)
        }
    }
    
    func updateUI(_ session: Session) {
        UserFetchService.shared.getTutorWithId(session.receiverId) { (user) in
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

