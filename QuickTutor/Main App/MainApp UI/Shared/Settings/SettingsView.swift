//
//  SettingsView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI

class SettingsView : MainLayoutTitleBackButton {
	
	let scrollView : UIScrollView = {
		let scrollView = UIScrollView()
		
		scrollView.isDirectionalLockEnabled = true
		scrollView.alwaysBounceVertical = true
		scrollView.canCancelContentTouches = false
		scrollView.isExclusiveTouch = false
		scrollView.backgroundColor = .clear
		scrollView.showsVerticalScrollIndicator = false
		
		return scrollView
	}()
	
	let scrollViewContainer = UIView()
	let settingsLocation = SettingsLocation()
	let settingsProfileHeader = SettingsProfileHeader()
	let settingsSpreadTheLove = SettingsSpreadTheLove()
	let settingsCommunity = SettingsCommunity()
	let settingsAccount = SettingsAccount()
	let container = UIView()

	override func configureView() {
		addSubview(scrollViewContainer)
		scrollViewContainer.addSubview(scrollView)
		scrollView.addSubview(container)
		scrollView.addSubview(settingsProfileHeader)
		container.addSubview(settingsSpreadTheLove)
		container.addSubview(settingsCommunity)
		container.addSubview(settingsAccount)
		super.configureView()
		
		container.backgroundColor = Colors.backgroundDark

		setupShadows()
		
		title.label.text = "Settings"
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		scrollViewContainer.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-1)
			make.centerX.width.bottom.equalToSuperview()
		}
		scrollView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-1)
			make.centerX.width.bottom.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		container.snp.makeConstraints { (make) in
			make.top.equalTo(settingsProfileHeader.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(AccountService.shared.currentUserType == .learner ? 600 : 700)
		}
		settingsProfileHeader.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview()
			make.height.equalTo(100)
		}
		settingsSpreadTheLove.snp.makeConstraints { (make) in
			make.top.equalTo(settingsProfileHeader.snp.bottom).offset(20)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.centerX.equalToSuperview()
			make.height.equalTo(230)
		}
		settingsCommunity.snp.makeConstraints { (make) in
			make.top.equalTo(settingsSpreadTheLove.snp.bottom).offset(20)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.centerX.equalToSuperview()
			make.height.equalTo(150)
		}
		settingsAccount.snp.makeConstraints { (make) in
			make.top.equalTo(settingsCommunity.snp.bottom).offset(20)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.centerX.equalToSuperview()
			make.height.equalTo(AccountService.shared.currentUserType == .learner ? 200 : 260)
		}
		if AccountService.shared.currentUserType == .tutor {
			updateConstraintsForTutor()
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		setupGradientView()
		setupGradientViewForHeader()
	}
	
	private func setupGradientView() {
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height * 0.4)
		gradientLayer.colors =  [Colors.navBarColor, Colors.backgroundDark].map{ $0.cgColor }
		gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
		scrollViewContainer.layer.insertSublayer(gradientLayer, at: 0)
	}
	
	private func setupGradientViewForHeader() {
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = CGRect(x: 0, y: 0, width: settingsProfileHeader.frame.width, height: settingsProfileHeader.frame.height)
		gradientLayer.colors =  [Colors.navBarColor, Colors.backgroundDark].map{ $0.cgColor }
		gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
		settingsProfileHeader.layer.insertSublayer(gradientLayer, at: 0)
	}
	
	private func updateConstraintsForTutor() {
		settingsLocation.applySettingsShadow()
		scrollView.addSubview(settingsLocation)
		settingsLocation.snp.makeConstraints { (make) in
			make.top.equalTo(settingsProfileHeader.snp.bottom).offset(20)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.centerX.equalToSuperview()
			make.height.equalTo(90)
		}
		settingsSpreadTheLove.snp.remakeConstraints { (make) in
			make.top.equalTo(settingsLocation.snp.bottom).offset(20)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.centerX.equalToSuperview()
			make.height.equalTo(230)
		}
	}
	private func setupShadows() {
		settingsSpreadTheLove.applySettingsShadow()
		settingsCommunity.applySettingsShadow()
		settingsAccount.applySettingsShadow()
	}
	func updateLocationsSubtitle() {
		print(CurrentUser.shared.tutor.region)
		settingsLocation.location.subtitleLabel.text = CurrentUser.shared.tutor.location != nil ? CurrentUser.shared.tutor.region : "This is the location displayed in your profile."
	}
}

