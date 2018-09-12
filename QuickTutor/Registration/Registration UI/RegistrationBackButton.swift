//
//  RegistrationBackButton.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit

class RegistrationBackButton: BaseView, Interactable {
    
    var button = UIImageView()
    let transition = CATransition()
	
    override func configureView() {
        addSubview(button)

        button.image = UIImage(named: "backButton")
		
		transition.duration = 0.4
		transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		transition.type = kCATransitionPush
	
		applyConstraints()
    }
    
    override func applyConstraints() {
        button.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
