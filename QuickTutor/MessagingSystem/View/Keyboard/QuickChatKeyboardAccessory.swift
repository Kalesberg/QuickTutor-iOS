//
//  QuickChatKeyboardAccessory.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

//class QuickChatKeyboardAccessory: StudentKeyboardAccessory {
//    
//    var quickChatViewShown = false
//    
//    let chatView: QuickChatView = {
//        let chat = QuickChatView()
//        return chat
//    }()
//    
//    var quickChatBottomAnchor: NSLayoutConstraint?
//    
//    override func setupViews() {
//        super.setupViews()
//        setupQuickChatView()
//        toggleQuickChatView()
//    }
//    
//    private func setupQuickChatView() {
//        chatView.delegate = self
//
//        chatView.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
//        quickChatBottomAnchor = chatView.bottomAnchor.constraint(equalTo: messageTextview.bottomAnchor, constant: -45)
//        quickChatBottomAnchor?.isActive = true
//    }
//    
//    @objc func toggleQuickChatView() {
//        quickChatViewShown ? hideQuickChatView() : showQuickChatView()
//    }
//    
//    private func showQuickChatView() {
//        quickChatViewShown = true
//        messageFieldTopAnchor?.constant = 45
//        self.layoutIfNeeded()
//        quickChatBottomAnchor?.constant = -45
//        UIViewPropertyAnimator(duration: 0.15, curve: .easeOut, animations: {
//            self.layoutIfNeeded()
//        }).startAnimation()
//    }
//    
//    private func hideQuickChatView() {
//        quickChatViewShown = false
//        messageFieldTopAnchor?.constant = 8
//        self.layoutIfNeeded()
//        quickChatBottomAnchor?.constant = 8
//        UIViewPropertyAnimator(duration: 0.15, curve: .easeOut, animations: {
//            self.layoutIfNeeded()
//        }).startAnimation()
//    }
//}
//
//extension QuickChatKeyboardAccessory: QuickChatViewDelegate {
//    func sendMessage(text: String) {
//        messageTextview.text = text
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let timestamp = Date().timeIntervalSince1970
//        let message = UserMessage(dictionary: ["text": text, "timestamp": timestamp, "senderId": uid])
//        delegate?.handleMessageSend(message: message)
//        hideQuickChatView()
//    }
//}

