//
//  CustomDatePicker.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/4/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

protocol CustomDatePickerDelegate {
    func didSelectDate(_ date: Double)
}

class CustomDatePicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var months = [String]()
    var dateData = [[String]]()
    var customDelegate: CustomDatePickerDelegate?
    var date: Date?
    
    var currentMonth: Int!
    var currentDay: Int!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPicker()
    }
    
    func setupPicker() {
        delegate = self
        dataSource = self
        tintColor = .white
        months = DateFormatter().monthSymbols
        dateData = [months, [String]()]
        
        let year = Calendar.current.component(.year, from: Date())
        currentMonth = Calendar.current.component(.month, from: Date())
        currentDay = Calendar.current.component(.day, from: Date())
        
        let dateComponents = DateComponents(year: year, month: currentMonth)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let days = range.count
        for day in 1...days {
            print(day)
            dateData[1].append("\(day)")
        }
        
        self.selectRow(currentMonth - 1, inComponent: 0, animated: true)
        self.selectRow(currentDay - 1, inComponent: 1, animated: true)
        updateDate()
        print(date - Date().timeIntervalSince1970)
        print(date - Date().timeIntervalSince1970)
        print(date - Date().timeIntervalSince1970)


        customDelegate?.didSelectDate((self.date?.timeIntervalSince1970)!)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: dateData[component][row], attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 && row < currentMonth - 1 {
            pickerView.selectRow(currentMonth - 1, inComponent: 0, animated: true)
        }
        if component == 1 && row < currentDay - 1 && pickerView.selectedRow(inComponent: 0) == currentMonth - 1{
            pickerView.selectRow(currentDay - 1, inComponent: 1, animated: true)
        }
        
        if component == 0 && row == currentMonth - 1 && pickerView.selectedRow(inComponent: 1) < currentDay - 1 {
            pickerView.selectRow(currentDay - 1, inComponent: 1, animated: true)
        }
        updateDate()
    }
    
    func updateDate() {
        let monthsToAdd = selectedRow(inComponent: 0) - (currentMonth - 1)
        guard let dateWithMonthsAdded = Calendar.current.date(byAdding: .month, value: monthsToAdd, to: Date()) else { return }
        let daysToAdd = selectedRow(inComponent: 1) - (currentDay - 1)
        guard let dateWithDaysAdded = Calendar.current.date(byAdding: .day, value: daysToAdd, to: dateWithMonthsAdded) else { return }
        self.date = dateWithDaysAdded
        customDelegate?.didSelectDate(dateWithDaysAdded.timeIntervalSince1970)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
