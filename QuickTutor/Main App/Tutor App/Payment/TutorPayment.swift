//
//  Payment.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorPaymentView : MainLayoutTitleBackButton {
    
    override func configureView() {
        super.configureView()
        
        title.label.text = "Payment"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
    }
    
}

class TutorPayment : BaseViewController {
    
    override var contentView: TutorPaymentView {
        return view as! TutorPaymentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func loadView() {
        view = TutorPaymentView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func handleNavigation() {
        
    }
}
