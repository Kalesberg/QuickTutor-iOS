//
//  SessionOnHoldModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SessionOnHoldModal: PauseSessionModal {
    
    var thinkingString = "Collin is thinking about adding time."
    
    let thinkingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        label.backgroundColor = Colors.navBarColor
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupThinkingLabel()
        unpauseButton.removeFromSuperview()
    }
    
    override func setupTitleLabel() {
        super.setupTitleLabel()
        titleLabel.text = "Session on hold"
    }
    
    func setupThinkingLabel() {
        background.addSubview(thinkingLabel)
        thinkingLabel.anchor(top: titleLabel.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
        thinkingLabel.text = thinkingString
    }
    
    func updateThinkingLabel(name: String) {
        thinkingLabel.text = "\(name) is thinking about adding time."
    }
    
}
