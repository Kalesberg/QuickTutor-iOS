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

var category : [Category] = Category.categories.shuffled()

class LearnerMainPageView : MainPageView {
	
	var search  = SearchBar()
	var learnerSidebar = LearnerSideBar()
	
	let tableView : UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		tableView.estimatedSectionHeaderHeight = 50
		tableView.sectionHeaderHeight = 50
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
	override func layoutSubviews() {
		super.layoutSubviews()
		sidebar.applyGradient(firstColor: UIColor(hex:"4b3868").cgColor, secondColor: Colors.sidebarPurple.cgColor, angle: 200, frame: sidebar.bounds)
		tableView.layoutSubviews()
		tableView.layoutIfNeeded()
	}
}
import Firebase
class LearnerMainPage : MainPage {

	override var contentView: LearnerMainPageView {
		return view as! LearnerMainPageView
	}
	override func loadView() {
		view = LearnerMainPageView()
	}
	
	var datasource = [Category : [FeaturedTutor]]()
	
	var didLoadMore = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		QueryData.shared.queryFeaturedTutor(categories: Array(category.prefix(4))) { (datasource) in
			if let datasource = datasource {
				
				self.contentView.tableView.performBatchUpdates({
					
					self.datasource.merge(datasource, uniquingKeysWith: { (_, last) in last })
					
					self.contentView.tableView.insertSections(IndexSet(integersIn: self.datasource.count - 3..<self.datasource.count + 1) , with: .fade )
					
				}, completion: { (finished) in
					if finished {
						self.didLoadMore = false
					}
				})
			}
		}
		AccountService.shared.currentUserType = .learner
		
		if LearnerData.userData.isTutor {
			contentView.sidebar.becomeQTItem.label.label.text = "Start Teaching"
		} else {
			contentView.sidebar.becomeQTItem.label.label.text = "Become A Tutor"
		}
		
		configureView()
		
		if let image = LocalImageCache.localImageManager.getImage(number: "1") {
			contentView.sidebar.profileView.profilePicView.image = image
		}
	}
	override func updateSideBar() {
		
        let formattedString = NSMutableAttributedString()
            
        if let school = user.school {
            formattedString
                .bold(user.name + "\n", 17, .white)
                .regular(school, 14, Colors.grayText)
        } else {
            formattedString
                .bold(user.name, 17, .white)
        }
        
        
		contentView.sidebar.profileView.profileNameView.attributedText = formattedString
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
			let next = LearnerMyProfile()
			next.learner = LearnerData.userData
			navigationController?.pushViewController(next, animated: true)
			hideSidebar()
			hideBackground()
		} else if(touchStartView == contentView.sidebar.reportItem) {
			navigationController?.pushViewController(LearnerFileReport(), animated: true)
			hideSidebar()
			hideBackground()
		} else if(touchStartView == contentView.sidebar.legalItem) {
			hideSidebar()
			hideBackground()
			guard let url = URL(string: "https://www.quicktutor.com") else {
				return
			}
			if #available(iOS 10, *) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			} else {
				UIApplication.shared.openURL(url)
			}
			//take user to legal on our website
		} else if(touchStartView == contentView.sidebar.helpItem) {
			navigationController?.pushViewController(LearnerHelp(), animated: true)
			hideSidebar()
			hideBackground()
		} else if(touchStartView == contentView.sidebar.becomeQTItem) {
			
			if LearnerData.userData.isTutor {
				_ = TutorSignIn.init({ (error) in
					if error != nil {
						print("error signing in...")
					} else {
						AccountService.shared.currentUserType = .tutor
						self.navigationController?.pushViewController(TutorPageViewController(), animated: true)
					}
				})
			} else {
				navigationController?.pushViewController(BecomeTutor(), animated: true)
			}
	
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
			
			cell.datasource = self.datasource[category[indexPath.section - 1]]

			return cell
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return datasource.count + 1
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = SectionHeader()
		if section == 0 {
			view.category.text = "Categories"
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
extension LearnerMainPage : UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if (scrollView.contentOffset.y - 60 >= (scrollView.contentSize.height - scrollView.frame.size.height))  && contentView.tableView.numberOfSections > 1 {
			
			if !didLoadMore && datasource.count < 12 {
				
				didLoadMore = true
				
				QueryData.shared.queryFeaturedTutor(categories: Array(category[self.datasource.count..<self.datasource.count + 4])) { (datasource) in
					//update datasource.
					if let datasource = datasource {
						
						self.contentView.tableView.performBatchUpdates({
							//merge current datasource with new datasource replacing duplicate keys with the new datasource
							self.datasource.merge(datasource, uniquingKeysWith: { (_, last) in last })
							
							//create indexSet for new sections to be added.
							self.contentView.tableView.insertSections(IndexSet(integersIn: self.datasource.count - 3..<self.datasource.count + 1) , with: .fade )
							
						}, completion: { (finished) in
							if finished {
								self.didLoadMore = false
							}
						})
					}
				}
			}
		}
	}
}
