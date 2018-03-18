//
//  RegistrationTextField.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit

class RegistrationTextField: BaseView {
    
    var placeholder = UILabel()
    var textField   = NoPasteTextField()
    var line        = UIView()

    override func configureView() {
        addSubview(placeholder)
        addSubview(textField)
        addSubview(line)
        
        placeholder.textColor = .white
        placeholder.textAlignment = .left
        placeholder.numberOfLines = 1
        placeholder.font = Fonts.createSize(14)
        
        textField.font = Fonts.createSize(CGFloat(DeviceInfo.textFieldFontSize))
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.tintColor = .white
        textField.adjustsFontSizeToFitWidth = true
        textField.adjustsFontForContentSizeCategory = true
        
        line.backgroundColor = .white
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        
        placeholder.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        line.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.8)
        }
        
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.35)
        }
    }
}

