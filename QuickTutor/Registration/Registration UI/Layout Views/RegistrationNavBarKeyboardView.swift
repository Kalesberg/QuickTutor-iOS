//
//  RegistrationNavBarKeyboardView.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit.UIView

class RegistrationNavBarKeyboardView: RegistrationNavBarView, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    var contentView  = UIView()
    
    override func configureView() {
        super.configureView()
        addSubview(contentView)
        addKeyboardView()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        nextButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(keyboardView.snp.top)
            make.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalTo(nextButton.snp.top)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
        }
    }
}
