//
//  SettingsLocation.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
class SettingsLocation : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	let sectionTitle : UILabel = {
		let label = UILabel()
		label.text = "Location"
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(18)
		return label
	}()
	
	let location = SettingsButton(title: "Your Location", subtitle: "This is the location displayed in your profile.")

	func configureView() {
		addSubview(sectionTitle)
		addSubview(location)
		
		location.buttonMask.addTarget(self, action: #selector(locationButtonPressed(_:)), for: .touchUpInside)
		
		applyContstraints()
	}
	
	func applyContstraints() {
		sectionTitle.snp.makeConstraints { (make) in
			make.top.left.right.equalToSuperview()
			make.height.equalTo(30)
		}
		location.snp.makeConstraints { (make) in
			make.top.equalTo(sectionTitle.snp.bottom).offset(10)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(60)
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		location.roundCorners(.allCorners , radius: 10)
	}
	@objc private func locationButtonPressed(_ sender: UIButton) {
		let vc = LocationVC()
		navigationController.pushViewController(vc, animated: true)
	}
}
