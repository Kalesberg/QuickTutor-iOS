//
//  DatePickerCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class RequestSessionDatePickerCell : UITableViewCell {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	var datePicker : UIDatePicker = {
		let datePicker = UIDatePicker()
	
		var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
		datePicker.setValue(UIColor.white, forKeyPath: "textColor")
		datePicker.minuteInterval = 15
		datePicker.minimumDate = Date().adding(minutes: 15)
		datePicker.maximumDate = Date().adding(days: 30)
		datePicker.datePickerMode = .dateAndTime		
		datePicker.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
		
		return datePicker
	}()
	
	let descriptionLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = UIColor.white
		label.textAlignment = .center
		label.font =  Fonts.createLightSize(13)
		label.text = "Sessions can be manually started before the requested start time with consent from both parties."
		label.numberOfLines = 0
		
		return label
	}()
	
	var delegate : RequestSessionDelegate?
	
	func configureTableViewCell() {
		addSubview(datePicker)
		addSubview(descriptionLabel)
		datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
		
		backgroundColor = Colors.navBarColor
		selectionStyle = .none

		applyConstraints()
	}
	
	func applyConstraints() {
		datePicker.snp.makeConstraints { (make) in
			make.top.centerX.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.75)
		}
		descriptionLabel.snp.makeConstraints { (make) in
			make.top.equalTo(datePicker.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.bottom.equalToSuperview()
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	@objc private func datePickerChanged(_ picker: UIDatePicker) {
		delegate?.startTimeDateChanged(date: picker.date)
	}
}
