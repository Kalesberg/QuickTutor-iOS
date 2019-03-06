//
//  QuickSearchSubcategoryCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 1/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QuickSearchSubcategoryCell: UICollectionViewCell {
    
    var subcategory: String?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(12)
        label.text = "Academics"
        label.textAlignment = .center
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
    }
    
    func setupMainView() {
        backgroundColor = Colors.gray
        layer.cornerRadius = 4
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 14, paddingBottom: 10, paddingRight: 14, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

