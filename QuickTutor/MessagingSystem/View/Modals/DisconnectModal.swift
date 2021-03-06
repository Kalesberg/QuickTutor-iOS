//
//  DisconnectModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

class DisconnectModal: CustomModal {
    var partnerId: String?

    override func handleConfirmButton() {
        guard let uid = Auth.auth().currentUser?.uid, let partnerId = partnerId else { return }
        NotificationCenter.default.post(name: Notifications.didDisconnect.name, object: nil)
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        let conversationRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(partnerId)
        Database.database().reference().child("connections").child(uid).child(userTypeString).child(partnerId).removeValue()
        Database.database().reference().child("connections").child(partnerId).child(otherUserTypeString).child(uid).removeValue()
        conversationRef.removeValue()
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(partnerId).removeValue()
        dismiss()
    }
}
