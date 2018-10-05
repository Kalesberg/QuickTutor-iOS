//
//  TutorEarningsBackgroundView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class TutorEarningsTableViewBackground: BaseView {
	let label: UILabel = {
		let label = UILabel()
		
		let formattedString = NSMutableAttributedString()
		formattedString
			.bold("No earnings yet!", 20, .white)
			.regular("\n\nPayment information will load here once you have had your first session!", 16, .white)
		
		label.attributedText = formattedString
		label.numberOfLines = 0
		label.textAlignment = .center
		
		return label
	}()
	
	override func configureView() {
		addSubview(label)
		super.configureView()
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.width.equalTo(260)
			make.centerX.equalToSuperview()
		}
	}
}
