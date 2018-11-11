//
//  TutorCardCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit
import FirebaseUI

class TutorCardCollectionViewCell: UICollectionViewCell {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureCollectionViewCell()
	}
	
	let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

	var parentViewController : UIViewController?
	
	var tutor: AWTutor! {
		didSet {
			setupTutorCardHeader()
			setupTutorCardAboutMe()
			setupTutorCardBody()
			setupTutorCardSubjects()
			tutor.reviews?.count == 0 ? setupNoTutorCardReviews() : setupTutorCardReviews()
			setupTutorCardPolicy()
			setupScrollViewContentSize()
		}
	}
	
	var delegate: AddTutorButtonDelegate?

	let scrollView : UIScrollView = {
		let scrollView = UIScrollView()
		
		scrollView.showsVerticalScrollIndicator = false
		scrollView.alwaysBounceVertical = true
		scrollView.canCancelContentTouches = true
		scrollView.isDirectionalLockEnabled = true
		scrollView.isExclusiveTouch = false
		scrollView.backgroundColor = Colors.navBarColor
		scrollView.layer.cornerRadius = 10
		
		return scrollView
	}()
	
    let tutorCardHeader = TutorCardHeader()
	let tutorCardAboutMe = MyProfileBioView()
	let tutorCardBody = MyProfileBody()
	let tutorCardSubjects = TutorMyProfileSubjects()
	let tutorCardReviews = TutorMyProfileReviewsView(isViewing: true)
	let noTutorCardReviews = NoReviewsView()
	let tutorCardPolicy = TutorMyProfilePolicies()
	
	let connectButton : UIButton = {
		let button = UIButton()
		button.titleLabel?.font = Fonts.createBoldSize(18)
		button.titleLabel?.textColor = .white
		button.backgroundColor = Colors.learnerPurple
		button.layer.cornerRadius = 8
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOffset = CGSize(width: 0, height: 2)
		button.layer.shadowRadius = 5
		button.layer.shadowOpacity = 0.6
		return button
	}()
	
	let dropShadowView = UIView()
	
    func configureCollectionViewCell() {
		backgroundColor = .clear
		
		addSubview(tutorCardHeader)
		addSubview(dropShadowView)
		addSubview(scrollView)
		scrollView.addSubview(tutorCardAboutMe)
		scrollView.addSubview(tutorCardBody)
		scrollView.addSubview(tutorCardSubjects)
		scrollView.addSubview(tutorCardReviews)
		scrollView.addSubview(tutorCardPolicy)
		addSubview(connectButton)
		
		connectButton.addTarget(self, action: #selector(connectButtonPressed(_:)), for: .touchUpInside)
		applyConstraints()
    }

    func applyConstraints() {
		tutorCardHeader.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.centerX.equalToSuperview()
			make.height.equalTo(120)
		}
		dropShadowView.snp.makeConstraints { (make) in
			make.top.equalTo(tutorCardHeader.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(1)
		}
		scrollView.snp.makeConstraints { (make) in
			make.top.equalTo(dropShadowView.snp.bottom).inset(5)
			make.width.centerX.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
			} else {
				make.bottom.equalToSuperview().inset(40)
			}
		}
		tutorCardAboutMe.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.centerX.equalToSuperview()
		}
		tutorCardBody.snp.makeConstraints { (make) in
			make.top.equalTo(tutorCardAboutMe.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(tutorCardBody.baseHeight)
		}
		tutorCardSubjects.snp.makeConstraints { (make) in
			make.top.equalTo(tutorCardBody.divider.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(80)
		}
		connectButton.snp.makeConstraints { (make) in
			make.centerY.equalTo(scrollView.snp.bottom).inset(5)
			make.centerX.equalToSuperview()
			make.width.equalTo(170)
			make.height.equalTo(35)
		}
    }

    override func layoutSubviews() {
        super.layoutSubviews()
		roundCorners(.allCorners, radius: 10)
		applyDefaultShadow()
        dropShadowView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 1.0, offset: CGSize(width: 0, height: 1), radius: 1)
        dropShadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
	private func setupTutorCardHeader() {
		tutorCardHeader.parentViewController = parentViewController
		tutorCardHeader.userId = tutor.uid
		tutorCardHeader.imageCount = tutor.images.filter({$0.value != ""}).count
		let reference : StorageReference!
		
		if let featuredDetails = tutor.featuredDetails {
			reference = storageRef.child("featured").child(tutor.uid).child("featuredImage")
			tutorCardHeader.featuredSubject.text = featuredDetails.subject
			tutorCardHeader.featuredSubject.isHidden = false
			tutorCardHeader.price.text = "$\(featuredDetails.price)/hr"
		} else {
			reference = storageRef.child("student-info").child(tutor.uid).child("student-profile-pic1")
			tutorCardHeader.price.text = "$\(tutor.price ?? 0)/hr"
		}
		tutorCardHeader.profileImageView.sd_setImage(with: reference)
		tutorCardHeader.profileImageView.roundCorners(.allCorners, radius: 8)
		tutorCardHeader.name.text = tutor.name.formatName()
		tutorCardHeader.reviewLabel.text = tutor.reviews?.count.formatReviewLabel(rating: tutor.tRating)
	}
	private func setupTutorCardAboutMe() {
		tutorCardAboutMe.aboutMeLabel.textColor = Colors.tutorBlue
		tutorCardAboutMe.bioLabel.text = (tutor.tBio != nil) ? tutor.tBio! : "Tutor has no bio!\n"
	}
	
	private func setupTutorCardBody() {
		tutorCardBody.additionalInformation.textColor = Colors.tutorBlue
		let extraInfomationViews = getViewsForExtraInformationSection()
		tutorCardBody.stackView.subviews.forEach({ $0.removeFromSuperview() })
		extraInfomationViews.forEach({ tutorCardBody.stackView.addArrangedSubview($0) })
		
		tutorCardBody.stackView.snp.remakeConstraints { (make) in
			make.top.equalTo(tutorCardBody.additionalInformation.snp.bottom).inset(-5)
			make.leading.equalToSuperview().inset(12)
			make.trailing.equalToSuperview().inset(5)
			make.height.equalTo(CGFloat(extraInfomationViews.count * 30))
		}
		tutorCardBody.snp.remakeConstraints { (make) in
			make.top.equalTo(tutorCardAboutMe.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(30 + CGFloat(extraInfomationViews.count * 30))
		}
	}
	
	private func setupTutorCardSubjects() {
		tutorCardSubjects.sectionTitle.textColor = Colors.tutorBlue
		tutorCardSubjects.datasource = tutor.subjects ?? []
	}
	private func setupNoTutorCardReviews() {
		if self.subviews.contains(tutorCardReviews) {
			tutorCardReviews.removeFromSuperview()
		}
		scrollView.addSubview(noTutorCardReviews)
		noTutorCardReviews.snp.makeConstraints { (make) in
			make.top.equalTo(tutorCardSubjects.snp.bottom).inset(-5)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(80)
		}
	}
	
	private func setupTutorCardReviews() {
		tutorCardReviews.dataSource = tutor.reviews ?? []
		tutorCardReviews.parentViewController = parentViewController
		
		tutorCardReviews.reviewLabel1.removeFromSuperview()
		tutorCardReviews.reviewLabel2.removeFromSuperview()
		
		if scrollView.subviews.contains(noTutorCardReviews) {
			noTutorCardReviews.removeFromSuperview()
		}
		tutorCardReviews.setupMostRecentReviews()
		
		tutorCardReviews.snp.makeConstraints { (make) in
			make.top.equalTo(tutorCardSubjects.snp.bottom).inset(-5)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(tutorCardReviews.reviewSectionHeight)
		}
	}

	private func setupTutorCardPolicy() {
		guard let policy = tutor.policy else { return }
		let policies = policy.split(separator: "_")

		tutorCardPolicy.policiesLabel.attributedText = NSMutableAttributedString()
			.bold("•  ", 20, .white).regular(tutor.distance.distancePreference(tutor.preference), 16, Colors.grayText)
			.bold("•  ", 20, .white).regular(tutor.preference.preferenceNormalization(), 16, Colors.grayText)
			.bold("•  ", 20, .white).regular(String(policies[0]).lateNotice(), 16, Colors.grayText)
			.bold("•  ", 20, .white).regular(String(policies[2]).cancelNotice(), 16, Colors.grayText)
			.regular(String(policies[1]).lateFee(), 16, Colors.qtRed)
			.regular(String(policies[3]).cancelFee(), 16, Colors.qtRed)
		
		tutorCardPolicy.snp.remakeConstraints { (make) in
			let topConstraint = self.tutor.reviews?.count == 0 ? noTutorCardReviews.divider.snp.bottom : tutorCardReviews.divider.snp.bottom
			make.top.equalTo(topConstraint).inset(-5)
			make.width.centerX.equalToSuperview()
		}
	}
	
	private func getViewsForExtraInformationSection() -> [UIView] {
		var views = [UIView]()
		
		views.append(ProfileItem(icon: UIImage(named: "tutored-in")!, title: "Tutored in \(tutor.tNumSessions ?? 0) sessions", color: Colors.tutorBlue))
		//this will be optional in the future but the DB only supports this for now.
		views.append(ProfileItem(icon: UIImage(named: "location")!, title: tutor.region, color: Colors.tutorBlue))
		
		if let languages = tutor.languages {
			views.append(ProfileItem(icon: UIImage(named: "speaks")!, title: "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))", color: Colors.tutorBlue))
		}
		if tutor.school != "" && tutor.school != nil {
			views.append(ProfileItem(icon: UIImage(named: "studys-at")!, title: tutor.school!, color: Colors.tutorBlue))
		}
		return views
	}
	
	private func setupScrollViewContentSize() {
		layoutIfNeeded()
		let connectButtonOffset : CGFloat = 35.0
		scrollView.contentSize.height = scrollView.subviews.reduce(0) { $0 + $1.frame.height } + connectButtonOffset
	}
	
    let addPaymentModal = AddPaymentModal()
    
	@objc private func connectButtonPressed(_ sender: UIButton) {
		sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: CGFloat(0.20), initialSpringVelocity: CGFloat(6.0), options: UIView.AnimationOptions.allowUserInteraction, animations: {
			sender.transform = CGAffineTransform.identity
		}, completion: { Void in()  })
		
        guard CurrentUser.shared.learner.hasPayment else {
            addPaymentModal.show()
            return
        }
        
		DataService.shared.getTutorWithId(tutor.uid) { tutor in
			let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
			vc.receiverId = tutor?.uid
			vc.chatPartner = tutor
			navigationController.pushViewController(vc, animated: true)
		}
	}
}

extension TutorCardCollectionViewCell: AddTutorButtonDelegate {
    func addTutorWithUid(_ uid: String, completion: (() -> Void)?) {
        DataService.shared.getTutorWithId(uid) { tutor in
            let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
            vc.receiverId = uid
            vc.chatPartner = tutor
            navigationController.pushViewController(vc, animated: true)
        }
        completion!()
    }
}
