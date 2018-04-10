//
//  TutorPendingSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorPendingSessionCell: BasePendingSessionCell {
    
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "acceptSessionButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "declineSessionButton"), for: .normal)
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
    }
}
