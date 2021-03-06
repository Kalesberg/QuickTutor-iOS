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
import Stripe

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
    
    private var cards = [STPCard]()
    private var defaultCard: STPCard?
    var customer: STPCustomer! {
        didSet {
            setCustomer()
        }
    }
    
    
    struct PostSessionReviewData {
        static var rating : Int!
        static var tipAmount : Double = 5
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
    
    // stripe payment variables
    private var amount: Int!
    private var fee: Int!
    private var paymentError: QTStripeError? = QTStripeError(error: StripeError.cancelApplePay)
    private var paymentCompletion: ((QTStripeError?) -> Void)?
    
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
        
        displayLoadingOverlay()
        
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewTap)))
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear (animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
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
                        if let message = error.message {
                            AlertController.genericErrorAlertWithoutCancel(self,
                                                                           title: "Payment Error",
                                                                           message: message)
                        } else {
                            AlertController.genericErrorAlertWithoutCancel(self,
                                                                           title: "Payment Error",
                                                                           message: "Your payment method was declined. Please contact your financial instituation or select a new method.")
                        }
                        
                        self.hasPaid = false
                    } else {
                        self.hasPaid = true
                        Database.database().reference().child("sessions").child(self.sessionId).child("cost").setValue(self.costOfSession + tip)
                        PostSessionManager.shared.setUnfinishedFlag(sessionId: self.sessionId, status: .paymentCharged)
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
                PostSessionManager.shared.setUnfinishedFlag(sessionId: sessionId, status: .reviewAdded)
                let vc = AccountService.shared.currentUserType == .learner ? LearnerMainPageVC() : QTTutorDashboardViewController.controller
                RootControllerManager.shared.configureRootViewController(controller: vc)
            }
            break
        case 2:
            PostSessionManager.shared.setUnfinishedFlag(sessionId: sessionId, status: .complete)
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
            guard let subcategory = SubjectStore.shared.findSubCategory(subject: subject) else { return }
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
        return Int(Double(cost) * 0.15 + 200)
    }
    
    func costInDollars(_ cost: Double) -> Int {
        return Int(cost * 100)
    }
    
    private func selectPayment () {
        NotificationCenter.default.addObserver(self, selector: #selector(updatedCustomer(_ :)), name: Notifications.didUpatePaymentCustomer.name, object: nil)
        
        let cardManagerVC = CardManagerViewController()
        cardManagerVC.setHasPaymentHistory(false)
        self.navigationController?.pushViewController(cardManagerVC, animated: true)
    }
    
    @objc
    private func updatedCustomer (_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String:Any] else { return }
        if let customer = userInfo["customer"] as? STPCustomer {
            self.customer = customer
            guard let cell = collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? QTRatingTipCollectionViewCell else { return }
            cell.setPayment(defaultCard: defaultCard)
        } else if let isApplyPay = userInfo["isApplyPay"] as? Bool, isApplyPay {
            defaultCard = nil
            guard let cell = collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? QTRatingTipCollectionViewCell else { return }
            cell.setPayment(defaultCard: defaultCard)
        }
    }
    
    // MARK: - Stripe Handlers
    private func getPayments (_ cell: QTRatingTipCollectionViewCell) {
        if let learner = CurrentUser.shared.learner, !learner.customer.isEmpty {
            displayLoadingOverlay()
            StripeService.retrieveCustomer(cusID: CurrentUser.shared.learner.customer) { customer, error in
                self.dismissOverlay()
                if let error = error {
                    if let message = error.message {
                        AlertController.genericAlertWithoutCancel(self, title: "Error Retrieving Cards", message: message)
                    } else {
                        AlertController.genericAlertWithoutCancel(self, title: "Error Retrieving Cards", message: error.error?.localizedDescription)
                    }
                } else if let customer = customer {
                    self.customer = customer
                    cell.setPayment(defaultCard: self.defaultCard)
                }
            }
        }
    }
    
    private func setCustomer() {
        guard let cards = customer.sources as? [STPCard] else { return }
        self.cards = cards
        guard let defaultCard = customer.defaultSource as? STPCard else { return }
        self.defaultCard = defaultCard
    }
    
    private func createCharge(tutorId: String, learnerId: String, cost: Int, tip: Int, completion: @escaping (QTStripeError?) -> Void) {
        let totalPrice = cost + tip
        amount = Int(Double(totalPrice + 57) / 0.968 + 0.5)
        
        let stripeFee = amount - totalPrice
        let applicationFee = calculateFee(totalPrice)
        fee = stripeFee + applicationFee
        
        paymentCompletion = completion
        
        displayLoadingOverlay()
        if CurrentUser.shared.learner.isApplePayDefault {
            // Apple Pay
            let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: Constants.APPLE_PAY_MERCHANT_ID, country: "US", currency: "USD")
            var description = tutor.formattedName
            if "quick-calls" == session?.type {
                description += " for your QuickCall."
            } else {
                description += " for your Session."
            }
            
            paymentRequest.paymentSummaryItems = [
                PKPaymentSummaryItem(label: description, amount: NSDecimalNumber(value: Double(amount) / 100.0))
            ]
            
            guard let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else { return }
            paymentAuthorizationViewController.delegate = self
            self.present(paymentAuthorizationViewController, animated: true)
        } else {
            StripeService.retrieveCustomer(cusID: CurrentUser.shared.learner.customer) { (customer, error) in
                if let customer = customer {
                    guard let card = customer.defaultSource?.stripeID else {
                        self.dismissOverlay()
                        let objStripeError = QTStripeError(error: StripeError.createChargeError)
                        completion(objStripeError)
                        return
                    }
                    
                    StripeService.destinationCharge(acctId: self.tutor.acctId,
                                                    customerId: learnerId,
                                                    customerStripeId: customer.stripeID,
                                                    sourceId: card,
                                                    amount: self.amount,
                                                    fee: self.fee,
                                                    description: self.session?.subject ?? "") { error in
                                                        if let error = error {
                                                            self.dismissOverlay()
                                                            completion(error)
                                                        } else {
                                                            self.checkSessionUsers(tutorId: tutorId, learnerId: learnerId) { learnerInfluencerId, tutorInfluencerId, error in
                                                                self.dismissOverlay()
                                                                if nil != learnerInfluencerId
                                                                    || nil != tutorInfluencerId {
                                                                    self.createQLPayment(tutorId: tutorId, learnerId: learnerId, fee: self.fee, learnerInfluencerId: learnerInfluencerId, tutorInfluencerId: tutorInfluencerId, completion: completion)
                                                                } else {
                                                                    completion(nil)
                                                                }
                                                            }
                                                        }
                    }
                } else {
                    self.dismissOverlay()
                    completion(error)
                }
            }
        }
    }
    
    private func checkSessionUsers(tutorId: String, learnerId: String, completion: @escaping(_ learnerInfluencerId: String?, _ tutorInfluencerId: String?,  _ error: QTStripeError?) -> Void) {
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
                    completion(nil, nil, QTStripeError(error: error))
                default:
                    break
                }
            })
    }
    
    private func createQLPayment(tutorId: String, learnerId: String, fee: Int, learnerInfluencerId: String?, tutorInfluencerId: String?, completion: @escaping(QTStripeError?) -> Void) {
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
                    completion(QTStripeError(error: error))
                }
            })
    }
}

