//
//  TutorMyProfilePolicies.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class TutorMyProfilePolicies: UIView {
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}
	
	let header: UILabel = {
		let label = UILabel()
		
		label.text = "Policies"
		label.textColor = UIColor(hex: "5785d4")
		label.font = Fonts.createBoldSize(16)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	let policiesLabel: UILabel = {
		let label = UILabel()
		
		label.translatesAutoresizingMaskIntoConstraints = false
		label.sizeToFit()
		label.numberOfLines = 0
		
		return label
	}()
	
	func configureView() {
		addSubview(header)
		addSubview(policiesLabel)
				
		applyConstraints()
	}
	
	func applyConstraints() {
		header.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(10)
			make.left.equalToSuperview().inset(10)
		}
		
		policiesLabel.snp.makeConstraints { make in
			make.top.equalTo(header.snp.bottom).inset(-10)
			make.left.equalToSuperview().inset(10)
			make.right.equalToSuperview().inset(15)
			make.bottom.equalToSuperview().inset(15)
		}
	}
}
