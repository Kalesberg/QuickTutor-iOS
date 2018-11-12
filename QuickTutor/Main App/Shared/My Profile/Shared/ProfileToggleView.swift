//
//  ProfileToggleView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol ProfileModeToggleViewDelegate: class {
    func profleModeToggleView(_ profileModeToggleView: ProfileModeToggleView, shouldSwitchTo side: UserType)
}

class ProfileModeToggleView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.text = "Learner mode"
        return label
    }()
    
    let switchButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.currentUserColor()
        button.layer.cornerRadius = 4
        button.setTitle("Switch", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(12)
        return button
    }()
    
    weak var delegate: ProfileModeToggleViewDelegate?
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
        setupSwitchButton()
    }
    
    func setupMainView() {
        layer.cornerRadius = 4
        layer.borderColor = Colors.profileGray.cgColor
        layer.borderWidth = 2
        backgroundColor = Colors.newBackground
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupSwitchButton() {
        addSubview(switchButton)
        switchButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 60, height: 30)
        addConstraint(NSLayoutConstraint(item: switchButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        switchButton.addTarget(self, action: #selector(switchSide), for: .touchUpInside)
    }
    
    @objc func switchSide() {
        let newUserType: UserType = AccountService.shared.currentUserType == .learner ? .tutor : .learner
        delegate?.profleModeToggleView(self, shouldSwitchTo: newUserType)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
