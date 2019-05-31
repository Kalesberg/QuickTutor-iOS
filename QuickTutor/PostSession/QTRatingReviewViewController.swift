//
//  QTRatingReviewViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 2/26/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import IQKeyboardManager
import Firebase
import Alamofire

class QTRatingReviewViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var session : Session?
    var sessionId : String!
    var costOfSession: Double!
    private var partnerId : String!
    private var runTime : Int!
    private var subject : String!
    var name : String!
    var sessionsWithPartner : Int = 0
    
    struct PostSessionReviewData {
        static var rating : Int!
        static var tipAmount : Double = 0
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
    
    var tutor : AWTutor!
    var learner : AWLearner!
    let learnerButtonNames = ["NEXT", "PAY", "COMPLETE"]
    let tutorButtonNames = ["NEXT", "COMPLETE"]
    var currentStep = 0
    var hasPaid: Bool = false
    var hasCompleted: Bool = false
    
    static var controller: QTRatingReviewViewController {
        return QTRatingReviewViewController(nibName: String(describing: QTRatingReviewViewController.self), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let session = session {
            partnerId = session.partnerId()
            runTime = session.runTime
            subject = session.subject
            
            if let sessionType = QTSessionType(rawValue: session.type), sessionType == .quickCalls {
                titleLabel.text = "Call complete!"
            } else {
                titleLabel.text = "Session complete!"
            }
        }
        
        Database.database().reference().child("sessions").child(sessionId).child("cost").setValue(costOfSession)
        
        displayLoadingOverlay()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewTap)))
        nextButton.layer.cornerRadius = 3
        nextButton.clipsToBounds = true
        
        // Disable automatic keyboard control
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        // Get data
        getSessionWithPartner(uid: CurrentUser.shared.learner.uid!)
        if AccountService.shared.currentUserType == .learner {
            getTutorAccount(uid: partnerId) { (tutor) in
                if let tutor = tutor {
                    self.tutor = tutor
                    self.configureDelegates()
                }
            }
        } else {
            getStudentAccount(uid: partnerId) { (learner) in
                if let learner = learner {
                    self.learner = learner
                    self.configureDelegates()
                }
            }
        }
        SessionService.shared.session = nil
    }

    @IBAction func onClickNextButton(_ sender: Any) {
        errorLabel.isHidden = true
        switch currentStep {
        case 0:
            if PostSessionReviewData.rating == nil {
                if AccountService.shared.currentUserType == .learner {
                    displayErrorMessage(text: "Please give this tutor a rating.")
                } else {
                    displayErrorMessage(text: "Please give this learner a rating.")
                }
                return
            }
            currentStep = currentStep + 1
            collectionView.scrollToItem(at: IndexPath(item: currentStep, section: 0), at: .centeredHorizontally, animated: true)
            collectionView.reloadItems(at: [IndexPath(item: currentStep, section: 0)])
            nextButton.setTitle((AccountService.shared.currentUserType == .learner ?
                learnerButtonNames[currentStep] : tutorButtonNames[currentStep]), for: .normal)
            break
        case 1:
            if AccountService.shared.currentUserType == .learner {
                guard hasPaid == false else { return }
                nextButton.isEnabled = false
                let tip = Double(PostSessionReviewData.tipAmount)
                AnalyticsService.shared.logSessionPayment(cost: costOfSession, tip: tip)
                createCharge(tutorId: tutor.uid, learnerId: CurrentUser.shared.learner.uid, cost: costInDollars(costOfSession), tip: Int(tip * 100)) { error in
                    if let error = error {
                        AlertController.genericErrorAlertWithoutCancel(self, title: "Payment Error", message: error.localizedDescription)
                        self.hasPaid = false
                    } else {
                        self.hasPaid = true
                        PostSessionManager.shared.setUnfinishedFlag(sessionId: (self.session?.id)!, status: .paymentCharged)
                        self.finishAndUpload()
                        self.currentStep = self.currentStep + 1
                        self.collectionView.scrollToItem(at: IndexPath(item: self.currentStep, section: 0), at: .centeredHorizontally, animated: true)
                        self.collectionView.reloadItems(at: [IndexPath(item: self.currentStep, section: 0)])
                        self.nextButton.setTitle((AccountService.shared.currentUserType == .learner ?
                            self.learnerButtonNames[self.currentStep] : self.tutorButtonNames[self.currentStep]), for: .normal)
                    }
                    self.nextButton.isEnabled = true
                }
            } else {
                guard hasCompleted == false else { return }
                finishAndUpload()
                hasCompleted = true
                PostSessionManager.shared.setUnfinishedFlag(sessionId: (session?.id)!, status: SessionStatus.reviewAdded)
                let vc = AccountService.shared.currentUserType == .learner ? LearnerMainPageVC() : QTTutorDashboardViewController.controller
                RootControllerManager.shared.configureRootViewController(controller: vc)
            }
            break
        case 2:
            PostSessionManager.shared.setUnfinishedFlag(sessionId: (session?.id)!, status: SessionStatus.complete)
            let vc = AccountService.shared.currentUserType == .learner ? LearnerMainPageVC() : QTTutorDashboardViewController.controller
            RootControllerManager.shared.configureRootViewController(controller: vc)
            break
        default:
            break
        }
    }
    
    @objc
    func handleViewTap() {
        dismissKeyboard()
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
    
    private func configureDelegates() {
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(QTRatingReviewCollectionViewCell.nib, forCellWithReuseIdentifier: QTRatingReviewCollectionViewCell.reuseIdentifier)
        collectionView.register(QTRatingTipCollectionViewCell.nib, forCellWithReuseIdentifier: QTRatingTipCollectionViewCell.reuseIdentifier)
        collectionView.register(QTRatingReceiptCollectionViewCell.nib, forCellWithReuseIdentifier: QTRatingReceiptCollectionViewCell.reuseIdentifier)
        dismissOverlay()
    }
    
    func displayErrorMessage(text: String) {
        errorLabel.text = text
        errorLabel.shake()
        errorLabel.isHidden = false
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
            
            let reviewDict : [String : Any] = [
                "dte" : Date().timeIntervalSince1970,
                "uid" : CurrentUser.shared.learner.uid!,
                "m" : PostSessionReviewData.review ?? "",
                "nm" : CurrentUser.shared.learner.name,
                "r" : PostSessionReviewData.rating,
                "sbj" : subject
            ]
            FirebaseData.manager.updateReviewPostSession(uid: partnerId, sessionId: sessionId, type: "tutor", review: reviewDict)
        }
    }
    
    func calculateFee(_ cost: Int) -> Int {
        return Int(Double(cost) * 0.10) + 200
    }
    
    func costInDollars(_ cost: Double) -> Int {
        return Int(cost * 100)
    }
    
    private func createCharge(tutorId: String, learnerId: String, cost: Int, tip: Int, completion: @escaping (Error?) -> Void) {
        let costWithTip = cost + tip
        let fee = calculateFee(costWithTip)
        self.displayLoadingOverlay()
        checkSessionUsers(tutorId: tutorId, learnerId: learnerId) { learnerInfluencerId, tutorInfluencerId, error in
            StripeService.retrieveCustomer(cusID: CurrentUser.shared.learner.customer) { (customer, error) in
                if let customer = customer {
                    guard let card = customer.defaultSource?.stripeID else {
                        self.dismissOverlay()
                        return completion(StripeError.createChargeError)
                    }
                    StripeService.destinationCharge(acctId: self.tutor.acctId,
                                             customerId: learnerId,
                                             customerStripeId: customer.stripeID,
                                             sourceId: card,
                                             amount: costWithTip,
                                             fee: fee,
                                             description: self.session?.subject ?? "", { error in
                        if let error = error {
                            completion(error)
                        } else if nil != learnerInfluencerId
                            || nil != tutorInfluencerId {
                            self.createQLPayment(tutorId: tutorId, learnerId: learnerId, fee: fee, learnerInfluencerId: learnerInfluencerId, tutorInfluencerId: tutorInfluencerId, completion: completion)
                        } else {
                            completion(nil)
                        }
                        self.dismissOverlay()
                    })
                } else {
                    self.dismissOverlay()
                    completion(error)
                }
            }
        }
    }
    
    private func checkSessionUsers(tutorId: String, learnerId: String, completion: @escaping(_ learnerInfluencerId: String?, _ tutorInfluencerId: String?,  _ error: Error?) -> Void) {
        let params = [
            "tutor_id": tutorId,
            "learner_id": learnerId
        ]
        Alamofire.request("\(Constants.API_BASE_URL)/quicklink/session-users", method: .post, parameters: params, encoding: URLEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value as [String: Any]):
                    completion(value["learner_influencer_id"] as? String, value["tutor_influencer_id"] as? String, nil)
                case .failure(let error):
                    completion(nil, nil, error)
                default:
                    break
                }
            })
    }
    
    private func createQLPayment(tutorId: String, learnerId: String, fee: Int, learnerInfluencerId: String?, tutorInfluencerId: String?, completion: @escaping(Error?) -> Void) {
        var params: [String: Any] = [
            "tutor_id": tutorId,
            "learner_id": learnerId,
            "fee": fee
        ]
        if let learnerInfluencerId = learnerInfluencerId {
            params["learner_influencer_id"] = learnerInfluencerId
        }
        if let tutorInfluencerId = tutorInfluencerId {
            params["tutor_influencer_id"] = tutorInfluencerId
        }
        
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

extension QTRatingReviewViewController: UICollectionViewDelegate {
    
}

extension QTRatingReviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.size.width
        let height = collectionView.frame.height
        
        return CGSize(width: width, height: height)
    }
}

