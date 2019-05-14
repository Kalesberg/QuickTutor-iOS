//
//  SessionRequestDateView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol SessionRequestDateViewDelegate {
    func sessionRequestDateView(_ dateView: SessionRequestDateView, didSelect date: Date)
}

class SessionRequestDatePicker: UIDatePicker {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let string = "myString"
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

class SessionRequestDateView: BaseSessionRequestViewSection {
    
    var delegate: SessionRequestDateViewDelegate?
    
    let datePicker: SessionRequestDatePicker = {
        let picker = SessionRequestDatePicker()
        picker.setValue(UIColor.white, forKey: "textColor")
        return picker
    }()
    
    override func setupViews() {
        super.setupViews()
        setupDatePicker()
        titleLabel.text = "What time would you like to start?"
    }
    
    func setupDatePicker() {
        addSubview(datePicker)
        datePicker.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 180)
        datePicker.minimumDate = Date().adding(minutes: 15)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        delegate?.sessionRequestDateView(self, didSelect: sender.date)
    }
}
