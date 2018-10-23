//
//  TutorCardCollectionViewBackground.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class TutorCardCollectionViewBackground: BaseView {
	let imageView: UIImageView = {
		let view = UIImageView()
		view.image = #imageLiteral(resourceName: "sad-face")
		return view
	}()
	
	let label: UILabel = {
		let label = UILabel()
		let formattedString = NSMutableAttributedString()
		formattedString
			.bold("No Tutors Found", 22, .white)
			.regular("\n\nSorry! We couldn't find anything, try adjusting your filters in the top right of the screen to improve your search results.", 17, .white)
		label.attributedText = formattedString
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()
	
	override func configureView() {
		addSubview(imageView)
		addSubview(label)
		super.configureView()
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { make in
			make.width.equalToSuperview().multipliedBy(0.75)
			make.centerX.equalToSuperview()
		}
		
		imageView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(0.6)
			make.bottom.equalTo(label.snp.top).inset(-25)
		}
	}
}

