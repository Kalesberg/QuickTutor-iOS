//
//  TutorPayment.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/29/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorPayment : BaseViewController {
    
    override var contentView: TutorRegPaymentView {
        return view as! TutorRegPaymentView
    }
    
    override func loadView() {
        view = TutorRegPaymentView()
    }
    
    override func handleNavigation() {
      
    }
}
