//
//  UpdatePayment.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class UpdatePaymentView: MainLayoutHeaderScroll {
    var addPaymentTitle = SectionTitle()
    var addPaymentBody = SectionBody()
    var removingPaymentTitle = SectionTitle()
    var removingPaymentBody = SectionBody()
    var changingDefaultTitle = SectionTitle()
    var changingDefaultBody = SectionBody()
    var updateCardTitle = SectionTitle()
    var updateCardBody = SectionBody()
    var strings: [String] = []

    override func configureView() {
        scrollView.addSubview(addPaymentTitle)
        scrollView.addSubview(addPaymentBody)
        scrollView.addSubview(removingPaymentTitle)
        scrollView.addSubview(removingPaymentBody)
        scrollView.addSubview(changingDefaultTitle)
        scrollView.addSubview(changingDefaultBody)
        scrollView.addSubview(updateCardTitle)
        scrollView.addSubview(updateCardBody)
        super.configureView()

        header.label.text = "Payment methods"

        addPaymentTitle.label.text = "To add a payment method:"

        let attributesDictionary: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: addPaymentBody.font]
        var fullAttributedString = NSMutableAttributedString(string: "Adding a payment method will allow you to pay for sessions and calls with tutors. You must have a payment method to enter a session or QuickCall with a tutor.\n\n", attributes: attributesDictionary)
        
        strings = ["1.  Tap the profile icon in the bottom right corner of your screen (on your tab bar).\n",
                   "2.  Tap the “Payment” option from your option menu.\n",
                   "3.  Tap the \"add new\" button.\n",
                   "4.  Select a type of payment method (add debit or credit card).\n",
                   "5.  Add your selected payment method by manually entering your card information or scanning your card.\n\n"]

        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)

            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))

            fullAttributedString.append(attributedString)
        }

        fullAttributedString.append(NSAttributedString(string: "When your session or call ends, your payment method is charged in accordance with the session/QuickCall price and total duration. Please review our Payments Terms of Service if you have any further questions regarding payments.", attributes: attributesDictionary))
        
        addPaymentBody.attributedText = fullAttributedString

        removingPaymentTitle.label.text = "Removing a payment method:"
        removingPaymentBody.text = "To remove a payment method, simply swipe on the payment method in your payment screen and tap the red trashcan icon."

        changingDefaultTitle.label.text = "Changing your default payment method:"
        changingDefaultBody.text = "To change your default payment method (only applies if you have more than one payment method on file) simply tap on the payment method and then select the “set as default” option on the bottom of your screen."
        
        updateCardTitle.label.text = "Updating card info"

        strings = ["1.  Tap the profile icon in the bottom right corner of your screen (on your tab bar).\n",
                   "2.  Tap the \"Payment\" bar from your option menu.\n",
                   "3.  Make changes.\n"]

        fullAttributedString = NSMutableAttributedString(string: "", attributes: attributesDictionary)

        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)

            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))

            fullAttributedString.append(attributedString)
        }

        updateCardBody.attributedText = fullAttributedString
    }

    override func applyConstraints() {
        super.applyConstraints()

        addPaymentTitle.constrainSelf(top: header.snp.bottom)
        addPaymentBody.constrainSelf(top: addPaymentTitle.snp.bottom)

        removingPaymentTitle.constrainSelf(top: addPaymentBody.snp.bottom)
        removingPaymentBody.constrainSelf(top: removingPaymentTitle.snp.bottom)
        
        changingDefaultTitle.constrainSelf(top: removingPaymentBody.snp.bottom)
        changingDefaultBody.constrainSelf(top: changingDefaultTitle.snp.bottom)

        updateCardTitle.constrainSelf(top: changingDefaultBody.snp.bottom)
        updateCardBody.constrainSelf(top: updateCardTitle.snp.bottom)
    }
}

class UpdatePaymentVC: BaseViewController {
    override var contentView: UpdatePaymentView {
        return view as! UpdatePaymentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Payment methods"
        contentView.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = UpdatePaymentView()
    }

    override func handleNavigation() {}
}
