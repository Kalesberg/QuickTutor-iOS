//
//  TutorPreferencesNextButton.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorPreferencesNextButton: InteractableView, Interactable {
    let label: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createSize(21)
        label.textColor = .white
        label.text = "Next"
        
        return label
    }()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        backgroundColor = Colors.tutorBlue
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func touchStart() {
        backgroundColor = Colors.lightBlue
    }
    
    func didDragOff() {
        backgroundColor = Colors.tutorBlue
    }
}
