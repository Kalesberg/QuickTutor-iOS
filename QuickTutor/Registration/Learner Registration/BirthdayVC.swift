//
//  Birthday.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/19/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit

class BirthdayVC: BaseRegistrationController {
    
    var isFacebookManaged = false
    
    let contentView: BirthdayVCView = {
        let view = BirthdayVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        setupAccessoryView()
    }
    
    func setupAccessoryView() {
        contentView.addSubview(accessoryView)
        accessoryView.anchor(top: nil, left: contentView.leftAnchor, bottom: contentView.datePicker.topAnchor, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 80)
    }
    
    func setupTargets() {
        accessoryView.nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
    }
    
    @objc func handleNext() {
        if checkAgeAndBirthdate() {
            proceedToNextScreen()
        } else {
            contentView.errorLabel.isHidden = false
        }
    }
    
    private func checkAgeAndBirthdate() -> Bool {
        let birthdate = contentView.datePicker.calendar!
        let birthday = birthdate.dateComponents([.day, .month, .year], from: contentView.datePicker.date)
        let age = birthdate.dateComponents([.year], from: contentView.datePicker.date, to: Date())
        
        guard let yearsOld = age.year, yearsOld >= 18,
            let day = birthday.day,
            let month = birthday.month,
            let year = birthday.year
        else { return false }
        
        Registration.age = age.year!
        Registration.dob = String("\(day)/\(month)/\(year)")
        contentView.errorLabel.isHidden = true
        
        return true
    }
    
    func proceedToNextScreen() {
        if isFacebookManaged {
            let next = UserPolicyVC()
            navigationController?.pushViewController(next, animated: true)
        } else {
            let next = UploadImageVC()
            navigationController!.pushViewController(next, animated: true)
        }
    }
    
}
