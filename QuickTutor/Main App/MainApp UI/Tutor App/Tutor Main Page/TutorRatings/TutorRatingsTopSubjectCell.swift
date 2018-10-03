//
//  TutorRatingsTopSubjectCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorRatingsTopSubjectCell: UICollectionViewCell {
    
    let subjectIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
        setupSubjectIcon()
    }
    
    func setupMainView() {
        backgroundColor = Colors.registrationDark
        layer.cornerRadius = 8
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 30)
    }
    
    func setupSubjectIcon() {
        addSubview(subjectIcon)
        subjectIcon.anchor(top: nil, left: nil, bottom: titleLabel.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 75, height: 75)
        addConstraint(NSLayoutConstraint(item: subjectIcon, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


