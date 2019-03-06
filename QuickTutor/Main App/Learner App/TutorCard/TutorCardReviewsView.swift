//
//  TutorCardReviewsView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol TutorCardReviewsViewDelegate {
    func reviewsView(_ reviewsView: TutorCardReviewsView, didUpdate height: CGFloat)
}

class TutorCardReviewsView: UIView {
    
    var delegate: TutorCardReviewsViewDelegate?
    
    let reviewView: ReviewView = {
        let view = ReviewView()
        return view
    }()
    
    let seeAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Read all 12 reviews", for: .normal)
        button.titleLabel?.font = Fonts.createSize(16)
        button.setTitleColor(Colors.purple, for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray
        view.layer.cornerRadius = 0.5
        return view
    }()
    
    var reviewsViewHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupReviewView()
        setupSeeAllButton()
        setupSeparator()
    }
    
    func setupReviewView() {
        addSubview(reviewView)
        reviewView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        reviewsViewHeightAnchor = reviewView.heightAnchor.constraint(equalToConstant: 120)
        reviewsViewHeightAnchor?.isActive = true
    }
    
    func setupSeeAllButton() {
        addSubview(seeAllButton)
        seeAllButton.anchor(top: reviewView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
    }
    
    func setupSeparator() {
        addSubview(separator)
        separator.anchor(top: seeAllButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func updateUI(_ tutor: AWTutor) {
        guard let lastReview = tutor.reviews?.last else { return }
        reviewView.nameLabel.text = lastReview.studentName
        reviewView.dateLabel.text = lastReview.formattedDate
        reviewView.reviewLabel.text = lastReview.message
        let rating = Int(lastReview.rating)
        reviewView.starView.setRating(rating)
        DataService.shared.getStudentWithId(lastReview.reviewerId) { (student) in
            guard let student = student else { return }
            self.reviewView.profileImageView.sd_setImage(with: student.profilePicUrl)
        }
        updateHeight()
    }
    
    func updateHeight() {
        guard let text = reviewView.reviewLabel.text else { return }
        let reviewHeight = text.estimateFrameForFontSize(14).height + 10
        reviewView.reviewTextHeightAnchor?.constant = reviewHeight
        reviewsViewHeightAnchor?.constant = reviewHeight + 40 + 18
        let height = reviewHeight + 40 + 18 + 20 + 45
        delegate?.reviewsView(self, didUpdate: height)
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
