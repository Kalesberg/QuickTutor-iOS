//
//  SettingsButton.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class SettingsButtonMask : UIButton {
	var originalBackgroundColor: UIColor!
	var highlightedBackgroundColor: UIColor!
	
	override var backgroundColor: UIColor? {
		didSet {
			if originalBackgroundColor == nil {
				originalBackgroundColor = backgroundColor
			}
		}
	}
	
	override var isHighlighted: Bool {
		didSet {
			guard let originalBackgroundColor = originalBackgroundColor else {
				return
			}
			backgroundColor = isHighlighted ? highlightedBackgroundColor : originalBackgroundColor
		}
	}
}

class SettingsButton : UIView {
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
	let arrowImage : UIImageView = {
		let imageView = UIImageView()
		imageView.image = #imageLiteral(resourceName: "backButton")
		imageView.contentMode = .scaleAspectFit
		imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
		return imageView
	}()
	let buttonMask : SettingsButtonMask = {
		let button = SettingsButtonMask()
		button.originalBackgroundColor = .clear
		button.highlightedBackgroundColor = Colors.navBarColor.darker()?.withAlphaComponent(0.5)
		return button
	}()

	func configureView() {
		addSubview(titleLabel)
		addSubview(subtitleLabel)
		addSubview(arrowImage)
		addSubview(buttonMask)
		
		backgroundColor = Colors.navBarColor
		
		subtitle == nil ? setupViewForTitleOnly() : applyConstraints()

		titleLabel.text = self.title ?? ""
		subtitleLabel.text = self.subtitle ?? ""		
	}
	
	func applyConstraints() {
		arrowImage.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(10)
			make.centerY.equalToSuperview()
			make.height.width.equalTo(15)
		}
		titleLabel.snp.makeConstraints { (make) in
			make.top.left.equalToSuperview().inset(10)
			make.right.equalTo(arrowImage.snp.left)
			make.height.equalTo(20)
		}
		subtitleLabel.snp.makeConstraints { (make) in
			make.top.equalTo(titleLabel.snp.bottom)
			make.left.equalToSuperview().inset(10)
			make.right.equalTo(arrowImage.snp.left)
			make.height.equalTo(20)
		}
		buttonMask.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
	func setupViewForTitleOnly() {
		subtitleLabel.removeFromSuperview()
		
		arrowImage.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(10)
			make.centerY.equalToSuperview()
			make.height.width.equalTo(15)
		}
		titleLabel.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.left.equalToSuperview().inset(10)
			make.right.equalTo(arrowImage.snp.left)
			make.height.equalTo(20)
		}
		buttonMask.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
}
