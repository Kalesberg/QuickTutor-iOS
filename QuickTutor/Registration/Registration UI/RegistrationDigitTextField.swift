//
//  RegistrationDigitTextField.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/30/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class RegistrationDigitTextField: BaseView {
    
    var textField = NoPasteTextField()
    var line = UIView()
    
    internal override func configureView() {
        addSubview(textField)
        addSubview(line)
        
        textField.font = Fonts.createBoldSize(30)
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.tintColor = .clear
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        
        line.backgroundColor = .white
    }
    
    internal func applyConstraint(rightMultiplier: ConstraintMultiplierTarget) {
        self.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.33333)
            make.right.equalToSuperview().multipliedBy(rightMultiplier)
        }

        textField.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalToSuperview()
        }

        line.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(1)
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.centerX.equalToSuperview()
        }
    }
}
