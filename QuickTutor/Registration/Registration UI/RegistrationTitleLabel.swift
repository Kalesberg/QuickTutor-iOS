//
//  RegistrationTitleLabel.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class RegistrationTitleLabel: BaseView {
    
    var label = UILabel()
    
    override func configureView() {
        super.configureView()
        addSubview(label)
        
        label.contentMode = .scaleAspectFit
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = Fonts.createBoldSize(22)
        label.sizeToFit()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
