//
//  TutorEarnings.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorEarningsView : TutorLayoutView {
    
    let label : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        
        let formattedString = NSMutableAttributedString()
        
        formattedString
            .bold("$3,350\n", 45, .white)
            .regular("2018 Earnings", 15, .white)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        label.attributedText = formattedString
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    let summaryLabel : UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("Earnings in past 7 days:\n", 15, .white)
            .bold("Earnings in past 30 days:\n", 15, .white)
            .bold("All time earnings:", 15, .white)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        label.attributedText = formattedString
        label.numberOfLines = 0
        
        return label
    }()
    
    let earningsLabel : UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("$12.00\n", 15, .white)
            .bold("$123.00\n", 15, .white)
            .bold("$1234.00", 15, .white)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        label.attributedText = formattedString
        label.numberOfLines = 0
        label.textAlignment = .right
        
        return label
    }()
    
    let infoContainer : UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.registrationDark
        
        return view
    }()
    
    let recentStatementsLabel : UILabel = {
        let label = UILabel()
        
        label.text = "Recent Statements"
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        
        return label
    }()
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.rowHeight = 40
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorColor = Colors.divider
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = Colors.registrationDark
        tableView.isScrollEnabled = false
        
        return tableView
    }()
    
    override func configureView() {
        addSubview(label)
        addSubview(infoContainer)
        infoContainer.addSubview(summaryLabel)
        infoContainer.addSubview(earningsLabel)
        addSubview(tableView)
        addSubview(recentStatementsLabel)
        super.configureView()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        label.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(150)
            make.centerX.equalToSuperview()
        }
        
        infoContainer.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom)
            make.height.equalTo(90)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        summaryLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(15)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        earningsLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(15)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        recentStatementsLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(50)
            make.top.equalTo(infoContainer.snp.bottom).inset(-15)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(recentStatementsLabel.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}

class TutorEarnings : BaseViewController {
    
    override var contentView: TutorEarningsView {
        return view as! TutorEarningsView
    }
    override func loadView() {
        view = TutorEarningsView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        
        contentView.tableView.register(TutorEarningsTableCellView.self, forCellReuseIdentifier: "tutorEarningsTableCellView")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.infoContainer.layer.addBorder(edge: .top, color: Colors.divider, thickness: 1)
        contentView.infoContainer.layer.addBorder(edge: .bottom, color: Colors.divider, thickness: 1)
        contentView.tableView.layer.addBorder(edge: .top, color: Colors.divider, thickness: 1)
        contentView.tableView.layer.addBorder(edge: .bottom, color: Colors.divider, thickness: 1)
    }
}


class TutorEarningsTableCellView : BaseTableViewCell {
    
    let leftLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createSize(16)
        label.adjustsFontSizeToFitWidth = true
        label.text = "3/3/18 - Chemistry"
        
        return label
    }()
    
    let rightLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createSize(16)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.text = "$10.00"
        
        return label
    }()
    
    override func configureView() {
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightLabel)
        super.configureView()
        
        backgroundColor = .clear
        selectionStyle = .none
        
        applyConstraints()
        
    }
    
    override func applyConstraints() {
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(15)
            make.height.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        rightLabel.snp.makeConstraints { (make) in
            make.left.equalTo(leftLabel.snp.right)
            make.centerY.height.equalToSuperview()
            make.right.equalToSuperview().inset(15)
        }
    }
}

extension TutorEarnings : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tutorEarningsTableCellView", for: indexPath) as! TutorEarningsTableCellView
        
        return cell
    }
}
