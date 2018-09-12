//
//  SessionReview.swift
//  QuickTutor
//
//  Created by QuickTutor on 8/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import SDWebImage

protocol PostSessionInformationDelegate {
	func didSelectRating(rating: Int)
	func didSelectTipPercentage(tipAmount: Int)
	func didWriteReview(review: String?)
	func reviewTextViewDidBecomeFirstResponsder()
	func reviewTextViewDidResign()
}

struct PostSessionReviewData {
	static var rating : Int!
	static var tipAmount : Int = 0 {
		didSet {
			print(tipAmount)
		}
	}
	static var review : String? = nil
}

struct PostSessionData {
	let partnerId: String?
	let sessionId: String?
	let session: Session?
	let sessionLength: Double?

	init(partnerId: String?, sessionId: String?, session: Session?, sessionLength: Double?) {
		self.partnerId = partnerId
		self.sessionId = sessionId
		self.session = session
		self.sessionLength = sessionLength
	}
}

class SessionReviewHeader : UIView {
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let containerView : UIView = {
		let view = UIView()
		
		view.backgroundColor = Colors.navBarColor
	
		return view
	}()
	
	let subtitle : UILabel = {
		let label = UILabel()
		
		label.textColor = UIColor.gray
		label.textAlignment = .center
		label.font = Fonts.createSize(14)
		
		return label
	}()
	
	func configureView() {
		addSubview(containerView)
		addSubview(subtitle)
		
		applyConstraints()
	}
	
	func applyConstraints() {
		containerView.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview()
			make.bottom.equalToSuperview().inset(5)
		}
		subtitle.snp.makeConstraints { (make) in
			make.width.centerX.bottom.equalToSuperview().inset(10)
			make.height.equalTo(30)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		containerView.layer.cornerRadius = 4
	}
}

class SessionReviewView : MainLayoutTitleTwoButton {
	let profileImageView : UIImageView = {
		let imageView = UIImageView()
		
		imageView.layer.masksToBounds = false
		imageView.clipsToBounds = true
		
		return imageView
	}()
	
	let nameLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createBoldSize(18)
		
		return label
	}()
	
	let collectionView : UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0
		
		collectionView.backgroundColor = Colors.backgroundDark
		collectionView.collectionViewLayout = layout
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.isPagingEnabled = true
		collectionView.decelerationRate = UIScrollViewDecelerationRateFast
		
		return collectionView
	}()
	
	let nextButton : UIButton = {
		let button = UIButton()
		
		button.backgroundColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple : Colors.tutorBlue
		button.setTitle("Submit", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = Fonts.createBoldSize(20)
	
		return button
	}()
	
	let errorLabel : UILabel = {
		let label = UILabel()

		label.textColor = Colors.qtRed
		label.font = Fonts.createItalicSize(17)
		label.textAlignment = .center
		label.isHidden = true
		
		return label
	}()
	override func configureView() {
		addSubview(collectionView)
		addSubview(profileImageView)
		addSubview(nameLabel)
		addSubview(nextButton)
		addSubview(errorLabel)
		super.configureView()
		
		title.label.text = "Session Complete!"
		navbar.backgroundColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple : Colors.tutorBlue
		statusbarView.backgroundColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple : Colors.tutorBlue
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		profileImageView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-10)
			make.centerX.equalToSuperview()
			make.width.height.equalTo(100)
		}
		nameLabel.snp.makeConstraints { (make) in
			make.top.equalTo(profileImageView.snp.bottom)
			make.centerX.width.equalToSuperview()
			make.height.equalTo(25)
		}
		nextButton.snp.makeConstraints { (make) in
			make.bottom.width.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.1)
		}
		errorLabel.snp.makeConstraints { (make) in
			make.bottom.equalTo(nextButton.snp.top)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(profileImageView.snp.top).inset(33)
			make.width.centerX.equalToSuperview()
			make.bottom.equalTo(nextButton.snp.top)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		profileImageView.layer.cornerRadius = profileImageView.frame.height / 20
	}
}

