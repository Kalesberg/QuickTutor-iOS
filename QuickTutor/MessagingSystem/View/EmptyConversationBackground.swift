//
//  EmptyConversationBackground.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class EmptyConversationBackground: UIView {
    let icon: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "emptyChatImage")
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.border
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Fonts.createSize(11)
        label.text = "Select a custom message, or introduce yourself by typing a message. A tutor must accept your connection request before you are able to message them again"
        return label
    }()

    func setupViews() {
        addSubview(icon)
        addSubview(textLabel)
        icon.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 140)
        textLabel.anchor(top: icon.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 100)
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
