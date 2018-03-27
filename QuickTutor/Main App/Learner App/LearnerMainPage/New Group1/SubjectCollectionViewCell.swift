//
//  SubjectCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SubjectCollectionViewCell : UICollectionViewCell {
	
	let label : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createSize(15)
		label.adjustsFontSizeToFitWidth = true
		label.adjustsFontForContentSizeCategory = true
		
		return label
	}()
	
	let imageView : UIImageView = {
		let imageView = UIImageView()
		//additional setup
		return imageView
	}()
	
	required override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	func configureView() {
		addSubview(imageView)
		addSubview(label)
		
		contentView.backgroundColor = .blue
		contentView.layer.cornerRadius = 5
		contentView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.7, offset: CGSize(width: 2, height: 2), radius: 5.0)
		
		applyConstraints()
	}
	
	func applyConstraints(){
		imageView.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(10)
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.8)
			make.centerX.equalToSuperview()
		}
		label.snp.makeConstraints { (make) in
			make.top.equalTo(imageView.snp.bottom)
			make.bottom.equalToSuperview()
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
}
