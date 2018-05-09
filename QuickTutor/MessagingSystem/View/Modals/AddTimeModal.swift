//
//  AddTimeModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class AddTimeModal: CustomTipModal {
    
    override func setupTitleLabel() {
        super.setupTitleLabel()
        titleLabel.text = "ADD TIME"
    }
    
    override func setupInfoLabel() {
        super.setupInfoLabel()
        infoLabel.text = "Time is charged to payment method."
    }
    
    override func setupViews() {
        super.setupViews()
        priceInput.inputMode = .minutes
        priceInput.getFormattedMinutes()
    }
    
}
