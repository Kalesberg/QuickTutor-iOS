//
//  LearnerMainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class LearnerMainPageView : MainPageView {
    
    var search  = SearchBar()
    var learnerSidebar = LearnerSideBar()
    
    override var sidebar: Sidebar {
        get {
            return learnerSidebar
        } set {
            if newValue is LearnerSideBar {
                learnerSidebar = newValue as! LearnerSideBar
            } else {
                print("incorrect sidebar type for LearnerMainPage")
            }
        }
    }
    
    override func configureView() {
        navbar.addSubview(search)
        super.configureView()
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        search.snp.makeConstraints { (make) in
            make.height.equalTo(35)
            make.width.equalToSuperview().multipliedBy(0.65)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(5)
        }
    }
}
