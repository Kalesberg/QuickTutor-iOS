//
//  MyProfileReviewsView.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseUI
import Foundation

class MyProfileReviewsView : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}

	let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

	var parentViewController : UIViewController?
	var isViewing : Bool = false
	var dataSource = [Review]() {
		didSet {
			setupReviewLabel()
		}
	}
	
	let reviewTitle : UILabel = {
		let label = UILabel()
		label.font = Fonts.createBoldSize(16)
		label.textAlignment = .left
		return label
	}()
	
	let seeAllButton : UIButton = {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 300))
		
		button.setTitle("See All »", for: .normal)
		button.titleLabel?.textColor = Colors.lightGrey
		button.titleLabel?.font = Fonts.createSize(14)

		return button
	}()
	let reviewLabel1 = TutorMyProfileReviewTableViewCell()
	let reviewLabel2 = TutorMyProfileReviewTableViewCell()

	
	var reviewSectionHeight : CGFloat {
		layoutIfNeeded()
		let verticlePadding : CGFloat = 45
		return (reviewLabel1.frame.height + reviewLabel2.frame.height + verticlePadding)
	}
	func configureView() {
		addSubview(reviewTitle)
		addSubview(seeAllButton)

		seeAllButton.addTarget(self, action: #selector(seeAllButtonPressed(_:)), for: .touchUpInside)
		reviewTitle.textColor = isViewing ? Colors.otherUserColor() : Colors.currentUserColor()
		
		applyConstraints()
	}
	
	func applyConstraints() {
		reviewTitle.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview().inset(12)
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalTo(30)
		}
		seeAllButton.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.right.equalToSuperview().inset(12)
		}
		setupMostRecentReviews()
	}
	
	func setupMostRecentReviews() {
	
		if dataSource.count >= 2 {
			setupReviewLabel1()
			setupReviewLabel2()
		} else if dataSource.count == 1 {
			setupReviewLabel1()
		} else {
			setupBackgroundLabel()
		}
	}
	
	private func setupReviewLabel1() {
		addSubview(reviewLabel1)
		reviewLabel1.snp.makeConstraints { (make) in
			make.top.equalTo(reviewTitle.snp.bottom).inset(-5)
			make.centerX.width.equalToSuperview()
		}
		let formattedName = dataSource[0].studentName.split(separator: " ")
		reviewLabel1.nameLabel.text = "\(String(formattedName[0])) \(String(formattedName[1]).prefix(1))."
		reviewLabel1.nameLabel.textColor = isViewing ? Colors.otherUserColor() : Colors.currentUserColor()
		reviewLabel1.reviewTextLabel.text = "\"\(dataSource[0].message)\""
		reviewLabel1.subjectLabel.attributedText = NSMutableAttributedString().bold("\(dataSource[0].rating) ★", 14, Colors.gold).bold(" - \(dataSource[0].subject)", 13, .white)
		reviewLabel1.dateLabel.text = "\(dataSource[0].date)"
		
		let reference = storageRef.child("student-info").child(dataSource[0].reviewerId).child("student-profile-pic1")
		reviewLabel1.profilePic.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
	}
	
	private func setupReviewLabel2() {
		addSubview(reviewLabel2)
		reviewLabel2.snp.makeConstraints { (make) in
			make.top.equalTo(reviewLabel1.snp.bottom)
			make.centerX.width.equalToSuperview()
		}
		let formattedName = dataSource[1].studentName.split(separator: " ")
		reviewLabel2.nameLabel.text = "\(String(formattedName[0])) \(String(formattedName[1]).prefix(1))."
		reviewLabel2.reviewTextLabel.text = "\"\(dataSource[1].message)\""
		reviewLabel2.subjectLabel.attributedText = NSMutableAttributedString().bold("\(dataSource[1].rating) ★", 14, Colors.gold).bold(" - \(dataSource[1].subject)", 13, .white)
		reviewLabel2.dateLabel.text = "\(dataSource[1].date)"
		
		let reference = storageRef.child("student-info").child(dataSource[1].reviewerId).child("student-profile-pic1")
		reviewLabel2.profilePic.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
	}
	
	private func setupBackgroundLabel() {
		addSubview(NoRatingsBackgroundView())
	}
	
	@objc func seeAllButtonPressed(_ sender: UIButton) {
		let vc = LearnerReviewsVC()
		vc.datasource = dataSource
		parentViewController?.navigationController?.present(vc, animated: true)
	}
	private func setupReviewLabel() {
		reviewTitle.text = dataSource.count > 0 ? "Reviews (\(dataSource.count))" : "No Reviews"
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		seeAllButton.layer.cornerRadius = 8
	}
}
