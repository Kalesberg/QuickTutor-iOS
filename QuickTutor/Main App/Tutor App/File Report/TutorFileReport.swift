//
//  FileReport.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorFileReportView : MainLayoutTitleBackButton {
    
    override func configureView() {
        super.configureView()
        
        title.label.text = "File Report"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
    }
    
}

class TutorFileReport : BaseViewController {
    
    override var contentView: TutorFileReportView {
        return view as! TutorFileReportView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func loadView() {
        view = TutorFileReportView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func handleNavigation() {
        
    }
}
