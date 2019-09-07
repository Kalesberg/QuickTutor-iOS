//
//  SessionRequestVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/23/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class SessionRequestVC: UIViewController {
    
    let contentView = SessionRequestVCView()
    var tutor: AWTutor? {
        didSet {
            guard let tutor = tutor else { return }
            contentView.tutor = tutor
            contentView.subjectView.collectionView.reloadData()
            contentView.subjectView.updateUI()
            price = Double(tutor.price)
            updatePriceLabelText(Double(tutor.price))
            updateTutorViewAsChosen()
            contentView.paymentView.paymentInputView.inputField.text = "\(tutor.price ?? 0)"
            checkForErrors()
        }
    }
    var subject: String?
    var startTime: Date = Date().adding(minutes: 15)
    var duration: Int = 30
    var price: Double?
    var sessionType: String = "online"
    var paymentType = QTSessionPaymentType.hour
    var requestError: SessionRequestError = .noTutor {
        didSet {
            contentView.sendView.accessoryView.titleLabel.text = requestError.rawValue
            if requestError == .none {
                contentView.sendView.connectButton.isUserInteractionEnabled = true
                contentView.sendView.connectButton.backgroundColor = Colors.purple
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = contentView
        checkForErrors()    
        contentView.tutorView.delegate = self
        contentView.parentViewController = self
        contentView.dateView.delegate = self
        contentView.durationView.delegate = self
        contentView.paymentView.delegate = self
        contentView.sessionTypeView.delegate = self
        contentView.sendView.connectButton.isUserInteractionEnabled = false
        contentView.sendView.connectButton.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)
        contentView.scrollView.isExclusiveTouch = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.contentView.durationView.collectionView.scrollToItem(at: IndexPath(item: 8, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        if let tutor = tutor {
            contentView.tutor = tutor
            contentView.tutorView.tutorCell.updateUI(user: tutor)
            contentView.tutorView.tutorCell.alpha = 1
            checkForErrors()
        }
        
        // Hide the bottom tab bar and relayout views
        tabBarController?.tabBar.isHidden = true
        edgesForExtendedLayout = .bottom
        extendedLayoutIncludesOpaqueBars = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideTabBar(hidden: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = tutor {
            contentView.subjectView.collectionView.reloadData()
            contentView.subjectView.updateUI()
        }
    }
    
    func setupNavBar() {
        navigationItem.title = "Schedule Session"
        edgesForExtendedLayout = []
        navigationController?.setNavigationBarHidden(false, animated: true)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        navigationController?.view.backgroundColor = Colors.newNavigationBarBackground
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func checkForErrors() {
        if tutor == nil {
            requestError = .noTutor
        } else if subject == nil {
            requestError = .noSubject
        } else if price == nil || price == 0 {
            requestError = .noPrice
        } else {
            requestError = .none
        }
    }
    
    @objc func sendRequest() {
        var sessionData = [String: Any] ()
        guard let tutor = tutor, let subject = subject, let price = price, let uid = Auth.auth().currentUser?.uid else { return }
        guard isValidPriceRange(price: price) else { return }
        sessionData["subject"] = subject
        sessionData["date"] = startTime.timeIntervalSince1970
        sessionData["startTime"] = startTime.timeIntervalSince1970
        sessionData["endTime"] = startTime.adding(minutes: duration).timeIntervalSince1970
        sessionData["type"] = sessionType
        sessionData["price"] = price
        sessionData["status"] = "pending"
        sessionData["senderId"] = uid
        sessionData["receiverId"] = tutor.uid
        sessionData["paymentType"] = paymentType.rawValue
        sessionData["duration"] = duration * 60 // sec
        guard let _ = sessionData["subject"], let _ = sessionData["date"], let _ = sessionData["startTime"], let _ = sessionData["endTime"], let _ = sessionData["type"], let _ = sessionData["price"] else {
            return
        }
        
        let sessionRequest = SessionRequest(data: sessionData)
        MessageService.shared.sendSessionRequestToId(sessionRequest: sessionRequest, tutor.uid)
        
        if let vcs = navigationController?.viewControllers, vcs.count >= 2 {
            if !UserDefaults.standard.bool(forKey: QTUserDefaultsKey.learnerAppRateForFirstSession) {
                vcs[vcs.count - 2].showReviewController(QTUserDefaultsKey.learnerAppRateForFirstSession)
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    func isValidPriceRange(price: Double) -> Bool {
        let realPrice = (price + 0.3) / 0.971
        guard realPrice >= 5 else {
            showPriceAlert(message: "There is a $5 minimum to every session.")
            return false
        }
        
        guard realPrice <= 15000 else {
            showPriceAlert(message: "There is a $15,000 maximum to every session.")
            return false
        }
        return true
    }
    
    func showPriceAlert(message: String) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            ac.dismiss(animated: true, completion: nil)
        }))
        present(ac, animated: true, completion: nil)
    }
    
    func updatePriceLabelText(_ price: Double) {
        var realPrice = price
        if !contentView.paymentView.paymentTypeView.secondaryButton.isSelected {
            realPrice = calculatePrice(price, duration: duration)
        }
        self.price = realPrice
        let fee = (realPrice + 0.3) / 0.971 - realPrice
        
        // fee
        let strFee = NSMutableAttributedString(attributedString: NSAttributedString(string: "+Processing Fee: ",
                                                                                    attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]))
        strFee.append(NSAttributedString(string: "$\(String(format: "%.2f", fee))"))
        contentView.paymentView.paymentInputView.feeLabel.attributedText = strFee
        
        // total
        contentView.paymentView.paymentInputView.digitsLabel.text = "$\(String(format: "%.2f", realPrice + fee))"
    }
    
    func calculatePrice(_ price: Double, duration: Int) -> Double {
        let minutesPerHours = 60.0
        return Double(duration) / minutesPerHours * price
    }
}

extension SessionRequestVC: SessionRequestTutorViewDelegate {
    func tutorViewShouldChooseTutor(_ tutorView: SessionRequestTutorView) {
        if CurrentUser.shared.learner.connectedTutorsCount == 0 {
            let alertController = UIAlertController(title: "", message: "You have no tutor connections", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alertController.addAction(dismiss)
            present(alertController, animated: true, completion: nil)
            return
        }
        let vc = SessionRequestViewConnectionsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tutorView(_ tutorView: SessionRequestTutorView, didChoose tutor: AWTutor) {
        tutorView.tutorCell.isHidden = false
        self.tutor = tutor
        contentView.tutorView.tutorCell.updateUI(user: tutor)
        
        if let featuredSubject = tutor.featuredSubject,
            let subjects = tutor.subjects,
            let index = subjects.firstIndex(of: featuredSubject) {
            contentView.subjectView.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .top)
            subject = featuredSubject
            checkForErrors()
        }
    }
    
    func updateTutorViewAsChosen() {
        guard let tutor = tutor else { return }
        contentView.tutorView.tutorCell.isHidden = false
        contentView.tutorView.tutorCell.updateUI(user: tutor)
    }
    
}

extension SessionRequestVC: SessionRequestDateViewDelegate {
    func sessionRequestDateView(_ dateView: SessionRequestDateView, didSelect date: Date) {
        self.startTime = date
        checkForErrors()
    }
}

extension SessionRequestVC: SessionRequestDurationViewDelegate {
    func sessionRequestDurationView(_ durationView: SessionRequestDurationView, didSelect duration: Int) {
        self.duration = duration
        if nil != tutor {
            guard let priceText = contentView.paymentView.paymentInputView.inputField.text else { return }
            updatePriceLabelText(Double(priceText) ?? 0)
            checkForErrors()
        }
    }
}

extension SessionRequestVC: SessionRequestPaymentViewDelegate {
    func sessionRequestPaymentView(_ paymentView: SessionRequestPaymentView, didEnter price: Double) {
        paymentType = paymentView.paymentTypeView.primaryButton.isSelected ? .hour : .session
        checkForErrors()
        updatePriceLabelText(price)
    }
}

extension SessionRequestVC: SessionRequestTypeViewDelegate {
    func sessionRequestTypeView(_ typeView: SessionRequestTypeView, didSelect type: String) {
        self.sessionType = type
        checkForErrors()
    }
}
