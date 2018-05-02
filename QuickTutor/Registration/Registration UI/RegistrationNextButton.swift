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

    var button : UILabel = {
        let label = UILabel()
        
        label.text = "  »"
        label.font = Fonts.createBoldSize(54)
        label.textColor = .white
        
        return label
    }()
    
    override func configureView() {
        addSubview(button)

        applyConstraints()
    }
    
    override func applyConstraints() {
        button.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
}
