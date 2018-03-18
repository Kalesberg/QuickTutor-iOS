//
//  RegistrationBigButton.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class RegistrationBigButton: BaseView, Interactable {
    
    var label = LeftTextLabel()
    
    override func configureView() {
        addSubview(label)
        
        layer.borderWidth = 1
        layer.cornerRadius = 30
        layer.borderColor = UIColor.white.cgColor
        label.label.textAlignment = .center
        label.label.font = Fonts.createLightSize(22)
        label.label.backgroundColor = .clear
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    
    func touchStart() {
        backgroundColor = .white
        label.label.textColor = .gray
    }
    func didDragOff() {
        backgroundColor = .clear
        label.label.textColor = .white
    }
}
