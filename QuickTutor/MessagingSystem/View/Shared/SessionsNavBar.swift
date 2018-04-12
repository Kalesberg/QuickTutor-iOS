//
//  SessionsNavBar.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SessionNavBar: UIView {
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.learnerPurple
        return view
    }()
    
    let clockIcon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "clockIcon"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.text = "01:33:13"
        label.font = Fonts.createSize(15)
        return label
    }()
    
    let timeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "hh : mm : ss"
        label.font = Fonts.createSize(11)
        return label
    }()
    
    let sessionTypeIcon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "videoCameraIcon"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let sessionTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Video"
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(10)
        return label
    }()
    
    func setupViews() {
        setupBackgroundView()
        setupClockIcon()
        setupTimeLabel()
        setupTimeDescriptionLabel()
        setupSessionTypeIcon()
        setupSessionTypeLabel()
    }
    
    func setupBackgroundView() {
        addSubview(backgroundView)
        backgroundView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupClockIcon() {
        addSubview(clockIcon)
        clockIcon.anchor(top: backgroundView.topAnchor, left: backgroundView.leftAnchor, bottom: backgroundView.bottomAnchor, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 0, width: 27, height: 30)
    }
    
    func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.anchor(top: clockIcon.topAnchor, left: clockIcon.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 100, height: 15)
    }
    
    func setupTimeDescriptionLabel() {
        addSubview(timeDescriptionLabel)
        timeDescriptionLabel.anchor(top: timeLabel.bottomAnchor, left: timeLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 60, height: 15)
    }
    
    func setupSessionTypeIcon() {
        addSubview(sessionTypeIcon)
        sessionTypeIcon.anchor(top: backgroundView.topAnchor, left: nil, bottom: nil, right: backgroundView.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 30, height: 18)
    }
    
    func setupSessionTypeLabel() {
        addSubview(sessionTypeLabel)
        sessionTypeLabel.anchor(top: sessionTypeIcon.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 15)
        addConstraint(NSLayoutConstraint(item: sessionTypeLabel, attribute: .centerX, relatedBy: .equal, toItem: sessionTypeIcon, attribute: .centerX, multiplier: 1, constant: -2))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
