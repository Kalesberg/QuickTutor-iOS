//
//  SessionHeaderCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SessionHeaderCell: UICollectionReusableView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(22)
        label.text = "Pending"
        return label
    }()
    
    func setupViews() {
        setupTitleLabel()
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
