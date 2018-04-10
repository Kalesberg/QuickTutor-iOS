//
//  EmptyCellBackground.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class EmptyMessagesBackground: UIView {
    
    let icon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(17)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createLightSize(13)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    
    func setupViews() {
        backgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        setupIcon()
        setupTitleLabel()
        setupDescriptionLabel()
    }
    
    private func setupIcon() {
        addSubview(icon)
        icon.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 18, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 95, height: 95)
        addConstraint(NSLayoutConstraint(item: icon, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: icon.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 18)
        
    }
    
    private func setupDescriptionLabel() {
        addSubview(descriptionLabel)
        descriptionLabel.anchor(top: titleLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 325, height: 35)
        addConstraint(NSLayoutConstraint(item: descriptionLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupForLearner() {
        icon.image = #imageLiteral(resourceName: "searchIcon")
        titleLabel.text = "Start Searching"
        descriptionLabel.text = "When you connect with tutors they’ll appear here, where you can send them messages and schedule sessions."
    }
    
    func setupForTutor() {
        icon.image = #imageLiteral(resourceName: "buildIcon")
        titleLabel.text = "Build Your Profile"
        descriptionLabel.text = "When you connect with learners they’ll appear here, where you can send them messages and schedule sessions"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}