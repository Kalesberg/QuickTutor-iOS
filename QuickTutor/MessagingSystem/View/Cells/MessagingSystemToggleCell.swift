//
//  MessagingSystemToggleCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class MessagingSystemToggleCell: UICollectionViewCell {
    var unselectedColor = UIColor.white.withAlphaComponent(0.5)
    var selectedColor = UIColor.white

    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = Fonts.createSize(15)
        return label
    }()
    
    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? selectedColor : unselectedColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? selectedColor : unselectedColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        completeSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .clear
        setupLabel()
    }
    
    func setupLabel() {
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

    func completeSetup() {
        
    }
}
