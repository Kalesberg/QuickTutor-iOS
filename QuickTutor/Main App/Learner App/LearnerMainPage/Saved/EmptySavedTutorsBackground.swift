//
//  EmptySavedTutorsBackground.swift
//  QuickTutor
//
//  Created by Will Saults on 5/17/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class EmptySavedTutorsBackground: UIView {
    let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.border
        label.numberOfLines = 0
        label.font = Fonts.createSize(15)
        label.text = "Maybe you’re not planning on learning today, but you can always start prepping for tomorrow. Tap the heart on your favorite tutors to save them here."
        return label
    }()
    
    func setupViews() {
        addSubview(textLabel)
        textLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 100)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
