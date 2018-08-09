//
//  DisconnectModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class DisconnectModal: CustomModal {
    
    var partnerId: String?
    
    override func handleConfirmButton() {
        guard let uid = Auth.auth().currentUser?.uid, let partnerId = partnerId else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let conversationRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(partnerId)
        Database.database().reference().child("connections").child(uid).child(partnerId).removeValue()
        Database.database().reference().child("connections").child(partnerId).child(uid).removeValue()
        conversationRef.removeValue()
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(partnerId).removeValue()
        dismiss()
    }
}

