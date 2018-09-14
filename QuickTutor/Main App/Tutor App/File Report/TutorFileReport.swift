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
		
		FirebaseData.manager.fetchUserSessions(uid: CurrentUser.shared.learner.uid, type: "tutor") { (sessions) in
			if let sessions = sessions {
				self.datasource = sessions.sorted(by: { $0.endTime > $1.endTime })
			} else {
				self.datasource = []
			}
		}
		
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(CustomFileReportTableViewCell.self, forCellReuseIdentifier: "fileReportCell")
        
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
	
	private func setHeader(index: Int) -> FileReportSessionView {
		let view = FileReportSessionView()
		view.applyGradient(firstColor: Colors.learnerPurple.cgColor, secondColor: Colors.tutorBlue.cgColor, angle: 110, frame: CGRect(x: 0, y: 0, width: contentView.tableView.frame.width, height: 85))
		
		let startTime = getFormattedTime(unixTime: TimeInterval(datasource[index].startTime))
		let endTime = getFormattedTime(unixTime: TimeInterval(datasource[index].endTime))
		let date = getFormattedDate(unixTime: TimeInterval(datasource[index].date)).split(separator: "-")
		
		//QuickFix. will change in the future
		if datasource[index].name == "" {
			view.nameLabel.text = "User no longer exists."
		} else {
			let name = datasource[index].name.split(separator: " ")
			if name.count == 2 {
				view.nameLabel.text = "with \(String(name[0]).capitalized) \(String(name[1]).capitalized.prefix(1))."
			} else {
				view.nameLabel.text = "with \(String(name[0]).capitalized)"
			}
		}
		
		view.profilePic.sd_setImage(with: storageRef.child("student-info").child(datasource[index].otherId).child("student-profile-pic1"), placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
		view.subjectLabel.text = datasource[index].subject
		view.monthLabel.text = String(date[1])
		view.dayLabel.text = String(date[0])
		let sessionCost = String(format: "$%.2f", datasource[index].cost)
		view.sessionInfoLabel.text = "\(startTime) - \(endTime) \(sessionCost)"

		return view
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
        return 1
    }
    
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return indexPath.section == 0 ? 0 : tableView.estimatedRowHeight
	}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            cell.backgroundColor = Colors.backgroundDark
            return cell
        } else {
            let cell : CustomFileReportTableViewCell = tableView.dequeueReusableCell(withIdentifier: "fileReportCell", for: indexPath) as! CustomFileReportTableViewCell
            cell.textLabel?.text = "File a report with this session"
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count + 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            let label = UILabel()
            label.text = "Your Past Sessions"
            label.textColor = .white
            label.font = Fonts.createBoldSize(20)
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.width.equalToSuperview().multipliedBy(0.9)
                make.center.equalToSuperview()
            }
            
            return view
        } else {
            return setHeader(index: section - 1)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return tableView.estimatedSectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard indexPath.section != 0 else { return }
		let next = TutorSessionDetails()
		next.datasource = datasource[indexPath.section - 1]
		self.navigationController?.pushViewController(next, animated: true)
		tableView.deselectRow(at: indexPath, animated: true)
    }
}
