//
//  ReadReceiptManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import Foundation

class ReadReceiptManager {
    
    var receiverId: String
    var delegate: ReadReceiptManagerDelegate?

    func listenForReadReceipts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(receiverId).child("readBy").observe(.value) { snapshot in
            guard let readByIds = snapshot.value as? [String: Any] else { return }
            self.delegate?.readReceiptManager(self, didUpdate: Array(readByIds.keys))
        }
    }

    func markConversationRead() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(receiverId).child("readBy").child(uid).setValue(true)
        Database.database().reference().child("conversationMetaData").child(receiverId).child(otherUserTypeString).child(uid).child("readBy").child(uid).setValue(true)
    }

    func invalidateReadReceipt() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(receiverId).child("readBy").child(uid).setValue(false)
        Database.database().reference().child("conversationMetaData").child(receiverId).child(otherUserTypeString).child(uid).child("readBy").child(uid).setValue(false)
    }

    init(receiverId: String) {
        self.receiverId = receiverId
        listenForReadReceipts()
    }
}
