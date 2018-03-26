//
//  EditProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorEditProfileView : MainLayoutTitleBackSaveButton, Keyboardable {
    
    var editButton = NavbarButtonEdit()
    
    override var rightButton: NavbarButton {
        get {
            return editButton
        } set {
            editButton = newValue as! NavbarButtonEdit
        }
    }
    
    var keyboardComponent = ViewComponent()
    
    override func configureView() {
        addKeyboardView()
        super.configureView()
        
        title.label.text = "Edit Profile"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
    }
    
}

class TutorEditProfile : BaseViewController {
    
    override var contentView: TutorEditProfileView {
        return view as! TutorEditProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func loadView() {
        view = TutorEditProfileView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func handleNavigation() {
        
    }
}
