//
//  TutorCardHeader.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class TutorCardHeader: UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	var parentViewController : UIViewController?
	var imageCount : Int = 0
	var userId : String = ""
	
	let profileImageView : UIImageView = {
		let imageView = UIImageView()
		imageView.scaleImage()
		imageView.clipsToBounds = true
		return imageView
	}()
	
	let name: UILabel = {
		var label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(20)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let reviewLabel: UILabel = {
		let label = UILabel()
		
		label.textColor = Colors.gold
		label.font = Fonts.createSize(15)
		label.textAlignment = .left
		
		return label
	}()
	
	let featuredSubject: UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(14)
		label.adjustsFontSizeToFitWidth = true
		label.isHidden = true
		
		return label
	}()
	
	let price : UILabel = {
		let label = UILabel()
		
		label.backgroundColor = Colors.green
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createBoldSize(14)
		label.layer.masksToBounds = true
		label.layer.cornerRadius = 10
		
		return label
	}()
	
	let buttonMask : UIButton = {
		let button = UIButton()
		button.backgroundColor = .clear
		return button
	}()
	
	
	let gradientView = UIView()
	
	func configureView() {
		addSubview(gradientView)
		addSubview(profileImageView)
		addSubview(name)
		addSubview(reviewLabel)
		addSubview(featuredSubject)
		addSubview(price)
		addSubview(buttonMask)
		
		buttonMask.addTarget(self, action: #selector(profileImageViewPressed), for: .touchUpInside)
		
		backgroundColor = Colors.navBarColor
		
		applyConstraints()
	}
	
	func applyConstraints() {
		gradientView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		profileImageView.snp.makeConstraints { make in
			make.left.equalToSuperview().inset(15)
			make.width.height.equalTo(90)
			make.bottom.equalToSuperview().inset(15)
		}
		name.snp.makeConstraints { make in
			make.left.equalToSuperview().inset(125)
			make.top.equalTo(profileImageView).inset(5)
			make.right.equalToSuperview().inset(5)
		}
		reviewLabel.snp.makeConstraints { make in
			make.top.equalTo(name.snp.bottom).inset(-5)
			make.left.right.equalTo(name)
		}
		featuredSubject.snp.makeConstraints { make in
			make.top.equalTo(reviewLabel.snp.bottom).inset(-5)
			make.left.equalToSuperview().inset(125)
			make.right.equalToSuperview().inset(5)
		}
		price.snp.makeConstraints { (make) in
			make.top.right.equalToSuperview().inset(12)
			make.width.equalTo(70)
			make.height.equalTo(20)
		}
		buttonMask.snp.makeConstraints { (make) in
			make.edges.equalTo(profileImageView)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		gradientView.applyGradient(firstColor: Colors.navBarColor.cgColor, secondColor: UIColor.clear.cgColor, angle: 0, frame: gradientView.bounds)
		profileImageView.roundCorners(.allCorners, radius: 8)
		
	}
	
	@objc func profileImageViewPressed(_ sender: UIButton) {
		parentViewController?.displayProfileImageViewer(imageCount: imageCount, userId: userId)
	}
}
