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

        title.label.text = "Service Fee"
        header.label.text = "What is the service fee?"

        serviceFeeBody.text = "When you first begin tutoring, a 10% service fee is deducted from your fare. After fifteen hours of tutoring, our service fee drops down to 7.5%.\n\nThe fee helps us maintain the QuickTutor platform and make continuous investments to improve our technologies.\n\nThe service fee also helps us cover costs for marketing and payment processing for learners, as well as reporting system support and user safety."
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

        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = TutorServiceFeeView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
