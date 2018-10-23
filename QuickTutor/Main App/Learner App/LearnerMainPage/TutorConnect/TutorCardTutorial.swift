//
//  TutorCardTutorial.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class TutorCardTutorial: InteractableView, Interactable {
	let imageView: UIImageView = {
		let view = UIImageView()
		view.image = #imageLiteral(resourceName: "finger")
		return view
	}()
	
	let label: UILabel = {
		let label = UILabel()
		label.text = "Swipe left to see more tutors!"
		label.textAlignment = .center
		label.textColor = .white
		label.font = Fonts.createBoldSize(20)
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	override func configureView() {
		addSubview(imageView)
		addSubview(label)
		super.configureView()
		
		backgroundColor = UIColor.black.withAlphaComponent(0.85)
		alpha = 0
		clipsToBounds = true
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(1.2)
			make.width.equalToSuperview().multipliedBy(0.8)
		}
		
		imageView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(0.9)
		}
	}
	
	func touchEndOnStart() {
		UIView.animate(withDuration: 0.6, animations: {
			self.alpha = 0.0
		}) { (true) in
			self.isHidden = true
			self.removeFromSuperview()
		}
	}
}
