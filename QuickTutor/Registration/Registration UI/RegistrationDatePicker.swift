//
//  RegistrationDatePicker.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/30/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class RegistrationDatePicker : BaseView {
    
    var datePicker = UIDatePicker()
	
    override func configureView() {
        addSubview(datePicker)
        
		datePicker.setValue(UIColor.white, forKeyPath: "textColor")
		datePicker.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 38/255, alpha: 1.0)
		datePicker.tintColor = .white
		datePicker.datePickerMode = .date
        
        applyConstraints()
	}
	
	override func applyConstraints() {
		datePicker.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.height.equalToSuperview()
			make.bottom.equalToSuperview()
		}
	}
}
