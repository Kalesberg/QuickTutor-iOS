//
//  SessionTypeView.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

// class OnlineVideoCallView : UIView {
//
//	override init(frame: CGRect) {
//		super.init(frame: .zero)
//		configureView()
//	}
//
//	required init?(coder aDecoder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//	let containerView : UIView = {
//		let view = UIView()
//		view.backgroundColor = Colors.navBarColor
//		return view
//	}()
//
//	let onlineVideoCallToggle : UIView = {
//		let view = UIView()
//		view.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.3960784314, blue: 0.7647058824, alpha: 1)
//		return view
//	}()
//	let onlineLabel : UILabel = {
//		let label = UILabel()
//
//		label.text = "Online / Video Call"
//		label.textColor = .white
//		label.textAlignment = .left
//		label.font = Fonts.createBoldSize(14)
//
//		return label
//	}()
//	let toggle = RegistrationCheckbox()
//
//	 func configureView() {
//		addSubview(containerView)
//		containerView.addSubview(onlineVideoCallToggle)
//		onlineVideoCallToggle.addSubview(onlineLabel)
//		onlineVideoCallToggle.addSubview(toggle)
//
//
//		toggle.isSelected = false
//
//		applyConstraints()
//	}
//	func applyConstraints() {
//		containerView.snp.makeConstraints { (make) in
//			make.top.bottom.equalToSuperview().inset(1)
//			make.width.centerX.equalToSuperview()
//		}
//		onlineVideoCallToggle.snp.makeConstraints { (make) in
//			make.width.equalToSuperview().multipliedBy(0.91)
//			make.center.equalToSuperview()
//			make.height.equalTo(35)
//		}
//		toggle.snp.makeConstraints { (make) in
//			make.centerY.equalToSuperview()
//			make.right.equalToSuperview().inset(8)
//			make.width.height.equalTo(20)
//		}
//		onlineLabel.snp.makeConstraints { (make) in
//			make.centerY.height.equalToSuperview()
//			make.left.equalToSuperview().inset(8)
//			make.right.equalTo(toggle.snp.left)
//		}
//	}
//	override func layoutSubviews() {
//		super.layoutSubviews()
//		onlineVideoCallToggle.layer.cornerRadius = 4
//	}
// }
