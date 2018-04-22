//
//  RegistrationNextButton.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class RegistrationNextButton: BaseView, Interactable {

    var button     = LeftTextLabel()
    var isTextOne  = true
    var isTextTwo  = false
    var textOne    = "»  "
    var textTwo    = " » "
    var textThree  = "  »"
    
    override func configureView() {
        addSubview(button)
        
        //_ = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(toggleText), userInfo: nil, repeats: true)

        button.label.text = textTwo
        button.label.font = Fonts.createBoldSize(54)
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        button.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc func toggleText(timer: Timer) {
        if(isTextOne) {
            button.label.text = textTwo
            isTextOne = false
            isTextTwo = true
        }
        else if(isTextTwo) {
            button.label.text = textThree
            isTextTwo = false
        }
        else {
            button.label.text = textOne
            isTextOne = true
        }
    }
}
