//
//  LearnerUnprofessional.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class LearnerUnprofessionalView : TutorUnprofessionalView {
    
    override func configureView() {
        super.configureView()
    
        header.text = "My learner was unprofessional"
    }
	override func layoutSubviews() {
		statusbarView.backgroundColor = Colors.tutorBlue
		navbar.backgroundColor = Colors.tutorBlue
	}
}


class LearnerUnprofessional : BaseViewController {
    
    override var contentView: LearnerUnprofessionalView {
        return view as! LearnerUnprofessionalView
    }
    
    var options = ["My learner was rude", "My learner made me feel unsafe", "My learner didn't match their profile picture(s)"]
	
	var datasource : UserSession! {
		didSet {
			print("datasource set")
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(CustomFileReportTableViewCell.self, forCellReuseIdentifier: "fileReportCell")
    }
    
    override func loadView() {
        view = LearnerUnprofessionalView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        
    }
}

extension LearnerUnprofessional : UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row) {
        case 0:
			let next = LearnerRude()
			next.datasource = self.datasource
            navigationController?.pushViewController(next, animated: true)
        case 1:
			let next = LearnerUnsafe()
			next.datasource = self.datasource
            navigationController?.pushViewController(next, animated: true)
        case 2:
			let next = LearnerProfilePics()
			next.datasource = self.datasource
            navigationController?.pushViewController(next, animated: true)
        default:
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func insertBorder(cell: UITableViewCell) {
        let border = UIView(frame:CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
        border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        cell.contentView.addSubview(border)
    }
}
