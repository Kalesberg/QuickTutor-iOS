//
//  SessionRequestCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class SessionRequestCell: UserMessageCell {
    
    var sessionRequest: SessionRequest?
    var userMessage: UserMessage?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "You requested a session"
        label.font = Fonts.createBoldSize(16)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let titleBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 60.0/255.0, green: 54.0/255.0, blue: 88.0/255.0, alpha: 1.0)
        return view
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(15)
        return label
    }()
    
    let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(12)
        label.numberOfLines = 0
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = Colors.green
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.font = Fonts.createSize(12)
        label.clipsToBounds = true
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(16)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let statusBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1E1E25")
        return view
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("Accept", for: .normal)
        button.setTitleColor(Colors.green, for: .normal)
        button.tag = 0
        button.backgroundColor = Colors.navBarColor
        button.titleLabel?.font = Fonts.createBoldSize(12)
        if #available(iOS 11.0, *) {
            button.layer.cornerRadius = 4
            button.layer.maskedCorners = [.layerMaxXMaxYCorner]
        }
        return button
    }()
    
    let declineButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(Colors.qtRed, for: .normal)
        button.setTitle("Decline", for: .normal)
        button.tag = 1
        button.backgroundColor = Colors.navBarColor
        button.titleLabel?.font = Fonts.createBoldSize(12)
        if #available(iOS 11.0, *) {
            button.layer.cornerRadius = 4
            button.layer.maskedCorners = [.layerMinXMaxYCorner]
        }
        return button
    }()
    
    var priceLabelWidthAnchor: NSLayoutConstraint?
    
    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        getSessionRequestWithId(message.sessionRequestId!)
        self.userMessage = message
    }
    
    func getSessionRequestWithId(_ id: String) {
//        guard sessionCache[id] == nil else {
//            print("this one has already be loaded")
//            sessionRequest = sessionCache[id]
//            loadFromRequest()
//            return
//        }
        Database.database().reference().child("sessions").child(id).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let sessionRequest = SessionRequest(data: value)
            sessionRequest.id = id
            self.sessionRequest = sessionRequest
            self.loadFromRequest()
            sessionCache[id] = sessionRequest
        }
    }
    
    func loadFromRequest() {
        guard let subject = sessionRequest?.subject, let price = sessionRequest?.price, let date = sessionRequest?.formattedDate(), let startTime = sessionRequest?.formattedStartTime(), let endTime = sessionRequest?.formattedEndTime() else { return }
        subjectLabel.text = subject
        priceLabel.text = "$\(price)0"
        dateTimeLabel.text = "\(date) \n\(startTime) - \(endTime)"
        setStatusLabel()
        if let constant = priceLabel.text?.estimateFrameForFontSize(12).width {
            priceLabelWidthAnchor = priceLabel.widthAnchor.constraint(equalToConstant: constant + 15)
            priceLabelWidthAnchor?.isActive = true
            self.layoutIfNeeded()
        }
        guard let id = Auth.auth().currentUser?.uid else { return }
        if self.userMessage?.senderId != id {
            setupAsTeacherView()
        }
    }
    
    func setStatusLabel() {
        guard let status = self.sessionRequest?.status else { return }
        switch status {
        case "pending":
            statusLabel.text = "Session Request Pending"
        case "declined":
            statusLabel.text = "Session Request Declines"
        case "accepted":
            statusLabel.text = "Session Request Accepted"
        case "expired":
            statusLabel.text = "Session Request Expired"
        case "cancelled":
            statusLabel.text = "Session Request Cancelled"
        default:
            break
        }
    }
    
    override func setupViews() {
        super.setupViews()
        setupMainView()
        setupTitleLabel()
        setupTitleBackground()
        setupSubjectLabel()
        setupDateTimeLabel()
        setupPriceLabel()
        setupStatusBackground()
        setupStatusLabel()
    }
    
    private func setupMainView() {
        bubbleView.clipsToBounds = true
        bubbleView.layer.cornerRadius = 8
        bubbleView.backgroundColor = Colors.learnerPurple
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 35)
    }
    
    private func setupTitleBackground() {
        insertSubview(titleBackground, belowSubview: titleLabel)
        titleBackground.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 35)
    }
    
    private func setupSubjectLabel() {
        addSubview(subjectLabel)
        subjectLabel.anchor(top: titleLabel.bottomAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 18)
    }
    
    private func setupDateTimeLabel() {
        addSubview(dateTimeLabel)
        dateTimeLabel.anchor(top: subjectLabel.bottomAnchor, left: bubbleView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 140, height: 40)
    }
    
    private func setupPriceLabel() {
        addSubview(priceLabel)
        priceLabel.anchor(top: titleLabel.bottomAnchor, left: nil, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 26, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 20)
    }
    
    private func setupStatusBackground() {
        addSubview(statusBackground)
        statusBackground.anchor(top: dateTimeLabel.bottomAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupStatusLabel() {
        statusBackground.addSubview(statusLabel)
        statusLabel.anchor(top: statusBackground.topAnchor, left: statusBackground.leftAnchor, bottom: statusBackground.bottomAnchor, right: statusBackground.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    }
    
    func setupAsTeacherView() {
        titleLabel.text = "You received a session request"
        guard sessionRequest?.status == "pending" else {
            return
        }
        addSubview(acceptButton)
        addSubview(acceptButton)
        acceptButton.anchor(top: nil, left: nil, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 109.5, height: 40)
        acceptButton.addTarget(self, action: #selector(handleButtonAction(sender:)), for: .touchUpInside)
        
        addSubview(declineButton)
        addSubview(declineButton)
        declineButton.anchor(top: nil, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 109.5, height: 40)
        acceptButton.addTarget(self, action: #selector(handleButtonAction(sender:)), for: .touchUpInside)
        statusLabel.isHidden = true
    }
    
    @objc func handleButtonAction(sender: UIButton) {
        guard let sessionRequestId = self.sessionRequest?.id, sessionRequest?.status == "pending" else { return }
        let valueToSet = sender.tag == 0 ? "accepted" : "declined"
        Database.database().reference().child("sessions").child(sessionRequestId).child("status").setValue(valueToSet)
        sessionCache.removeValue(forKey: sessionRequestId)
        
        acceptButton.isHidden = true
        declineButton.isHidden = true
        statusLabel.isHidden = false
        statusLabel.text = sender.tag == 0 ? "ACCEPTED" : "DECLINED"
    }
    
    
    
}
