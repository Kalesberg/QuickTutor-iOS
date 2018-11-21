//
//  SettingsVC.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class SettingsVC : BaseViewController {
	override var contentView: SettingsView {
		return view as! SettingsView
	}
    
	override func loadView() {
		view = SettingsView()
	}
    
	override func viewDidLoad() {
		super.viewDidLoad()
        setupNavBar()
        contentView.settingsAccount.parentViewController = self
        contentView.settingsProfileHeader.parentViewController = self
	}
    
    func setupNavBar() {
        navigationItem.title = "Settings"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupFacebook() {
        
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if AccountService.shared.currentUserType == .tutor {
			contentView.updateLocationsSubtitle()
		}
	
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.scrollView.setContentSize()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}


