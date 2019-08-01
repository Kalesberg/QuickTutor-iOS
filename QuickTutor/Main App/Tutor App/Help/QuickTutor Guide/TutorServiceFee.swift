//
//  TutorServiceFee.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorServiceFeeView: MainLayoutHeaderScroll {
    var serviceFeeBody = SectionBody()

    override func configureView() {
        scrollView.addSubview(serviceFeeBody)
        super.configureView()

        header.label.text = "What is the service fee?"

        serviceFeeBody.text = "There is a $2.00 + 10% service fee, which is deducted from every transaction you facilitate as a QuickTutor.\n\nThis fee helps us maintain the QuickTutor platform and make continuous investments to improve our technologies.\n\nThe service fee also helps us cover costs for marketing and payment processing for our users, as well as reporting system support and user safety."
    }

    override func applyConstraints() {
        super.applyConstraints()

        serviceFeeBody.constrainSelf(top: header.snp.bottom)
    }
}

class TutorServiceFee: BaseViewController {
    override var contentView: TutorServiceFeeView {
        return view as! TutorServiceFeeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Service Fee"
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = TutorServiceFeeView()
    }

}
