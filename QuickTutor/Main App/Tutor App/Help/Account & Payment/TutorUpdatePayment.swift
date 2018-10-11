//
//  TutorUpdatePayment.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/23/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import Foundation
import UIKit

class TutorUpdatePaymentView: MainLayoutHeaderScroll {
    var addBankTitle = SectionTitle()
    var addBankBody = SectionBody()
    var yourBankSubtitle = SectionSubTitle()
    var yourBankBody = SectionBody()

    var strings: [String] = []

    override func configureView() {
        scrollView.addSubview(addBankTitle)
        scrollView.addSubview(addBankBody)
        scrollView.addSubview(yourBankSubtitle)
        scrollView.addSubview(yourBankBody)
        super.configureView()

        title.label.text = "Help"
        header.label.text = "Updating your bank"

        addBankTitle.label.text = "ADD A BANK"

        addBankBody.text = "Adding a bank account allows you to get paid for tutoring.\n\nWhen a session ends, the funds will be deposited into your bank account. You will be paid in accordance to the price and length of a session.\n"

        yourBankSubtitle.label.text = "To add your bank:"

        strings = ["1.  Select Payment from the navigation bar.\n", "2.  Tap “add bank”.\n", "3.  Add your bank by entering your legal name, routing number, account number."]

        let attributesDictionary: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: addBankBody.font]
        let fullAttributedString = NSMutableAttributedString(string: "Adding a payment method will allow you to connect, communicate and schedule sessions with tutors.\n\nYou can add payment methods such as debit or credit cards. When a session ends, your payment method is charged in accordance to the session price and length of the session.\n\n", attributes: attributesDictionary)

        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)

            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))

            fullAttributedString.append(attributedString)
        }

        yourBankBody.attributedText = fullAttributedString
    }

    override func applyConstraints() {
        super.applyConstraints()

        addBankTitle.constrainSelf(top: header.snp.bottom)

        addBankBody.constrainSelf(top: addBankTitle.snp.bottom)

        yourBankSubtitle.constrainSelf(top: addBankBody.snp.bottom)

        yourBankBody.constrainSelf(top: yourBankSubtitle.snp.bottom)
    }
}

class TutorUpdatePayment: BaseViewController {
    override var contentView: TutorUpdatePaymentView {
        return view as! TutorUpdatePaymentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = TutorUpdatePaymentView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
