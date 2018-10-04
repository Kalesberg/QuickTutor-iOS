//
//  TutorRatingsReviewCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorRatingsReviewCell: UICollectionViewCell {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.learnerPurple
        label.font = Fonts.createBoldSize(12)
        return label
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gold
        label.font = Fonts.createSize(12)
        return label
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(12)
        return label
    }()
    
    let reviewTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.grayText
        label.font = Fonts.createItalicSize(12)
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(10)
        label.textAlignment = .right
        return label
    }()
    
    var nameLabelWidthAnchor: NSLayoutConstraint?
    
    func updateUI(review: Review) {
        nameLabel.text = review.studentName
        nameLabelWidthAnchor = nameLabel.widthAnchor.constraint(equalToConstant: review.studentName.estimateFrameForFontSize(12).width + 10)
        nameLabelWidthAnchor?.isActive = true
        layoutIfNeeded()
        ratingLabel.text = "★ \(review.rating)"
        subjectLabel.text = review.subject
        dateLabel.text = review.date
        reviewTextLabel.text = "\"\(review.message)\""
        DataService.shared.getStudentWithId(review.reviewerId) { (learner) in
            guard let learner = learner else { return }
            self.profileImageView.sd_setImage(with: learner.profilePicUrl)
        }
    }
    
    func setupViews() {
        setupMainView()
        setupProfilePicImageView()
        setupNameLabel()
        setupRatingLabel()
        setupSubjectLabel()
        setupReviewTextLabel()
        setupDateLabel()
    }
    
    func setupMainView() {
        backgroundColor = Colors.registrationDark
    }
    
    func setupProfilePicImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 7, paddingBottom: 5, paddingRight: 0, width: 50, height: 0)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 7, paddingBottom: 5, paddingRight: 7, width: 0, height: 12)
        
    }
    
    func setupRatingLabel() {
        addSubview(ratingLabel)
        ratingLabel.anchor(top: topAnchor, left: nameLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: 40, height: 10)
    }
    
    func setupSubjectLabel() {
        addSubview(subjectLabel)
        //        subjectLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 10)
        
    }
    
    func setupReviewTextLabel() {
        addSubview(reviewTextLabel)
        reviewTextLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 7, paddingBottom: 8, paddingRight: 7, width: 0, height: 0)
    }
    
    func setupDateLabel() {
        addSubview(dateLabel)
        dateLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 100, height: 10)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

