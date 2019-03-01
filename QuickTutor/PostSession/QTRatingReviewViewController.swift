//
//  QTRatingReviewViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 2/26/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import IQKeyboardManager

class QTRatingReviewViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var session : Session?
    var sessionId : String!
    var costOfSession: Double!
    var partnerId : String!
    var runTime : Int!
    var subject : String!
    var name : String!
    var sessionsWithPartner : Int = 0
    
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
    
    var tutor : AWTutor!
    var learner : AWLearner!
    let learnerButtonNames = ["NEXT", "PAY", "COMPLETE"]
    let tutorButtonNames = ["NEXT", "COMPLETE"]
    var currentStep = 0
    var hasPaid: Bool = false
    var hasCompleted: Bool = false
    
    static func loadView() -> QTRatingReviewViewController {
        return QTRatingReviewViewController(nibName: String(describing: QTRatingReviewViewController.self), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                let costWithTip = costOfSession + Double(PostSessionReviewData.tipAmount)
                AnalyticsService.shared.logSessionPayment(cost: costOfSession, tip: Double(PostSessionReviewData.tipAmount))
                createCharge(cost: Int(costWithTip * 100), secondsTaught: tutor.secondsTaught + runTime) { (error) in
                    if let error = error {
                        AlertController.genericErrorAlertWithoutCancel(self, title: "Payment Error", message: error.localizedDescription)
                        self.hasPaid = false
                    } else {
                        self.hasPaid = true
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
                let vc = AccountService.shared.currentUserType == .learner ? LearnerMainPageVC() : TutorMainPage()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 2:
            let vc = AccountService.shared.currentUserType == .learner ? LearnerMainPageVC() : TutorMainPage()
            PostSessionManager.shared.setUnfinishedFlag(sessionId: (session?.id)!, status: SessionStatus.reviewAdded)
            self.navigationController?.pushViewController(vc, animated: true)
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
    
    private func createCharge(cost: Int, secondsTaught: Int, completion: @escaping (Error?) -> Void) {
        let fee = secondsTaught >= 36000 ? Int(Double(cost) * 0.75) + 200 : Int(Double(cost) * 0.10) + 200
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
                Stripe.destinationCharge(acctId: self.tutor.acctId, customerId: customer.stripeID, sourceId: card, amount: cost, fee: fee, description: self.session?.subject ?? " ", { (error) in
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
                if let cell: QTRatingTipCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: QTRatingTipCollectionViewCell.reuseIdentifier,
                                                                                                for: indexPath) as? QTRatingTipCollectionViewCell {
                    cell.setProfileInfo(user: tutor, subject: subject, costOfSession: costOfSession)
                    cell.didSelectTip = { tip in
                        PostSessionReviewData.tipAmount = tip
                    }
                    return cell
                }
            } else {
                if let cell: QTRatingReceiptCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: QTRatingReceiptCollectionViewCell.reuseIdentifier,
                                                                                                    for: indexPath) as? QTRatingReceiptCollectionViewCell {
                    cell.setProfileInfo(user: learner,
                                        subject: subject,
                                        bill: costOfSession,
                                        tip: PostSessionReviewData.tipAmount,
                                        sessionDuration: runTime,
                                        partnerSessionNumber: sessionsWithPartner)
                    return cell
                }
            }
            break
        case 2:
            if let cell: QTRatingReceiptCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: QTRatingReceiptCollectionViewCell.reuseIdentifier,
                                                                                                for: indexPath) as? QTRatingReceiptCollectionViewCell {
                cell.setProfileInfo(user: tutor,
                                    subject: subject,
                                    bill: costOfSession,
                                    tip: PostSessionReviewData.tipAmount,
                                    sessionDuration: runTime,
                                    partnerSessionNumber: sessionsWithPartner)
                return cell
            }
        default:
            break
        }
        
        return UICollectionViewCell()
    }

}
