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
    let sessionDetails = ["Your charge", "Transaction Fee", "Payment Proc.", "You Made", "Recieved Payment"]
    
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
extension TutorSessionDetails : UITableViewDelegate, UITableViewDataSource {
    
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
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

