//
//  Settings.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorSettingsView : LearnerSettingsView {
    
    var visibleOnQT = ItemToggle()
    var visibleInfoLabel = SettingsItem()
	
	var tutorProfileView = SettingsProfileView()
	
	override var profileView: SettingsProfileView {
		get {
			return tutorProfileView
		}
		set {
			tutorProfileView = newValue as SettingsProfileView
		}
	}
	
    override func configureView() {
        scrollView.addSubview(visibleOnQT)
        scrollView.addSubview(visibleInfoLabel)
        super.configureView()
        
        navbar.backgroundColor = Colors.tutorBlue
        statusbarView.backgroundColor = Colors.tutorBlue
        
        visibleOnQT.label.text = "Show me on QuickTutor"
        visibleOnQT.toggle.isOn = true
        
        visibleInfoLabel.label.text = "With this enabled, learners will see your profile in their search results."
        visibleInfoLabel.label.font = Fonts.createSize(14)
        visibleInfoLabel.label.textColor = Colors.grayText
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        visibleOnQT.snp.remakeConstraints { (make) in
            make.top.equalTo(accountHeader.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        
        visibleOnQT.divider.snp.remakeConstraints { (make) in
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(signOut.snp.top)
        }
        
        visibleInfoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(visibleOnQT.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        
        visibleInfoLabel.label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(15)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerY.equalToSuperview()
        }
        
        signOut.snp.remakeConstraints { (make) in
            make.top.equalTo(visibleInfoLabel.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
    }
}

class TutorSettings : BaseViewController {
    
    override var contentView: TutorSettingsView {
        return view as! TutorSettingsView
    }
	
	var tutor : AWTutor!
	var wasHidden : Bool!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
		
		guard let tutor = CurrentUser.shared.tutor else { return }
		self.tutor = tutor
		wasHidden = tutor.isVisible
		
		contentView.visibleOnQT.toggle.addTarget(self, action: #selector(toggleSwitched(_:)), for: .touchUpInside)
		
		contentView.profileView.imageView.loadUserImages(by: tutor.images["image1"]!)
		contentView.profileView.label.text = "\(tutor.name!)\n\(tutor.phone.formatPhoneNumber())\n\(tutor.email!)"
    }
    override func loadView() {
        view = TutorSettingsView()
    }
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		contentView.visibleOnQT.toggle.isOn = tutor.isVisible
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		updateTutorVisibilityIfNeeded()
	}
	
	@objc private func toggleSwitched(_ sender : UISwitch) {
		tutor.isVisible = sender.isOn
	}
	
	private func updateTutorVisibilityIfNeeded() {
		if wasHidden != tutor.isVisible {
			FirebaseData.manager.updateTutorVisibility(uid: tutor.uid, status: (tutor.isVisible) ? 0 : 1)
		}
	}
    override func handleNavigation() {
		
    }
}
