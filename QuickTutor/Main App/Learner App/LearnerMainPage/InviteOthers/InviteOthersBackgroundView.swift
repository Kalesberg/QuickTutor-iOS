//
//  InviteOthersBackgroundView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class InviteOthersBackgroundView: InteractableView, Interactable {
	let label: UILabel = {
		let label = UILabel()
		let formattedString = NSMutableAttributedString()
		
		formattedString
			.bold("Connect your phone contacts to invite some friends!", 19, .white)
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 8
		formattedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, formattedString.length))
		label.attributedText = formattedString
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()
	
	let button = InviteOthersButton()
	
	override func configureView() {
		addSubview(label)
		addSubview(button)
		super.configureView()
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { make in
			make.width.equalTo(250)
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().inset(-80)
		}
		
		button.snp.makeConstraints { make in
			make.width.equalTo(130)
			make.height.equalTo(50)
			make.top.equalTo(label.snp.bottom).inset(-25)
			make.centerX.equalToSuperview()
		}
	}
}
