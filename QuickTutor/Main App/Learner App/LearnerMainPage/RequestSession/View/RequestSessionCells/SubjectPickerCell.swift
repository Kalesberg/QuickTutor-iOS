//
//  RequestSessionTableViewCells.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class RequestSessionSubjectPickerCell : UITableViewCell {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	let subjectPicker = UIPickerView()
	
	var datasource = [String]() {
		didSet {
			subjectPicker.reloadAllComponents()
		}
	}
	
	var delegate : RequestSessionDelegate?
	
	func configureTableViewCell() {
		addSubview(subjectPicker)
		
		subjectPicker.delegate = self
		subjectPicker.dataSource = self
		
		backgroundColor = Colors.navBarColor
		selectionStyle = .none
		
		applyConstraints()
	}
	
	func applyConstraints() {
		subjectPicker.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}
extension RequestSessionSubjectPickerCell : UIPickerViewDelegate, UIPickerViewDataSource {
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let attributedString = NSAttributedString(string: datasource[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font : Fonts.createSize(20)])
		return attributedString
	}
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return datasource.count
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return datasource[row]
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		delegate?.sessionSubjectChanged(subject: datasource[row])
	}
}
