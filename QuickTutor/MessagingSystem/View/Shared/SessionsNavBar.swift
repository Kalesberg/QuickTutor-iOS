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
        view.backgroundColor = Colors.purple
        return view
    }()
    
    let clockBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.purple
        view.layer.cornerRadius = 20
        return view
    }()
    
    let clockIcon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "clockIcon"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let timeLabel: CountdownTimer = {
        let coundown = CountdownTimer()
        return coundown
    }()
    
    
    func setupViews() {
        setupBackgroundView()
        setupClockBackgroundView()
        setupClockIcon()
        setupTimeLabel()
    }
    
    func setupBackgroundView() {
        addSubview(backgroundView)
        backgroundView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        backgroundView.backgroundColor = Colors.purple
    }
    
    func setupClockBackgroundView() {
        addSubview(clockBackgroundView)
        clockBackgroundView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: -20, paddingBottom: 18, paddingRight: 0, width: 130, height: 40)
    }
    
    func setupClockIcon() {
        addSubview(clockIcon)
        clockIcon.anchor(top: clockBackgroundView.topAnchor, left: clockBackgroundView.leftAnchor, bottom: clockBackgroundView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 30, paddingBottom: 8, paddingRight: 0, width: 20, height: 20)
    }
    
    func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.anchor(top: clockIcon.topAnchor, left: clockIcon.rightAnchor, bottom: clockIcon.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 100, height: 0)
    }
    
    func setOpaque() {
        backgroundView.alpha = 0.5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
