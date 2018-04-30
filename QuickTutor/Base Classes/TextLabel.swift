//
//  RegistrationSmallTextLabel.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/30/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TextLabel: BaseView {
    
    var label = UILabel()
    
    override func configureView() {
        super.configureView()
        addSubview(label)
        
        label.textColor = .white
        label.numberOfLines = 0
        
        applyConstraints()
    }
}

class LeftTextLabel: TextLabel {
    
    override func applyConstraints() {
        label.textAlignment = .left
        
        label.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.9)
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

class CenterTextLabel: TextLabel {
    
    override func applyConstraints() {
        label.textAlignment = .center
        
        label.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.9)
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}

class RightTextLabel: TextLabel {
    
    override func applyConstraints() {
        label.textAlignment = .right
        
        label.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.9)
            make.width.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
