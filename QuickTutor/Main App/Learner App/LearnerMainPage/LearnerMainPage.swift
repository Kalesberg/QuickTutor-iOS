//
//  LearnerMainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class LearnerMainPageView : MainPageView {
	
	var search  = SearchBar()
	var learnerSidebar = LearnerSideBar()
	
	let tableView : UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
	
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		tableView.estimatedSectionHeaderHeight = 30
		
		return tableView
	}()
	
	override var sidebar: Sidebar {
		get {
			return learnerSidebar
		} set {
			if newValue is LearnerSideBar {
				learnerSidebar = newValue as! LearnerSideBar
			} else {
				print("incorrect sidebar type for LearnerMainPage")
			}
		}
	}
	
	override func configureView() {
		navbar.addSubview(search)
		addSubview(tableView)
		super.configureView()
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		search.snp.makeConstraints { (make) in
			make.height.equalTo(35)
			make.width.equalToSuperview().multipliedBy(0.65)
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().inset(5)
		}
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).multipliedBy(1.05)
			make.bottom.equalTo(safeAreaLayoutGuide)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
}

class LearnerMainPage : MainPage {
	
	override var contentView: LearnerMainPageView {
		return view as! LearnerMainPageView
	}
	override func loadView() {
		view = LearnerMainPageView()
	}
	
	var categories = ["Categories","Experiences", "Academics", "Outdoors", "Remedial","Health","Trades","Sports","Tech","Auto","Language","The Arts","Business"]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureView()
		if let image = LocalImageCache.localImageManager.getImage(number: "1") {
			contentView.sidebar.profileView.profilePicView.image = image
		}
	}
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		contentView.sidebar.applyGradient(firstColor: Colors.tutorBlue.cgColor, secondColor: Colors.sidebarPurple.cgColor, angle: 200, frame: contentView.sidebar.bounds)
		contentView.tableView.reloadData()
	}
	override func updateSideBar() {
		contentView.sidebar.profileView.profileNameView.label.text = user.name
		contentView.sidebar.profileView.profileSchoolView.label.text = user.school
		contentView.sidebar.profileView.profilePicView.image = image.getImage(number: "1")
	}
	private func configureView() {
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		
		contentView.tableView.register(FeaturedTutorTableViewCell.self, forCellReuseIdentifier: "featuredCell")
		contentView.tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "categoryCell")
	}
	
	override func handleNavigation() {
		super.handleNavigation()
		
		if(touchStartView == contentView.sidebar.paymentItem) {
			navigationController?.pushViewController(hasPaymentMethod ? CardManager() : LearnerPayment(), animated: true)
			hideSidebar()
			hideBackground()
		} else if(touchStartView == contentView.sidebar.settingsItem) {
			navigationController?.pushViewController(LearnerSettings(), animated: true)
			hideSidebar()
			hideBackground()
		} else if(touchStartView == contentView.sidebar.profileView) {
			navigationController?.pushViewController(LearnerMyProfile(), animated: true)
			hideSidebar()
			hideBackground()
		} else if(touchStartView == contentView.sidebar.reportItem) {
			navigationController?.pushViewController(LearnerFileReport(), animated: true)
			hideSidebar()
			hideBackground()
		} else if(touchStartView == contentView.sidebar.legalItem) {
			hideSidebar()
			hideBackground()
			//take user to legal on our website
		} else if(touchStartView == contentView.sidebar.helpItem) {
			navigationController?.pushViewController(LearnerHelp(), animated: true)
			hideSidebar()
			hideBackground()
		} else if(touchStartView == contentView.sidebar.becomeQTItem) {
			navigationController?.pushViewController(BecomeTutor(), animated: true)
			hideSidebar()
			hideBackground()
		} else if (touchStartView is SearchBar) {
			self.present(SearchSubjects(), animated: true, completion: nil)
		}
	}
}

extension LearnerMainPage : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.estimatedRowHeight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
			tableView.estimatedRowHeight = 225
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "featuredCell", for: indexPath) as! FeaturedTutorTableViewCell
			
			tableView.estimatedRowHeight = 200
			return cell
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 12
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = SectionHeader()
		view.category.text = categories[section]
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return tableView.estimatedSectionHeaderHeight
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

}