extension QTRatingReviewViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true) {
            self.dismissOverlay()
            
            if let paymentError = self.paymentError,
                paymentError.error?.localizedDescription == StripeError.cancelApplePay.localizedDescription {
                self.nextButton.isEnabled = true
                return
            }
            self.paymentCompletion?(self.paymentError)
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        STPAPIClient.shared().createToken(with: payment) { token, error in
            if let error = error {
                self.paymentError = QTStripeError(error: error)
                completion(.failure)
            } else {
                guard let tokenId = token?.stripeID else {
                    self.paymentError = nil
                    completion(.failure)
                    return
                }
                
                var description = ""
                if let subject = self.session?.subject {
                    if "quick-call" == self.session?.type {
                        description = "QuickCall: \(subject)"
                    } else {
                        description = "Session: \(subject)"
                    }
                }
                StripeService.makeApplePay(acctId: self.tutor.acctId,
                                           customerId: CurrentUser.shared.learner.uid,
                                           receiptEmail: CurrentUser.shared.learner.email,
                                           tokenId: tokenId,
                                           amount: self.amount,
                                           fee: self.fee,
                                           description: description) { error in
                                            if let error = error {
                                                self.paymentError = error
                                                completion(.failure)
                                            } else {
                                                self.checkSessionUsers(tutorId: self.tutor.uid, learnerId: CurrentUser.shared.learner.uid) { learnerInfluencerId, tutorInfluencerId, error in
                                                    if nil != learnerInfluencerId
                                                        || nil != tutorInfluencerId {
                                                        self.createQLPayment(tutorId: self.tutor.uid, learnerId: CurrentUser.shared.learner.uid, fee: self.fee, learnerInfluencerId: learnerInfluencerId, tutorInfluencerId: tutorInfluencerId) { error in
                                                            self.paymentError = error
                                                            completion(.success)
                                                        }
                                                    } else {
                                                        self.paymentError = error
                                                        completion(.success)
                                                    }
                                                }
                                            }
                }
            }
        }
    }
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
            NotificationCenter.default.removeObserver(self)
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
                    if let type = session?.type {
                        let sessionType = QTSessionType(rawValue: type) ?? QTSessionType.online
                        cell.didSelectTip = { tip, totalCost in
                            PostSessionReviewData.tipAmount = tip
                            self.nextButton.setTitle("\(self.learnerButtonNames[self.currentStep]) TOTAL: $\(String(format: "%.02f", totalCost))", for: .normal)
                        }
                        cell.didSelectPayment = {
                            self.selectPayment ()
                        }
                        cell.didSelectCustomTip = {
                            let vc = QTRatingReviewCustomTipViewController.controller
                            vc.modalPresentationStyle = .overCurrentContext
                            vc.delegate = cell
                            self.present(vc, animated: true, completion: nil)
                        }
                        cell.setProfileInfo(user: tutor, subject: subject, costOfSession: costOfSession, sessionType: sessionType)
                        
                        // stripe
                        if cards.isEmpty {
                            getPayments (cell)
                        } else {
                            cell.setPayment (defaultCard: defaultCard)
                        }
                    }
                    return cell
                }
            } else {
                NotificationCenter.default.removeObserver(self)
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
            NotificationCenter.default.removeObserver(self)
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
