//
//  TutorPaymentEarnings.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/23/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorPaymentEarningsView : PaymentOptionsView {
    
    override func configureView() {
        super.configureView()
        
        cardBody.text = "Learners adding their debit card or credit card is the only way to pay for tutoring sessions for now.\n\nQuickTutor operates with Stripe API, which handle billions of dollars every year for forward-thinking businesses around the world. All you have to do is input your bank information once, and your earnings are directly distributed to you after sessions."
        
        cashBody.text = "QuickTutor is designed for a cashless exchange between two individuals. After each session, your earnings will be virtually deposited into your QuickTutor wallet. Your receipt is then emailed to you, and your sessions tab is updated under the “past” section with all the details regarding the session."
        
        gratuityBody.text = "You are aloud to ask for tips as a tutor. Learners tipping tutors is not required for sessions. Giving a tip is optional. Tips are added to the total of your earnings, and are still subject to the QuickTutor 10% or 7.5% service fee (depending on your hours completed). "
    }
}


class TutorPaymentEarnings : BaseViewController {
    
    override var contentView: TutorPaymentEarningsView {
        return view as! TutorPaymentEarningsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }
    
    override func loadView() {
        view = TutorPaymentEarningsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
