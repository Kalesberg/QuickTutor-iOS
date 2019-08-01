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
        navigationItem.title = "Payouts and earnings"
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
