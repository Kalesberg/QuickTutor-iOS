//
//  MyProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

protocol UpdatedTutorCallBack : class {
	func tutorWasUpdated(tutor: AWTutor!)
}


class TutorMyProfileView : LearnerMyProfileView {
    
    override func configureView() {
        super.configureView()
        
        title.label.text = "My Profile"
        statusbarView.backgroundColor = Colors.tutorBlue
        navbar.backgroundColor = Colors.tutorBlue
    }
    
}

class TutorMyProfile : BaseViewController, UpdatedTutorCallBack {
	
	
	
	override var contentView: TutorMyProfileView {
		return view as! TutorMyProfileView
	}
	
	let horizontalScrollView = UIScrollView()
	var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
	var pageControl : UIPageControl = UIPageControl(frame: CGRect(x:50,y: 300, width:200, height:50))
	
	func tutorWasUpdated(tutor: AWTutor!) {
		self.tutor = tutor
	}
	
	var tutor : AWTutor! {
		didSet {
			pageCount = tutor.images.filter({$0.value != ""}).count
			contentView.tableView.reloadData()
		}
	}
	
	var pageCount : Int!
	
	override func viewDidLoad() {
		contentView.addSubview(horizontalScrollView)
		super.viewDidLoad()
		configureDelegates()
	}
	
	override func loadView() {
		view = TutorMyProfileView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		configureScrollView()
		configurePageControl()
		setUpImages()
	}
	
	private func configureDelegates() {
		horizontalScrollView.delegate = self
		
		pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		
		contentView.tableView.register(ProfilePicTableViewCell.self, forCellReuseIdentifier: "profilePicTableViewCell")
		contentView.tableView.register(AboutMeTableViewCell.self, forCellReuseIdentifier: "aboutMeTableViewCell")
		contentView.tableView.register(SubjectsTableViewCell.self, forCellReuseIdentifier: "subjectsTableViewCell")
		contentView.tableView.register(PoliciesTableViewCell.self, forCellReuseIdentifier: "policiesTableViewCell")
		contentView.tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "ratingTableViewCell")
		contentView.tableView.register(NoRatingsTableViewCell.self, forCellReuseIdentifier: "noRatingsTableViewCell")
		contentView.tableView.register(ExtraInfoTableViewCell.self, forCellReuseIdentifier: "extraInfoTableViewCell")
	}
	private func configureScrollView() {
		
		horizontalScrollView.isUserInteractionEnabled = false
		horizontalScrollView.isHidden = true
		horizontalScrollView.isPagingEnabled = true
		horizontalScrollView.showsHorizontalScrollIndicator = false
		
		horizontalScrollView.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.35)
			make.centerX.equalToSuperview()
			make.top.equalTo(contentView.navbar.snp.bottom).inset(-15)
		}
		contentView.layoutIfNeeded()
		
		horizontalScrollView.contentSize = CGSize(width: horizontalScrollView.frame.size.width * CGFloat(pageCount), height: horizontalScrollView.frame.size.height)
	}
	
	private func configurePageControl() {
		
		// The total number of pages that are available is based on how many available colors we have.
		pageControl.numberOfPages = pageCount
		pageControl.currentPage = 0
		pageControl.pageIndicatorTintColor = .white
		pageControl.currentPageIndicatorTintColor = Colors.tutorBlue
		contentView.backgroundView.addSubview(pageControl)
		
		pageControl.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalTo(horizontalScrollView.snp.bottom).inset(-10)
		}
	}
	
	@objc func changePage(sender: AnyObject) -> () {
		let x = CGFloat(pageControl.currentPage) * horizontalScrollView.frame.size.width
		horizontalScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
	}
	
	private func setUpImages() {
		var count = 1
		let tutorImages = tutor.images.filter({$0.value != ""})

		tutorImages.forEach({
			let imageView = UIImageView()
			imageView.loadUserImages(by: $0.value)
			imageView.scaleImage()
			self.horizontalScrollView.addSubview(imageView)
			
			imageView.snp.makeConstraints({ (make) in
				make.top.equalToSuperview()
				make.height.equalToSuperview()
				make.width.equalTo(UIScreen.main.bounds.width)
				if (count != 1) {
					make.left.equalTo(self.horizontalScrollView.subviews[count - 2].snp.right)
				} else {
					make.centerX.equalToSuperview()
				}
			})
			count += 1
		})
		contentView.layoutIfNeeded()
	}
	
	override func handleNavigation() {
		if (touchStartView is NavbarButtonEdit) {
			let next = TutorEditProfile()
			next.tutor = self.tutor
			next.delegate = self
			navigationController?.pushViewController(next, animated: true)
		} else if(touchStartView == contentView.xButton) {

			contentView.backgroundView.alpha = 0.0
			contentView.xButton.alpha = 0.0
			horizontalScrollView.isUserInteractionEnabled = false
			horizontalScrollView.isHidden = true
			contentView.leftButton.isHidden = false
		}
	}
}

