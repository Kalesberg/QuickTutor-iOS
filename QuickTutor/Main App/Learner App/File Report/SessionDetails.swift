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
        header.label.text = "Session Details"
		
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
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
}


class SessionDetails : BaseViewController {
    
    override var contentView: SessionDetailsView {
        return view as! SessionDetailsView
    }
	
	let options = ["My tutor cancelled", "My tutor was late", "My tutor was unprofessional", "Harrassment", "Other"]
	let sessionDetails = ["Tutor Fare", "Total", "Payment Method"]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		contentView.tableView.dataSource = self
		contentView.tableView.delegate = self
		contentView.tableView.register(CustomFileReportTableViewCell.self, forCellReuseIdentifier: "fileReportCell")
		contentView.tableView.register(SessionDetailsTableViewCell.self, forCellReuseIdentifier: "sessionDetailsCell")
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
    
    override func handleNavigation() { }
}
extension SessionDetails : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return options.count
		} else {
			return sessionDetails.count
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.estimatedRowHeight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell : CustomFileReportTableViewCell = tableView.dequeueReusableCell(withIdentifier: "fileReportCell", for: indexPath) as! CustomFileReportTableViewCell
			
			cell.textLabel?.text = options[indexPath.row]
			return cell
		} else {
			let cell : SessionDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "sessionDetailsCell", for: indexPath) as! SessionDetailsTableViewCell
			cell.textLabel?.text = sessionDetails[indexPath.row]
			cell.rightLabel.text = "$18.50"
			return cell
		}
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0)
		view.backgroundColor = Colors.backgroundDark
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 1 {
			return 44
		}
		return 0
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			switch indexPath.row {
			case 0:
				navigationController?.pushViewController(TutorCancelled(), animated: true)
			case 1:
				navigationController?.pushViewController(TutorLate(), animated: true)
			case 2:
				navigationController?.pushViewController(TutorUnprofessional(), animated: true)
			case 3:
				navigationController?.pushViewController(TutorHarassment(), animated: true)
			case 4:
				navigationController?.pushViewController(TutorOther(), animated: true)
			default:
				break
			}
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

class SessionDetailsTableViewCell : UITableViewCell {
	
	var rightLabel = UILabel()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configureTableViewCell() {
		addSubview(rightLabel)
		let cellBackground = UIView()
		cellBackground.backgroundColor = UIColor(red: 0.08, green: 0.05, blue: 0.08, alpha: 1)
		selectedBackgroundView = cellBackground
		
		textLabel?.font = Fonts.createSize(14)
		textLabel?.textColor = Colors.grayText
		textLabel?.adjustsFontSizeToFitWidth = true
		
		backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		
		rightLabel.font = Fonts.createSize(14)
		rightLabel.textColor = Colors.grayText
		rightLabel.adjustsFontSizeToFitWidth = true
		rightLabel.numberOfLines = 2
		rightLabel.textAlignment = .right
		
		applyConstraints()
	}
	
	func applyConstraints() {
		rightLabel.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(5)
			make.centerY.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalToSuperview()
		}
	}
}
