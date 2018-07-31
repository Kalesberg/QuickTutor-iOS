//
//  RegistrationGradientView.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class RegistrationGradientView: BaseLayoutView {
    
    internal override func configureView() {
        super.configureView()
        
        applyGradient(firstColor: (Colors.oldTutorBlue.cgColor), secondColor: (Colors.oldLearnerPurple.cgColor), angle: 160, frame: frame)
    }
    
    internal override func applyConstraints() {}
}
