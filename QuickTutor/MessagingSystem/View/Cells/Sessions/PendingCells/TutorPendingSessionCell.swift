//
//  TutorPendingSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class TutorPendingSessionCell: BasePendingSessionCell, MessageButtonDelegate {
    
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "acceptButtonText"), for: .normal)
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "declineButtonText"), for: .normal)
    }
    
    override func handleButton1() {
        showConversationWithUID(session.partnerId())
    }
    
    override func handleButton2() {
        Database.database().reference().child("sessions").child(session.id).child("status").setValue("accepted")
        markSessionDataStale()
    }
    
    override func handleButton3() {
        Database.database().reference().child("sessions").child(session.id).child("status").setValue("declined")
        markSessionDataStale()
    }
    
    func markSessionDataStale() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        Database.database().reference().child("userSessions").child(uid)
            .child(userTypeString).child(session.id).setValue(0)
        Database.database().reference().child("userSessions").child(session.partnerId())
            .child(otherUserTypeString).child(session.id).setValue(0)
    }
}
