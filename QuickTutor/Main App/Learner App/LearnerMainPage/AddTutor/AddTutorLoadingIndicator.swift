//
//  AddTutorLoadingIndicator.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Lottie

class AWLoadingIndicatorView: BaseView {
	let loadingView: LOTAnimationView = {
		let lottieView = LOTAnimationView(name: "loading11")
		lottieView.contentMode = .scaleAspectFit
		lottieView.loopAnimation = true
		lottieView.alpha = 0
		return lottieView
	}()
	
	let searchingLabel: UILabel = {
		let label = UILabel()
		label.font = Fonts.createSize(13)
		label.textAlignment = .left
		label.textColor = .white
		return label
	}()
	
	let containerView = UIView()
	let defaultText = "Try searching for tutors by their username"
	
	override func configureView() {
		addSubview(containerView)
		containerView.addSubview(loadingView)
		containerView.addSubview(searchingLabel)
		super.configureView()
		searchingLabel.text = defaultText
		applyConstraints()
	}
	
	override func applyConstraints() {
		searchingLabel.snp.makeConstraints { make in
			make.centerX.bottom.top.equalToSuperview()
		}
		loadingView.snp.makeConstraints { make in
			make.right.equalTo(searchingLabel.snp.left).inset(10)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(50)
		}
		containerView.snp.makeConstraints { make in
			make.centerX.top.equalToSuperview()
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	func displayLoadingIndicator(with searchText: String) {
		loadingView.isHidden = false
		UIView.animate(withDuration: 0.2) {
			self.loadingView.alpha = 1.0
			self.searchingLabel.alpha = 1.0
			self.searchingLabel.text = searchText
			self.loadingView.play()
		}
	}
	
	func dismissLoadingIndicator() {
		UIView.animate(withDuration: 0.2) {
			self.loadingView.alpha = 0
			self.searchingLabel.alpha = 0
			self.loadingView.stop()
		}
	}
	
	func displayDefaultText() {
		UIView.animate(withDuration: 0.2) {
			self.searchingLabel.alpha = 1.0
			self.loadingView.alpha = 0
			self.searchingLabel.text = self.defaultText
		}
	}
}
