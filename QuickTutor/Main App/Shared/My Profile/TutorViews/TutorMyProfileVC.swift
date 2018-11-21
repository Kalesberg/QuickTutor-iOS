//
//  MyProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseUI
import Foundation
import UIKit

protocol UpdatedTutorCallBack: class {
    func tutorWasUpdated(tutor: AWTutor!)
}

class TutorMyProfileVC: BaseViewController, UpdatedTutorCallBack {

    override var contentView: TutorMyProfileView {
        return view as! TutorMyProfileView
    }
	override func loadView() {
		view = TutorMyProfileView()
	}
	let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

	var dataSource = [Review]()
    var tutor: AWTutor!
	var isViewing: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()
		guard let reviews = tutor.reviews else { return }
		dataSource = reviews
        navigationItem.title = tutor.username
        if !isViewing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfile))
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		contentView.isViewing = isViewing
		setupMyProfileHeader()
		setupMyProfileBioView()
		setupMyProfileBody()
		setupMyProfileSubjects()
		tutor.reviews?.count == 0 ? setupMyProfileNoReviews() : setupMyProfileReviews()
		setupMyProfilePolicies()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		contentView.scrollView.contentSize.height = contentView.scrollView.subviews.reduce(0) { $0 + $1.frame.height }
	}
	
	func tutorWasUpdated(tutor: AWTutor!) {
		self.tutor = tutor
		let name = tutor.name.split(separator: " ")
		contentView.myProfileHeader.nameLabel.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
	}
	
	private func setupMyProfileHeader() {
		let reference = storageRef.child("student-info").child(tutor.uid).child("student-profile-pic1")
		contentView.myProfileHeader.userId = tutor.uid
		contentView.myProfileHeader.nameLabel.text = tutor.formattedName
		contentView.myProfileHeader.imageCount = tutor.images.filter({ $0.value != "" }).count
		contentView.myProfileHeader.profileImageView.sd_setImage(with: reference)
		contentView.myProfileHeader.parentViewController = self
		contentView.myProfileHeader.price.text = "$\(String(describing: tutor.price!))/hr"
		contentView.myProfileHeader.rating.text = "\(String(describing: tutor.tRating ?? 5.0)) ★ Rating"
		
		//let reviewsString = (dataSource.count == 1) ? "rating" : "ratings"
		//contentView.myProfileHeader.rating.text = "\(String(describing: tutor.tRating ?? 5.0)) ★ (\(String(describing: dataSource.count)) \(reviewsString))"
	}
	
	private func setupMyProfileBioView() {
		let bio : String
		if tutor.tBio == "" && !isViewing {
			bio = "No biography yet! You can add a bio by tapping \"edit\" in the top right of the screen."
		} else if tutor.tBio == "" && isViewing {
			bio = "\(tutor.formattedName) has not yet entered a biography."
		} else {
			bio = tutor.tBio
		}
		contentView.myProfileBioView.bioLabel.text = bio
	}
	
	private func setupMyProfileBody() {
		let extraInfomationViews = getViewsForExtraInformationSection()
		contentView.myProfileBody.stackView.subviews.forEach({ $0.removeFromSuperview() })
		extraInfomationViews.forEach({	self.contentView.myProfileBody.stackView.addArrangedSubview($0) })
		
		contentView.myProfileBody.stackView.snp.remakeConstraints { (make) in
			make.top.equalTo(contentView.myProfileBody.additionalInformation.snp.bottom).inset(-5)
			make.leading.equalToSuperview().inset(12)
			make.trailing.equalToSuperview().inset(5)
			make.height.equalTo(CGFloat(extraInfomationViews.count * 30))
		}
		contentView.myProfileBody.snp.remakeConstraints { (make) in
			make.top.equalTo(contentView.myProfileBioView.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(30 + CGFloat(extraInfomationViews.count * 30))
		}
	}
	
	private func setupMyProfileSubjects() {
		contentView.myProfileSubjects.datasource = tutor.subjects ?? []
	}
	
	private func setupMyProfileNoReviews() {
		contentView.scrollView.addSubview(contentView.myProfileNoReviews)
		contentView.myProfileNoReviews.snp.makeConstraints { (make) in
			make.top.equalTo(contentView.myProfileSubjects.snp.bottom).inset(-5)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(80)
		}
	}
	
	private func setupMyProfileReviews() {
		guard let reviews = tutor.reviews else { return }
		contentView.myProfileReviews.isViewing = isViewing
		contentView.myProfileReviews.parentViewController = self
		contentView.myProfileReviews.dataSource = reviews.sorted(by: { $0.timestamp > $1.timestamp })
		
		contentView.myProfileReviews.setupMostRecentReviews()
		
		contentView.myProfileReviews.snp.makeConstraints { (make) in
			make.top.equalTo(contentView.myProfileSubjects.snp.bottom).inset(-5)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(contentView.myProfileReviews.reviewSectionHeight)
		}
	}
	private func setupMyProfilePolicies() {
		guard let policy = tutor.policy else { return }
		let policies = policy.split(separator: "_")
		contentView.myProfilePolicies.policiesLabel.attributedText = NSMutableAttributedString()
			.bold("•  ", 20, .white).regular(tutor.distance.distancePreference(tutor.preference), 16, Colors.grayText)
			.bold("•  ", 20, .white).regular(tutor.preference.preferenceNormalization(), 16, Colors.grayText)
			.bold("•  ", 20, .white).regular(String(policies[0]).lateNotice(), 16, Colors.grayText)
			.bold("•  ", 20, .white).regular(String(policies[2]).cancelNotice(), 16, Colors.grayText)
				.regular(String(policies[1]).lateFee(), 16, Colors.qtRed)
				.regular(String(policies[3]).cancelFee(), 16, Colors.qtRed)

		contentView.myProfilePolicies.snp.makeConstraints { (make) in
			let topConstraint = tutor.reviews?.count == 0 ? contentView.myProfileNoReviews.snp.bottom : contentView.myProfileReviews.snp.bottom
			make.top.equalTo(topConstraint).inset(-5)
			make.width.centerX.equalToSuperview()
		}
	}
	
	private func getViewsForExtraInformationSection() -> [UIView] {
		var views = [UIView]()
		
		views.append(ProfileItem(icon: UIImage(named: "tutored-in")!, title: "Tutored in \(tutor.lNumSessions!) sessions", color: Colors.tutorBlue))
		views.append(ProfileItem(icon: UIImage(named: "location")!, title: tutor.region, color: Colors.tutorBlue))
		
		if let languages = tutor.languages {
			views.append(ProfileItem(icon: UIImage(named: "speaks")!, title: "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))", color: Colors.tutorBlue))
		}
		if tutor.school != "" && tutor.school != nil {
			views.append(ProfileItem(icon: UIImage(named: "studys-at")!, title: tutor.school!, color: Colors.tutorBlue))
		}
		return views
	}
    
    @objc func editProfile() {
        let next = TutorEditProfile()
        next.tutor = tutor
        next.delegate = self
        navigationController?.pushViewController(next, animated: true)
    }
}

extension TutorMyProfileVC: ProfileImageViewerDelegate {
    func dismiss() {
        dismissProfileImageViewer()
    }
}
extension TutorMyProfileVC : UIScrollViewDelegate {
	//allow scrolling to not be affected by UIButton or UITableView
	func touchesShouldCancel(in view: UIView) -> Bool {
		return view is UIButton
	}
	//disable Horizontal scroll.
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: true)
	}
}
