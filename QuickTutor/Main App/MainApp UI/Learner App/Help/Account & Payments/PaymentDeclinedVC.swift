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
    var paymentDeclinedBody = SectionBody()
    var paymentDeclinedBody2 = SectionBody()
    var strings: [String] = []

    override func configureView() {
        addSubview(paymentDeclinedBody)
        addSubview(paymentDeclinedBody2)
        super.configureView()

        title.label.text = "Help"
        header.text = "Why was my payment declined?"

        strings = ["•  “Card Declined”.\n", "•  “Payment method invalid. Please review your settings.”\n", "•  “Transaction error.”"]

        let attributesDictionary: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: paymentDeclinedBody.font]
        let fullAttributedString = NSMutableAttributedString(string: "You’ll be unable to request a session with a tutor if your payment for a past session was declined by your debit or credit card.\n\nIf one of the following error messages was displayed when you attempted to request a session, your payment method may have declined the transaction.\n\n", attributes: attributesDictionary)

        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)

            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))

            fullAttributedString.append(attributedString)
        }

        paymentDeclinedBody.attributedText = fullAttributedString

        paymentDeclinedBody2.text = "\nMost of the time, adding a new payment method may resolve the issue. Just in case that doesn’t work, we have listed some additional possible scenarios that may be occurring so you can better resolve the issue."
    }

    override func applyConstraints() {
        super.applyConstraints()

        paymentDeclinedBody.constrainSelf(top: header.snp.bottom)
        paymentDeclinedBody2.constrainSelf(top: paymentDeclinedBody.snp.bottom)
    }
}

class PaymentDeclinedVC: BaseViewController {
    override var contentView: PaymentDeclinedView {
        return view as! PaymentDeclinedView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
