//
//  BaseUpcomingSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

class BaseUpcomingSessionCell: BaseSessionCell, MessageButtonDelegate, CancelSessionButtonDelegate {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()

        let cancelSessionImage = AccountService.shared.currentUserType == .learner ? #imageLiteral(resourceName: "cancelSessionButton") : #imageLiteral(resourceName: "cancelSessionWhiteTutor")
        let startSessionImage = AccountService.shared.currentUserType == .learner ? #imageLiteral(resourceName: "startSessionButton") : #imageLiteral(resourceName: "startSessionButtonTutor")
        let messageButtomimage = AccountService.shared.currentUserType == .learner ? #imageLiteral(resourceName: "messageButton") : #imageLiteral(resourceName: "messageButtonWhiteTutor")
        actionView.actionButton3.setImage(cancelSessionImage, for: .normal)
        actionView.actionButton2.setImage(startSessionImage, for: .normal)
        actionView.actionButton1.setImage(messageButtomimage, for: .normal)
    }

    override func handleButton1() {
        showConversationWithUID(session.partnerId())
    }

    override func handleButton2() {
        startSession()
    }

    override func handleButton3() {
        cancelSession(id: session.id)
        delegate?.sessionCell(self, shouldReloadSessionWith: session.id)
    }

    func startSession() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let value = ["startedBy": uid, "startType": "manual", "sessionType": session.type]
        Database.database().reference().child("sessionStarts").child(uid).child(session.id).setValue(value)
        Database.database().reference().child("sessionStarts").child(session.partnerId()).child(session.id).setValue(value)
    }
}
