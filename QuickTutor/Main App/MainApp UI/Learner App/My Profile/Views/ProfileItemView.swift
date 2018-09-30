//
//  ProfileItemView.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class ProfileItem: UIView {
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	var icon : UIImage?
	var title: String?
	
	init(icon: UIImage, title: String) {
		self.icon = icon
		self.title = title
		super.init(frame: .zero)
		configureView()
	}
	
	var imageViewContainer : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.currentUserColor()
		view.layer.cornerRadius = 12.5
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	var imageView : UIImageView = {
		let imageView = UIImageView()
		imageView.scaleImage()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	var titleLabel : UILabel = {
		let label = UILabel()
		label.textColor = Colors.grayText
		label.textAlignment = .left
		label.numberOfLines = 2
		label.lineBreakMode = .byWordWrapping
		label.font = Fonts.createSize(14)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	func configureView() {
		addSubview(imageViewContainer)
		imageViewContainer.addSubview(imageView)
		addSubview(titleLabel)
		
		titleLabel.text = self.title
		imageView.image = self.icon
		
		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = Colors.navBarColor
		
		applyConstraints()
	}
	
	func applyConstraints() {
		imageViewContainer.snp.makeConstraints { make in
			make.centerY.left.equalToSuperview()
			make.height.width.equalTo(25)
		}
		imageView.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
		titleLabel.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.left.equalTo(imageViewContainer.snp.right).inset(-11)
			make.right.equalToSuperview().inset(3)
		}
	}
}
