//
//  PaymentDeclined.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class PaymentDeclinedView: MainLayoutHeader {
    var debitCardTitle = SectionTitle()
    var debitCardBody = SectionBody()
    var applePayTitle = SectionTitle()
    var applePayBody = SectionBody()
    
    var strings: [String] = []

    override func configureView() {
        addSubview(debitCardTitle)
        addSubview(debitCardBody)
        addSubview(applePayTitle)
        addSubview(applePayBody)
        
        super.configureView()

        header.text = "Why was my payment declined?"
        debitCardTitle.label.text = "Debit/Credit Card"
        debitCardBody.text = "You will be unable to add a payment method on file or receive any in-app services (sessions, calls, in-app features, products if your debit/credit card is invalid."
        
        applePayTitle.label.text = "Apple Pay"
        let attributesDictionary: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: applePayBody.font]
        let fullAttributedString = NSMutableAttributedString(string: "You will be unable to facilitate transactions if your Apple Pay payment method is not verified with your bank. Please check your Wallet app or contact your financial institution regarding any issues with your Apple Pay payment method.\n\nIf one of the following error messages was displayed when you attempted to add a payment method or pay for a session, your payment method may have declined the verification or transaction.\n\n", attributes: attributesDictionary)
        
        strings = ["1.  Card declined.\n",
            "2.  Payment method invalid. Please review your settings.\n",
            "3.  Transaction error.\n",
            "4.  Payment method invalid.\n",
            "5.  Sorry, invalid card data. Please try again!\n\n"]

        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)

            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))

            fullAttributedString.append(attributedString)
        }
        
        fullAttributedString.append(NSAttributedString(string: "Most of the time, adding a new payment method will resolve your issues.", attributes: attributesDictionary))
        applePayBody.attributedText = fullAttributedString
    }

    override func applyConstraints() {
        super.applyConstraints()

        debitCardTitle.constrainSelf(top: header.snp.bottom)
        debitCardBody.constrainSelf(top: debitCardTitle.snp.bottom)
        applePayTitle.constrainSelf(top: debitCardBody.snp.bottom)
        applePayBody.constrainSelf(top: applePayTitle.snp.bottom)
    }
}

class PaymentDeclinedVC: BaseViewController {
    override var contentView: PaymentDeclinedView {
        return view as! PaymentDeclinedView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Payment declined"
    }

    override func loadView() {
        view = PaymentDeclinedView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func handleNavigation() {}
}
