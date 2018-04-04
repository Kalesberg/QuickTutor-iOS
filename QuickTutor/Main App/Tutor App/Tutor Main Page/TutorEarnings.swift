//
//  TutorEarnings.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorEarningsView : TutorLayoutView {
    
    override func configureView() {
        super.configureView()
        
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
    }
}

class TutorEarnings : BaseViewController {
    
    override var contentView: TutorEarningsView {
        return view as! TutorEarningsView
    }
    override func loadView() {
        view = TutorEarningsView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
