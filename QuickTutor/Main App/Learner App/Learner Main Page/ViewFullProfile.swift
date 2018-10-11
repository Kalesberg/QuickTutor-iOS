//
//  ViewFullProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/29/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class ViewFullProfileView: MainLayoutOneButton {
    var exit = NavbarButtonX()

    override var leftButton: NavbarButton {
        get {
            return exit
        } set {
            exit = newValue as! NavbarButtonX
        }
    }

    override func configureView() {
        super.configureView()

        navbar.backgroundColor = Colors.tutorBlue
        statusbarView.backgroundColor = Colors.tutorBlue

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()
    }
}

class ViewFullProfile: BaseViewController {
    override var contentView: ViewFullProfileView {
        return view as! ViewFullProfileView
    }

    override func loadView() {
        view = ViewFullProfileView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func handleNavigation() {
        if touchStartView is NavbarButtonX {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
