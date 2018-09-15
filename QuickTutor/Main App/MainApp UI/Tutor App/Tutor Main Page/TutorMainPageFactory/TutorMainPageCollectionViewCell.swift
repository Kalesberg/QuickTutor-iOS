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
        
        view.contentMode = .scaleAspectFill
        
        return view
    }()
	
	let label : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createBoldSize(13)
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
        label.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
            make.width.top.equalToSuperview()
        }
	}
	
	func touchStart() {
		alpha = 0.6
	}
	
	func didDragOff() {
		alpha = 1.0
	}
}
