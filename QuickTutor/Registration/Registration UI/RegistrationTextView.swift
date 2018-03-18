//
//  RegistrationTextView.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/30/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class RegistrationTextView : BaseView {
    
    var textView = UITextView()
    
    override func configureView() {
        addSubview(textView)

        textView.font = Fonts.createSize(20)
        textView.keyboardAppearance = .dark
        textView.textColor = .white
        textView.tintColor = .white
        textView.backgroundColor = .clear
        textView.autocorrectionType = .no
        textView.isSecureTextEntry = true
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(10)
        }
    }
}
