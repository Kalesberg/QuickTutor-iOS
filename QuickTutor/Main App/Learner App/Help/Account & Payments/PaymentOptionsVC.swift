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

        header.label.text = "Payments and earnings"

        cardTitle.label.text = "DEBIT AND CREDIT CARD"
        cardBody.text = "Learners adding their debit or credit card is the only way to pay for tutoring sessions for now.\n\nQuickTutor operates with Stripe API, which handles billions of dollars every year for forward-thinking businesses around the world. All you have to do is input your bank information once, and your earnings as a tutor are directly distributed to you after sessions."

        cashTitle.label.text = "CASH"
        cashBody.text = "QuickTutor is designed for a cashless exchange between two individuals. After each session, your earnings will be virtually deposited into your bank account. Your receipt will then emailed to you, and your sessions tab is updated under the “past” section with all the details regarding the session."

        gratuityTitle.label.text = "GRATUITY"
        gratuityBody.text = "You are allowed to ask for tips as a tutor. Learners tipping tutors is not required after a session. Tipping a tutor is entirely optional. Tips are added to the total of the session. Tips are subject to our 10% or 7.5% service fee (depending on your hours completed). \n\n"
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
        navigationItem.title = "Help"
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = PaymentOptionsView()
    }

    override func handleNavigation() {}
}
