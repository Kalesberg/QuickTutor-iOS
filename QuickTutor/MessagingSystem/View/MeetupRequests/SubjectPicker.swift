//
//  SubjectPicker.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/4/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

protocol SubjectPickerDelegate {
    func didSelectSubject(title: String)
}

class SubjectPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let subjects = ["Mathematics", "Science", "History", "English", "Writing"]
    var subjectDelegate: SubjectPickerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPicker()
    }
    
    func setupPicker() {
        delegate = self
        dataSource = self
        tintColor = .white
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subjects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: subjects[row], attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(subjects[row])
        subjectDelegate?.didSelectSubject(title: subjects[row])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
