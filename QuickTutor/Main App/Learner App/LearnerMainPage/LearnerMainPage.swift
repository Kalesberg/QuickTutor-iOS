//
//  LearnerMainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
// BUG :: Tableview 'Jumps' when switching sizing from the Category cell to the featuredTutor cell.
	// only happens when scrolling back up to top.

import Foundation
import UIKit
import Firebase

var spotlights = [Category : [SpotlightTutor]]()
var category = [Category]()

struct SpotlightTutor {

	var ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)

	static let shared = SpotlightTutor()
	
	var name   : String!
	var image  : String!
	var region : String!
	var topic  : String!
	var price  : String!

	public func queryFeaturedTutor(_ completion: @escaping (Error?) -> Void) {
		
		let dispatch = DispatchGroup()
		
		for category in Category.categories {
			
			var tutors : [SpotlightTutor] = []
			let categoryString = category.mainPageData.displayName.lowercased()
			
			dispatch.enter()
			
			self.ref.child("spotlight").queryOrdered(byChild: "t").queryEqual(toValue: categoryString).queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
				
				for snap in snapshot.children {
					
					let child = snap as! DataSnapshot
					let value = child.value as? NSDictionary
					var tutor = SpotlightTutor.shared
					
					tutor.name   = value?["name"  ] as! String
					tutor.image  = value?["image" ] as! String
					tutor.price  = value?["price" ] as! String
					tutor.region = value?["region"] as! String
					tutor.topic  = value?["t"     ] as! String
					
					tutors.append(tutor)
				}
				spotlights[Category.category(for: categoryString)!] = tutors
				dispatch.leave()
			}
		}
		dispatch.notify(queue: .main) {
			category = Category.categories.shuffled()
			completion(nil)
		}
	}
	func queryByCategory(category: Category, _ completion: @escaping ([SpotlightTutor]?) -> Void) {
		
		var tutors : [SpotlightTutor] = []
		
		self.ref.child("spotlight").queryOrdered(byChild: "t").queryEqual(toValue: category.mainPageData.displayName.lowercased()).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in
			
			for snap in snapshot.children {
				
				let child = snap as! DataSnapshot
				let value = child.value as? NSDictionary
				
				var tutor = SpotlightTutor.shared
				
				tutor.name   = value?["name"  ] as! String
				tutor.image  = value?["image" ] as! String
				tutor.price  = value?["price" ] as! String
				tutor.region = value?["region"] as! String
				tutor.topic  = value?["t"     ] as! String
				
				tutors.append(tutor)
				
				completion(tutors)
			}
		}
	}
	func queryBySubject(subcategory: String, subject: String, _ completion: @escaping ([SpotlightTutor]?) -> Void) {
		
		var uids : [String]
		//we will need to create codes for every subject so that we can query a range of similar subjects...
		self.ref.child(subcategory).queryOrdered(byChild: "r").queryEqual(toValue: 5).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in
			
			for snap in snapshot.children {
				let child = snap as! DataSnapshot
				print(child.key)
				
			}
		}
	}
//	func queryBySubcategory(subcategory: String, _ completion: @escaping ([SpotlightTutor]?) -> Void) {
//
//		var tutors : [String] = []
//		//pull people from the subcategory selected.
//		self.ref.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: "t").queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in
//
//			for snap in snapshot.children {
//				let child = snap as! DataSnapshot
//				self.ref.child("tutor-info").child(child.key).observeSingleEvent(of: .value, with: { (snapshot) in
//					var tutor = SpotlightTutor.shared
//					let value = child.value as? NSDictionary
//
//					tutor.name   = value?["nm"  ] as! String
//					tutor.image  = value?["img" ] as! String
//					tutor.price  = value?["" ] as! String
//					tutor.region = value?["region"] as! String
//					tutor.topic  = value?["t"     ] as! String
//
//					tutors.append(tutor)
//
//					completion(tutors)
//
//				})
//			}
//		}
//	}
}

class LearnerMainPageView : MainPageView {
	
	var search  = SearchBar()
	var learnerSidebar = LearnerSideBar()
	
	let tableView : UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		tableView.estimatedSectionHeaderHeight = 30
		tableView.translatesAutoresizingMaskIntoConstraints = true
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
			make.top.equalTo(navbar.snp.bottom).inset(-2)
			make.bottom.equalToSuperview()
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
	
	override func viewDidLoad() {
		super.viewDidLoad()

		configureView()
		if let image = LocalImageCache.localImageManager.getImage(number: "1") {
			contentView.sidebar.profileView.profilePicView.image = image
		}
	}
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		contentView.sidebar.applyGradient(firstColor: UIColor(hex:"4b3868").cgColor, secondColor: Colors.sidebarPurple.cgColor, angle: 200, frame: contentView.sidebar.bounds)
		contentView.tableView.layoutSubviews()
		contentView.tableView.layoutIfNeeded()
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
			navigationController?.pushViewController(SearchSubjects(), animated: true)
		}
	}
}

extension LearnerMainPage : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return indexPath.section == 0 ? 205.0 : 170.0
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return indexPath.section == 0 ? 205.0 : 170.0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "featuredCell", for: indexPath) as! FeaturedTutorTableViewCell
			cell.sectionIndex = indexPath.section
			return cell
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 13
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = SectionHeader()
		if section == 0 {
			view.category.text = "Category"
		} else {
			view.category.text = category[section - 1].mainPageData.displayName
		}
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 50
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
