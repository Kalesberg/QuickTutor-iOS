//
//  TutorRatings.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorRatingsView : TutorHeaderLayoutView {
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 250
        tableView.isScrollEnabled = true
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
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
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
	
	var tutor : AWTutor! {
		didSet{
			contentView.tableView.reloadData()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		configureDelegates()
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
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return 30
        case 3:
            return 120
        case 4:
            return 30
        case 5:
            return UITableViewAutomaticDimension
        default:
            break
        }
        return 0
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
				.bold("\(tutor.numSessions!)\n", 16, .white)
				.regular("Sessions", 15, Colors.grayText)
			
			let paragraphStyle1 = NSMutableParagraphStyle()
			
			paragraphStyle1.lineSpacing = 6
			
			formattedString1.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle1, range:NSMakeRange(0, formattedString1.length))
		
			cell.infoLabel1.attributedText = formattedString1
			
			cell.infoLabel1.textAlignment = .center
			cell.infoLabel1.numberOfLines = 0
			
			let formattedString2 = NSMutableAttributedString()
			
			formattedString2
				.bold("\(tutor.numSessions!)\n", 16, .white)
				.regular("5-Stars", 15, Colors.grayText)
			
			let paragraphStyle2 = NSMutableParagraphStyle()
			
			paragraphStyle2.lineSpacing = 6
			
			formattedString2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle2, range:NSMakeRange(0, formattedString2.length))
			
			cell.infoLabel2.attributedText = formattedString2
			
			cell.infoLabel2.textAlignment = .center
			cell.infoLabel3.numberOfLines = 0
			
			let formattedString3 = NSMutableAttributedString()
			
			formattedString3
				.bold("\(tutor.hours!)\n", 16, .white)
				.regular("Hours", 15, Colors.grayText)
			
			let paragraphStyle3 = NSMutableParagraphStyle()
			
			paragraphStyle3.lineSpacing = 6
			
			formattedString3.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle3, range:NSMakeRange(0, formattedString3.length))
			
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
				cell.subjectLabel.text = tutor.topSubject!
				//store top subject as a path.
			return cell
        case 4:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        case 5:
			
            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingTableViewCell", for: indexPath) as! RatingTableViewCell
            cell.datasource = tutor.reviews
            cell.backgroundColor = Colors.registrationDark
            
//            cell.reviewLabel.snp.updateConstraints { (make) in
//                make.top.equalToSuperview().inset(15)
//            }
//			
            cell.seeAllButton.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().inset(15)
            }
            
            return cell
			
        default:
            break
        }
        
        return UITableViewCell()
    }
}

