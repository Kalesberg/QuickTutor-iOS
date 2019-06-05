//
//  BirthdayVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class BirthdayVCView: BaseRegistrationView {
    
    let date = Date()
    let dateformatter = DateFormatter()
    let calendar = Calendar.current
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.setValue(UIColor.white, forKeyPath: "textColor")
        picker.backgroundColor = UIColor(red: 30 / 255, green: 30 / 255, blue: 38 / 255, alpha: 1.0)
        picker.tintColor = .white
        picker.datePickerMode = .date
        return picker
    }()
    
    let birthdayLabel: RegistrationTextField = {
        let field = RegistrationTextField()
        field.placeholder.text = "Birthday"
        field.isUserInteractionEnabled = false
        return field
    }()
    
    let birthdayVisibilityLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(14)
        label.textColor = .white
        label.text = "Others will not be able to see your birthday."
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let ageAgreementLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = Colors.registrationGray
        label.text = "By entering your birthday, you agree that you are at least 18 years old."
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupBirthdayVisibilityLabel()
        setupBirthdayLabel()
        setupAgeAgreementLabel()
        setupDatePicker()
        setupErrorLabelBelow(ageAgreementLabel)
        errorLabel.text = "You must be 18 years or older to use QuickTutor"
    }
    
    func setupBirthdayVisibilityLabel() {
        addSubview(birthdayVisibilityLabel)
        birthdayVisibilityLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.top).offset(65)
            make.height.equalTo(35)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview()
        }
    }
    
    func setupBirthdayLabel() {
        addSubview(birthdayLabel)
        birthdayLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.height.equalTo(100)
        }
    }
    
    func setupAgeAgreementLabel() {
        addSubview(ageAgreementLabel)
        ageAgreementLabel.snp.makeConstraints { make in
            make.top.equalTo(birthdayLabel.snp.bottom).offset(10)
            make.left.equalTo(titleLabel)
            make.right.equalTo(birthdayLabel)
        }
    }
    
    func setupDatePicker() {
        addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(DeviceInfo.keyboardHeight)
        }
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        setDatePickerDates()
    }
    
    private func setDatePickerDates() {
        let date = Date()
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: date)
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -113, to: date)
        datePicker.setDate(date, animated: true)
        dateformatter.dateFormat = "MMMM d'\(daySuffix(date: date))', yyyy"
        let today = dateformatter.string(from: date)
        birthdayLabel.textField.text = today
    }
    
    private func daySuffix(date: Date) -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        // Show new date on label when its changed.
        dateformatter.dateFormat = "MMMM d'\(daySuffix(date: datePicker.date))', yyyy"
        let date = dateformatter.string(from: datePicker.date)
        UIView.animate(withDuration: 0.2, animations: {
            self.birthdayLabel.textField.transform.scaledBy(x: 0.95, y: 0.95)
            self.birthdayLabel.textField.alpha = 0
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.birthdayLabel.textField.alpha = 1
                self.birthdayLabel.textField.text! = date
                self.birthdayLabel.textField.transform = .identity
            })
        }
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "What's your birthday?"
    }
}
