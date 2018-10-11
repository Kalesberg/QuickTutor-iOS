//
//  TutorRatingsHeaderCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorRatingsHeaderCell: UICollectionReusableView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(15)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
