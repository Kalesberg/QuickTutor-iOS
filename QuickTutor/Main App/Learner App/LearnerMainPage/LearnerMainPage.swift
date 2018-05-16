//
//  LearnerMainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

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
		tableView.backgroundColor = Colors.backgroundDark
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
			make.centerY.equalToSuperview()
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
class LearnerMainPage : MainPage {
	
	override var contentView: LearnerMainPageView {
		return view as! LearnerMainPageView
	}
	override func loadView() {
		view = LearnerMainPageView()
	}
	
	var datasource = [Category : [AWTutor]]()
	var didLoadMore = false
	var learner : AWLearner!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		queryFeaturedTutors()
		configureView()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		guard let learner = CurrentUser.shared.learner else {
			try! Auth.auth().signOut()
			self.navigationController?.pushViewController(SignIn(), animated: true)
			return
		}
		
		self.learner = learner
		AccountService.shared.currentUserType = .learner
		
		self.configureSideBarView()
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        displayMessagesTutorial()
    }
    
	private func configureSideBarView(){
		
		let formattedString = NSMutableAttributedString()
		contentView.sidebar.becomeQTItem.label.label.text = learner.isTutor ? "Start Tutoring" : "Become a QuickTutor"
		
		if let school = learner.school {
			formattedString
				.bold(learner.name + "\n", 17, .white)
                .regular(school, 14, Colors.grayText)
		} else {
			formattedString
				.bold(learner.name, 17, .white)
		}
		
		contentView.sidebar.ratingView.ratingLabel.text = String(learner.lRating)
		contentView.sidebar.profileView.profileNameView.attributedText = formattedString
		contentView.sidebar.profileView.profilePicView.loadUserImages(by: learner.images["image1"]!)
		contentView.sidebar.profileView.profileNameView.adjustsFontSizeToFitWidth = true
	}
	
	private func configureView() {
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		
		contentView.tableView.register(FeaturedTutorTableViewCell.self, forCellReuseIdentifier: "tutorCell")
		contentView.tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "categoryCell")
	}
    
    func displayMessagesTutorial() {
        
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "navbar-messages")
        
        let tutorial = TutorCardTutorial()
        tutorial.label.text = "This is where you'll message your tutors and schedule sessions!"
        tutorial.label.numberOfLines = 2
        tutorial.addSubview(image)
        contentView.addSubview(tutorial)
        
        tutorial.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tutorial.label.snp.remakeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        image.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView.messagesButton.image)
        }
        
        tutorial.imageView.snp.remakeConstraints { (make) in
            make.top.equalTo(image.snp.bottom).inset(-5)
            make.centerX.equalTo(image)
        }
        
        UIView.animate(withDuration: 1, animations: {
            tutorial.alpha = 1
        }, completion: { (true) in
            UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
                tutorial.imageView.center.y += 10
            })
        })
    }
    
	
	private func queryFeaturedTutors() {
		QueryData.shared.queryAWTutorsByFeaturedCategory(categories: Array(category[self.datasource.count..<self.datasource.count + 4])) { (datasource) in
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
	}
	
	override func handleNavigation() {
		super.handleNavigation()
        
        if(touchStartView == contentView.sidebarButton) {
            let startX = self.contentView.sidebar.center.x
            self.contentView.sidebar.center.x = (startX * -1)
            self.contentView.sidebar.alpha = 1.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                self.contentView.sidebar.center.x = startX
            })
            self.contentView.sidebar.isUserInteractionEnabled = true
            showBackground()
        } else if(touchStartView == contentView.backgroundView) {
            self.contentView.sidebar.isUserInteractionEnabled = false
            let startX = self.contentView.sidebar.center.x
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                self.contentView.sidebar.center.x *= -1
            }, completion: { (value: Bool) in
                self.contentView.sidebar.alpha = 0
                self.contentView.sidebar.center.x = startX
            })
            hideBackground()
        } else if(touchStartView == contentView.sidebar.paymentItem) {
			let next = CardManager()
			next.customerId = learner.customer
			navigationController?.pushViewController(next, animated: true)
			
			hideSidebar()
			hideBackground()
		} else if(touchStartView == contentView.sidebar.settingsItem) {
			
			let next = LearnerSettings()
			next.learner = self.learner
			navigationController?.pushViewController(next, animated: true)
			
			hideSidebar()
			hideBackground()
		} else if(touchStartView == contentView.sidebar.profileView) {
			
			let next = LearnerMyProfile()
			next.learner = CurrentUser.shared.learner
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
		} else if(touchStartView == contentView.sidebar.helpItem) {
			navigationController?.pushViewController(LearnerHelp(), animated: true)
			hideSidebar()
			hideBackground()
		} else if(touchStartView == contentView.sidebar.becomeQTItem) {
				AccountService.shared.currentUserType = .tutor
				if learner.isTutor {
					self.navigationController?.pushViewController(TutorPageViewController(), animated: true)
				} else {
					self.navigationController?.pushViewController(BecomeTutor(), animated: true)
				}
			hideSidebar()
			hideBackground()
		} else if (touchStartView is SearchBar) {
			
			let nav = self.navigationController
			let transition = CATransition()
			
			DispatchQueue.main.async {
				nav?.view.layer.add(transition.segueFromBottom(), forKey: nil)
				nav?.pushViewController(SearchSubjects(), animated: false)
			}
            
        } else if (touchStartView is InviteButton) {
            navigationController?.pushViewController(InviteOthers(), animated: true)
        }
	}
}

extension LearnerMainPage : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
				return 180
			} else {
				return 210
			}
		} else {
			return 170.0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
			
			return cell
			
		} else {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "tutorCell", for: indexPath) as! FeaturedTutorTableViewCell
			
			cell.datasource = self.datasource[category[indexPath.section - 1]]
			cell.category =  category[indexPath.section - 1]
			
			return cell
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return datasource.count + 1
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = SectionHeader()
		view.category.text = (section == 0) ? "Categories" : category[section - 1].mainPageData.displayName
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
				queryFeaturedTutors()
			}
		}
	}
}
