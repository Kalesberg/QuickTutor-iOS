//
//  RatingCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class RatingCell : BasePostSessionCell {

	let ratingView : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.newNavigationBarBackground
		return view
	}()
	
	let descriptionLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = Colors.gold
		label.font = Fonts.createBoldSize(20)
		label.textAlignment = .center
		
		return label
	}()
	
	let starView = RatingStarView()
	let descriptions =  ["Not good", "Disappointing", "Okay", "Good", "Excellent"]
	
	var delegate : PostSessionInformationDelegate?
	
	override func configureCollectionViewCell() {
		addSubview(ratingView)
		ratingView.addSubview(starView)
		ratingView.addSubview(descriptionLabel)
		super.configureCollectionViewCell()

		starView.delegate = self
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		ratingView.snp.makeConstraints { (make) in
			make.top.equalTo(backgroundHeaderView.snp.bottom).inset(-1)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(125)
		}
		starView.snp.makeConstraints { (make) in
			make.bottom.equalTo(ratingView.snp.centerY)
			make.height.equalToSuperview().dividedBy(2.5)
			make.width.equalToSuperview().multipliedBy(0.8)
			make.centerX.equalToSuperview()
		}
		descriptionLabel.snp.makeConstraints { (make) in
			make.top.equalTo(ratingView.snp.centerY).inset(10)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		ratingView.roundCorners([.bottomLeft, .bottomRight], radius: 4)
	}
}

extension RatingCell : RatingStarViewDelegate {
	func didUpdateRating(rating: Int) {
		delegate?.didSelectRating(rating: rating)
		descriptionLabel.text = descriptions[rating - 1]
	}
}
