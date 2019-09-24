//
//  TutorPaymentEarnings.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/23/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorPaymentEarningsView: PaymentOptionsView {
    override func configureView() {
        super.configureView()

        header.label.text = "Payouts & earnings"
        
        cardTitle.label.text = "Payouts (direct deposit)"
        let attributesDictionary: [NSAttributedString.Key: Any] = [.font: cardBody.font]
        let fullAttributedString = NSMutableAttributedString(string: "QuickTutor instantly deposits your earnings to all major US banks through Stripe API. However, in some cases a payout may take two-to-three days depending on your bank or credit union’s policies and procedures.\n\nFeel free to contact us at ", attributes: attributesDictionary)
        fullAttributedString.append(NSAttributedString(string: "support@quicktutor.com", attributes: [.font: UIFont.qtBoldFont(size: 14), .foregroundColor: UIColor(hex: "6362C1")]))
        fullAttributedString.append(NSAttributedString(string: " if you have any questions regarding a payout method or feel you have not been compensated properly for your services and we will resolve your issue within 72 hours.", attributes: attributesDictionary))
        
        cardBody.attributedText = fullAttributedString
        
        cashTitle.label.text = "Cash"
        cashBody.text = "QuickTutor is designed for cashless exchanges. After every transaction, your earnings will be direct deposited to you, your receipt is then emailed to you, and your sessions tab is updated under the \"past\" section with all the details regarding the transaction."
        
        gratuityTitle.label.text = "Gratuity"
        gratuityBody.text = "You are allowed to ask for tips as a tutor. However, being tip is not required and any aggressive behavior regarding tipping will not be tolerated. Giving a tip is completely optional. Tips are added to the total of your earnings and are still subject to the QuickTutor service fee ($2.00 + 10% of the total)."
    }
}

class TutorPaymentEarnings: BaseViewController {
    override var contentView: TutorPaymentEarningsView {
        return view as! TutorPaymentEarningsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Payouts and earnings"
        
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
