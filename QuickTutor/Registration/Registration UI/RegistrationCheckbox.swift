//
//  RegistrationCheckbox.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/30/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class RegistrationCheckbox: BaseView, Interactable {
    
    var checkbox = UIImageView()
    
    let selectedImage = UIImage(named: "registration-checkbox-selected")! as UIImage
    let unselectedImage = UIImage(named: "registration-checkbox-unselected")! as UIImage
    
    var isSelected: Bool = true {
        didSet {
            if isSelected == true {
                checkbox.image = selectedImage
            } else {
                checkbox.image = unselectedImage
            }
        }
    }
    
    override func configureView() {
        addSubview(checkbox)
        
        checkbox.image = selectedImage
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        checkbox.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func touchEndOnStart() {
        isSelected = !isSelected
    }
}

