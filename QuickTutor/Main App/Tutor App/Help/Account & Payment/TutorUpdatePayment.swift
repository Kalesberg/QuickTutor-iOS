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
    var removingMethodTitle = SectionTitle()
    var removingMethodBody = SectionBody()
    var changingMethodTitle = SectionTitle()
    var changingMethodBody = SectionBody()
    
    var strings: [String] = []

    override func configureView() {
        scrollView.addSubview(addBankTitle)
        scrollView.addSubview(addBankBody)
        scrollView.addSubview(removingMethodTitle)
        scrollView.addSubview(removingMethodBody)
        scrollView.addSubview(changingMethodTitle)
        scrollView.addSubview(changingMethodBody)
        
        super.configureView()

        header.label.text = "Updating payout information"

        addBankTitle.label.text = "Add a bank"

        var attributesDictionary: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: addBankBody.font]
        var fullAttributedString = NSMutableAttributedString(string: "Currently, QuickTutor offers one payout method, which should be a US bank account. Adding a payout method is required and enables you to be paid for your services.\n\n", attributes: attributesDictionary)
        
        strings = ["1.  Open the QuickTutor app.\n",
            "2.  Make sure you’re on QuickTutor profile, and not regular user mode.\n",
            "3.  Tap the profile icon in the bottom right corner of your screen (on your tab bar).\n",
            "4.  Tap the \"Payment\" option from your option menu.\n",
            "5.  Tap the \"add new\" button.\n",
            "6.  Enter your name as well as your account and routing numbers.\n",
            "7.  Tap the \"Next\" or \"Save\" button.\n"]
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        addBankBody.attributedText = fullAttributedString

        removingMethodTitle.label.text = "Removing a payout method:"
        attributesDictionary = [.font: removingMethodBody.font]
        fullAttributedString = NSMutableAttributedString(string: "Note: ", attributes: [.font: UIFont.qtBoldFont(size: 14)])
        fullAttributedString.append(NSAttributedString(string: "You cannot remove your default payout method on QuickTutor. You can only remove secondary payout methods.\n\nTo remove a payout method, simply swipe on the payout method (bank) in your payment screen and tap the red, trashcan icon.", attributes: attributesDictionary))
        removingMethodBody.attributedText = fullAttributedString

        changingMethodTitle.label.text = "Changing your default payment method"
        changingMethodBody.text = "To change your default payout method (only applies if you have more than one payout method) simply tap on the method you want to make your default and then select the \"set as default\" option on the bottom of your screen."
    }

    override func applyConstraints() {
        super.applyConstraints()

        addBankTitle.constrainSelf(top: header.snp.bottom)
        addBankBody.constrainSelf(top: addBankTitle.snp.bottom)

        removingMethodTitle.constrainSelf(top: addBankBody.snp.bottom)
        removingMethodBody.constrainSelf(top: removingMethodTitle.snp.bottom)
        
        changingMethodTitle.constrainSelf(top: removingMethodBody.snp.bottom)
        changingMethodBody.constrainSelf(top: changingMethodTitle.snp.bottom)
    }
}

class TutorUpdatePayment: BaseViewController {
    override var contentView: TutorUpdatePaymentView {
        return view as! TutorUpdatePaymentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Updating payout info"
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = TutorUpdatePaymentView()
    }

}
