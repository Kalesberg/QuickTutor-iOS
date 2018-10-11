//
//  TaxInformation.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorTaxInfoView: MainLayoutTitleBackButton {
    override func configureView() {
        super.configureView()

        title.label.text = "Tax Information"
    }

    override func applyConstraints() {
        super.applyConstraints()
    }
}

class TutorTaxInfo: BaseViewController {
    override var contentView: TutorTaxInfoView {
        return view as! TutorTaxInfoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        view = TutorTaxInfoView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func handleNavigation() {}
}
