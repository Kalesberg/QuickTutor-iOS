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

	let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

    var learner: AWLearner!
	var datasource = [Review]()
	var isViewing: Bool = false
    
    var isEditable = true {
        didSet {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		datasource = learner.lReviews
        if AccountService.shared.currentUser != nil && learner != nil {
            if AccountService.shared.currentUser.uid.caseInsensitiveCompare(learner.uid) == ComparisonResult.orderedSame {
                // If this is my profile, app will show the edit icon and the title with "My Profile" string.
                navigationItem.title = "My Profile"
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_pencil"),
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(editProfile))
            } else {
                // If this is not my profile, app will just show a title with a learner's nickname
                navigationItem.title = learner.name
                navigationItem.rightBarButtonItem = nil
            }
        }
        navigationController?.setNavigationBarHidden(false, animated: true)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
		setupMyProfileHeader()
		setupMyProfileBioView()
		setupMyProfileBody()
		setupMyProfileReviews()
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}
	
    func learnerWasUpdated(learner: AWLearner!) {
        self.learner = learner
        let name = learner.name.split(separator: " ")
        contentView.myProfileHeader.nameLabel.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
    }
	
	private func setupMyProfileHeader() {
		let reference = storageRef.child("student-info").child(learner.uid).child("student-profile-pic1")
		
		contentView.myProfileHeader.userId = learner.uid
		contentView.myProfileHeader.parentViewController = self
		contentView.myProfileHeader.nameLabel.text = learner.formattedName
		contentView.myProfileHeader.imageCount = learner.images.filter({ $0.value != "" }).count
		contentView.myProfileHeader.profileImageView.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "placeholder-square"))
		contentView.myProfileHeader.rating.text = learner.lRating != nil ? "\(learner.lRating!) ★" : ""
	}

	private func setupMyProfileBioView() {
		let bio : String
		if learner.bio == "" && !isViewing {
			bio = "No biography yet! You can add a bio by tapping \"edit\" in the top right of the screen."
		} else if learner.bio == "" && isViewing {
			bio = "\(learner.formattedName) has not yet entered a biography."
		} else {
			bio = learner.bio
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
	
	private func setupMyProfileReviews() {
		contentView.myProfileReviews.dataSource = learner.lReviews.sorted(by: { $0.timestamp > $1.timestamp })
		contentView.myProfileReviews.isViewing = isViewing
		contentView.myProfileReviews.parentViewController = self
		
		contentView.myProfileReviews.setupMostRecentReviews()
		
		contentView.myProfileReviews.snp.makeConstraints { (make) in
			make.top.equalTo(contentView.myProfileBody.divider.snp.bottom).inset(-5)
			make.width.centerX.bottom.equalToSuperview()
			make.height.equalTo(contentView.myProfileReviews.reviewSectionHeight)
		}
	}
	
	private func getViewsForExtraInformationSection() -> [UIView] {
		var views = [UIView]()
		
		views.append(ProfileItem(icon: UIImage(named: "uploadImageDefaultImage")!, title: "Has tutored \(learner.lNumSessions!) sessions", color: Colors.purple ))
		
		if let languages = learner.languages {
			views.append(ProfileItem(icon: UIImage(named: "uploadImageDefaultImage")!, title: "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))", color: Colors.purple))
		}
		if learner.school != "" && learner.school != nil {
			views.append(ProfileItem(icon: UIImage(named: "uploadImageDefaultImage")!, title: learner.school!, color : Colors.purple))
		}
		return views
    }
    
    @objc func editProfile() {
        let next = LearnerEditProfileVC()
//        next.delegate = self
        navigationController?.pushViewController(next, animated: true)
    }
}

extension LearnerMyProfileVC: ProfileImageViewerDelegate {
    func dismiss() {
        dismissProfileImageViewer()
    }
}

extension LearnerMyProfileVC : UIScrollViewDelegate {
	//allow scrolling to not be affected by UIButton or UITableView
	func touchesShouldCancel(in view: UIView) -> Bool {
		return view is UIButton
	}
	//disable Horizontal scroll.
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: true)
	}
}
