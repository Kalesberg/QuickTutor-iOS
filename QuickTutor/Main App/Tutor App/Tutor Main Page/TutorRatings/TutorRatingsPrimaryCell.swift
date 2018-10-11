//
//  TutorRatingsPrimaryCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorRatingsPrimaryCell: UICollectionViewCell {
    
    let infoBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.registrationDark
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    let ratingBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gold
        return view
    }()
    
    let starIcon: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(30)
        label.text = "★ 4.71"
        return label
    }()
    
    let detailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Based on 450 session ratings"
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(12)
        return label
    }()
    
    func setupViews() {
        setupInfoBackgroundView()
        setupRatingsBackgroundView()
        setupRatingLabel()
        setupDetailsLabel()
    }
    
    func setupInfoBackgroundView() {
        addSubview(infoBackgroundView)
        infoBackgroundView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 90)
    }
    
    func setupRatingsBackgroundView() {
        infoBackgroundView.addSubview(ratingBackgroundView)
        ratingBackgroundView.anchor(top: infoBackgroundView.topAnchor, left: infoBackgroundView.leftAnchor, bottom: nil, right: infoBackgroundView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 63)
    }
    
    func setupRatingLabel() {
        ratingBackgroundView.addSubview(ratingLabel)
        ratingLabel.anchor(top: ratingBackgroundView.topAnchor, left: ratingBackgroundView.leftAnchor, bottom: ratingBackgroundView.bottomAnchor, right: ratingBackgroundView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 3, paddingRight: 0, width: 0, height: 0)
    }
    func setupDetailsLabel() {
        infoBackgroundView.addSubview(detailsLabel)
        detailsLabel.anchor(top: nil, left: infoBackgroundView.leftAnchor, bottom: infoBackgroundView.bottomAnchor, right: infoBackgroundView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 25)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

