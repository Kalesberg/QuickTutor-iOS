//
//  TutorRatings.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct TopSubcategory {
	var subcategory = ""
	let hours : Int
	let numSessions : Int
	let rating : Double
	let subjects : String
	
	init(dictionary : [String : Any]) {
		hours = dictionary["hr"] as? Int ?? 0
		numSessions = dictionary["nos"] as? Int ?? 0
		rating = dictionary["r"] as? Double ?? 0.0
		subjects = dictionary["sbj"] as? String ?? ""
	}
	
}
class TutorRatingsView : TutorHeaderLayoutView {
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 250
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

		return tableView
    }()
    
    override func configureView() {
        addSubview(tableView)
        super.configureView()
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
}

class TutorRatings : BaseViewController {
    
    override var contentView: TutorRatingsView {
        return view as! TutorRatingsView
    }
    override func loadView() {
        view = TutorRatingsView()
    }

	private let ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)

	var tutor : AWTutor! {
		didSet{
			contentView.tableView.reloadData()
		}
	}

	var topSubject : (String, UIImage)? {
		didSet {
			if topSubject == nil {
				//TODO create backgroundView
			}
			contentView.tableView.reloadData()
		}
	}
	var _5StarSessions : Int = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
		configureDelegates()
		
		guard let tutor = CurrentUser.shared.tutor else { return }
		self.tutor = tutor
		findTopSubjects()
		FirebaseData.manager.fetchUserSessions(uid: tutor.uid, type: "tutor") { (sessions) in
			guard let sessions = sessions else { return }
			for session in sessions {
				if session.tutorRating == 5 {
					self._5StarSessions += 1
				}
			}
		}
	}
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.layer.addBorder(edge: .top, color: Colors.divider, thickness: 1)
        contentView.tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.layer.addBorder(edge: .bottom, color: Colors.divider, thickness: 1)
        
        contentView.tableView.cellForRow(at: IndexPath(row: 3, section: 0))?.layer.addBorder(edge: .top, color: Colors.divider, thickness: 1)
        contentView.tableView.cellForRow(at: IndexPath(row: 3, section: 0))?.layer.addBorder(edge: .bottom, color: Colors.divider, thickness: 1)
        
        contentView.tableView.cellForRow(at: IndexPath(row: 5, section: 0))?.layer.addBorder(edge: .top, color: Colors.divider, thickness: 1)
        contentView.tableView.cellForRow(at: IndexPath(row: 5, section: 0))?.layer.addBorder(edge: .bottom, color: Colors.divider, thickness: 1)
    }
	
	private func configureDelegates() {
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		
		contentView.tableView.register(TutorMainPageHeaderCell.self, forCellReuseIdentifier: "tutorMainPageHeaderCell")
		contentView.tableView.register(TutorMainPageSummaryCell.self, forCellReuseIdentifier: "tutorMainPageSummaryCell")
		contentView.tableView.register(TutorMainPageTopSubjectCell.self, forCellReuseIdentifier: "tutorMainPageTopSubjectCell")
		contentView.tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "ratingTableViewCell")
		contentView.tableView.register(NoRatingsTableViewCell.self, forCellReuseIdentifier: "noRatingsTableViewCell")
	}
	
	private func findTopSubjects() {
		func bayesianEstimate(C: Double, r: Double, v: Double, m: Double) -> Double {
			return (v / (v + m)) * ((r + Double((m / (v + m)))) * C)
		}
	
		FirebaseData.manager.fetchSubjectsTaught(uid: tutor.uid) { (subcategoryList) in
			let avg = subcategoryList.map({$0.rating / 5}).average
			let topSubcategory = subcategoryList.sorted {
				return bayesianEstimate(C: avg, r: $0.rating / 5, v: Double($0.numSessions), m: 0) > bayesianEstimate(C: avg, r: $1.rating / 5, v: Double($1.numSessions), m: 10)
				}.first
			guard let subcategory = topSubcategory?.subcategory else {
				self.topSubject = nil
				return
			}
			self.topSubject = SubjectStore.findSubcategoryImage(subcategory: subcategory)
		}
	}
}

