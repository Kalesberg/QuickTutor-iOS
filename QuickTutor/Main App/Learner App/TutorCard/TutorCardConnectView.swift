//
//  TutorCardConnectView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorCardConnectView: CardFooterView {
    
    let accessoryView: TutorCardAccessoryView = {
        let view = TutorCardAccessoryView()
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        leftAccessoryView = accessoryView
    }
}
