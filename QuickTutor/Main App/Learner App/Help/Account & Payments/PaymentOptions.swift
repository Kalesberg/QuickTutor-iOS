//
//  PaymentOptions.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class PaymentOptionsView : MainLayoutHeaderScroll {
    
    var cardTitle = SectionTitle()
    var cardBody = SectionBody()
    var cashTitle = SectionTitle()
    var cashBody = SectionBody()
    var gratuityTitle = SectionTitle()
    var gratuityBody = SectionBody()
    
    override func configureView() {
        scrollView.addSubview(cardTitle)
        scrollView.addSubview(cardBody)
        scrollView.addSubview(cashTitle)
        scrollView.addSubview(cashBody)
        scrollView.addSubview(gratuityTitle)
        scrollView.addSubview(gratuityBody)
        super.configureView()
        
        title.label.text = "Help"
        header.label.text = "Payment Options"
        
        cardTitle.label.text = "DEBIT AND CREDIT CARD"
        cardBody.text = "Adding a debit card or credit card is the only way to pay for tutoring sessions for now. Adding a payment method in the form of a debit or credit card will allow you to connect, communicate and schedule sessions with tutors.\n\nQuickTutor is free to download and use. You must enter a payment method to participate in tutoring sessions. Most often -- tutoring sessions will cost you money. You will not be charged when you schedule a tutoring session — you are charged after a tutoring session, for the time that you used. Therefore, if you schedule a sixty-minute session for $60.00 and leave after 30 mins, your payment method will only be charged $30.00. Easy as pie.\n\nQuickTutor operates with Stripe API, which handle billions of dollars every year for forward-thinking businesses around the world. All you have to do is input your card information once, and payments are directly distributed to tutors after sessions."
        
        cashTitle.label.text = "CASH"
        cashBody.text = "QuickTutor is designed for a cashless exchange between two individuals. Your payment method is charged immediately following the end of a session. Your receipt is emailed to you, and your sessions tab is updated under “Past” with all the details regarding the session. "
        
        gratuityTitle.label.text = "GRATUITY"
        gratuityBody.text = "Tipping tutors is not required for sessions. Giving a tip is optional.\n\n"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        cardTitle.constrainSelf(top: header.snp.bottom)
        
        cardBody.constrainSelf(top: cardTitle.snp.bottom)
        
        cashTitle.constrainSelf(top: cardBody.snp.bottom)
        
        cashBody.constrainSelf(top: cashTitle.snp.bottom)
        
        gratuityTitle.constrainSelf(top: cashBody.snp.bottom)
        
        gratuityBody.constrainSelf(top: gratuityTitle.snp.bottom)
    }
}


class PaymentOptions : BaseViewController {
    
    override var contentView: PaymentOptionsView {
        return view as! PaymentOptionsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }
    
    override func loadView() {
        view = PaymentOptionsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        
    }
}

