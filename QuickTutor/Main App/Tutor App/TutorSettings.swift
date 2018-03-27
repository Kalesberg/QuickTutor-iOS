//
//  Settings.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorSettingsView : LearnerSettingsView {
    
    //var tutorScrollView = TutorSettingsScrollView()
    
//    override var scrollView: SettingsScrollView {
//        get {
//            return tutorScrollView
//        } set {
//            
//        }
//    }
    
    override func configureView() {
        super.configureView()
        
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
    }
    
}

class TutorSettings : BaseViewController {
    
    override var contentView: TutorSettingsView {
        return view as! TutorSettingsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func loadView() {
        view = TutorSettingsView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func handleNavigation() {
        
    }
}
