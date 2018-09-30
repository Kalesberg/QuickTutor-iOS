//
//  MyProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import FirebaseUI
import Foundation
import SnapKit
import UIKit

protocol LearnerWasUpdatedCallBack {
    func learnerWasUpdated(learner: AWLearner!)
}

class LearnerMyProfileVC: BaseViewController, LearnerWasUpdatedCallBack {

    override var contentView: LearnerMyProfileView {
        return view as! LearnerMyProfileView
    }

    override func loadView() {
        view = LearnerMyProfileView()
    }

    var learner: AWLearner! {
        didSet {
			contentView.myProfileReviews.tableView.reloadData()
        }
    }
	
	var datasource  =  [Review]() {
		didSet{
			if datasource.count == 0 {
				contentView.myProfileReviews.tableView.backgroundView = NoRatingsTableViewCell()
			} else {
				contentView.myProfileReviews.tableView.backgroundView = nil
			}
			contentView.myProfileReviews.tableView.reloadData()
		}
	}
	let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	
	var isViewing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegates()
		datasource = learner.lReviews
        let name = learner.name.split(separator: " ")
        contentView.myProfileHeader.nameLabel.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
		
        let reference = storageRef.child("student-info").child(learner.uid).child("student-profile-pic1")
		let imageView = UIImageView()
		imageView.sd_setImage(with: reference, placeholderImage: nil)
        contentView.myProfileHeader.profileImageViewButton.setImage(imageView.image, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		setAboutMeLabelText()
		layoutExtraInfomration()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		var contentSizeHeight : CGFloat = 0.0
		
		for view in contentView.scrollView.subviews {
			contentSizeHeight += view.frame.height
		}
		
		contentView.scrollView.contentSize.height = contentSizeHeight + 300
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

	}

	private func configureDelegates() {
       	contentView.myProfileReviews.tableView.delegate = self
       	contentView.myProfileReviews.tableView.dataSource = self
		contentView.myProfileReviews.tableView.register(TutorMyProfileReviewTableViewCell.self, forCellReuseIdentifier: "ratingTableViewCell")
	}
	
    func learnerWasUpdated(learner: AWLearner!) {
        self.learner = learner
        let name = learner.name.split(separator: " ")
        contentView.myProfileHeader.nameLabel.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
    }

	private func layoutExtraInfomration() {
		var views = [UIView]()
		
		views.append(ProfileItem(icon: UIImage(named: "tutored-in")!, title: "Tutored in \(learner.lNumSessions!) sessions"))
		
		if let languages = learner.languages {
			views.append(ProfileItem(icon: UIImage(named: "speaks")!, title: "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))"))
		}
		
		if learner.school != "" && learner.school != nil {
			views.append(ProfileItem(icon: UIImage(named: "studys-at")!, title: "Studies at " + learner.school!))
		}

		contentView.myProfileBody.stackView.subviews.forEach({ $0.removeFromSuperview() })		
		views.forEach({	self.contentView.myProfileBody.stackView.addArrangedSubview($0) })
		
		contentView.myProfileBody.stackView.snp.remakeConstraints { (make) in
			make.top.equalTo(contentView.myProfileBody.additionalInformation.snp.bottom).inset(-5)
			make.leading.equalToSuperview().inset(12)
			make.trailing.equalToSuperview().inset(5)
			make.height.equalTo(CGFloat(views.count * 30))
		}
		
		contentView.myProfileBody.snp.remakeConstraints { (make) in
			make.top.equalTo(contentView.myProfileBioView.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(30 + CGFloat(views.count * 30))
		}
		
		setupReviews()
	}
	
	private func setupReviews() {
		contentView.myProfileReviews.review.text = learner.lReviews.count > 0 ? "Reviews (\(learner.lReviews.count))" : "No Reviews"
		
		contentView.myProfileReviews.snp.remakeConstraints { (make) in
			make.top.equalTo(contentView.myProfileBody.divider.snp.bottom).inset(-5)
			make.width.centerX.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		contentView.myProfileReviews.tableView.snp.remakeConstraints { make in
			make.top.equalTo(contentView.myProfileReviews.review.snp.bottom)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.95)
			make.height.equalTo((learner.lReviews.count) == 1 ? 120 : 190)
		}
	}
	
	private func setAboutMeLabelText() {
		let bio : String
		if learner.bio == "" && !isViewing {
			bio = "No biography yet! You can add a bio by tapping \"edit\" in the top right of the screen."
		} else if learner.bio == "" && isViewing {
			let name = learner.name.split(separator: " ")
			bio = "\(String(name[0])) has not yet entered a biography."
		} else {
			bio = learner.bio
		}
		contentView.myProfileBioView.bioLabel.text = bio
	}
	
	override func handleNavigation() {
		if touchStartView is NavbarButtonEdit {
			let next = LearnerEditProfileVC()
			next.delegate = self
			navigationController?.pushViewController(next, animated: true)
		}
	}
}

extension LearnerMyProfileVC: ProfileImageViewerDelegate {
    func dismiss() {
        dismissProfileImageViewer()
    }
}

extension LearnerMyProfileVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let reviews = learner.lReviews, reviews.count > 0 else { return 0 }
		return (reviews.count > 2) ? 2 : 1
	}
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ratingTableViewCell", for: indexPath) as!
		TutorMyProfileReviewTableViewCell

		cell.nameLabel.text = learner.formattedName
		cell.reviewTextLabel.text = datasource[indexPath.row].message
		cell.subjectLabel.attributedText = NSMutableAttributedString().bold("\(datasource[indexPath.row].rating) ★", 14, Colors.gold).bold(" - \(datasource[indexPath.row].subject)", 13, .white)
		cell.dateLabel.text = "\(datasource[indexPath.row].date)"
		
		let reference = storageRef.child("student-info").child(datasource[indexPath.row].reviewerId).child("student-profile-pic1")
		cell.profilePic.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
		
		return cell
    }
}

extension LearnerMyProfileVC : UIScrollViewDelegate {
	//allow scrolling to not be affected by UIButton or UITableView
	func touchesShouldCancel(in view: UIView) -> Bool {
		return (view is UIButton || view is UITableView)
	}
	//disable Horizontal scroll.
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: true)
	}
}
