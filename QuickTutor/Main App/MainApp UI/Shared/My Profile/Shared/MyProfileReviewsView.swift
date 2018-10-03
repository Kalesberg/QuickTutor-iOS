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
	
	var isViewing : Bool = false
	
	init(isViewing:Bool=false) {
		self.isViewing = isViewing
		super.init(frame: .zero)
		configureView()
	}

	let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	var parentViewController : UIViewController?
	
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
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
		button.setTitle("See All »", for: .normal)
		button.titleLabel?.textColor = Colors.lightGrey
		button.titleLabel?.font = Fonts.createSize(14)
		return button
	}()
	
	let divider : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.divider
		return view
	}()
	
	let reviewLabel1 = MyProfileReview()
	let reviewLabel2 = MyProfileReview()
	
	var reviewSectionHeight : CGFloat {
		layoutIfNeeded()
		let maxLabelWidth: CGFloat = (UIScreen.main.bounds.width - 60)
		let neededSize1 = reviewLabel1.reviewTextLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude))
		let neededSize2 = reviewLabel2.reviewTextLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude))

		return (neededSize1.height + 50 + neededSize2.height + 50 + 20)
	}
	
	func configureView() {
		addSubview(reviewTitle)
		addSubview(seeAllButton)
		addSubview(divider)

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
		
		reviewLabel1.profilePic.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "placeholder-square"))
	}
	
	private func setupReviewLabel2() {
		addSubview(reviewLabel2)
		reviewLabel2.snp.makeConstraints { (make) in
			make.top.equalTo(reviewLabel1.snp.bottom)
			make.centerX.width.equalToSuperview()
		}
		let formattedName = dataSource[1].studentName.split(separator: " ")
		reviewLabel2.nameLabel.text = "\(String(formattedName[0])) \(String(formattedName[1]).prefix(1))."
		reviewLabel2.nameLabel.textColor = isViewing ? Colors.otherUserColor() : Colors.currentUserColor()
		reviewLabel2.reviewTextLabel.text = "\"\(dataSource[1].message)\""
		reviewLabel2.subjectLabel.attributedText = NSMutableAttributedString().bold("\(dataSource[1].rating) ★", 14, Colors.gold).bold(" - \(dataSource[1].subject)", 13, .white)
		reviewLabel2.dateLabel.text = "\(dataSource[1].date)"
		
		let reference = storageRef.child("student-info").child(dataSource[1].reviewerId).child("student-profile-pic1")
		reviewLabel2.profilePic.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "placeholder-square"))
	}
	
	private func setupBackgroundLabel() {
		let backgroundView = NoRatingsBackgroundView()
		addSubview(backgroundView)
		backgroundView.snp.makeConstraints { (make) in
			make.top.equalTo(reviewTitle.snp.bottom).inset(-5)
			make.centerX.width.equalToSuperview()
		}
	}
	
	@objc func seeAllButtonPressed(_ sender: UIButton) {
		let vc = LearnerReviewsVC()
		vc.datasource = dataSource
		vc.contentView.navbar.backgroundColor = isViewing ? Colors.otherUserColor() : Colors.currentUserColor()
		vc.contentView.statusbarView.backgroundColor = isViewing ? Colors.otherUserColor() : Colors.currentUserColor()
		vc.isViewing = isViewing
		parentViewController?.navigationController?.present(vc, animated: true)
	}
	
	private func setupReviewLabel() {
		reviewTitle.text = dataSource.count > 0 ? "Reviews (\(dataSource.count))" : "Reviews"
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		seeAllButton.layer.cornerRadius = 8
	}
}
