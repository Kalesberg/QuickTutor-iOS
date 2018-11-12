//
//  FeaturedCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class TutorCollectionViewCell: UICollectionViewCell {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 4
        if #available(iOS 11.0, *) {
            iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let infoContainerView: UIView = {
        let view = UIView()
        view.layer.borderColor = Colors.profileGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Zach F."
        label.font = Fonts.createBoldSize(10)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(10)
        label.textAlignment = .right
        label.text = "$60/hr"
        return label
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.text = "Math"
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createBlackSize(12)
        return label
    }()
    
    let starView: StarView = {
        let view = StarView()
        return view
    }()
    
    func setupViews() {
        setupProfileImageView()
        setupInfoContainerView()
        setupNameLabel()
        setupPriceLabel()
        setupSubjectLabel()
        setupStarView()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 115)
    }
    
    func setupInfoContainerView() {
        insertSubview(infoContainerView, belowSubview: profileImageView)
        infoContainerView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: -1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: infoContainerView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 13)
    }
    
    func setupPriceLabel() {
        addSubview(priceLabel)
        priceLabel.anchor(top: infoContainerView.topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 40, height: 13)
    }
    
    func setupSubjectLabel() {
        addSubview(subjectLabel)
        subjectLabel.anchor(top: nameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 15)
    }
    
    func setupStarView() {
        addSubview(starView)
        starView.anchor(top: subjectLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 6, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 38, height: 6)
        starView.tintStars(color: Colors.currentUserColor())
    }
    
    func updateUI(_ tutor: FeaturedTutor) {
        nameLabel.text = tutor.name
        subjectLabel.text = tutor.subject
        priceLabel.text = "$\(tutor.price)/hr"
        profileImageView.sd_setImage(with: URL(string: tutor.imageUrl)!, completed: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
