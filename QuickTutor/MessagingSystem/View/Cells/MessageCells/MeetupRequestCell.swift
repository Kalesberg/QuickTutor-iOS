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
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "You requested a meet up"
        label.font = Fonts.createBoldSize(16)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(15)
        return label
    }()
    
    let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(12)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .green
        label.textAlignment = .right
        label.font = Fonts.createSize(12)
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(16)
        return label
    }()
    
    let statusBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1E1E25")
        return view
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "confirmButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.tag = 0
        return button
    }()
    
    let declineButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "cancelButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.tag = 1
        return button
    }()
    
    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        getSessionRequestWithId(message.sessionRequestId!)
        guard let id = Auth.auth().currentUser?.uid else { return }
        if message.senderId != id {
            setupAsTeacherView()
        }
    }
    
    func getSessionRequestWithId(_ id: String) {
        guard sessionCache[id] == nil else {
            print("this one has already be loaded")
            sessionRequest = sessionCache[id]
            loadFromRequest()
            return
        }
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
        guard let subject = sessionRequest?.subject, let price = sessionRequest?.price, let date = sessionRequest?.formattedDate(), let startTime = sessionRequest?.formattedStartTime() else { return }
        subjectLabel.text = subject
        priceLabel.text = "$\(price)0"
        dateTimeLabel.text = "\(date) @ \(startTime)"
        setStatusLabel()
    }
    
    func setStatusLabel() {
        guard let status = self.sessionRequest?.status else { return }
        switch status {
        case "pending":
            statusLabel.text = "REQUEST PENDING"
        case "declined":
            statusLabel.text = "DECLINED"
        case "accepted":
            statusLabel.text = "ACCEPTED"
        case "expired":
            statusLabel.text = "EXPIRED"
        default:
            break
        }
    }
    
    override func setupViews() {
        super.setupViews()
        setupTitleLabel()
        setupSubjectLabel()
        setupDateTimeLabel()
        setupPriceLabel()
        setupStatusBackground()
        setupStatusLabel()
        
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 35)
    }
    
    private func setupSubjectLabel() {
        addSubview(subjectLabel)
        subjectLabel.anchor(top: titleLabel.bottomAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    private func setupDateTimeLabel() {
        addSubview(dateTimeLabel)
        dateTimeLabel.anchor(top: subjectLabel.bottomAnchor, left: bubbleView.leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 140, height: 20)
    }
    
    private func setupPriceLabel() {
        addSubview(priceLabel)
        priceLabel.anchor(top: subjectLabel.bottomAnchor, left: nil, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 80, height: 20)
    }
    
    private func setupStatusBackground() {
        addSubview(statusBackground)
        statusBackground.anchor(top: dateTimeLabel.bottomAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupStatusLabel() {
        statusBackground.addSubview(statusLabel)
        statusLabel.anchor(top: statusBackground.topAnchor, left: statusBackground.leftAnchor, bottom: statusBackground.bottomAnchor, right: statusBackground.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupAsTeacherView() {
        titleLabel.text = "You received a session request"
        guard sessionRequest?.status == "pending" else {
            return
        }
        addSubview(acceptButton)
        acceptButton.anchor(top: statusBackground.topAnchor, left: statusBackground.leftAnchor, bottom: statusBackground.bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 20, paddingBottom: 4, paddingRight: 0, width: 35, height: 0)
        acceptButton.addTarget(self, action: #selector(handleButtonAction(sender:)), for: .touchUpInside)
        
        addSubview(declineButton)
        declineButton.anchor(top: statusBackground.topAnchor, left: nil, bottom: statusBackground.bottomAnchor, right: statusBackground.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 4, paddingRight: 20, width: 35, height: 0)
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
