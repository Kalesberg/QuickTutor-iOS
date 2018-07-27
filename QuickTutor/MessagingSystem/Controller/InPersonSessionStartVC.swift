//
//  InPersonSessionStartVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import SocketIO

class InpersonSessionStartVC: BaseSessionStartVC, MessageButtonDelegate {
    
    var startAccepted = false
    var confirmedByParnter = false
    var confirmedByUser = false
    
    let messageButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Message", for: .normal)
        button.setTitleColor(Colors.learnerPurple, for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = Colors.learnerPurple.cgColor
        button.titleLabel?.font = Fonts.createSize(16)
        button.layer.cornerRadius = 4
        button.backgroundColor = Colors.navBarColor
        button.isHidden = true
        return button
    }()
    
    
    override func setupViews() {
        super.setupViews()
        socket = SocketClient.shared.socket
        setupMessageButton()
        setupObservers()
    }
    
    func setupMessageButton() {
        view.addSubview(messageButton)
        messageButton.anchor(top: receieverBox.bottomAnchor, left: receieverBox.leftAnchor, bottom: nil, right: receieverBox.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 35)
        messageButton.addTarget(self, action: #selector(handleMessageButton), for: .touchUpInside)
    }
    
    @objc func handleMessageButton() {
        guard let partnerId = session?.partnerId() else { return }
        showConversationWithUID(partnerId)
    }
    
    func setupObservers() {
        
        socket.on(SocketEvents.manualStartAccetped) { _, _ in
            self.showConfirmMeetupButton()
        }
        
        socket.on(SocketEvents.meetupConfirmed) { (data, ack) in
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let value = data[0] as? [String: Any] else { return }
            if let confirmedBy = value["confirmedBy"] as? String {
                if confirmedBy != uid {
                    self.confirmedByParnter = true
                } else {
                    self.confirmedByUser = true
                }
                
                if self.confirmedByUser && self.confirmedByParnter {
                    self.proceedToSession()
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(pushConversationVC(notification:)), name: NSNotification.Name(rawValue: "sendMessage"), object: nil)
        
    }
    
    @objc func pushConversationVC(notification: Notification) {
        guard let userInfo = notification.userInfo, let uid = userInfo["uid"] as? String else { return }
        let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.receiverId = uid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func proceedToSession() {
        let vc = InPersonSessionVC()
        vc.sessionId = sessionId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func updateTitleLabel() {
        guard let uid = Auth.auth().currentUser?.uid, let username = partnerUsername else { return }
        // In-person Automatic
        if startType == "automatic" && session?.type == "in-person" {
            titleLabel.text = "Time to meet up!"
        }
        
        // In-person Manual Started By Current User
        if startType == "manual" && session?.type == "in-person" && initiatorId == uid {
            titleLabel.text = "Time to meet up!"
            let userType = AccountService.shared.currentUserType == .learner ? "tutor" : "learner"
            statusLabel.text = "Waiting for your \(userType) to accept the manual start..."
            statusLabel.isHidden = false
        }
        
        // In-person Manual Started By Other User
        if startType == "manual" && session?.type == "in-person" && initiatorId != uid {
            titleLabel.text = "\(username) wants to meet up early!"
            confirmButton.isHidden = false
        }
    }
    
    override func confirmManualStart() {
        checkPermissions()
        removeStartData()
        socket.emit(SocketEvents.manualStartAccetped, ["roomKey": sessionId!])
    }
    
    func showConfirmMeetupButton() {
        guard let _ = Auth.auth().currentUser?.uid, let _ = session?.id, let _ = partnerId, !startAccepted else { return }
        messageButton.isHidden = false
        confirmButton.isHidden = false
        startAccepted = true
        confirmButton.removeTarget(self, action: #selector(confirmManualStart), for: .touchUpInside)
        confirmButton.setTitle("Confirm Meet Up", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmMeetup), for: .touchUpInside)
    }
    
    @objc func confirmMeetup() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userType = AccountService.shared.currentUserType == .learner ? "tutor" : "learner"
        statusLabel.text = "Waiting for your \(userType) to confirm meet-up..."
        statusLabel.isHidden = false
        confirmButton.isHidden = true
        socket.emit(SocketEvents.meetupConfirmed, ["roomKey": sessionId!, "confirmedBy": uid])
    }
    
}
