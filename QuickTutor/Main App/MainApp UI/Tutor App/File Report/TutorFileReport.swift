//
//  FileReport.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import SDWebImage

class TutorFileReport : BaseViewController {
    
    override var contentView: LearnerFileReportView {
        return view as! LearnerFileReportView
    }
	
	let storageRef = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	
	var localTimeZoneAbbreviation: String {
		return TimeZone.current.abbreviation() ?? ""
	}
	var datasource = [UserSession]() {
		didSet {
			if datasource.count == 0 {
				let view = TutorCardCollectionViewBackground()
				view.label.attributedText =	NSMutableAttributedString().bold("No recent sessions!", 22, .white)
				view.label.textAlignment = .center
				view.label.numberOfLines = 0
				contentView.tableView.backgroundView = view
			} else {
				contentView.tableView.backgroundView = nil
			}
			contentView.tableView.reloadData()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		FirebaseData.manager.fetchUserSessions(uid: CurrentUser.shared.learner.uid!, type: "tutor") { (sessions) in
			if let sessions = sessions {
				self.datasource = sessions.sorted(by: { $0.endTime > $1.endTime })
			} else {
				self.datasource = []
			}
		}
		
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(SessionHistoryCell.self, forCellReuseIdentifier: "sessionHistoryCell")
        
        contentView.navbar.backgroundColor = Colors.tutorBlue
        contentView.statusbarView.backgroundColor = Colors.tutorBlue
    }
    
    override func loadView() {
        view = LearnerFileReportView()
    }
	
	private func getFormattedTime(unixTime: TimeInterval) -> String {
		let date = Date(timeIntervalSince1970: unixTime)
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
		dateFormatter.dateFormat = "h:mm a"
		return dateFormatter.string(from: date)
	}
	private func getFormattedDate(unixTime: TimeInterval) -> String {
		let date = Date(timeIntervalSince1970: unixTime)
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
		dateFormatter.dateFormat = "d-MMM"
		return dateFormatter.string(from: date)
	}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        
    }
}
extension TutorFileReport : UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return datasource.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80
	}
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "sessionHistoryCell", for: indexPath) as! SessionHistoryCell
		
		let startTime = getFormattedTime(unixTime: TimeInterval(datasource[indexPath.row].startTime))
		let endTime = getFormattedTime(unixTime: TimeInterval(datasource[indexPath.row].endTime))
		let date = getFormattedDate(unixTime: TimeInterval(datasource[indexPath.row].date)).split(separator: "-")
		
		if datasource[indexPath.row].name == "" {
			cell.nameLabel.text = "User no longer exists."
		} else {
			let name = datasource[indexPath.row].name.split(separator: " ")
			if name.count == 2 {
				cell.nameLabel.text = "with \(String(name[0]).capitalized) \(String(name[1]).capitalized.prefix(1))."
			} else {
				cell.nameLabel.text = "with \(String(name[0]).capitalized)"
			}
		}
		
		cell.profilePic.sd_setImage(with: storageRef.child("student-info").child(datasource[indexPath.row].otherId).child("student-profile-pic1"), placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
		cell.subjectLabel.text = datasource[indexPath.row].subject
		cell.monthLabel.text = String(date[1])
		cell.dayLabel.text = String(date[0])
		cell.sessionInfoLabel.text = "\(startTime) - \(endTime)"
		
		let sessionCost = String(format: "$%.2f", (datasource[indexPath.row].cost / 100))
		cell.sessionInfoLabel.text = "\(startTime) - \(endTime) \(sessionCost)"
		
		return cell
	}

	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .none
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let endTime = Double(datasource[indexPath.row].endTime)
		if endTime < Date().timeIntervalSince1970 - 604800 {
			return false
		}
		return true
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let fileReport = UITableViewRowAction(style: .default, title: "File Report") { (action, indexPath) in
			let next = SessionDetails()
			next.datasource = self.datasource[indexPath.row]
			self.navigationController?.pushViewController(next, animated: true)
		}
		return [fileReport]
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
