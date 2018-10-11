//
//  TutorRatingsStatisticsCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorRatingsStatisticsCell: UICollectionViewCell {
    
    let topAccentView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gold
        return view
    }()
    
    let titleLabelBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.registrationDark
        view.layer.addBorder(edge: .top, color: .black, thickness: 2)
        return view
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createBoldSize(26)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(12)
        label.textAlignment = .center
        label.textColor = Colors.grayText
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        setupMainView()
        setupTopAccentView()
        setupCountLabel()
        setupTitleLabelBackgroundView()
        setupTitleLabel()
    }
    
    func setupMainView() {
        backgroundColor = Colors.registrationDark
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    func setupTopAccentView() {
        addSubview(topAccentView)
        topAccentView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 8)
    }
    
    func setupCountLabel() {
        addSubview(countLabel)
        countLabel.anchor(top: topAccentView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 75)
    }
    
    func setupTitleLabelBackgroundView() {
        addSubview(titleLabelBackgroundView)
        titleLabelBackgroundView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
    }
    
    func setupTitleLabel() {
        titleLabelBackgroundView.addSubview(titleLabel)
        titleLabel.anchor(top: titleLabelBackgroundView.topAnchor, left: titleLabelBackgroundView.leftAnchor, bottom: titleLabelBackgroundView.bottomAnchor, right: titleLabelBackgroundView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

