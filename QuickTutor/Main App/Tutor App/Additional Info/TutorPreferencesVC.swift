//
//  TutorPreferences.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorPreferencesVC: BaseRegistrationController {

    let contentView: TutorPreferencesView = {
        let view = TutorPreferencesView()
        return view
    }()

    var price: Int = 0
    var distance: Int = 0
    var inPerson: Bool = true
    var inVideo: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        progressView.setProgress(1/6)
    }

    override func loadView() {
        view = contentView
    }

    func setupTargets() {
        contentView.accessoryView.nextButton.addTarget(self, action: #selector(savePreferences), for: .touchUpInside)
    }
    
    @objc func savePreferences() {
        TutorRegistration.price = Int(contentView.hourSliderView.slider.value)
        TutorRegistration.distance = Int(contentView.distanceSliderView.slider.value)
        guard let index = contentView.collectionView.indexPathsForSelectedItems?[0].item else {
            TutorRegistration.sessionPreference = 0
            return
        }
        if index == 0 {
            TutorRegistration.sessionPreference = 1
        } else if index == 1 {
            TutorRegistration.sessionPreference = 2
        } else {
            TutorRegistration.sessionPreference = 3
        }
        let next = TutorBioVC()
        navigationController?.pushViewController(next, animated: true)
    }
}
