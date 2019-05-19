//
//  ProfileVCCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class ProfileCVCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? Colors.darkBackground.darker(by: 30) : Colors.darkBackground
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSemiBoldSize(14)
        label.textColor = .white
        return label
    }()
    
    let icon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
        setupIcon()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newBackground
    }
    
    func setupTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 60, width: 0, height: 0)
    }
    
    func setupIcon() {
        contentView.addSubview(icon)
        icon.anchor(top: nil, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 20, height: 20)
        addConstraint(NSLayoutConstraint(item: icon, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
