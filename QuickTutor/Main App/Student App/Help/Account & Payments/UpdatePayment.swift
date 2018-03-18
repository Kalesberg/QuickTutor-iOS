//
//  UpdatePayment.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class UpdatePaymentView : MainLayoutHeaderScroll {
    
    var addPaymentTitle = SectionTitle()
    var addPaymentBody = SectionBody()
    var scanCardTitle = SectionTitle()
    var scanCardBody = SectionBody()
    var updateCardTitle = SectionTitle()
    var updateCardBody = SectionBody()
    var strings: [String] = []
    
    override func configureView() {
        scrollView.addSubview(addPaymentTitle)
        scrollView.addSubview(addPaymentBody)
        scrollView.addSubview(scanCardBody)
        scrollView.addSubview(scanCardTitle)
        scrollView.addSubview(updateCardTitle)
        scrollView.addSubview(updateCardBody)
        super.configureView()
        
        title.label.text = "Payments & Earnings"
        header.label.text = "Updating a payment method"
        
        addPaymentTitle.label.text = "ADD A PAYMENT METHOD"
        
        strings = ["1.  Select Payment from the navigation bar menu.\n", "2.  Tap add payment method.\n", "3.  Add a payment method by scanning a card or manually entering card info."]
        
        let attributesDictionary = [NSAttributedStringKey.font : addPaymentBody.font]
        var fullAttributedString = NSMutableAttributedString(string: "Adding a payment method will allow you to connect, communicate and schedule sessions with tutors.\n\nYou can add payment methods such as debit or credit cards. When a session ends, your payment method is charged in accordance to the session price and length of the session.\n\n", attributes: attributesDictionary)
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        addPaymentBody.attributedText = fullAttributedString
        
        scanCardTitle.label.text = "SCAN A DEBIT OR CREDIT CARD"
        
        strings = ["1.  To scan a card, tap the camera icon. Your phone may ask permission for QuickTutor to use your camera.\n", "2.  Center your camera on the phone’s screen so that the entire card is visible and all four corners flash green.\n", "3.  Enter the card’s expiration date, CVV number, and billing ZIP or postal code."]
        
        fullAttributedString = NSMutableAttributedString(string: "", attributes: attributesDictionary)
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        scanCardBody.attributedText = fullAttributedString
        
        updateCardTitle.label.text = "UPDATING CARD INFO"
        
        strings = ["1.  Select “Payment” from your app menu.\n", "2.  Select the payment option you’d like to update.\n", "3.  Make changes, then tap save when you’re done.\n\n"]
        
        fullAttributedString = NSMutableAttributedString(string: "", attributes: attributesDictionary)
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        updateCardBody.attributedText = fullAttributedString
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        addPaymentTitle.constrainSelf(top: header.snp.bottom)
        
        addPaymentBody.constrainSelf(top: addPaymentTitle.snp.bottom)
        
        scanCardTitle.constrainSelf(top: addPaymentBody.snp.bottom)
        
        scanCardBody.constrainSelf(top: scanCardTitle.snp.bottom)
        
        updateCardTitle.constrainSelf(top: scanCardBody.snp.bottom)
        
        updateCardBody.constrainSelf(top: updateCardTitle.snp.bottom)
    }
}


class UpdatePayment : BaseViewController {
    
    override var contentView: UpdatePaymentView {
        return view as! UpdatePaymentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }
    
    override func loadView() {
        view = UpdatePaymentView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        
    }
}