extension TutorRatings : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return 160
        case 1,5:
            return UITableView.automaticDimension
        case 2,4:
            return 30
        case 3:
            return 120
        default:
			return 0
		}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch (indexPath.row) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "tutorMainPageHeaderCell", for: indexPath) as! TutorMainPageHeaderCell
			cell.headerLabel.text = String(tutor.tRating)
			
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "tutorMainPageSummaryCell", for: indexPath) as! TutorMainPageSummaryCell
			
			let formattedString1 = NSMutableAttributedString()
			
			formattedString1
				.bold("\(tutor.tNumSessions!)\n", 16, .white)
				.regular("Sessions", 15, Colors.grayText)
			let paragraphStyle1 = NSMutableParagraphStyle()
			paragraphStyle1.lineSpacing = 6
			formattedString1.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle1, range:NSMakeRange(0, formattedString1.length))
			cell.infoLabel1.attributedText = formattedString1
			cell.infoLabel1.textAlignment = .center
			cell.infoLabel1.numberOfLines = 0
			
			let formattedString2 = NSMutableAttributedString()
			formattedString2
				.bold("\(tutor.tNumSessions!)\n", 16, .white)
				.regular("5-Stars", 15, Colors.grayText)
			
			let paragraphStyle2 = NSMutableParagraphStyle()
			paragraphStyle2.lineSpacing = 6
			formattedString2.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle2, range:NSMakeRange(0, formattedString2.length))
			cell.infoLabel2.attributedText = formattedString2
			cell.infoLabel2.textAlignment = .center
			cell.infoLabel3.numberOfLines = 0
			
			
			let formattedString3 = getFormattedTimeString(seconds: tutor.hours!)
			let paragraphStyle3 = NSMutableParagraphStyle()
			paragraphStyle3.lineSpacing = 6
			formattedString3.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle3, range:NSMakeRange(0, formattedString3.length))
			
			cell.infoLabel3.attributedText = formattedString3
			cell.infoLabel3.textAlignment = .center
			cell.infoLabel3.numberOfLines = 0
			
			return cell
        case 2:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "tutorMainPageTopSubjectCell", for: indexPath) as! TutorMainPageTopSubjectCell

			guard let topSubject = topSubject else {
				cell.icon.image = #imageLiteral(resourceName: "cameraIcon")
				cell.subjectLabel.text = "No top subject yet."
				return cell
			}
			
			cell.subjectLabel.text = topSubject.0
			cell.icon.image = topSubject.1
	
			return cell
        case 4:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        case 5:
			guard let datasource = tutor.reviews else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "noRatingsTableViewCell", for: indexPath) as! NoRatingsTableViewCell
				cell.backgroundColor = Colors.registrationDark
				cell.label2.snp.updateConstraints { (make) in
					make.height.equalTo(55)
				}
                
                cell.label1.snp.makeConstraints { (make) in
                    make.top.equalToSuperview().inset(8)
                    make.left.equalToSuperview().inset(20)
                }
                
                cell.label1.textColor = .white
                
				return cell
			}
			
			if datasource.count == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "noRatingsTableViewCell", for: indexPath) as! NoRatingsTableViewCell
				cell.backgroundColor = Colors.registrationDark
				cell.label2.snp.updateConstraints { (make) in
					make.height.equalTo(55)
				}
                
                cell.label1.snp.makeConstraints { (make) in
                    make.top.equalToSuperview().inset(8)
                    make.left.equalToSuperview().inset(20)
                }
                
                cell.label1.textColor = .white
                
				return cell
			}
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "ratingTableViewCell", for: indexPath) as! RatingTableViewCell
			cell.backgroundColor = Colors.registrationDark
			cell.seeAllButton.snp.updateConstraints { (make) in
				make.bottom.equalToSuperview().inset(15)
			}
            
            if datasource.count == 1 {
                cell.tableView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.95)
                    make.height.equalTo(120)
                    make.centerX.equalToSuperview()
                }
            }

			cell.datasource = datasource
			
			return cell
			
        default:
            break
        }
        return UITableViewCell()
    }
	func getFormattedTimeString (seconds : Int) -> NSMutableAttributedString {
		let hours = seconds / 3600
		let minutes = (seconds % 3600) / 60
		let seconds = (seconds % 3600) % 60
		
		let formattedString3 = NSMutableAttributedString()
		if hours > 0 {
			return formattedString3.bold("\(hours)\n", 16, .white).regular("Hours", 15, Colors.grayText)
		} else if minutes > 0 {
			return formattedString3.bold("\(minutes)\n", 16, .white).regular("Minutes", 15, Colors.grayText)
		} else {
			return formattedString3.bold("\(seconds)\n", 16, .white).regular("Seconds", 15, Colors.grayText)
		}
	}
}

