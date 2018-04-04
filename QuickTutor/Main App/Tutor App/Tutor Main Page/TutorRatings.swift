//
//  TutorRatings.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorRatingsView : TutorLayoutView {
    
    override func configureView() {
        super.configureView()
        
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
    }
}

class TutorRatings : BaseViewController {
    
    override var contentView: TutorRatingsView {
        return view as! TutorRatingsView
    }
    override func loadView() {
        view = TutorRatingsView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
