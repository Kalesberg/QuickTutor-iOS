//
//  EndSessionProfileBox.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class EndSessionProfileBox: SessionProfileBox {
    
    override func setupImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 23.5, paddingBottom: 0, paddingRight: 23.5, width: 0, height: 113)
    }
    
    override func setupNameLabel() {
        super.setupNameLabel()
        nameLabel.font = Fonts.createSize(18)
    }
    
}
