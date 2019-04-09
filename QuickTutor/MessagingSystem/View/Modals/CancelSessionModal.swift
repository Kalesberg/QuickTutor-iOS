//
//  CancelSessionModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class CancelSessionModal: CustomModal {
    
    override func setupHeight() {
        setHeightTo(160)
    }
    
    override func setupNoteLabel() {
        background.addSubview(noteLabel)
        noteLabel.anchor(top: titleLabel.bottomAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 7, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 55)
        if AccountService.shared.currentUserType == .tutor {
            noteLabel.text = "Canceling sessions is not recommended. Please ensure you are not violating your own cancellation policy."
        }
    }

    override func handleConfirmButton() {
        delegate?.handleCancel(id: sessionId)
    }
}
