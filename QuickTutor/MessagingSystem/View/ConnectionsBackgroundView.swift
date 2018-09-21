//
//  ConnectionsBackgroundView.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/20/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class ConnectionsBackgroundView : UIView {
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	let backgroundViewIcon : UIImageView = {
		let imageView = UIImageView()
		
		imageView.scaleImage()
		imageView.image = UIImage(named: "connections-icon")
		
		return imageView
	}()

	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Looks like you don't have any connections. You can add tutors by username in the top-right!"
		label.font = Fonts.createSize(14)
		label.textColor = .white
		label.textAlignment = .center
		label.numberOfLines = 2
		label.lineBreakMode = .byWordWrapping
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()

	func configureView() {
		addSubview(backgroundViewIcon)
		addSubview(title)
		
		applyConstraints()
	}
	
	func applyConstraints() {
		backgroundViewIcon.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.3)
			make.height.equalToSuperview().multipliedBy(0.2)
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(0.5)
		}
		title.snp.makeConstraints { (make) in
			make.top.equalTo(backgroundViewIcon.snp.bottom)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.9)
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		title.sizeToFit()
	}
}
