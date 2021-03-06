//
//  SettingsProfileHeader.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import FirebaseUI

class SettingsProfileHeader: UIView {
	
    var parentViewController: UIViewController?
    
	let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	let profileImageView : UIImageView = {
		let imageView = UIImageView()
		imageView.layer.masksToBounds = false
		imageView.clipsToBounds = true
		imageView.backgroundColor = .red
		imageView.layer.cornerRadius = 8
		return imageView
	}()
    
	let nameLabel : UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.textAlignment = .left
		label.adjustsFontSizeToFitWidth = true
		label.font = Fonts.createBoldSize(18)
		return label
	}()
    
	let phoneNumberLabel : UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.textAlignment = .left
		label.adjustsFontSizeToFitWidth = true
		label.font = Fonts.createSize(16)
		return label
	}()
    
	let emailLabel : UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.textAlignment = .left
		label.adjustsFontSizeToFitWidth = true
		label.font = Fonts.createSize(16)
		return label
	}()
    
	let arrowImage : UIImageView = {
		let imageView = UIImageView()
		imageView.image = #imageLiteral(resourceName: "backButton")
		imageView.contentMode = .scaleAspectFit
		imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
		return imageView
	}()
    
	let buttonMask : UIButton = {
		let button = UIButton()
		button.backgroundColor = .clear
		return button
	}()
	
	func configureView() {
		addSubview(profileImageView)
		addSubview(nameLabel)
		addSubview(phoneNumberLabel)
		addSubview(emailLabel)
		addSubview(arrowImage)
		addSubview(buttonMask)
		
		buttonMask.addTarget(self, action: #selector(profileHeaderButtonPressed(_:)), for: .touchUpInside)
		
		setupUserDetails()
		applyContstraints()
	}
	
	func applyContstraints() {
		profileImageView.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.left.equalToSuperview().inset(15)
			make.height.width.equalTo(80)
		}
		phoneNumberLabel.snp.makeConstraints { (make) in
			make.centerY.right.equalToSuperview()
			make.left.equalTo(profileImageView.snp.right).offset(10)
			make.height.equalTo(25)
		}
		nameLabel.snp.makeConstraints { (make) in
			make.bottom.equalTo(phoneNumberLabel.snp.top)
			make.right.equalToSuperview()
			make.left.equalTo(profileImageView.snp.right).offset(10)
			make.height.equalTo(25)
		}
		emailLabel.snp.makeConstraints { (make) in
			make.top.equalTo(phoneNumberLabel.snp.bottom)
			make.right.equalToSuperview()
			make.left.equalTo(profileImageView.snp.right).offset(10)
			make.height.equalTo(25)
		}
		arrowImage.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.right.equalToSuperview().inset(10)
			make.width.height.equalTo(15)
		}
		buttonMask.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
	
	private func setupUserDetails() {
		emailLabel.text = CurrentUser.shared.learner.email
		phoneNumberLabel.text = CurrentUser.shared.learner.phone.formatPhoneNumber()
		nameLabel.text = CurrentUser.shared.learner.formattedName
		let reference = storageRef.child("student-info").child(CurrentUser.shared.learner.uid!).child("student-profile-pic1")
		profileImageView.sd_setImage(with: reference)
	}
	
	@objc private func profileHeaderButtonPressed(_ sender: UIButton) {
		if AccountService.shared.currentUserType == .learner {
            let controller = QTProfileViewController.controller
            let tutor = CurrentUser.shared.tutor ?? AWTutor(dictionary: [:])
            controller.user = tutor.copy(learner: CurrentUser.shared.learner)
            controller.profileViewType = .myLearner
			parentViewController?.navigationController?.pushViewController(controller, animated: true)
		} else {
            let controller = QTProfileViewController.controller
            controller.user = CurrentUser.shared.tutor
            controller.profileViewType = .myTutor
            parentViewController?.navigationController?.pushViewController(controller, animated: true)
		}
	}
	
}
