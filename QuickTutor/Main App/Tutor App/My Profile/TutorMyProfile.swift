//
//  MyProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorMyProfileView : MainLayoutTitleBackTwoButton {
    
    var editButton = NavbarButtonEdit()
    
    override var rightButton: NavbarButton {
        get {
            return editButton
        } set {
            editButton = newValue as! NavbarButtonEdit
        }
    }
    
    override func configureView() {
        super.configureView()
        
        title.label.text = "My Profile"
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
    }

}

class TutorMyProfile : BaseViewController {

    override var contentView: TutorMyProfileView {
        return view as! TutorMyProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func loadView() {
        view = TutorMyProfileView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func handleNavigation() {
        if (touchStartView is NavbarButtonEdit) {
            navigationController?.pushViewController(TutorEditProfile(), animated: true)
        }
    }
}