extension QTRatingReviewViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AccountService.shared.currentUserType == .learner ? 3 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            if let cell: QTRatingReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: QTRatingReviewCollectionViewCell.reuseIdentifier,
                                                                                               for: indexPath) as? QTRatingReviewCollectionViewCell {
                cell.didUpdateRating = { rating in
                    PostSessionReviewData.rating = rating
                }
                cell.didWriteReview = { review in
                    PostSessionReviewData.review = review
                }
                
                if AccountService.shared.currentUserType == .learner {
                    cell.setProfileInfo(user: tutor, subject: subject)
                } else {
                    cell.setProfileInfo(user: learner, subject: subject)
                }
                return cell
            }
            break
        case 1:
            if AccountService.shared.currentUserType == .learner {
                if let cell: QTRatingTipCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: QTRatingTipCollectionViewCell.reuseIdentifier, for: indexPath) as? QTRatingTipCollectionViewCell {
                    cell.setProfileInfo(user: tutor, subject: subject, costOfSession: costOfSession)
                    cell.didSelectTip = { tip in
                        PostSessionReviewData.tipAmount = tip
                    }
                    return cell
                }
            } else {
                if let cell: QTRatingReceiptCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: QTRatingReceiptCollectionViewCell.reuseIdentifier,
                                                                                                    for: indexPath) as? QTRatingReceiptCollectionViewCell {
                    if let type = session?.type {
                        let sessionType = QTSessionType(rawValue: type) ?? QTSessionType.online
                        cell.setProfileInfo(user: learner,
                                            subject: subject,
                                            bill: costOfSession,
                                            fee: calculateFee(costInDollars(costOfSession)),
                                            tip: PostSessionReviewData.tipAmount,
                                            sessionDuration: runTime,
                                            partnerSessionNumber: sessionsWithPartner,
                                            sessionType: sessionType)
                    }
                    return cell
                }
            }
            break
        case 2:
            if let cell: QTRatingReceiptCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: QTRatingReceiptCollectionViewCell.reuseIdentifier,
                                                                                                for: indexPath) as? QTRatingReceiptCollectionViewCell {
                if let type = session?.type {
                    let sessionType = QTSessionType(rawValue: type) ?? QTSessionType.online
                    cell.setProfileInfo(user: tutor,
                                        subject: subject,
                                        bill: costOfSession,
                                        fee: calculateFee(costInDollars(costOfSession)),
                                        tip: PostSessionReviewData.tipAmount,
                                        sessionDuration: runTime,
                                        partnerSessionNumber: sessionsWithPartner,
                                        sessionType: sessionType)
                }
                return cell
            }
        default:
            break
        }
        
        return UICollectionViewCell()
    }

}
