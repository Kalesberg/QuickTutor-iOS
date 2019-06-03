//
//  RecentSearchCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/13/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class RecentSearchCell: QuickSearchSubcategoryCell {
    override func setupViews() {
        super.setupViews()
        backgroundColor = Colors.newScreenBackground
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        layer.borderWidth = 1
    }
    
    override func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
}
