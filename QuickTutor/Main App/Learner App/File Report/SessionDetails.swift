//
//  SessionOptions.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class SessionDetailsView : MainLayoutHeader {
    
    var tableView = UITableView()
    var sessionHeader = FileReportSessionView()
    
    override func configureView() {
        addSubview(tableView)
        addSubview(sessionHeader)
        super.configureView()
		
        title.label.text = "File Report"
        header.text = "Session Details"
		
		tableView.estimatedRowHeight = 44
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		
	}
    
    override func applyConstraints() {
        super.applyConstraints()
        
        sessionHeader.snp.makeConstraints { (make) in
            make.top.equalTo(header.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(85)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(sessionHeader.snp.bottom)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
	override func layoutSubviews() {
		statusbarView.backgroundColor = (AccountService.shared.currentUserType == .learner) ? Colors.learnerPurple : Colors.tutorBlue
		navbar.backgroundColor =  (AccountService.shared.currentUserType == .learner) ? Colors.learnerPurple : Colors.tutorBlue
	}
}


class SessionDetails : BaseViewController {
    
    override var contentView: SessionDetailsView {
        return view as! SessionDetailsView
    }
	
	let options = ["My tutor cancelled", "My tutor was late", "My tutor was unprofessional", "Harrassment", "Other"]
	
	var datasource : UserSession! {
		didSet {
			setHeader()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		contentView.tableView.dataSource = self
		contentView.tableView.delegate = self
		contentView.tableView.register(CustomFileReportTableViewCell.self, forCellReuseIdentifier: "fileReportCell")
    }
    
    override func viewDidLayoutSubviews() {
        contentView.sessionHeader.applyGradient(firstColor: Colors.learnerPurple.cgColor, secondColor: Colors.tutorBlue.cgColor, angle: 110, frame: self.contentView.sessionHeader.bounds)
    }
    
    override func loadView() {
        view = SessionDetailsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
	
	private func setHeader() {
		let endTimeString = getDateAndEndTime(unixTime: TimeInterval(datasource.endTime))
		let name = datasource.name.split(separator: " ")
		
		contentView.sessionHeader.nameLabel.text = "with \(String(name[0]).capitalized) \(String(name[1]).capitalized.prefix(1))."
		contentView.sessionHeader.profilePic.loadUserImages(by: datasource.imageURl)
		contentView.sessionHeader.subjectLabel.text = datasource.subject
		contentView.sessionHeader.monthLabel.text = endTimeString.1
		contentView.sessionHeader.dayLabel.text = endTimeString.0
		
		let startTime = getStartTime(unixTime: TimeInterval(datasource.startTime))
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		if let amount = formatter.string(from: datasource.price as NSNumber) {
			contentView.sessionHeader.sessionInfoLabel.text = "\(startTime) - \(endTimeString.2) \(amount)"
		}
	}
	override func handleNavigation() { }
}

extension SessionDetails : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomFileReportTableViewCell = tableView.dequeueReusableCell(withIdentifier: "fileReportCell", for: indexPath) as! CustomFileReportTableViewCell
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0:
				let next = TutorCancelled()
				next.datasource = self.datasource
                navigationController?.pushViewController(next, animated: true)
            case 1:
				let next = TutorLate()
				next.datasource = self.datasource
				navigationController?.pushViewController(next, animated: true)
            case 2:
				let next = TutorUnprofessional()
				next.datasource = self.datasource
				navigationController?.pushViewController(next, animated: true)
            case 3:
				let next = TutorHarassment()
				next.datasource = self.datasource
				navigationController?.pushViewController(next, animated: true)
            case 4:
				let next = TutorOther()
				next.datasource = self.datasource
				navigationController?.pushViewController(next, animated: true)
            default:
                break
        }

		tableView.deselectRow(at: indexPath, animated: true)
	}
}

