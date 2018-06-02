//
//  SubmitButton.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class SubmitButton : InteractableView, Interactable {
    
    var label = CenterTextLabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        backgroundColor = Colors.learnerPurple
        layer.cornerRadius = 20
        label.label.text = "SUBMIT"
        label.label.font = Fonts.createBoldSize(16)
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func constrainSelf() {
        self.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(250)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
    
    func touchStart() {
        alpha = 0.6
    }
    
    func touchEndOnStart() {
        alpha = 1
    }
}

