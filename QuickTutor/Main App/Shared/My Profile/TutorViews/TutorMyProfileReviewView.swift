//
//  TutorMyProfileReviewView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/17/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseUI

class TutorMyProfileReviewsView : UIView {
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
		let baseHeight = self.subviews.reduce(0) { $0 + $1.frame.height } - 30
		let labelHeight1 = reviewLabel1.reviewTextLabel.text?.height(withConstrainedWidth: UIScreen.main.bounds.width - 60, font: Fonts.createItalicSize(14)) ?? 0
		let labelHeight2 = reviewLabel2.reviewTextLabel.text?.height(withConstrainedWidth: UIScreen.main.bounds.width - 60, font: Fonts.createItalicSize(14)) ?? 0
		return  baseHeight + labelHeight1 + labelHeight2
	}
	
	func configureView() {
		addSubview(reviewTitle)
		addSubview(divider)
		
		seeAllButton.addTarget(self, action: #selector(seeAllButtonPressed(_:)), for: .touchUpInside)
		reviewTitle.textColor = Colors.purple
		
		applyConstraints()
	}

	func applyConstraints() {
		reviewTitle.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview().inset(12)
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalTo(30)
		}
		divider.snp.makeConstraints { (make) in
			make.bottom.centerX.equalToSuperview()
			make.height.equalTo(1)
			make.width.equalToSuperview().inset(20)
		}
	}
	func setupMostRecentReviews() {
		if dataSource.count >= 2 {
			setupReviewLabel1()
			setupReviewLabel2()
			setupSeeAllButton()
		} else if dataSource.count == 1 {
			setupReviewLabel1()
			setupSeeAllButton()
		}
	}
	private func setupSeeAllButton() {
		addSubview(seeAllButton)
		seeAllButton.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.right.equalToSuperview().inset(12)
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
		reviewLabel1.nameLabel.textColor = Colors.purple
		reviewLabel1.reviewTextLabel.text = "\"\(dataSource[0].message)\""
		reviewLabel1.subjectLabel.attributedText = NSMutableAttributedString().bold("\(dataSource[0].rating) ★", 14, Colors.gold).bold(" - \(dataSource[0].subject)", 13, .white)
		reviewLabel1.dateLabel.text = "\(dataSource[0].formattedDate)"
		
		let reference = storageRef.child("student-info").child(dataSource[0].reviewerId).child("student-profile-pic1")
		reviewLabel1.profilePic.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "placeholder-square"))
		reviewLabel1.buttonMask.tag = 0
		reviewLabel1.buttonMask.addTarget(self, action: #selector(showReviewerProfile(_:)), for: .touchUpInside)
	}
	
	private func setupReviewLabel2() {
		addSubview(reviewLabel2)
		reviewLabel2.snp.makeConstraints { (make) in
			make.top.equalTo(reviewLabel1.snp.bottom)
			make.centerX.width.equalToSuperview()
		}
		let formattedName = dataSource[1].studentName.split(separator: " ")
		reviewLabel2.nameLabel.text = "\(String(formattedName[0])) \(String(formattedName[1]).prefix(1))."
		reviewLabel2.nameLabel.textColor = Colors.purple
		reviewLabel2.reviewTextLabel.text = "\"\(dataSource[1].message)\""
		reviewLabel2.subjectLabel.attributedText = NSMutableAttributedString().bold("\(dataSource[1].rating) ★", 14, Colors.gold).bold(" - \(dataSource[1].subject)", 13, .white)
		reviewLabel2.dateLabel.text = "\(dataSource[1].formattedDate)"
		
		let reference = storageRef.child("student-info").child(dataSource[1].reviewerId).child("student-profile-pic1")
		reviewLabel2.profilePic.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "placeholder-square"))
		reviewLabel2.buttonMask.tag = 1
		reviewLabel2.buttonMask.addTarget(self, action: #selector(showReviewerProfile(_:)), for: .touchUpInside)
	}
	
	@objc private func seeAllButtonPressed(_ sender: UIButton) {
		let vc = TutorReviewsVC()
		vc.datasource = dataSource
		vc.contentView.navbar.backgroundColor = Colors.purple
		vc.contentView.statusbarView.backgroundColor = Colors.purple
		vc.isViewing = isViewing
		let nav = parentViewController?.navigationController
		DispatchQueue.main.async {
			nav?.view.layer.add(CATransition().segueFromBottom(), forKey: nil)
			nav?.pushViewController(vc, animated: false)
		}
	}
	
	@objc private func showReviewerProfile(_ sender: UIButton) {
		let vc = LearnerMyProfileVC()
		FirebaseData.manager.fetchLearner(dataSource[sender.tag].reviewerId) { (learner) in
			if let learner = learner {
				vc.learner = learner
				vc.isViewing = true
                vc.isEditable = false
				self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
			}
		}
	}
	
	private func setupReviewLabel() {
		reviewTitle.text = dataSource.count > 0 ? "Reviews (\(dataSource.count))" : "Reviews"
	}
}

extension String {
	func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		
		return boundingBox.height
	}
}

class NoReviewsView : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}
	
	let reviewTitle : UILabel = {
		let label = UILabel()
		label.text = "Reviews"
		label.font = Fonts.createBoldSize(16)
		label.textAlignment = .left
		label.textColor = Colors.purple
		return label
	}()
	
	let divider : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.divider
		return view
	}()
	
	let backgroundView = NoRatingsBackgroundView()
	
	
	func configureView() {
		addSubview(reviewTitle)
		addSubview(divider)
		addSubview(backgroundView)

		reviewTitle.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview().inset(12)
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalTo(30)
		}
		backgroundView.snp.makeConstraints { (make) in
			make.top.equalTo(reviewTitle.snp.bottom).inset(-5)
			make.centerX.width.equalToSuperview()
		}
		divider.snp.makeConstraints { (make) in
			make.bottom.centerX.equalToSuperview()
			make.height.equalTo(1)
			make.width.equalToSuperview().inset(20)
		}
	}
}
