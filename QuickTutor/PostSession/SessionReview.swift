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
import Alamofire

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
		collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
		collectionView.isScrollEnabled = false

		return collectionView
	}()
	
	let nextButton : UIButton = {
		let button = UIButton()
		
		button.backgroundColor = Colors.purple
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
		navbar.backgroundColor = Colors.purple
		statusbarView.backgroundColor = Colors.purple
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
	var costOfSession: Double!
	var partnerId : String!
	var runTime : Int!
	var subject : String!
	var name : String!
	var sessionsWithPartner : Int = 0
	
	var tutor : AWTutor!
	var learner : AWLearner!
	var cellTitles = [String]()
	var cellHeaderViewTitles = [String]()
	var buttonTitles = [String]()

	var hasPaid: Bool = false
	var hasCompleted: Bool = false
	
	var currentItem : Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		hideKeyboardWhenTappedAround()
		setupButtons()
		getSessionWithPartner(uid: CurrentUser.shared.learner.uid!)
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
        SessionService.shared.session = nil
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
		FirebaseData.manager.fetchUserSessions(uid: CurrentUser.shared.learner.uid!, type: AccountService.shared.currentUserType.rawValue) { (sessions) in
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
		let firstName = String(nameSplit[0]).capitalized
		name = String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1) + ".")
		contentView.nameLabel.text = name
		
		cellTitles =  ["How was your time with \(firstName)?", "Was this session helpful?", "It's optional, but highly appreciated."]
		cellHeaderViewTitles = ["Rate your overall experience.", "Describe your session.", "A little generosity can go a long way."]
		buttonTitles = ["Submit Rating","Submit Review","Submit & Pay", "Complete"]
		contentView.profileImageView.sd_setImage(with: storageRef.child("student-info").child(tutor.uid).child("student-profile-pic1"))
	}
	
	private func setupViewForLearnerReview() {
		let nameSplit = self.learner.name.split(separator: " ")
		let firstName = String(nameSplit[0]).capitalized
		name = String(nameSplit[0]) + " " +  String(nameSplit[1].prefix(1) + ".")
		contentView.nameLabel.text = name
		
		cellTitles =  ["How was your time with \(firstName)?", "Did you enjoy working with \(firstName)?"]
		cellHeaderViewTitles = ["Rate your overall experience.", "Describe your session."]
		contentView.profileImageView.sd_setImage(with: storageRef.child("student-info").child(learner.uid).child("student-profile-pic1"))
		buttonTitles = ["Submit Rating","Submit Review","Complete"]
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
			contentView.collectionView.scrollToItem(at: IndexPath(item: currentItem + 1, section: 0), at: .centeredHorizontally, animated: true)
		case 2:
			if  AccountService.shared.currentUserType == .learner {
				guard hasPaid == false else { return }
				contentView.nextButton.isEnabled = false
				let costWithTip = costOfSession + Double(PostSessionReviewData.tipAmount)
                AnalyticsService.shared.logSessionPayment(cost: costOfSession, tip: Double(PostSessionReviewData.tipAmount))
                createCharge(tutorId: tutor.acctId, cost: Int(costWithTip * 100)) { (error) in
					if let error = error {
						AlertController.genericErrorAlertWithoutCancel(self, title: "Payment Error", message: error.localizedDescription)
						self.hasPaid = false
					} else {
						self.hasPaid = true
						self.finishAndUpload()
						self.contentView.collectionView.scrollToItem(at: IndexPath(item: self.currentItem + 1, section: 0), at: .centeredHorizontally, animated: true)
					}
					self.contentView.nextButton.isEnabled = true
				}
			} else {
				guard hasCompleted == false else { return }
				finishAndUpload()
				hasCompleted = true
                PostSessionManager.shared.setUnfinishedFlag(sessionId: (session?.id)!, status: SessionStatus.reviewAdded)
                let vc = AccountService.shared.currentUserType == .learner ? LearnerMainPageVC() : QTTutorDashboardViewController.controller
                self.navigationController?.pushViewController(vc, animated: true)
            }
		case 3:
            let vc = AccountService.shared.currentUserType == .learner ? LearnerMainPageVC() : QTTutorDashboardViewController.controller
            PostSessionManager.shared.setUnfinishedFlag(sessionId: (session?.id)!, status: SessionStatus.reviewAdded)
			self.navigationController?.pushViewController(vc, animated: true)
		default:
			break
		}
	}
	
	private func finishAndUpload() {
		if AccountService.shared.currentUserType == .learner {
			let updatedRating = ((tutor.tRating * Double(tutor.tNumSessions)) + Double(PostSessionReviewData.rating)) / Double(tutor.tNumSessions + 1)
			let updatedHours = tutor.secondsTaught + runTime
			guard let category = SubjectStore.findCategoryBy(subject: subject) else { return }
			guard let subcategory = SubjectStore.findSubCategory(resource: category, subject: subject) else { return }
			let tutorInfo : [String : Any] = ["hr" : updatedHours, "nos" : tutor.tNumSessions + 1, "tr" : updatedRating.truncate(places: 1)]
			let subcategoryInfo : [String : Any] = ["hr" : updatedHours, "nos" : tutor.tNumSessions + 1, "r" : updatedRating.truncate(places: 1)]
			let featuredInfo : [String : Any] = ["rv" : tutor.tNumSessions + 1, "r" : updatedRating.truncate(places: 1)]
			FirebaseData.manager.updateTutorPostSession(uid: partnerId, sessionId: sessionId, subcategory: subcategory.lowercased(), tutorInfo: tutorInfo, subcategoryInfo: subcategoryInfo, sessionRating: PostSessionReviewData.rating)
			FirebaseData.manager.updateTutorFeaturedPostSession(partnerId, sessionId: sessionId, featuredInfo: featuredInfo)
			
			guard let review = PostSessionReviewData.review, review != "" else { return }
			let reviewDict : [String : Any] = [
				"dte" : Date().timeIntervalSince1970,
				"uid" : CurrentUser.shared.learner.uid!,
				"m" : PostSessionReviewData.review ?? "",
				"nm" : CurrentUser.shared.learner.name,
				"r" : PostSessionReviewData.rating,
				"sbj" : subject
			]
			FirebaseData.manager.updateReviewPostSession(uid: partnerId, sessionId: sessionId, type: "learner", review: reviewDict)
		} else {
			let updatedRating = ((learner.lRating * Double(learner.lNumSessions)) + Double(PostSessionReviewData.rating)) / Double(learner.lNumSessions + 1)
			let updatedHours = learner.lHours + runTime
			
			FirebaseData.manager.updateLearnerPostSession(uid: partnerId, studentInfo: ["nos" : learner.lNumSessions + 1, "hr" : updatedHours, "r" : updatedRating.truncate(places: 1)])
			guard let review = PostSessionReviewData.review, review != "" else { return }
			let reviewDict : [String : Any] = [
				"dte" : Date().timeIntervalSince1970,
				"uid" : CurrentUser.shared.learner.uid!,
				"m" : review,
				"nm" : CurrentUser.shared.learner.name,
				"r" : PostSessionReviewData.rating,
				"sbj" : subject
			]
			FirebaseData.manager.updateReviewPostSession(uid: partnerId, sessionId: sessionId, type: "tutor", review: reviewDict)
		}
	}

    private func createCharge(tutorId: String, cost: Int, completion: @escaping (Error?) -> Void) {
		let fee = Int(Double(cost) * 0.1) + 200
		self.displayLoadingOverlay()
        
        checkTutor(tutorId: tutorId) { takeRate, paypal, error in
            Stripe.retrieveCustomer(cusID: CurrentUser.shared.learner.customer) { (customer, error) in
                if let error = error {
                    self.dismissOverlay()
                    completion(error)
                } else if let customer = customer {
                    guard let card = customer.defaultSource?.stripeID else {
                        self.dismissOverlay()
                        return completion(StripeError.createChargeError)
                    }
                    Stripe.destinationCharge(acctId: self.tutor.acctId, customerId: customer.stripeID, sourceId: card, amount: cost, fee: fee, description: self.session?.subject ?? " ", { (error) in
                        if let error = error {
                            completion(error)
                        } else if let takeRate = takeRate,
                            let paypal = paypal {
                            self.createQLPayment(tutorId: tutorId, fee: fee, takeRate: takeRate, paypal: paypal, completion: completion)
                        } else {
                            completion(nil)
                        }
                        self.dismissOverlay()
                    })
                }
            }
        }
	}
    
    private func checkTutor(tutorId: String, completion: @escaping(_ takeRate: Float?, _ paypal: String?,  _ error: Error?) -> Void) {
        let params = [
            "tutorId": tutorId
        ]
        Alamofire.request("\(Constants.API_BASE_URL)/quicklink/check-tutor", method: .post, parameters: params, encoding: URLEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value as [String: Any]):
                    if let status = value["status"] as? Int,
                        status == 1,
                        let strTakeRate = value["take_rate"] as? String,
                        let takeRate = Float(strTakeRate),
                        let paypal = value["stripe_key"] as? String {
                        completion(takeRate / 100.0, paypal, nil)
                    } else {
                        completion(nil, nil, nil)
                    }
                case .failure(let error):
                    completion(nil, nil, error)
                default:
                    break
                }
            })
    }
    
    private func createQLPayment(tutorId: String, fee: Int, takeRate: Float, paypal: String, completion: @escaping(Error?) -> Void) {
        let params: [String: Any] = [
            "tutorId": tutorId,
            "ql_cut": Float(fee) * takeRate,
            "qt_cut": Float(fee) * (1 - takeRate),
            "paypal": paypal
        ]
        
        Alamofire.request("\(Constants.API_BASE_URL)/quicklink/payments", method: .post, parameters: params, encoding: URLEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            })
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
				cell.total = costOfSession
				cell.titleView.subtitle.text = cellTitles[indexPath.row]
				cell.title.text = cellHeaderViewTitles[indexPath.row]

				return cell
			} else {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "receiptCell", for: indexPath) as! ReceiptCell
				
				cell.partner.profileImageView.image = contentView.profileImageView.image
				cell.partner.infoLabel.text = contentView.nameLabel.text
				cell.subject.infoLabel.text = session?.subject
				cell.sessionLength.infoLabel.text = getFormattedTimeString(seconds: runTime)
				cell.hourlyRate.infoLabel.text = "$" + String(Int(session?.price ?? 0))
				
				let total = costOfSession + Double(PostSessionReviewData.tipAmount)
				cell.total.infoLabel.text = "$" + String(format: "%.2f", total)
				cell.tip.infoLabel.text = "$\(PostSessionReviewData.tipAmount)"
				
				cell.totalSessions.attributedText = AccountService.shared.currentUserType == .learner ? NSMutableAttributedString().regular("Sessions Completed:    ", 14, Colors.purple).bold("\(CurrentUser.shared.learner.lNumSessions + 1)", 14, .white) : NSMutableAttributedString().regular("Sessions Completed:    ", 14, Colors.purple).bold("\(CurrentUser.shared.tutor.tNumSessions + 1)", 14, .white)
				
				cell.totalSessionsWithPartner.attributedText = AccountService.shared.currentUserType == .learner ? NSMutableAttributedString().regular("Sessions Completed With \(name!):    ", 14, Colors.purple).bold("\(self.sessionsWithPartner + 1)", 14, .white) : NSMutableAttributedString().regular("Sessions Completed With \(name!):     ", 14, Colors.purple).bold("\(self.sessionsWithPartner + 1)", 14, .white)
				
				return cell
			}
		case 3:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "receiptCell", for: indexPath) as! ReceiptCell

			cell.partner.profileImageView.image = contentView.profileImageView.image
			cell.partner.infoLabel.text = contentView.nameLabel.text
			cell.subject.infoLabel.text = session?.subject
			cell.sessionLength.infoLabel.text = getFormattedTimeString(seconds: runTime)
			cell.hourlyRate.infoLabel.text = "$" + String(Int(session?.price ?? 0)) + "/hr"
			let total = costOfSession + Double(PostSessionReviewData.tipAmount)
			cell.total.infoLabel.text = "$" + String(format: "%.2f", total)
			cell.tip.infoLabel.text = "$\(PostSessionReviewData.tipAmount)"
		
			cell.totalSessions.attributedText = AccountService.shared.currentUserType == .learner ? NSMutableAttributedString().regular("Sessions Completed:    ", 14, Colors.purple).bold("\(CurrentUser.shared.learner.lNumSessions + 1)", 14, .white) : NSMutableAttributedString().regular("Sessions Completed:    ", 14, Colors.purple).bold("\(CurrentUser.shared.tutor.tNumSessions + 1)", 14, .white)
			
			cell.totalSessionsWithPartner.attributedText = AccountService.shared.currentUserType == .learner ? NSMutableAttributedString().regular("Sessions Completed With \(name!):    ", 14, Colors.purple).bold("\(self.sessionsWithPartner + 1)", 14, .white) : NSMutableAttributedString().regular("Sessions Completed With \(name ?? ""):     ", 14, Colors.purple).bold("\(self.sessionsWithPartner + 1)", 14, .white)
			
			return cell
		default:
			return UICollectionViewCell()
		}
	}
	
	func getFormattedTimeString (seconds : Int) -> String {
		let hours = seconds / 3600
		let minutes = (seconds % 3600) / 60
		let seconds = (seconds % 3600) % 60
	
		if hours > 0 {
			return "\(hours) hours and \(minutes) minutes"
		} else if minutes > 0 {
			return "\(minutes) minutes and \(seconds) seconds"
		} else {
			return "\(seconds) seconds"
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
			UIView.animate(withDuration: 0.2) {
				if AccountService.shared.currentUserType == .learner {
					self.contentView.nameLabel.isHidden = (indexPath.row  == 3)
					self.contentView.nextButton.setTitle(self.buttonTitles[indexPath.row], for: .normal)
					self.contentView.profileImageView.transform = (indexPath.row  == 3) ? CGAffineTransform.init(scaleX: 0, y: 0) : .identity
				} else {
					self.contentView.nameLabel.isHidden = (indexPath.row == 2)
					self.contentView.nextButton.setTitle(self.buttonTitles[indexPath.row], for: .normal)
					self.contentView.profileImageView.transform = (indexPath.row == 2) ? CGAffineTransform.init(scaleX: 0, y: 0) : .identity
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
		return Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
	}
}
