//
//  ReviewView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class ReviewView: UIView {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = Colors.gray
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark S."
        label.textAlignment = .left
        label.textColor = .white
        label.font = Fonts.createBlackSize(14)
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Dec 2019"
        label.textAlignment = .left
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = Fonts.createBoldSize(10)
        return label
    }()
    
    let starView: StarView = {
        let view = StarView()
        view.tintStars(color: Colors.purple)
        return view
    }()
    
    let reviewLabel: UILabel = {
        let label = UILabel()
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = Fonts.createSize(16)
        return label
    }()
    
    var reviewTextHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupProfileImageView()
        setupNameLabel()
        setupDateLabel()
        setupStarView()
        setupReviewLabel()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 0)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 150, height: 17)
    }
    
    func setupDateLabel() {
        addSubview(dateLabel)
        dateLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: profileImageView.bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 150, height: 12)
    }
    
    func setupStarView() {
        addSubview(starView)
        starView.anchor(top: nil, left: nil, bottom: profileImageView.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 55, height: 8)
    }
    
    func setupReviewLabel() {
        addSubview(reviewLabel)
        reviewLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 18, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        reviewTextHeightAnchor = reviewLabel.heightAnchor.constraint(equalToConstant: 63)
        reviewTextHeightAnchor?.isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
