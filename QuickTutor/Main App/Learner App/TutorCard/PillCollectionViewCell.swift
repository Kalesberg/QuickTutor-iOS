//
//  PillCollectionViewCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class PillCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? Colors.learnerPurple : Colors.gray
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Swift"
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(14)
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
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
