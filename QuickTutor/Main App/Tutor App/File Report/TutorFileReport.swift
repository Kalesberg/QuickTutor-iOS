//
//  FileReport.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorFileReport : BaseViewController {
    
    override var contentView: LearnerFileReportView {
        return view as! LearnerFileReportView
    }
	
	var datasource = [UserSession]() {
		didSet {
			if datasource.count == 0 {
				let view = TutorCardCollectionViewBackground()
				let formattedString = NSMutableAttributedString()
				
				formattedString
					.bold("No past sessions!", 22, .white)
				
				view.label.attributedText = formattedString
				view.label.textAlignment = .center
				view.label.numberOfLines = 0
				contentView.tableView.backgroundView = view
			}
			contentView.tableView.reloadData()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		FirebaseData.manager.getUserSessions(uid: CurrentUser.shared.tutor.uid, type: "tutor") { (sessions) in
			self.datasource = sessions
		}
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(CustomFileReportTableViewCell.self, forCellReuseIdentifier: "fileReportCell")
        
        contentView.navbar.backgroundColor = Colors.tutorBlue
        contentView.statusbarView.backgroundColor = Colors.tutorBlue
        
        contentView.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func loadView() {
        view = LearnerFileReportView()
    }
	
	private func getStartTime(unixTime: TimeInterval) -> String {
		let date = Date(timeIntervalSince1970: unixTime)
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
		dateFormatter.locale = NSLocale.current
		dateFormatter.dateFormat = "hh:mm a"
		
		return dateFormatter.string(from: date)
	}
	
	private func getDateAndEndTime(unixTime: TimeInterval) -> (String, String, String) {
		let date = Date(timeIntervalSince1970: unixTime)
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
		dateFormatter.locale = NSLocale.current
		dateFormatter.dateFormat = "d-MMM-hh:mm a"
		let dateString = dateFormatter.string(from: date).split(separator: "-")
		return (String(dateString[0]), String(dateString[1]), String(dateString[2]))
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
        return tableView.estimatedRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomFileReportTableViewCell = tableView.dequeueReusableCell(withIdentifier: "fileReportCell", for: indexPath) as! CustomFileReportTableViewCell
        
        cell.textLabel?.text = "File a report with this session"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = FileReportSessionView()
		view.applyGradient(firstColor: Colors.learnerPurple.cgColor, secondColor: Colors.tutorBlue.cgColor, angle: 110, frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 85))
		
		let endTimeString = getDateAndEndTime(unixTime: TimeInterval(datasource[section].endTime))
		let name = datasource[section].name.split(separator: " ")
		
		view.nameLabel.text = "with \(String(name[0]).capitalized) \(String(name[1]).capitalized.prefix(1))."
		view.profilePic.loadUserImages(by: datasource[section].imageURl)
		view.subjectLabel.text = datasource[section].subject
		view.monthLabel.text = endTimeString.1
		view.dayLabel.text = endTimeString.0
		
		let startTime = getStartTime(unixTime: TimeInterval(datasource[section].startTime))
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		if let amount = formatter.string(from: datasource[section].price as NSNumber) {
			view.sessionInfoLabel.text = "\(startTime) - \(endTimeString.2) \(amount)"
		}
		
		return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.estimatedSectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let next = TutorSessionDetails()
		next.datasource = datasource[indexPath.section]
		self.navigationController?.pushViewController(next, animated: true)
		tableView.deselectRow(at: indexPath, animated: true)
    }
}
