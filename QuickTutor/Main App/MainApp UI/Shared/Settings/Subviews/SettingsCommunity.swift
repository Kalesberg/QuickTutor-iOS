//
//  settingsCommunity.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class SettingsCommunity : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	let sectionTitle : UILabel = {
		let label = UILabel()
		label.text = "Community"
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(18)
		return label
	}()
	
	let communityGuidelines = SettingsButton(title: "Commnuity Guidelines", subtitle: "Read our guidelines on interacting with others.")
	let userSafety = SettingsButton(title: "User Safety", subtitle: "Read how to stay safe using QuickTutor.")
	
	let divider : UIView = {
		let view = UIView()
		view.backgroundColor = .black
		return view
	}()
	
	private func configureView() {
		addSubview(sectionTitle)
		addSubview(communityGuidelines)
		addSubview(divider)
		addSubview(userSafety)
		
		communityGuidelines.buttonMask.addTarget(self, action: #selector(communityGuideLinesPressed(_:)), for: .touchUpInside)
		userSafety.buttonMask.addTarget(self, action: #selector(userSafetyPressed(_:)), for: .touchUpInside)

		applyContstraints()
	}
	
	private func applyContstraints() {
		sectionTitle.snp.makeConstraints { (make) in
			make.top.left.right.equalToSuperview()
			make.height.equalTo(30)
		}
		communityGuidelines.snp.makeConstraints { (make) in
			make.top.equalTo(sectionTitle.snp.bottom).offset(10)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(60)
		}
		divider.snp.makeConstraints { (make) in
			make.top.equalTo(communityGuidelines.snp.bottom)
			make.centerX.width.equalToSuperview()
			make.height.equalTo(1)
		}
		userSafety.snp.makeConstraints { (make) in
			make.top.equalTo(divider.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(60)
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		communityGuidelines.roundCorners([.topLeft, .topRight], radius: 10)
		userSafety.roundCorners([.bottomLeft, .bottomRight], radius: 10)
	}
	@objc private func communityGuideLinesPressed(_ sender: UIButton) {
		let next = WebViewVC()
		next.contentView.title.label.text = "Community Guidelines"
		next.url = "https://www.quicktutor.com/community/community-guidelines"
		next.loadAgreementPdf()
		navigationController.pushViewController(next, animated: true)
	}
	@objc private func userSafetyPressed(_ sender: UIButton) {
		let next = WebViewVC()
		next.contentView.title.label.text = "User Safety"
		next.url = "https://www.quicktutor.com/community/user-safety"
		next.loadAgreementPdf()
		navigationController.pushViewController(next, animated: true)
	}
}
