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
            checkForErrors()
        }
    }
    var subject: String?
    var startTime: Date = Date().adding(minutes: 15)
    var duration: Int = 20
    var price: Double?
    var sessionType: String = "online"
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.contentView.durationView.collectionView.scrollToItem(at: IndexPath(item: 6, section: 0), at: .centeredHorizontally, animated: false)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let tutor = tutor {
            contentView.subjectView.collectionView.reloadData()
            contentView.subjectView.updateUI()
        }
    }
    
    func setupNavBar() {
        navigationItem.title = "Request Session"
        edgesForExtendedLayout = []
        navigationController?.setNavigationBarHidden(false, animated: true)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        navigationController?.view.backgroundColor = Colors.darkBackground
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func checkForErrors() {
        if tutor == nil {
            requestError = .noTutor
        } else if subject == nil {
            requestError = .noSubject
        } else if price == nil || price == 0{
            requestError = .noPrice
        } else {
            requestError = .none
        }
    }
    
    @objc func sendRequest() {
        var sessionData = [String: Any] ()
        guard let tutor = tutor, let subject = subject, let price = price, let uid = Auth.auth().currentUser?.uid else { return }
        sessionData["subject"] = subject
        sessionData["date"] = startTime.timeIntervalSince1970
        sessionData["startTime"] = startTime.timeIntervalSince1970
        sessionData["endTime"] = startTime.adding(minutes: duration).timeIntervalSince1970
        sessionData["type"] = sessionType
        sessionData["price"] = price
        sessionData["status"] = "pending"
        sessionData["senderId"] = uid
        sessionData["receiverId"] = tutor.uid
        guard let _ = sessionData["subject"], let _ = sessionData["date"], let _ = sessionData["startTime"], let _ = sessionData["endTime"], let _ = sessionData["type"], let _ = sessionData["price"] else {
            return
        }
        
        let sessionRequest = SessionRequest(data: sessionData)
        DataService.shared.sendSessionRequestToId(sessionRequest: sessionRequest, tutor.uid)
        navigationController?.popViewController(animated: true)
    }
    
}

extension SessionRequestVC: SessionRequestTutorViewDelegate {
    func tutorViewShouldChooseTutor(_ tutorView: SessionRequestTutorView) {
        let vc = SessionRequestViewConnectionsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tutorView(_ tutorView: SessionRequestTutorView, didChoose tutor: AWTutor) {
        tutorView.tutorCell.alpha = 1
        self.tutor = tutor
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
        print(duration)
        checkForErrors()
    }
}

extension SessionRequestVC: SessionRequestPaymentViewDelegate {
    func sessionRequestPaymentView(_ paymentView: SessionRequestPaymentView, didEnter price: Double) {
        self.price = price
        checkForErrors()
        updatePriceLabelText(price)
    }
    
    func updatePriceLabelText(_ price: Double) {
        if contentView.paymentView.paymentTypeView.secondaryButton.isSelected {
            guard let priceText = contentView.paymentView.paymentInputView.inputField.text else { return }
            contentView.paymentView.paymentInputView.digitsLabel.text = "$\(priceText)"
        } else {
            guard let priceText = contentView.paymentView.paymentInputView.inputField.text else { return }
            let calculatedPrice = Double(duration) / 60.0 * price
            self.price = calculatedPrice
            contentView.paymentView.paymentInputView.digitsLabel.text = "$\(String(format: "%.2f", calculatedPrice))"
        }
    }
}

extension SessionRequestVC: SessionRequestTypeViewDelegate {
    func sessionRequestTypeView(_ typeView: SessionRequestTypeView, didSelect type: String) {
        self.sessionType = type
        checkForErrors()
    }
}
