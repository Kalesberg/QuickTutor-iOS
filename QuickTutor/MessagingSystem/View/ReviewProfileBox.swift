//
//  ReviewProfileBox.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class ReviewProfileBox: SessionProfileBox {
    
    override func setupImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 123, height: 123)
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: boundingBox, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    override func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: imageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
}
