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
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "declineSessionButton"), for: .normal)
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "acceptSessionButton"), for: .normal)
    }
    
    override func handleButton1() {
        showConversationWithUID(session.partnerId())
    }
    
    override func handleButton2() {
        Database.database().reference().child("sessions").child(session.id).child("status").setValue("declined")
    }
    
    override func handleButton3() {
        Database.database().reference().child("sessions").child(session.id).child("status").setValue("accepted")
    }
}
