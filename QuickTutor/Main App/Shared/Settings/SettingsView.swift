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

class SettingsView : UIView {

    var parentViewController: UIViewController?
	
	let scrollView : UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.isDirectionalLockEnabled = true
		scrollView.alwaysBounceVertical = true
		scrollView.isExclusiveTouch = true
		scrollView.isUserInteractionEnabled = true
		scrollView.backgroundColor = Colors.backgroundDark
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

    func configureView() {
		addSubview(scrollViewContainer)
		scrollViewContainer.addSubview(scrollView)
		scrollView.addSubview(container)
		scrollView.addSubview(settingsProfileHeader)
		container.addSubview(settingsSpreadTheLove)
		container.addSubview(settingsCommunity)
		container.addSubview(settingsAccount)
		container.backgroundColor = Colors.backgroundDark
		setupShadows()
	}
	
    func applyConstraints() {
		scrollViewContainer.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.centerX.width.bottom.equalToSuperview()
		}
		scrollView.snp.makeConstraints { (make) in
			make.centerX.top.width.bottom.equalToSuperview()
		}
		settingsProfileHeader.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview()
			make.height.equalTo(100)
		}
		container.snp.makeConstraints { (make) in
			make.top.equalTo(settingsProfileHeader.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(AccountService.shared.currentUserType == .learner ? 660 : 820)
		}
		if AccountService.shared.currentUserType == .tutor {
			addLocationSubview()
		}
		settingsSpreadTheLove.snp.makeConstraints { (make) in
			make.top.equalTo( AccountService.shared.currentUserType == .tutor ? settingsLocation.snp.bottom : settingsProfileHeader.snp.bottom).offset(20)
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
			make.height.equalTo(AccountService.shared.currentUserType == .learner ? 260 : 290)
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
		gradientLayer.colors =  [Colors.navBarColor, Colors.backgroundDark].map { $0.cgColor }
		gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
		settingsProfileHeader.layer.insertSublayer(gradientLayer, at: 0)
	}
	
	private func addLocationSubview() {
		settingsLocation.applySettingsShadow()
		scrollView.addSubview(settingsLocation)
		settingsLocation.snp.makeConstraints { (make) in
			make.top.equalTo(settingsProfileHeader.snp.bottom).offset(20)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.centerX.equalToSuperview()
			make.height.equalTo(90)
		}
	}
	private func setupShadows() {
		settingsSpreadTheLove.applySettingsShadow()
		settingsCommunity.applySettingsShadow()
		settingsAccount.applySettingsShadow()
	}
	func updateLocationsSubtitle() {
		settingsLocation.location.subtitleLabel.text = CurrentUser.shared.tutor.location != nil ? CurrentUser.shared.tutor.region : "This is the location displayed in your profile."
	}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

