//
//  Messaging.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

class MessageView : MainLayoutOneButton {
	
	var messagesButton = NavbarButtonMessages()
	var backgroundView = InteractableObject()
	
	var label = UILabel()
	
	var messagesView = BaseView()
	var messagesSessionsControl = UISegmentedControl()
	
	var search         = SearchBar()
	
	override func configureView() {
		addSubview(backgroundView)
		
		//navbar.addSubview(sidebarButton)
		navbar.addSubview(search)
		
		messagesView.addSubview(messagesSessionsControl)
		addSubview(messagesView)
		addSubview(label)
		super.configureView()
		
		backgroundView.backgroundColor = .black
		backgroundView.alpha = 0.0
		
		label.text = "Here is Messaging"
		label.textAlignment = .center
		label.font = Fonts.createSize(40)
		label.adjustsFontSizeToFitWidth = true
		label.textColor = .white
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		search.snp.makeConstraints { (make) in
			make.height.equalTo(35) //(1 - (DeviceInfo.multiplier - 1)) *
			make.width.equalToSuperview().multipliedBy(0.65)
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().inset(5)
		}
		
		
		backgroundView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		messagesView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.left.equalTo(layoutMarginsGuide.snp.left)
			make.right.equalTo(layoutMarginsGuide.snp.right)
			make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
		}
		
		messagesSessionsControl.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.height.equalTo(30)
			make.width.equalToSuperview().multipliedBy(0.75)
			make.centerX.equalToSuperview()
		}
		label.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalToSuperview().dividedBy(2)
		}
	}
}

class Message : BaseViewController {
	
	override var contentView: MessageView {
		return view as! MessageView
	}
	override func loadView() {
		view = MessageView()
	}
	
	private var hasPaymentMethod : Bool!
	private var hasStudentBio : Bool!
	
	let user = UserData.userData
	let image = LocalImageCache.localImageManager
	
	var parentPageViewController : PageViewController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print("view did load.")

	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		//temporary
		hasPaymentMethod = UserDefaultData.localDataManager.hasPaymentMethod
		hasStudentBio = UserDefaultData.localDataManager.hasBio
		
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		print("view will appear")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@objc internal func controlChanged() {
		let _ = contentView.messagesSessionsControl.subviews[0]
		let _ = contentView.messagesSessionsControl.subviews[1]
		
		//        switch contentView.messagesSessionsControl.selectedSegmentIndex
		//        {
		//        case 0:
		//            contentView.messagesSessionsControl.layer.sublayers![0].frame = CGRect(x: leftView.frame.minX + 1.5, y: leftView.frame.minY + 1.5, width: leftView.frame.width - 7, height: leftView.frame.height - 3)
		//        case 1:
		//            contentView.messagesSessionsControl.layer.sublayers![0].frame = CGRect(x: rightView.frame.minX + 1.5, y: rightView.frame.minY + 1.5, width: rightView.frame.width - 7, height: rightView.frame.height - 3)
		//        default:
		//            break
		//        }
	}
	
	override func handleNavigation() {}
	
	internal func showSidebar() {}
	
	internal func showBackground() {}
	
	internal func hideSidebar() {}
	
	internal func hideBackground() {}
}
extension Message : PageObservation {
	
	func getParentPageViewController(parentRef: PageViewController) {
		parentPageViewController = parentRef
	}
	func accessSetViewControllers() {
		parentPageViewController.setViewControllers([Message()], direction: .forward, animated: true, completion: nil)
	}
}
