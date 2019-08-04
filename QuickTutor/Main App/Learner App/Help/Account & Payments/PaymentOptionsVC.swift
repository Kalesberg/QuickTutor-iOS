//
//  PaymentOptions.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class PaymentOptionsView: MainLayoutHeaderScroll {
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

        header.label.text = "Payment options"

        cardTitle.label.text = "Debit and Credit Card"
        let attributesDictionary: [NSAttributedString.Key: Any] = [.font: cardBody.font]
        let fullAttributedString = NSMutableAttributedString(string: "QuickTutor operates with Stripe API, which handles billions of dollars every year for forward-thinking businesses around the world. Entering your debit and credit card information is always a safe and secure way to pay for anything on QuickTutor.", attributes: attributesDictionary)
        cardBody.attributedText = fullAttributedString

        cashTitle.label.text = "Apple Pay"
        cashBody.text = "QuickTutor is also Apple Pay integrated, allowing you to use your Apple Wallet to pay for anything on QuickTutor."

        gratuityTitle.label.text = "Cash & Gratuity"
        gratuityBody.text = "QuickTutor is a cashless experience. To avoid fraud and numerous potential discrepancies, do not pay tutors for their services outside of the app. However, feel free to tip your tutor with cash after in-person learning sessions."
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

class PaymentOptionsVC: BaseViewController {
    override var contentView: PaymentOptionsView {
        return view as! PaymentOptionsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Payment options"
        contentView.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = PaymentOptionsView()
    }

    override func handleNavigation() {}
}
