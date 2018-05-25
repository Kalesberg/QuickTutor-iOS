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
        
        socket.on(SocketEvents.manualStartAccetped) { (data, ack) in
            self.showConfirmMeetupButton()
        }
        
        socket.on(SocketEvents.meetupConfirmed) { (data, ack) in
            self.proceedToSession()
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
        vc.sessionId = self.sessionId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func updateTitleLabel() {
        guard let uid = Auth.auth().currentUser?.uid, let username = partnerUsername else { return }
        //In-person Automatic
        if startType == "automatic" && session?.type == "in-person" {
            self.titleLabel.text = "Time to meet up!"
        }
        
        //In-person Manual Started By Current User
        if startType == "manual" && session?.type == "in-person" && initiatorId == uid {
            self.titleLabel.text = "Time to meet up!"
            self.statusLabel.text = "Waiting for your partner to accept the manual start..."
            self.statusLabel.isHidden = false
        }
        
        //In-person Manual Started By Other User
        if startType == "manual" && session?.type == "in-person" && initiatorId != uid {
            titleLabel.text = "\(username) wants to meet up early!"
            self.confirmButton.isHidden = false
        }
    }
    
    override func confirmManualStart() {
        socket.emit(SocketEvents.manualStartAccetped, ["roomKey": sessionId!])
    }
    
    
    
    func showConfirmMeetupButton() {
        guard let uid = Auth.auth().currentUser?.uid, let id = session?.id, let partnerId = partnerId, !startAccepted else { return }
        messageButton.isHidden = false
        confirmButton.isHidden = false
        startAccepted = true
        confirmButton.removeTarget(self, action: #selector(confirmManualStart), for: .touchUpInside)
        confirmButton.setTitle("Confirm Meet Up", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmMeetup), for: .touchUpInside)
    }
    
    @objc func confirmMeetup() {
        statusLabel.text = "Waiting for your partner to confirm meet-up..."
        statusLabel.isHidden = false
        confirmButton.isHidden = true
        socket.emit(SocketEvents.meetupConfirmed, ["roomKey": sessionId!])
    }
    
}

