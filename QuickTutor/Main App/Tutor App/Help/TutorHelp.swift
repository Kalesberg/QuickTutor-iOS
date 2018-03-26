//
//  Help.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorHelpView : MainLayoutTitleBackButton {
    
    override func configureView() {
        super.configureView()
        
        title.label.text = "Help"
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
    }
    
}

class TutorHelp : BaseViewController {
    
    override var contentView: TutorHelpView {
        return view as! TutorHelpView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func loadView() {
        view = TutorHelpView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func handleNavigation() {
        
    }
}
