//
//  StudentBio.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/6/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class BioView : RegistrationNavBarKeyboardView {
    
    var bioTextView    = RegistrationTextView()
    var characterCount = LeftTextLabel()
    
    override func configureView() {
        super.configureView()
        
        contentView.addSubview(bioTextView)
        contentView.addSubview(characterCount)
        
        titleLabel.label.text = "Tell us about yourself"

        bioTextView.textView.becomeFirstResponder()
        bioTextView.textView.autocorrectionType = .yes
        bioTextView.textView.returnKeyType = .default
        
        bioTextView.layer.borderWidth = 1
        bioTextView.layer.borderColor = UIColor.white.cgColor
        bioTextView.layer.cornerRadius = 10
        
        characterCount.label.adjustsFontForContentSizeCategory = true
        characterCount.label.adjustsFontSizeToFitWidth = true
        characterCount.label.textColor = .white
        characterCount.label.font = Fonts.createSize(18)
        characterCount.label.text = "300"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        bioTextView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.8)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        characterCount.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.2)
            make.top.equalTo(bioTextView.snp.bottom)
            make.right.equalToSuperview().inset(10)
        }
    }
}




