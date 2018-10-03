//
//  MyProfileBodyView.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class MyProfileBody : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}
	
	var isViewing : Bool = false
	
	let additionalInformation : UILabel = {
		let label = UILabel()
		label.text = "Additional Information"
		label.font = Fonts.createBoldSize(16)
		
		return label
	}()
	
	var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.distribution = .fillProportionally
		stackView.axis = .vertical
		stackView.spacing = 10
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	let divider : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.divider
		return view
	}()

	var baseHeight : CGFloat = CGFloat(60)
	
	func configureView() {
		addSubview(additionalInformation)
		addSubview(stackView)
		addSubview(divider)
		
		additionalInformation.textColor = isViewing ? Colors.otherUserColor() :  Colors.currentUserColor()
		
		applyConstraints()
	}
	
	func applyConstraints() {
		additionalInformation.snp.makeConstraints { (make) in
			make.top.width.equalToSuperview()
			make.left.equalToSuperview().inset(12)
			make.height.equalTo(30)
		}
		stackView.snp.makeConstraints { (make) in
			make.top.equalTo(additionalInformation.snp.bottom).inset(-5)
			make.leading.equalToSuperview().inset(12)
			make.trailing.equalToSuperview().inset(5)
		}
		divider.snp.makeConstraints { (make) in
			make.top.equalTo(stackView.snp.bottom).inset(-15)
			make.width.equalToSuperview().inset(20)
			make.centerX.equalToSuperview()
			make.height.equalTo(1)
		}
	}
}
