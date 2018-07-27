//
//  durationPickerCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class RequestSessionDurationPickerCell : UITableViewCell {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	let pickerView = UIPickerView()
	
	let descriptionLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = UIColor.white
		label.textAlignment = .center
		label.font =  Fonts.createLightSize(13)
		label.text = "Although you have a set duration for each session, sessions can be ended or paused at any time. You can also add more time to any session."
		label.numberOfLines = 0
		
		return label
	}()
	
	var datasource : [String] = ["Choose a duration","15 min", "30 min","45 min", "1.0 hr","1.5 hr","2.0 hr","2.5 hr","3.0 hr","3.5 hr","4.0 hr","4.5 hr","5.0 hr","5.5 hr","6.0 hr","6.5 hr","7.0 hr","7.5 hr","8.0 hr","8.5 hr","9.0 hr","9.5 hr","10.0 hr","10.5 hr","11.0 hr","12.0 hr","12.5 hr"]
	
	var delegate : RequestSessionDelegate?
	
	func configureTableViewCell() {
		addSubview(pickerView)
		addSubview(descriptionLabel)
		
		pickerView.delegate = self
		pickerView.dataSource = self
		
		backgroundColor = Colors.navBarColor
		selectionStyle = .none
		
		applyConstraints()
	}
	
	func applyConstraints() {
		pickerView.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.75)
		}
		descriptionLabel.snp.makeConstraints { (make) in
			make.top.equalTo(pickerView.snp.bottom)
			make.bottom.width.centerX.equalToSuperview()
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}
extension RequestSessionDurationPickerCell : UIPickerViewDelegate, UIPickerViewDataSource {
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
		if row == 0 {
			delegate?.durationChanged(displayDuration: nil, duration: nil)
		} else if row == 1 || row == 2 || row == 3 {
			let minuteString = datasource[row].removeCharacters(from: CharacterSet.decimalDigits.inverted)
			guard let duration = Int(minuteString) else { return }
			delegate?.durationChanged(displayDuration: datasource[row] ,duration: duration)
		} else {
			let minuteString = datasource[row].removeCharacters(from: CharacterSet.decimalDigits.inverted)
			let duration = (minuteString as NSString).doubleValue
			delegate?.durationChanged(displayDuration: datasource[row], duration: Int((duration / 10) * 60))
		}
	}
}
