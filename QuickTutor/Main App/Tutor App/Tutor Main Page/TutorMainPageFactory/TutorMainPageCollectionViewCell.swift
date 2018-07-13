//
//  TutorMainPageCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/23/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class TutorMainPageCollectionViewCell : UICollectionViewCell {
	
	required override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    let imageView : UIImageView = {
        let view = UIImageView()
        
        view.scaleImage()
        
        return view
    }()
	
	let label : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createSize(13)
		label.textAlignment = .center
		label.numberOfLines = 0
		label.adjustsFontSizeToFitWidth = true
		label.backgroundColor = Colors.navBarColor
		
		return label
	}()
	
	func configureView() {
		addSubview(imageView)
		addSubview(label)
		
		
		
		clipsToBounds = true
		layer.cornerRadius = 4
		applyDefaultShadow()
		applyConstraints()
	}
	
	func applyConstraints() {
		imageView.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview().inset(-15)
			make.centerX.equalToSuperview()
		}
		
		label.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.height.equalTo(30)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
		}
	}
	
	func touchStart() {
		alpha = 0.6
	}
	
	func didDragOff() {
		alpha = 1.0
	}
}