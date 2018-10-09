//
//  SpreadTheLove.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class SettingsSpreadTheLove : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}

	let sectionTitle : UILabel = {
		let label = UILabel()
		label.text = "Spread the Love"
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(18)
		return label
	}()
	
	let settingsButton = SettingsButton(title: "Leave us a rating in the App Store!", subtitle: "We appreciate any feedback you give us.")
	
	let socialMediaTitle : UILabel = {
		let label = UILabel()
		label.text = "Follow us for updates!"
		label.textColor = Colors.currentUserColor()
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(14)
		return label
	}()
	
	let twitterButton : UIButton = {
		let button = UIButton()
		button.setImage(AccountService.shared.currentUserType == .learner ? #imageLiteral(resourceName: "twitter-icon-learner") : #imageLiteral(resourceName: "social-twitter"), for: .normal)
		button.tag = 0
		return button
	}()
	let facebookButton : UIButton = {
		let button = UIButton()
		button.setImage(AccountService.shared.currentUserType == .learner ? #imageLiteral(resourceName: "facebook-icon-learner") : #imageLiteral(resourceName: "social-facebook"), for: .normal)
		button.tag = 1
		return button
	}()
	let instagramButton : UIButton = {
		let button = UIButton()
		button.setImage(AccountService.shared.currentUserType == .learner ? #imageLiteral(resourceName: "instagram-icon-learner"): #imageLiteral(resourceName: "social-instagram"), for: .normal)
		button.tag = 2
		return button
	}()
	let divider : UIView = {
		let view = UIView()
		view.backgroundColor = .black
		return view
	}()
	lazy var stackView : UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [twitterButton, facebookButton, instagramButton])
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.contentMode = .scaleAspectFit
		stackView.spacing = 5
		return stackView
	}()
	
	let stackViewContainer : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.navBarColor
		return view
	}()
	
	func configureView() {
		addSubview(sectionTitle)
		addSubview(settingsButton)
		addSubview(divider)
		addSubview(stackViewContainer)
		stackViewContainer.addSubview(socialMediaTitle)
		stackViewContainer.addSubview(stackView)
		
		settingsButton.buttonMask.addTarget(self, action: #selector(rateUsOnAppStore(_:)), for: .touchUpInside)
		twitterButton.addTarget(self, action: #selector(socialMediaButtonPressed(_:)), for: .touchUpInside)
		facebookButton.addTarget(self, action: #selector(socialMediaButtonPressed(_:)), for: .touchUpInside)
		instagramButton.addTarget(self, action: #selector(socialMediaButtonPressed(_:)), for: .touchUpInside)
		
		applyContstraints()
	}
	
	func applyContstraints() {
		sectionTitle.snp.makeConstraints { (make) in
			make.top.left.right.equalToSuperview()
			make.height.equalTo(30)
		}
		settingsButton.snp.makeConstraints { (make) in
			make.top.equalTo(sectionTitle.snp.bottom).offset(20)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(60)
		}
		divider.snp.makeConstraints { (make) in
			make.top.equalTo(settingsButton.snp.bottom)
			make.centerX.width.equalToSuperview()
			make.height.equalTo(1)
		}
		stackViewContainer.snp.makeConstraints { (make) in
			make.top.equalTo(divider.snp.bottom)
			make.width.centerX.bottom.equalToSuperview()
		}
		socialMediaTitle.snp.makeConstraints { (make) in
			make.top.equalTo(settingsButton.snp.bottom).inset(-2)
			make.left.equalToSuperview().inset(10)
			make.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		stackView.snp.makeConstraints { (make) in
			make.top.equalTo(socialMediaTitle.snp.bottom).inset(-5)
			make.width.equalToSuperview().multipliedBy(0.8)
			make.centerX.bottom.equalToSuperview()
			make.height.equalTo(50)
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		settingsButton.roundCorners([.topLeft, .topRight], radius: 10)
		stackViewContainer.roundCorners([.bottomLeft, .bottomRight], radius: 10)
	}
	
	@objc private func rateUsOnAppStore(_ sender: UIButton) {
		SocialMedia.rateApp(appUrl: "itms-apps://itunes.apple.com/app/id1388092698", webUrl: "", completion: { _ in
		})
	}
	
	@objc private func socialMediaButtonPressed(_ sender: UIButton) {
		switch sender.tag {
		case 0:
			SocialMedia.rateApp(appUrl: "twitter://user?screen_name=QuickTutor", webUrl: "https://twitter.com/QuickTutor", completion: { _ in
			})
		case 1:
			SocialMedia.rateApp(appUrl: "fb://profile/1346980958682540", webUrl: "https://www.facebook.com/QuickTutorApp/", completion: { _ in
			})
		case 2:
			SocialMedia.rateApp(appUrl: "instagram://user?username=QuickTutor", webUrl: "https://www.instagram.com/quicktutor/", completion: { _ in
			})
		default:
			break
		}
	}
}
