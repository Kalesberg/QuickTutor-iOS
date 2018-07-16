//
//  SessionTypeCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
//
//  RequestSessionCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class RequestSessionTypeCell : UITableViewCell {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	var requestData : TutorPreferenceData? {
		didSet {
			configureButtons(preference: requestData?.sessionPreference)
			setSessionTypeLabel(preference: requestData?.sessionPreference)
			setDistancePreferenceLabel(distance: requestData?.travelPreference)
		}
	}
	
	let distancePreferenceLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = #colorLiteral(red: 0.4901960784, green: 0.4980392157, blue: 0.9568627451, alpha: 1)
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.font = Fonts.createSize(15)
		label.numberOfLines = 2
		
		return  label
	}()
	
	let sessionTypePreferenceLabel : UILabel = {
		let label = UILabel()

		label.textColor = .white
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.font = Fonts.createBoldSize(14)
		label.sizeToFit()
		
		return label
	}()
	
	let container = UIView()
	
	let inPersonButton : UIButton = {
		let button = UIButton()
		
		button.setTitle("In-Person", for: .normal)
		button.titleLabel?.font = Fonts.createSize(20)
		button.titleLabel?.textAlignment = .center
		button.titleLabel?.textColor = .white
		button.titleLabel?.adjustsFontSizeToFitWidth = true
		button.backgroundColor = Colors.notSelectedPurple
		button.isSelected = false
	
		return button
	}()
	
	let videoCallButton : UIButton = {
		let button = UIButton()
		
		button.setTitle("Online (Video)", for: .normal)
		button.titleLabel?.font = Fonts.createSize(20)
		button.titleLabel?.textAlignment = .center
		button.titleLabel?.textColor = .white
		button.titleLabel?.adjustsFontSizeToFitWidth = true
		button.backgroundColor = Colors.notSelectedPurple
		button.isSelected = false
		
		return button
	}()
	
	var delegate : RequestSessionDelegate?
	
	func configureTableViewCell() {
		addSubview(distancePreferenceLabel)
		addSubview(sessionTypePreferenceLabel)
		addSubview(container)
		container.addSubview(inPersonButton)
		container.addSubview(videoCallButton)
		
		inPersonButton.addTarget(self, action: #selector(inPersonButtonPress(_:)), for: .touchUpInside)
		videoCallButton.addTarget(self, action: #selector(onlineButtonPress(_:)), for: .touchUpInside)

		backgroundColor = Colors.navBarColor
		selectionStyle = .none
		
		applyConstraints()
	}
	
	func applyConstraints() {
		distancePreferenceLabel.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(20)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalTo(30)
		}
		container.snp.makeConstraints { (make) in
			make.top.equalTo(distancePreferenceLabel.snp.bottom)
			make.centerX.equalToSuperview()
			make.height.equalTo(70)
			make.width.equalTo(282)
		}
		videoCallButton.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.height.equalTo(50)
			make.width.equalTo(140)
			make.right.equalToSuperview()
		}
		inPersonButton.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.height.equalTo(50)
			make.width.equalTo(140)
			make.left.equalToSuperview()
		}
		sessionTypePreferenceLabel.snp.makeConstraints { (make) in
			make.top.equalTo(container.snp.bottom).inset(-10)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalTo(30)
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		inPersonButton.roundCorners([.topLeft, .bottomLeft], radius: 6)
		videoCallButton.roundCorners([.topRight, .bottomRight], radius: 6)
	}
	@objc private func inPersonButtonPress(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		if sender.isSelected {
			sender.backgroundColor = Colors.selectedPurple
			UIView.animate(withDuration: 0.1) {
				sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
			}
			if videoCallButton.isEnabled {
				videoCallButton.transform = .identity
				videoCallButton.backgroundColor = Colors.notSelectedPurple
				videoCallButton.isSelected = false
			}
			delegate?.isOnlineChanged(isOnline: false)
		} else {
			UIView.animate(withDuration: 0.1) {
				sender.transform = .identity
			}
			sender.backgroundColor = Colors.notSelectedPurple
			delegate?.isOnlineChanged(isOnline: nil)
		}
	}
	@objc private func onlineButtonPress(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		if sender.isSelected {
			UIView.animate(withDuration: 0.1) {
				sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
			}
			sender.backgroundColor = Colors.selectedPurple
			if inPersonButton.isEnabled {
				inPersonButton.transform = .identity
				inPersonButton.backgroundColor = Colors.notSelectedPurple
				inPersonButton.isSelected = false
			}
			delegate?.isOnlineChanged(isOnline: true)
		} else {
			UIView.animate(withDuration: 0.1) {
				sender.transform = .identity
			}
			sender.backgroundColor = Colors.notSelectedPurple
			delegate?.isOnlineChanged(isOnline: nil)
		}
	}
	private func setSessionTypeLabel(preference: Int?) {
		let name = requestData?.name
		
		if let preference = preference {
			switch preference {
			case 0:
				sessionTypePreferenceLabel.text = "\(name != nil ? name! : "This tutor") is only available to message."
			case 1:
				sessionTypePreferenceLabel.text = "\(name != nil ? name! : "This tutor") is only available for Online (Video) sessions."
			case 2:
				sessionTypePreferenceLabel.text = "\(name != nil ? name! : "This tutor") is only available for in-person sessions."
			case 3:
				sessionTypePreferenceLabel.text = "\(name != nil ? name! : "This tutor") is available for both session types."
			default:
				sessionTypePreferenceLabel.text = "\(name != nil ? name! : "This tutor") is available for both session types."
			}
		} else {
			sessionTypePreferenceLabel.text = "\(name != nil ? name! : "This tutor") is available for both session types."
		}
	}
	
	private func setDistancePreferenceLabel(distance: Int?) {
		let name = requestData?.name
		if let distance = distance {
			distancePreferenceLabel.text = "\(name != nil ? name! : "This tutor") is willing to travel \(distance) miles for this session."
		} else {
			distancePreferenceLabel.text = "\(name != nil ? name! : "This tutor") has no travel preference."
		}
	}
	
	private func configureButtons(preference: Int?) {
		if let preference = preference {
			switch preference {
			case 0:
				inPersonButton.backgroundColor = UIColor.gray
				inPersonButton.isEnabled = false
				videoCallButton.backgroundColor = UIColor.gray
				videoCallButton.isEnabled = false
			case 1:
				inPersonButton.backgroundColor = UIColor.gray
				inPersonButton.isEnabled = false
			case 2:
				videoCallButton.backgroundColor = UIColor.gray
				videoCallButton.isEnabled = false
			default:
				return
			}
		}
	}
}
