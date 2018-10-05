//
//  TutorEarningsTableViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class TutorEarningsTableCellView: BaseTableViewCell {
	let leftLabel: UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.font = Fonts.createSize(16)
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let rightLabel: UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.font = Fonts.createSize(14)
		label.adjustsFontSizeToFitWidth = true
		label.textAlignment = .center
		
		return label
	}()
	
	let rightLabelContainer: UIView = {
		let view = UIView()
		
		view.backgroundColor = UIColor(hex: "1EAD4A")
		view.layer.cornerRadius = 10
		return view
	}()
	
	override func configureView() {
		contentView.addSubview(leftLabel)
		contentView.addSubview(rightLabelContainer)
		rightLabelContainer.addSubview(rightLabel)
		super.configureView()
		
		backgroundColor = .clear
		selectionStyle = .none
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		leftLabel.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.left.equalToSuperview().inset(5)
			make.width.equalToSuperview().multipliedBy(0.8)
		}
		rightLabelContainer.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.right.equalToSuperview().inset(10)
			make.left.equalTo(leftLabel.snp.right)
			make.height.equalTo(20)
		}
		rightLabel.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}
