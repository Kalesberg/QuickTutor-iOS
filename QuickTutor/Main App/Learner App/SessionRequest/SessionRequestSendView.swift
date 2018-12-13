//
//  SessionRequestSendView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SessionRequestSendView: CardFooterView {
    
    let accessoryView: SessionRequestErrorAccessoryView = {
        let view = SessionRequestErrorAccessoryView()
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        leftAccessoryView = accessoryView
        connectButton.setTitle("SEND REQUEST", for: .normal)
    }
}

