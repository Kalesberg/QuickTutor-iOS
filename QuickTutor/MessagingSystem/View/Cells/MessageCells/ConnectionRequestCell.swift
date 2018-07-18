//
//  ConnectionRequestCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/6/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class ConnectionRequestCell: UserMessageCell {
    
    var status: String?
    var connectionRequestId: String?
    var userMessage: UserMessage?
    
    let actionBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1E1E25")
        if #available(iOS 11.0, *) {
            view.layer.cornerRadius = 4
            view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        return view
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(16)
        label.text = "Connection Request Pending"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("Accept", for: .normal)
        button.setTitleColor(Colors.green, for: .normal)
        button.tag = 0
        button.isHidden = true
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
        button.isHidden = true
        button.backgroundColor = Colors.navBarColor
        button.titleLabel?.font = Fonts.createBoldSize(12)
        if #available(iOS 11.0, *) {
            button.layer.cornerRadius = 4
            button.layer.maskedCorners = [.layerMinXMaxYCorner]
        }
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        setupActionBackground()
        setupStatusLabel()
        setupAcceptButton()
        setupDeclineButton()
        if #available(iOS 11.0, *) {
            bubbleView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        self.userMessage = message
        if message.senderId != AccountService.shared.currentUser.uid! && status == "pending" {
            setupForTeacherView()
        }
        
        guard let requestId = message.connectionRequestId else { return }
        self.connectionRequestId = requestId
        loadFromRequest()
    }
    
    private func setupActionBackground() {
        addSubview(actionBackground)
        actionBackground.anchor(top: nil, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
    }
    
    private func setupStatusLabel() {
        addSubview(statusLabel)
        statusLabel.anchor(top: actionBackground.topAnchor, left: actionBackground.leftAnchor, bottom: actionBackground.bottomAnchor, right: actionBackground.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    }
    
    func setupAcceptButton() {
        addSubview(acceptButton)
        acceptButton.anchor(top: nil, left: nil, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 109.5, height: 40)
        acceptButton.addTarget(self, action: #selector(approveConnectionRequest), for: .touchUpInside)
    }
    
    func setupDeclineButton() {
        addSubview(declineButton)
        declineButton.anchor(top: nil, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 109.5, height: 40)
        declineButton.addTarget(self, action: #selector(denyConnectionRequest), for: .touchUpInside)
    }
    
    func setupForTeacherView() {
        statusLabel.isHidden = true
        acceptButton.isHidden = false
        declineButton.isHidden = false
    }
    
    func loadFromRequest() {
        guard let id = connectionRequestId else { return }
        Database.database().reference().child("connectionRequests").child(id).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                return
            }
            guard let status = value["status"] as? String else { return }
            self.status = status
            self.setStatusLabel()
        }
    }
    
    @objc func approveConnectionRequest() {
        guard let id = connectionRequestId else { return }
        guard let uid = Auth.auth().currentUser?.uid, let receiverId = chatPartner?.uid else { return }
        Database.database().reference().child("connectionRequests").child(id).child("status").setValue("accepted")
        let values = ["/\(uid)/\(receiverId)": 1, "/\(receiverId)/\(uid)": 1]
        Database.database().reference().child("connections").updateChildValues(values)
        acceptButton.isHidden = true
        declineButton.isHidden = true
        statusLabel.isHidden = false
        self.status = "accepted"
        setStatusLabel()
    }
    
    @objc func denyConnectionRequest() {
        guard let id = connectionRequestId else { return }
        Database.database().reference().child("connectionRequests").child(id).child("status").setValue("declined")
        acceptButton.isHidden = true
        declineButton.isHidden = true
        statusLabel.isHidden = false
        self.status = "declined"
        setStatusLabel()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        guard let partnerId = chatPartner?.uid else { return }
        Database.database().reference().child("conversations").child(userTypeString).child(uid).child(partnerId).removeValue()
        Database.database().reference().child("conversations").child(otherUserTypeString).child(partnerId).child(id).removeValue()
    }
    
    func setStatusLabel() {
        guard let status = self.status else { return }
        
        if status == "pending" {
            showActionButtons()
        } else {
            hideActionButtons()
        }
        switch status {
        case "pending":
            break
        case "declined":
            statusLabel.text = "Connection Request Declined"
        case "accepted":
            statusLabel.text = "Connection Request Accepted"
        case "expired":
            statusLabel.text = "Connection Request Expired"
        default:
            break
        }
    }
    
    func showActionButtons() {
        guard self.userMessage?.senderId != AccountService.shared.currentUser.uid else { return }
        acceptButton.isHidden = false
        declineButton.isHidden = false
        statusLabel.isHidden = true
    }
    
    func hideActionButtons() {
        acceptButton.isHidden = true
        declineButton.isHidden = true
        statusLabel.isHidden = false
    }
    
}

