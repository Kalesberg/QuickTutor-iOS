//
//  SettingsButtonToggle.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class SettingsButtonToggle : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	var title: String?
	var subtitle: String?
	
	init(title: String, subtitle: String?=nil) {
		self.title = title
		self.subtitle = subtitle
		super.init(frame: .zero)
		configureView()
	}
	
	let titleLabel : UILabel = {
		let label = UILabel()
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(15)
		label.adjustsFontSizeToFitWidth = true
		label.textColor = Colors.purple
		return label
	}()
	
	let subtitleLabel : UILabel = {
		let label = UILabel()
		label.textAlignment = .left
		label.font = Fonts.createSize(14)
		label.adjustsFontSizeToFitWidth = true
		label.textColor = Colors.grayText
		return label
	}()
	let toggle : UISwitch = {
		let toggle = UISwitch(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
		toggle.tintColor = Colors.purple
		toggle.thumbTintColor = .white
		toggle.onTintColor = Colors.purple
		return toggle
	}()
	
	func configureView() {
		addSubview(titleLabel)
		addSubview(subtitleLabel)
		addSubview(toggle)
		
		backgroundColor = Colors.navBarColor
		
		if subtitle == nil {
			setupViewForTitleOnly()
		} else {
			applyConstraints()
		}
		
		titleLabel.text = self.title ?? ""
		subtitleLabel.text = self.subtitle ?? ""
	}
	
	func applyConstraints() {
		toggle.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(10)
			make.centerY.equalToSuperview()
		}
		titleLabel.snp.makeConstraints { (make) in
			make.top.left.equalToSuperview().inset(10)
			make.right.equalTo(toggle.snp.left)
			make.height.equalTo(20)
		}
		subtitleLabel.snp.makeConstraints { (make) in
			make.top.equalTo(titleLabel.snp.bottom)
			make.left.equalToSuperview().inset(10)
			make.right.equalTo(toggle.snp.left)
			make.height.equalTo(20)
		}
	}
	func setupViewForTitleOnly() {
		subtitleLabel.removeFromSuperview()
		
		toggle.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(10)
			make.centerY.equalToSuperview()
			make.height.width.equalTo(15)
		}
		titleLabel.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.left.equalToSuperview().inset(10)
			make.right.equalTo(toggle.snp.left)
			make.height.equalTo(20)
		}
	}
}
