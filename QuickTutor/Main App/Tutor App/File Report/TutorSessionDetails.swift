//
//  TutorSessionDetails.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorSessionDetails : BaseViewController {
	
	override var contentView: SessionDetailsView {
		return view as! SessionDetailsView
	}
	
	let options = ["Learner cancelled", "Learner was late", "Learner was unprofessional", "Harrassment", "Other"]

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
	
	override func handleNavigation() { }
}
extension TutorSessionDetails : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.estimatedRowHeight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomFileReportTableViewCell = tableView.dequeueReusableCell(withIdentifier: "fileReportCell", for: indexPath) as! CustomFileReportTableViewCell
        
        cell.textLabel?.text = options[indexPath.row]
        
        return cell
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0:
                navigationController?.pushViewController(LearnerCancelled(), animated: true)
            case 1:
                navigationController?.pushViewController(LearnerLate(), animated: true)
            case 2:
                navigationController?.pushViewController(LearnerUnprofessional(), animated: true)
            case 3:
                navigationController?.pushViewController(LearnerHarassment(), animated: true)
            case 4:
                navigationController?.pushViewController(LearnerOther(), animated: true)
            default:
                break
        }

		tableView.deselectRow(at: indexPath, animated: true)
	}
}


