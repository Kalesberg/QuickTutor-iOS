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
    var subjects = ["Mathematics", "Science", "History", "English", "Writing"]
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

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return subjects.count
    }

    func pickerView(_: UIPickerView, attributedTitleForRow row: Int, forComponent _: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: subjects[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        return attributedString
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        print(subjects[row])
        subjectDelegate?.didSelectSubject(title: subjects[row])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