class SessionReview : BaseViewController {
	
	override var contentView: SessionReviewView {
		return view as! SessionReviewView
	}
	override func loadView() {
		view = SessionReviewView()
	}
	let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

	var session : Session?
	var sessionId : String!
	var costOfSession: Int!
	var partnerId : String!
	var runTime : Int!
	var subject : String!
	var name : String!
	var sessionsWithPartner : Int = 0
	
	var tutor : AWTutor!
	var learner : AWLearner!
	var cellTitles = [String]()
	var cellHeaderViewTitles : [String] = ["Rate your overall experience", "Leave your tutor a review."]
	var buttonTitles : [String] = ["Submit Rating","Submit Review","Submit & Pay", "Complete"]

	var currentItem : Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		hideKeyboardWhenTappedAround()
		setupButtons()
		getSessionWithPartner(uid: CurrentUser.shared.learner.uid)
		if AccountService.shared.currentUserType == .learner {
			getTutorAccount(uid: partnerId) { (tutor) in
				if let tutor = tutor {
					self.tutor = tutor
					self.configureDelegates()
					self.setupViewForTutorReview()
				}
			}
		} else {
			getStudentAccount(uid: partnerId) { (learner) in
				if let learner = learner {
					self.learner = learner
					self.configureDelegates()
					self.setupViewForLearnerReview()
				}
			}
		}
	}

	private func configureDelegates() {
		contentView.collectionView.delegate = self
		contentView.collectionView.dataSource = self

		contentView.collectionView.register(ReviewCell.self, forCellWithReuseIdentifier: "reviewCell")
		contentView.collectionView.register(RatingCell.self, forCellWithReuseIdentifier: "ratingCell")
		contentView.collectionView.register(TipCell.self, forCellWithReuseIdentifier: "tipCell")
		contentView.collectionView.register(ReceiptCell.self, forCellWithReuseIdentifier: "receiptCell")
	}
	
	private func setupButtons() {
		contentView.nextButton.addTarget(self, action: #selector(nextButtonPressed(_:)), for: .touchUpInside)
	}
	
	private func getTutorAccount(uid: String,_ completion: @escaping (AWTutor?) -> Void) {
		FirebaseData.manager.fetchTutor(uid, isQuery: false) { (tutor) in
			guard let tutor = tutor else { return completion(nil) }
			completion(tutor)
		}
	}
	
	private func getStudentAccount(uid: String,_ completion: @escaping (AWLearner?) -> Void) {
		FirebaseData.manager.fetchLearner(uid) { (learner) in
			guard let learner = learner else { return completion(nil) }
			completion(learner)
		}
	}
	private func getSessionWithPartner(uid: String) {
		FirebaseData.manager.fetchUserSessions(uid: CurrentUser.shared.learner.uid, type: AccountService.shared.currentUserType.rawValue) { (sessions) in
			guard let sessions = sessions else { return }
			sessions.forEach({
				if $0.otherId == self.partnerId {
					self.sessionsWithPartner += 1
				}
			})
		}
	}
	private func setupViewForTutorReview() {
		let nameSplit = self.tutor.name.split(separator: " ")
		name = String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1))
		contentView.nameLabel.text = name
		
		cellTitles =  ["How was your time with \(name!)?", "Was this session helpful?", "It's optional, but highly appreciated."]
		cellHeaderViewTitles.append("Leave your tutor a tip.")
		
		contentView.profileImageView.sd_setImage(with: storageRef.child("student-info").child(CurrentUser.shared.learner.uid).child("student-profile-pic1"))
	}
	
	private func setupViewForLearnerReview() {
		let nameSplit = self.learner.name.split(separator: " ")
		name = String(nameSplit[0]) + " " +  String(nameSplit[1].prefix(1))
		contentView.nameLabel.text = name
		
		contentView.profileImageView.sd_setImage(with: storageRef.child("student-info").child(CurrentUser.shared.learner.uid).child("student-profile-pic1"))
		self.cellTitles =  ["How was your time with \(name!)?", "Was this session helpful?"]
	}
	
	func doesContainNaughtyWord(text: String, naughtyWords: [String]) -> Bool {
		return naughtyWords.reduce(false) {$0 || text.contains ($1.lowercased()) }
	}

	func displayErrorMessage(text: String) {
		contentView.errorLabel.text = text
		contentView.errorLabel.shake()
		contentView.errorLabel.isHidden = false
	}
	
	@objc private func nextButtonPressed(_ sender: UIButton) {
		contentView.errorLabel.isHidden = true
		switch currentItem {
		case 0:
			if PostSessionReviewData.rating != nil {
				contentView.collectionView.scrollToItem(at: IndexPath(item: currentItem + 1, section: 0), at: .centeredHorizontally, animated: true)
			} else {
				displayErrorMessage(text: "Please give this tutor a rating.")
			}
		case 1:
			if let review = PostSessionReviewData.review {
				let naughtyWords : [String] = BadWords.loadBadWords()
				if !doesContainNaughtyWord(text: review.lowercased(), naughtyWords: naughtyWords) {
					contentView.collectionView.scrollToItem(at: IndexPath(item: currentItem + 1, section: 0), at: .centeredHorizontally, animated: true)
				} else {
					displayErrorMessage(text: "Reviews cannot contain inappropriate words.")
				}
			} else {
				contentView.collectionView.scrollToItem(at: IndexPath(item: currentItem + 1, section: 0), at: .centeredHorizontally, animated: true)
			}
		case 2:
			if  AccountService.shared.currentUserType == .learner{
				contentView.nextButton.isEnabled = false
				createCharge(cost: costOfSession + (PostSessionReviewData.tipAmount * 100)) { (error) in
					if let error = error {
						print(error.localizedDescription)
					} else {
						self.finishAndUpload()
						self.contentView.collectionView.scrollToItem(at: IndexPath(item: self.currentItem + 1, section: 0), at: .centeredHorizontally, animated: true)
					}
					self.contentView.nextButton.isEnabled = true
				}
			} else {
				finishAndUpload()
				self.navigationController?.popBackToMain()
			}
			
		case 3:
			finishAndUpload()
			self.navigationController?.popBackToMain()
		default:
			break
		}
	}
	
	private func finishAndUpload() {
		if AccountService.shared.currentUserType == .learner {
			let updatedRating = ((tutor.tRating * Double(tutor.tNumSessions)) + Double(PostSessionReviewData.rating)) / Double(tutor.tNumSessions + 1)
			let updatedHours = Double(tutor.hours) + round(Double(runTime) / 60 / 60)
			guard let subcategory = SubjectStore.findSubCategory(resource: SubjectStore.findCategoryBy(subject: subject)!, subject: subject) else { return }
			let tutorInfo : [String : Any] = ["hr" : updatedHours, "nos" : tutor.tNumSessions + 1, "tr" : updatedRating.truncate(places: 1)]
			let subcategoryInfo : [String : Any] = ["hr" : updatedHours, "nos" : tutor.tNumSessions + 1, "r" : updatedRating.truncate(places: 1)]
			FirebaseData.manager.updateTutorPostSession(uid: partnerId, subcategory: subcategory.lowercased(), tutorInfo: tutorInfo, subcategoryInfo: subcategoryInfo)
			
			if PostSessionReviewData.review != nil && PostSessionReviewData.review! != "" {
				let reviewDict : [String : Any] = [
					"dte" : Date().timeIntervalSince1970,
					"dur" : round(Double(runTime) / 60),
					"uid" : partnerId,
					"m" : PostSessionReviewData.review!,
					"nm" : tutor.name,
					"p" : costOfSession / 100,
					"r" : PostSessionReviewData.rating,
					"sbj" : subject
				]
				FirebaseData.manager.updateReviewPostSession(uid: partnerId, type: "learner", review: reviewDict)
			}
		} else {
			let updatedRating = ((learner.lRating * Double(learner.lNumSessions)) + Double(PostSessionReviewData.rating)) / Double(learner.lNumSessions + 1)
			let updatedHours = Double(learner.lHours) + round(Double(runTime) / 60 / 60)
			FirebaseData.manager.updateLearnerPostSession(uid: CurrentUser.shared.learner.uid, studentInfo: ["nos" : learner.lNumSessions + 1, "lhs" : updatedHours, "r" : updatedRating.truncate(places: 1)])
			if let review = PostSessionReviewData.review {
				let reviewDict : [String : Any] = [
					"dte" : Date().timeIntervalSince1970,
					"dur" : round(Double(runTime) / 60),
					"uid" : partnerId,
					"m" : review,
					"nm" : learner.name,
					"p" : costOfSession / 100,
					"r" : PostSessionReviewData.rating,
					"sbj" : subject
				]
				FirebaseData.manager.updateReviewPostSession(uid: partnerId, type: "tutor", review: reviewDict)
			}
		}
	}

	private func createCharge(cost: Int, completion: @escaping (Error?) -> Void) {
		let fee = Int(Double(cost) * 0.10)
		self.displayLoadingOverlay()
		Stripe.retrieveCustomer(cusID: CurrentUser.shared.learner.customer) { (customer, error) in
			if let error = error {
				self.dismissOverlay()
				completion(error)
			} else if let customer = customer {
				guard let card = customer.defaultSource?.stripeID else {
					self.dismissOverlay()
					return completion(StripeError.createChargeError)
				}
				Stripe.destinationCharge(acctId: self.tutor.acctId, customerId: customer.stripeID, sourceId: card, amount: cost, fee: fee, description: "Think of clever description of charge.", { (error) in
					if let error = error {
						completion(error)
					} else {
						completion(nil)
					}
					self.dismissOverlay()
				})
			}
		}
	}
}
extension SessionReview : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cellTitles.count + 1
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		switch indexPath.item {
		case 0:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ratingCell", for: indexPath) as! RatingCell
			
			cell.delegate = self
			cell.titleView.subtitle.text = cellTitles[indexPath.row]
			cell.title.text = cellHeaderViewTitles[indexPath.row]
			
			return cell
		case 1:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath) as! ReviewCell
			
			cell.delegate = self
			cell.titleView.subtitle.text = cellTitles[indexPath.row]
			cell.title.text = cellHeaderViewTitles[indexPath.row]

			return cell
		case 2:
			if AccountService.shared.currentUserType == .learner {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tipCell", for: indexPath) as! TipCell
				cell.delegate = self
				cell.total = Double(costOfSession)
				cell.titleView.subtitle.text = cellTitles[indexPath.row]
				cell.title.text = cellHeaderViewTitles[indexPath.row]
				return cell
			} else {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "receiptCell", for: indexPath) as! ReceiptCell
				
				cell.partner.profileImageView.image = contentView.profileImageView.image
				cell.partner.infoLabel.text = contentView.nameLabel.text
				cell.subject.infoLabel.text = session?.subject
				let (h,m) = secondsToHoursMinutesSeconds(seconds: runTime)
				cell.sessionLength.infoLabel.text = h > 0 ? "\(h) hours and \(m) minutes" : "\(m) Minutes"
				cell.hourlyRate.infoLabel.text = "$" + String(Int(session?.price ?? 0.0))
				let total = costOfSession + PostSessionReviewData.tipAmount
				cell.total.infoLabel.text = "$" + String(format: "%.2f", Double(total / 100))
				cell.tip.infoLabel.text = "$\(PostSessionReviewData.tipAmount)"
				
				cell.totalSessions.attributedText = AccountService.shared.currentUserType == .learner ? NSMutableAttributedString().regular("Sessions Completed:    ", 14, Colors.learnerPurple).bold("\(CurrentUser.shared.learner.lNumSessions + 1)", 14, .white) : NSMutableAttributedString().regular("Sessions Completed:    ", 14, Colors.tutorBlue).bold("\(CurrentUser.shared.tutor.tNumSessions + 1)", 14, .white)
				
				cell.totalSessionsWithPartner.attributedText = AccountService.shared.currentUserType == .learner ? NSMutableAttributedString().regular("Sessions Completed With \(name):    ", 14, Colors.learnerPurple).bold("\(self.sessionsWithPartner + 1)", 14, .white) : NSMutableAttributedString().regular("Sessions Completed With \(name):     ", 14, Colors.tutorBlue).bold("\(self.sessionsWithPartner + 1)", 14, .white)
				
				return cell
			}
		case 3:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "receiptCell", for: indexPath) as! ReceiptCell

			cell.partner.profileImageView.image = contentView.profileImageView.image
			cell.partner.infoLabel.text = contentView.nameLabel.text
			cell.subject.infoLabel.text = session?.subject
			let (h,m) = secondsToHoursMinutesSeconds(seconds: runTime)
			cell.sessionLength.infoLabel.text = h > 0 ? "\(h) hours and \(m) minutes" : "\(m) Minutes"
			cell.hourlyRate.infoLabel.text = "$" + String(Int(session?.price ?? 0.0)) + "/hr"
			let total = costOfSession + PostSessionReviewData.tipAmount
			cell.total.infoLabel.text = "$" + String(format: "%.2f", Double(total / 100))
			cell.tip.infoLabel.text = "$\(PostSessionReviewData.tipAmount)"
		
			cell.totalSessions.attributedText = AccountService.shared.currentUserType == .learner ? NSMutableAttributedString().regular("Sessions Completed:    ", 14, Colors.learnerPurple).bold("\(CurrentUser.shared.learner.lNumSessions + 1)", 14, .white) : NSMutableAttributedString().regular("Sessions Completed:    ", 14, Colors.tutorBlue).bold("\(CurrentUser.shared.tutor.tNumSessions + 1)", 14, .white)
			
			cell.totalSessionsWithPartner.attributedText = AccountService.shared.currentUserType == .learner ? NSMutableAttributedString().regular("Sessions Completed With \(name):    ", 14, Colors.learnerPurple).bold("\(self.sessionsWithPartner + 1)", 14, .white) : NSMutableAttributedString().regular("Sessions Completed With \(name):     ", 14, Colors.tutorBlue).bold("\(self.sessionsWithPartner + 1)", 14, .white)
			
			return cell
		default:
			return UICollectionViewCell()
		}
	}
	
	func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
		return (seconds / 3600, (seconds % 60))
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = UIScreen.main.bounds.width - 20
		return CGSize(width: width, height: collectionView.frame.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 20
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
		if let indexPath = contentView.collectionView.indexPathForItem(at: center) {
			currentItem = indexPath.row
			contentView.nextButton.setTitle(buttonTitles[currentItem], for: .normal)
			UIView.animate(withDuration: 0.2) {
				self.contentView.profileImageView.transform = (self.currentItem == 3) ? CGAffineTransform.init(scaleX: 0, y: 0) : .identity
				if AccountService.shared.currentUserType == .learner {
					self.contentView.nameLabel.isHidden = (self.currentItem == 3)
				} else {
					self.contentView.nameLabel.isHidden = (self.currentItem == 2)
				}
				if indexPath.row == 3 {
					self.contentView.collectionView.reloadData()
				}
			}
		}
	}
}

extension SessionReview : PostSessionInformationDelegate {
	func reviewTextViewDidBecomeFirstResponsder() {
		UIView.animate(withDuration: 0.1) {
			self.contentView.profileImageView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
			self.contentView.nameLabel.alpha = 0
		}
	}
	func reviewTextViewDidResign() {
		UIView.animate(withDuration: 0.2) {
			self.contentView.profileImageView.transform = .identity
			self.contentView.nameLabel.alpha = 1
		}
	}
	func didSelectRating(rating: Int) {
		PostSessionReviewData.rating = rating
	}
	func didSelectTipPercentage(tipAmount: Int) {
		PostSessionReviewData.tipAmount = tipAmount
	}
	
	func didWriteReview(review: String?) {
		PostSessionReviewData.review = review
	}
}

extension Double {
	func truncate(places : Int)-> Double {
		return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
	}
}
