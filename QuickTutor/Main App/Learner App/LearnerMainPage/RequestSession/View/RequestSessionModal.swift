//
//  RequestSessionModal.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import CoreLocation

class RequestSessionMenu :  UIView {
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	let requestSessionBackgroundView = RequestSessionBackgroundView()
	let cancelRequestView = CancelRequestView()
	
	func configureView() {
		addSubview(requestSessionBackgroundView)
		addSubview(cancelRequestView)
		applyConstraints()
	}
	func applyConstraints() {
		requestSessionBackgroundView.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.8)
		}
		cancelRequestView.snp.makeConstraints { (make) in
			make.top.equalTo(requestSessionBackgroundView.snp.bottom)
			make.bottom.equalToSuperview()
			make.width.centerX.equalToSuperview()
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		cancelRequestView.roundCorners([.bottomLeft, .bottomRight], radius: 6)
		cancelRequestView.cancelRequestButton.layer.cornerRadius = 10
		cancelRequestView.requestSessionButton.layer.cornerRadius = 10
	}
}

class RequestSessionModal :  UIView {
	let chatPartnerId : String
	
	init(uid: String, requestData: TutorPreferenceData) {
		self.chatPartnerId = uid
		print("uid")
		requestSessionMenu.requestSessionBackgroundView.requestData = requestData
		print(requestData.name)
		print(requestData.pricePreference)
		print(requestData.sessionPreference)
		print(requestData.subjects)
		print(requestData.travelPreference)
		
		super.init(frame: .zero)
		configureView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let requestSessionMenu = RequestSessionMenu()
	
	func configureView() {
		addSubview(requestSessionMenu)
		isUserInteractionEnabled = true
		requestSessionMenu.cancelRequestView.cancelRequestButton.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
		requestSessionMenu.cancelRequestView.requestSessionButton.addTarget(self, action: #selector(requestButtonPressed(_:)), for: .touchUpInside)
		backgroundColor = UIColor.black.withAlphaComponent(0.6)
		
		applyConstraints()
	}
	 func applyConstraints() {
		requestSessionMenu.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalToSuperview().multipliedBy(0.55)
		}
	}
	@objc private func cancelButtonPressed(_ sender: UIButton) {
		self.removeFromSuperview()
		RequestSessionData.clearSessionData()
		if let current = UIApplication.getPresentedViewController() {
			current.becomeFirstResponder()
		}
	}
	@objc private func requestButtonPressed(_ sender: UIButton) {
		var sessionData = [String : Any]()
		
		guard let subject = RequestSessionData.subject else {
			showErrorMessage(message: RequestSessionErrorType.subjectNotChosen.rawValue)
			return
		}
		guard let startTime = RequestSessionData.startTime else {
			showErrorMessage(message: RequestSessionErrorType.startTimeNotChosen.rawValue)
			return
		}
		guard let duration = RequestSessionData.duration else {
			showErrorMessage(message: RequestSessionErrorType.durationNotChosen.rawValue)
			return
		}
		guard let price = RequestSessionData.price else {
			showErrorMessage(message: RequestSessionErrorType.priceNotChosen.rawValue)
			return
		}
		guard let sessionType = RequestSessionData.isOnline else {
			showErrorMessage(message: RequestSessionErrorType.sessionTypeNotChosen.rawValue)
			return
		}

		let endTime = startTime.adding(minutes: duration)

		sessionData["status"] = "pending"
		sessionData["type"] = sessionType ? "online" : "in-person"
		sessionData["expiration"] = getExpiration(endTime: endTime)
		sessionData["senderId"] = CurrentUser.shared.learner.uid
		sessionData["receiverId"] = chatPartnerId
		sessionData["subject"] = subject
		sessionData["date"] = startTime.timeIntervalSince1970
		sessionData["startTime"] = startTime.timeIntervalSince1970
		sessionData["endTime"] = endTime.timeIntervalSince1970
		sessionData["price"] = Double(price)
		
		let sessionRequest = SessionRequest(data: sessionData)
		DataService.shared.sendSessionRequestToId(sessionRequest: sessionRequest, chatPartnerId)
		self.removeFromSuperview()
		RequestSessionData.clearSessionData()
		if let current = UIApplication.getPresentedViewController() {
			current.becomeFirstResponder()
		}
	}
	
	func getExpiration(endTime: Date) -> TimeInterval {
		let difference = (endTime.timeIntervalSince1970 - Date().timeIntervalSince1970) / 2
		let expirationDate = Date().addingTimeInterval(difference)
		return expirationDate.timeIntervalSince1970
	}
	
	func showErrorMessage(message: String) {
		requestSessionMenu.cancelRequestView.errorLabel.isHidden = false
		requestSessionMenu.cancelRequestView.errorLabel.text = message
	}
	func hideErrorMessage() {
		requestSessionMenu.cancelRequestView.errorLabel.isHidden = true
	}
}

enum RequestSessionErrorType : String {
	case subjectNotChosen = "Please choose a subject for this session"
	case startTimeNotChosen = "Please choose a start time for this session"
	case durationNotChosen = "Please choose a duration for this session"
	case endTimeDurationError = "The total duration of a session must be atleast 15 minutes"
	case priceNotChosen = "Please choose a price for this session"
	case sessionTypeNotChosen = "Please choose a session type for this session"
}