extension TutorMyProfile : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 6
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch (indexPath.row) {
		case 0:
			return 200
		case 1:
			return UITableViewAutomaticDimension
		case 2:
			return UITableViewAutomaticDimension
		case 3:
			return 90
		case 4:
			return UITableViewAutomaticDimension
		case 5:
			return UITableViewAutomaticDimension
		default:
			break
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch (indexPath.row) {
			
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: "profilePicTableViewCell", for: indexPath) as! ProfilePicTableViewCell
			
			cell.nameLabel.text = tutor.name
			cell.locationLabel.text = tutor.region
			cell.profilePicView.loadUserImages(by: tutor.images["image1"]!)
			
			return cell
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: "aboutMeTableViewCell", for: indexPath) as! AboutMeTableViewCell
			
			cell.bioLabel.text = tutor.tBio + "\n"
			
			return cell
		case 2:
			let cell = tableView.dequeueReusableCell(withIdentifier: "extraInfoTableViewCell", for: indexPath) as! ExtraInfoTableViewCell
            
            for view in cell.contentView.subviews {
                view.snp.removeConstraints()
            }
            
            cell.speakItem.removeFromSuperview()
            cell.studysItem.removeFromSuperview()
			
			cell.tutorItem.label.text = "Has tutored \(tutor.tNumSessions!) sessions"
			
			if let languages = tutor.languages {
				cell.speakItem.label.text = "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))"
				cell.contentView.addSubview(cell.speakItem)
				
				cell.tutorItem.snp.makeConstraints { (make) in
					make.left.equalToSuperview().inset(12)
					make.right.equalToSuperview().inset(20)
					make.height.equalTo(35)
					make.top.equalToSuperview().inset(10)
				}
				
				if tutor.school != "" {
					cell.studysItem.label.text = "Studies at " + tutor.school!
					cell.contentView.addSubview(cell.studysItem)
					
					cell.speakItem.snp.makeConstraints { (make) in
						make.left.equalToSuperview().inset(12)
						make.right.equalToSuperview().inset(20)
						make.height.equalTo(35)
						make.top.equalTo(cell.tutorItem.snp.bottom)
					}
					
					cell.studysItem.snp.makeConstraints { (make) in
						make.left.equalToSuperview().inset(12)
						make.right.equalToSuperview().inset(20)
						make.height.equalTo(35)
						make.top.equalTo(cell.speakItem.snp.bottom)
						make.bottom.equalToSuperview().inset(10)
					}
				} else {
					cell.speakItem.snp.makeConstraints { (make) in
						make.left.equalToSuperview().inset(12)
						make.right.equalToSuperview().inset(20)
						make.height.equalTo(35)
						make.top.equalTo(cell.tutorItem.snp.bottom)
						make.bottom.equalToSuperview().inset(10)
					}
				}
			} else {
				if tutor.school != "" {
					cell.studysItem.label.text = "Studies at " + tutor.school!
					cell.contentView.addSubview(cell.studysItem)
					
					cell.tutorItem.snp.makeConstraints { (make) in
						make.left.equalToSuperview().inset(12)
						make.right.equalToSuperview().inset(20)
						make.height.equalTo(35)
						make.top.equalToSuperview().inset(10)
					}
					
					cell.studysItem.snp.makeConstraints { (make) in
						make.left.equalToSuperview().inset(12)
						make.right.equalToSuperview().inset(20)
						make.height.equalTo(35)
						make.top.equalTo(cell.tutorItem.snp.bottom)
						make.bottom.equalToSuperview().inset(10)
					}
				} else {
					cell.tutorItem.snp.makeConstraints { (make) in
						make.left.equalToSuperview().inset(12)
						make.right.equalToSuperview().inset(20)
						make.height.equalTo(35)
						make.top.equalToSuperview().inset(10)
						make.bottom.equalToSuperview().inset(10)
					}
				}
			}
            
            cell.applyConstraints()
			
			return cell
			
		case 3:
			let cell = tableView.dequeueReusableCell(withIdentifier: "subjectsTableViewCell", for: indexPath) as! SubjectsTableViewCell
			
			cell.datasource = tutor.subjects
			
			return cell
			
		case 4:

			guard let datasource = tutor.reviews else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "noRatingsTableViewCell", for: indexPath) as!
				NoRatingsTableViewCell
				return cell
			}
			
			if datasource.count == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "noRatingsTableViewCell", for: indexPath) as!
				NoRatingsTableViewCell
				return cell
			}
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "ratingTableViewCell", for: indexPath) as!
			RatingTableViewCell
			
			cell.seeAllButton.isHidden = !(datasource.count > 2)
			cell.datasource = datasource
			return cell
			
		case 5:
			let cell = tableView.dequeueReusableCell(withIdentifier: "policiesTableViewCell", for: indexPath) as! PoliciesTableViewCell
			
			if let policy = tutor.policy {
				let policies = policy.split(separator: "_")
				
				let formattedString = NSMutableAttributedString()
				
				formattedString
					.regular(tutor.distance.distancePreference(tutor.preference), 14, .white)
					.regular(tutor.preference.preferenceNormalization(), 14, .white)
					.regular(String(policies[0]).lateNotice(), 14, .white)
					.regular(String(policies[2]).cancelNotice(), 14, .white)
					.regular(String(policies[1]).lateFee(), 13, Colors.qtRed)
					.regular(String(policies[3]).cancelFee(), 13, Colors.qtRed)
				
				cell.policiesLabel.attributedText = formattedString
			} else {
				// show "No Policies cell"
			}
			return cell
		default:
			break
		}
		return UITableViewCell()
	}
}
extension TutorMyProfile : UIScrollViewDelegate {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageNumber = round(horizontalScrollView.contentOffset.x / horizontalScrollView.frame.size.width)
		pageControl.currentPage = Int(pageNumber)
	}
}
