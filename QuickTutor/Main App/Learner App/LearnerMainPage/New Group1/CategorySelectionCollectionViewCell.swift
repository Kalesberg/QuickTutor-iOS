//
//  CategorySelectionCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class CategorySelectionCollectionViewCell : UICollectionViewCell {
	
	required override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let category : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.text = "Hello"
		label.font = Fonts.createSize(15)
		label.alpha = 0.6
		
		return label
	}()
	
	let dot : UIView = {
		let view = UIView()
		
		view.layer.cornerRadius = view.frame.size.width / 2
		view.clipsToBounds = true
		view.layer.borderColor = UIColor.white.cgColor
		view.layer.borderWidth = 5.0
		
		return view
	}()
	
	override var isSelected : Bool {
		didSet {
			category.alpha = isSelected ? 1.0 : 0.6
			dot.isHidden = isSelected ? false : true
		}
	}
	
	func configureView() {
		addSubview(category)
		addSubview(dot)
		dot.isHidden = true
		
		applyConstraints()
	}
	
	func applyConstraints(){
		category.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.9)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
		dot.snp.makeConstraints { (make) in
			make.top.equalTo(category.snp.bottom)
			make.height.width.equalToSuperview().multipliedBy(0.1)
			make.centerX.equalToSuperview()
		}
	}
}

