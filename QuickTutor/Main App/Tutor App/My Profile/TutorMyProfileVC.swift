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

class TutorMyProfile: BaseViewController, UpdatedTutorCallBack {

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
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupMyProfileHeader()
		setupMyProfileBioView()
		setupMyProfileBody()
		setupMyProfileReviews()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		var contentSizeHeight : CGFloat = 0.0
		for view in contentView.scrollView.subviews {
			contentSizeHeight += view.frame.height
		}
		contentView.scrollView.contentSize.height = contentSizeHeight + 200
	}
	
	func tutorWasUpdated(tutor: AWTutor!) {
		self.tutor = tutor
		let name = tutor.name.split(separator: " ")
		contentView.myProfileHeader.nameLabel.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
	}
	
	private func setupMyProfileHeader() {
		//TODO: Look into getting an image from SDWebImage framework.
		let reference = storageRef.child("student-info").child(tutor.uid).child("student-profile-pic1")
		let imageView = UIImageView()
		imageView.sd_setImage(with: reference, placeholderImage: nil)
		
		contentView.myProfileHeader.userId = tutor.uid
		contentView.myProfileHeader.nameLabel.text = tutor.formattedName
		contentView.myProfileHeader.imageCount = tutor.images.filter({ $0.value != "" }).count
		contentView.myProfileHeader.profileImageViewButton.setImage(imageView.image, for: .normal)
		contentView.myProfileHeader.parentViewController = self
		contentView.myProfileHeader.price.text = "$\(String(describing: tutor.price!))/hr"
		let reviewsString = (dataSource.count == 1) ? "Review" : "Reviews"
		contentView.myProfileHeader.rating.text = "\(String(describing: tutor.tRating ?? 5.0)) (\(String(describing: dataSource.count)) \(reviewsString))"
	}
	
	private func setupMyProfileBioView() {
		let bio : String
		if tutor.bio == "" && !isViewing {
			bio = "No biography yet! You can add a bio by tapping \"edit\" in the top right of the screen."
		} else if tutor.bio == "" && isViewing {
			bio = "\(tutor.formattedName) has not yet entered a biography."
		} else {
			bio = tutor.bio
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
		
	}
	private func setupMyProfileReviews() {
		contentView.myProfileReviews.isViewing = isViewing
		contentView.myProfileReviews.parentViewController = self
		contentView.myProfileReviews.dataSource = tutor.reviews!.sorted(by: { $0.date > $1.date })
		
		contentView.myProfileReviews.setupMostRecentReviews()
		
		contentView.myProfileReviews.snp.makeConstraints { (make) in
			make.top.equalTo(contentView.myProfileBody.divider.snp.bottom).inset(-5)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(contentView.myProfileReviews.reviewSectionHeight)
			make.bottom.equalToSuperview()
		}
	}
	
	private func setupMyProfilePolicies() {
		
	}
	private func getViewsForExtraInformationSection() -> [UIView] {
		var views = [UIView]()
		
		views.append(ProfileItem(icon: UIImage(named: "tutored-in")!, title: "Tutored in \(tutor.lNumSessions!) sessions"))
		
		//this will be optional in the future but the DB only supports this for now.
		views.append(ProfileItem(icon: UIImage(named: "location")!, title: tutor.region))
		
		if let languages = tutor.languages {
			views.append(ProfileItem(icon: UIImage(named: "speaks")!, title: "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))"))
		}
		if tutor.school != "" && tutor.school != nil {
			views.append(ProfileItem(icon: UIImage(named: "studys-at")!, title: "Studies at " + tutor.school!))
		}
		return views
	}


    override func handleNavigation() {
        if touchStartView is NavbarButtonEdit {
            let next = TutorEditProfile()
            next.tutor = tutor
            next.delegate = self
            navigationController?.pushViewController(next, animated: true)
        }
    }
}

extension TutorMyProfile: ProfileImageViewerDelegate {
    func dismiss() {
        dismissProfileImageViewer()
    }
}
extension TutorMyProfile : UIScrollViewDelegate {
	//allow scrolling to not be affected by UIButton or UITableView
	func touchesShouldCancel(in view: UIView) -> Bool {
		return view is UIButton
	}
	//disable Horizontal scroll.
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: true)
	}
}
