//
//  TutorUnprofessional.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorUnprofessionalView : MainLayoutHeader {
    
    var tableView = UITableView()
    
    override func configureView() {
        addSubview(tableView)
        super.configureView()
        
        title.label.text = "File Report"
        header.text = "My tutor was unprofessional"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.isScrollEnabled = false
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		
		applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()

		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(header.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
		}
	}
	override func layoutSubviews() {
		statusbarView.backgroundColor = Colors.learnerPurple
		navbar.backgroundColor = Colors.learnerPurple
	}
}


class TutorUnprofessional : BaseViewController {
    
    override var contentView: TutorUnprofessionalView {
        return view as! TutorUnprofessionalView
    }
    
    var options = ["My tutor was rude", "My tutor made me feel unsafe", "My tutor didn't help me", "Is my tutor allowed to ask for tips?", "My tutor didn't match their profile picture(s)"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(CustomFileReportTableViewCell.self, forCellReuseIdentifier: "fileReportCell")
    }
    
    override func loadView() {
        view = TutorUnprofessionalView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        
    }
}

extension TutorUnprofessional : UITableViewDelegate, UITableViewDataSource {
    
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
            navigationController?.pushViewController(TutorRude(), animated: true)
        case 1:
            navigationController?.pushViewController(TutorUnsafe(), animated: true)
        case 2:
            navigationController?.pushViewController(TutorDidNotHelp(), animated: true)
        case 3:
            navigationController?.pushViewController(TutorTips(), animated: true)
        case 4:
			navigationController?.pushViewController(TutorProfilePics(), animated: true)
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

