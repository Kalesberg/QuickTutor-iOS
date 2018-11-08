//
//  FeaturedCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class FeaturedTutorCollectionViewCell: UICollectionViewCell {
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(frame _: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
    let featuredTutor = FeaturedTutorView()
	
    let view: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.green
        view.layer.cornerRadius = 10
        return view
    }()

    let price: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(13)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .clear
        return label
    }()
	
    func configureView() {
        contentView.addSubview(featuredTutor)
        contentView.addSubview(view)
        view.addSubview(price)
        backgroundColor = Colors.navBarColor
        applyDefaultShadow()

        featuredTutor.backgroundColor = .clear
        applyConstraints()
    }

    func applyConstraints() {
        featuredTutor.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(-3)
        }
        view.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(-13)
            make.left.equalToSuperview().inset(-5)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
        price.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
