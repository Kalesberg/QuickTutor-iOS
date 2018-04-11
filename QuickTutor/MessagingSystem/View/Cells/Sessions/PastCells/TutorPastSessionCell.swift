//
//  TutorPastSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorPastSessionCell: BasePastSessionCell, MessageButtonDelegate, RequestSessionButtonDelegate {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsDoubleButton()
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "viewProfileButton"), for: .normal)
    }
    
    
    override func handleButton1() {
        showConversationWithUID(session.partnerId())
    }
    override func handleButton2() {
        let vc = ViewFullProfile()
        navigationController.pushViewController(vc, animated: true)
    }
    
}
