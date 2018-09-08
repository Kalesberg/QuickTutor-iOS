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
	func didSelectTipPercentage(tipAmount: Int?)
	func didWriteReview(review: String?)
	func reviewTextViewDidBecomeFirstResponsder()
	func reviewTextViewDidResign()
}

struct PostSessionReviewData {
	static var rating : Int!
	static var tipPercentage : Int? = nil
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
	
	let title : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createBoldSize(18)
		
		return label
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
		addSubview(title)
		addSubview(subtitle)
		applyConstraints()
	}
	
	func applyConstraints() {
		containerView.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview()
			make.bottom.equalToSuperview().inset(5)
		}
		title.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview().inset(15)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		subtitle.snp.makeConstraints { (make) in
			make.top.equalTo(title.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(20)
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
		imageView.image = #imageLiteral(resourceName: "defaultProfileImage")
		
		return imageView
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
		
		button.backgroundColor = Colors.learnerPurple
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
		addSubview(nextButton)
		addSubview(errorLabel)
		super.configureView()
		
		title.label.text = "Session Complete!"
		navbar.backgroundColor = Colors.learnerPurple
		statusbarView.backgroundColor = Colors.learnerPurple
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		profileImageView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-10)
			make.centerX.equalToSuperview()
			make.width.height.equalTo(100)
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

	var postSessionData : PostSessionData?
	var sessionId : String!
	var costOfSession: Int = 1800
	var partnerId : String = "GhKRwo0Z0DchEWDR3U0oa9hs9Pk2"
	var runTime : Int = 36000
	
	var tutor : AWTutor!
	var learner : AWLearner!
	
	var cellTitles = [String]()
	var cellHeaderViewTitles : [String] = ["Rate your overall experience", "Leave your tutor a review."]
	var buttonTitles : [String] = ["Submit Rating","Submit Review","No Tip", "Complete"]

	var currentItem : Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		hideKeyboardWhenTappedAround()
		setupButtons()

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
		contentView.collectionView.register(SubmitPayCell.self, forCellWithReuseIdentifier: "submitPayCell")
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
	
	private func setupViewForTutorReview() {
		let nameSplit = self.tutor.name.split(separator: " ")
		let name = String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1))
		cellTitles =  ["How was your time with \(name)?", "Was this session helpful?", "It's optional, but highly appreciated."]
		cellHeaderViewTitles.append("Leave your tutor a tip.")
		contentView.profileImageView.sd_setImage(with: storageRef.child("student-info").child(CurrentUser.shared.learner.uid).child("student-profile-pic1"))
	}
	
	private func setupViewForLearnerReview() {
		let nameSplit = self.learner.name.split(separator: " ")
		let name = String(nameSplit[0]) + " " +  String(nameSplit[1].prefix(1))
		contentView.profileImageView.sd_setImage(with: storageRef.child("student-info").child(CurrentUser.shared.learner.uid).child("student-profile-pic1"))
		self.cellTitles =  ["How was your time with \(name)?", "Was this session helpful?"]
	}
	
	func doesContainNaughtyWord(text: String, naughtyWords: [String]) -> Bool {
		return naughtyWords.reduce(false) {$0 || text.contains ($1.lowercased()) }
	}
	
	@objc private func nextButtonPressed(_ sender: UIButton) {
		contentView.errorLabel.isHidden = true

		switch currentItem {
		case 0:
			if PostSessionReviewData.rating != nil {
				contentView.collectionView.scrollToItem(at: IndexPath(item: currentItem + 1, section: 0), at: .centeredHorizontally, animated: true)
			} else {
				contentView.errorLabel.text = "Please give this tutor a rating."
				contentView.errorLabel.shake()
				contentView.errorLabel.isHidden = false
			}
		case 1:
			if let review = PostSessionReviewData.review {
				let naughtyWords : [String] = BadWords.loadBadWords()
				if !doesContainNaughtyWord(text: review.lowercased(), naughtyWords: naughtyWords) {
					contentView.collectionView.scrollToItem(at: IndexPath(item: currentItem + 1, section: 0), at: .centeredHorizontally, animated: true)
				} else {
					contentView.errorLabel.text = "Reviews cannot contain inappropriate words."
					contentView.errorLabel.shake()
					contentView.errorLabel.isHidden = false
				}
			} else {
				contentView.collectionView.scrollToItem(at: IndexPath(item: currentItem + 1, section: 0), at: .centeredHorizontally, animated: true)
			}
		case 2:
			contentView.collectionView.scrollToItem(at: IndexPath(item: currentItem + 1, section: 0), at: .centeredHorizontally, animated: true)
			finishAndUpload()
		case 3:
			self.navigationController?.popBackToMain()
		default:
			break
		}
	}
	
	private func finishAndUpload() {
		if AccountService.shared.currentUserType == .learner {
			let updatedRating = ((tutor.tRating * Double(tutor.tNumSessions)) + Double(PostSessionReviewData.rating)) / Double(tutor.tNumSessions + 1)
			let updatedHours = Double(tutor.hours) + round(Double(runTime) / 60 / 60) //hours
			let duration = runTime / 60 //minutes
			//create charge on laerners account
			createCharge(cost: costOfSession)
			//call 'Subject' and 'Subcategory' to update those ratings -- do this last. we don't even use them.
			
		} else {
			//learner data
		}
	}
	
	private func createCharge(cost: Int) {
		let fee = Int(Double(cost) * 0.10)
		Stripe.retrieveCustomer(cusID: CurrentUser.shared.learner.customer) { (customer, error) in
			if let error = error {
				print(error.localizedDescription)
			} else if let customer = customer {
				guard let card = customer.defaultSource?.stripeID else { print("Could not find card..."); return }
				//Format amount...
				Stripe.destinationCharge(acctId: self.tutor.acctId, customerId: customer.stripeID, sourceId: card, amount: cost, fee: fee, description: "Think of clever description of charge.", { (error) in
					if let error = error {
						print(error.localizedDescription)
					} else {
						//TODO: Navigate.
					}
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
			cell.titleView.title.text = (AccountService.shared.currentUserType == .learner) ? String(tutor.name.split(separator: " ")[0]) : String(learner.name.split(separator: " ")[0])
			cell.titleView.subtitle.text = cellTitles[indexPath.row]
			cell.title.text = cellHeaderViewTitles[indexPath.row]
			
			return cell
		case 1:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath) as! ReviewCell
			
			cell.delegate = self
			cell.titleView.title.text = (AccountService.shared.currentUserType == .learner) ? String(tutor.name.split(separator: " ")[0]) : String(learner.name.split(separator: " ")[0])
			cell.titleView.subtitle.text = cellTitles[indexPath.row]
			cell.title.text = cellHeaderViewTitles[indexPath.row]

			return cell
		case 2:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tipCell", for: indexPath) as! TipCell
			
			cell.delegate = self
			cell.total = Double(costOfSession)
			cell.titleView.title.text = (AccountService.shared.currentUserType == .learner) ? String(tutor.name.split(separator: " ")[0]) : String(learner.name.split(separator: " ")[0])
			cell.titleView.subtitle.text = cellTitles[indexPath.row]
			cell.title.text = cellHeaderViewTitles[indexPath.row]

			return cell
		case 3:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "receiptCell", for: indexPath) as! ReceiptCell
			
			return cell
		default:
			return UICollectionViewCell()
		}
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
			contentView.profileImageView.isHidden = (currentItem == 3)
		}
	}
}

extension SessionReview : PostSessionInformationDelegate {
	func reviewTextViewDidBecomeFirstResponsder() {
		UIView.animate(withDuration: 0.2) {
			self.contentView.profileImageView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
		}
	}
	func reviewTextViewDidResign() {
		UIView.animate(withDuration: 0.2) {
			self.contentView.profileImageView.transform = .identity
		}
	}
	func didSelectRating(rating: Int) {
		PostSessionReviewData.rating = rating
	}
	func didSelectTipPercentage(tipAmount: Int?) {
		if tipAmount != nil {
			contentView.nextButton.setTitle("Submit & Pay", for: .normal)
		} else {
			contentView.nextButton.setTitle("No Tip", for: .normal)
		}
		PostSessionReviewData.tipPercentage = tipAmount
	}
	
	func didWriteReview(review: String?) {
		PostSessionReviewData.review = review
	}
}
