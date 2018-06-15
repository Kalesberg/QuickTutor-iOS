//
//  FeaturedCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class FeaturedTutorCollectionViewCell : UICollectionViewCell {
	
	let featuredTutor = FeaturedTutorView()
	
	let view : UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(red: 105/255, green: 105/255, blue: 192/255, alpha: 1.0)
		view.layer.cornerRadius = 10
		return view
	}()
	
	let price : UILabel = {
		let label = UILabel()
		
		label.textAlignment = .center
		label.textColor = .white
		label.font = Fonts.createSize(13)
		label.adjustsFontSizeToFitWidth = true
		label.backgroundColor = .clear
		
		return label
	}()
	
	required override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	func configureView() {
		contentView.addSubview(featuredTutor)
		contentView.addSubview(view)
		view.addSubview(price)
        
        backgroundColor = Colors.navBarColor
        applyDefaultShadow()

		featuredTutor.backgroundColor = .clear
		applyConstraints()
	}
	func applyConstraints(){
		featuredTutor.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.center.equalToSuperview()
			make.height.equalToSuperview()
		}
		view.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(-10)
			make.left.equalToSuperview().inset(-5)
			make.width.equalTo(60)
			make.height.equalTo(20)
		}
		price.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
}
