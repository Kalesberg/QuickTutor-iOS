//
//  MyProfileBioView.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class MyProfileBioView : UIView {
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	var aboutMeLabel: UILabel = {
		let label = UILabel()
		
		label.text = "About Me"
		label.font = Fonts.createBoldSize(16)
		label.textColor = Colors.currentUserColor()
		label.translatesAutoresizingMaskIntoConstraints = false

		return label
	}()

	var bioLabel: UILabel = {
		let label = UILabel()
		
		label.numberOfLines = 0
		label.textColor = Colors.grayText
		label.font = Fonts.createSize(13)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	let divider : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.divider
		return view
	}()
	
	func configureView() {
		addSubview(aboutMeLabel)
		addSubview(bioLabel)
		addSubview(divider)
		
		backgroundColor = Colors.navBarColor
		applyConstraints()
	}
	
	func applyConstraints() {
		aboutMeLabel.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.left.equalToSuperview().inset(12)
			make.height.equalTo(30)
		}
		
		bioLabel.snp.makeConstraints { make in
			make.top.equalTo(aboutMeLabel.snp.bottom).inset(-5)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().inset(20)
			make.bottom.equalToSuperview().inset(15)
		}
		
		divider.snp.makeConstraints { make in
			make.height.equalTo(1)
			make.width.equalToSuperview().inset(20)
			make.centerX.bottom.equalToSuperview()
		}
	}
}
