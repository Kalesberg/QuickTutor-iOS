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
	
	let label = UILabel()
    let earningsLabel = UILabel()
	
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
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorColor = Colors.divider
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = Colors.registrationDark
        tableView.isScrollEnabled = true
        tableView.tableFooterView = UIView()
		
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
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
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
	
	let dateFormatter = DateFormatter()
	
	var datasource = [BalanceTransaction.Data]() {
		didSet {
			if datasource.count == 0 {
                contentView.tableView.backgroundView = TutorEarningsTableViewBackground()
			}
			getEarnings()
			getYearlyEarnings()
			contentView.tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		dateFormatter.dateFormat = "MM/dd/yyyy"
		
		self.displayLoadingOverlay()
		Stripe.retrieveBalanceTransactionList(acctId: CurrentUser.shared.tutor.acctId) { (transactions) in
			if let transactions = transactions {
				self.datasource = transactions.data.sorted {
					return $0.created < $1.created
				}
			}
			self.dismissOverlay()
		}
		
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        
        contentView.tableView.register(TutorEarningsTableCellView.self, forCellReuseIdentifier: "tutorEarningsTableCellView")
    }

	private func getYearlyEarnings() {
		var thisYearTotal : Int = 0

		let year = Calendar.current.component(.year, from: Date())

		if let firstOfYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1)) {
			let firstDay = firstOfYear.timeIntervalSince1970
			for transaction in datasource {
				guard let net = transaction.net else { continue }
				if transaction.created > Int(firstDay) {
					thisYearTotal += net
				}
			}
			contentView.label.textColor = .white

			let formattedString = NSMutableAttributedString()

			formattedString
				.bold("\(thisYearTotal.yearlyEarningsFormat())\n", 45, .white)
				.regular("\(year) Earnings", 15, .white)

			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 8
			formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))

			contentView.label.attributedText = formattedString
			contentView.label.textAlignment = .center
			contentView.label.numberOfLines = 0
		}
	}
	
	private func getEarnings() {
		var last7Days : Int = 0
		var last30Days : Int = 0
		var allTime : Int = 0

		let lastWeek = NSDate().timeIntervalSince1970 - 604800
		let lastMonth = NSDate().timeIntervalSince1970 - 2629743

		for transaction in datasource {
			guard let net = transaction.net else { continue }

			if (transaction.created) > Int(lastWeek) {
				last7Days += net
			}
			if (transaction.created) > Int(lastMonth) {
				last30Days += net
			}
			allTime += net
		}

		let formattedString = NSMutableAttributedString()
		formattedString
			.bold(last7Days.currencyFormat() + "\n", 15, .white)
			.bold(last30Days.currencyFormat() + "\n", 15, .white)
			.bold(allTime.currencyFormat() + "\n", 15, .white)

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 8
		formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, formattedString.length))

		contentView.earningsLabel.attributedText = formattedString
		contentView.earningsLabel.numberOfLines = 0
		contentView.earningsLabel.textAlignment = .right
		return
	}
	
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.infoContainer.layer.addBorder(edge: .top, color: Colors.divider, thickness: 1)
        contentView.infoContainer.layer.addBorder(edge: .bottom, color: Colors.divider, thickness: 1)
    }
}

extension TutorEarnings : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return datasource.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "tutorEarningsTableCellView", for: indexPath) as! TutorEarningsTableCellView
		
		cell.leftLabel.text = "\(datasource[indexPath.row].created.earningsDateFormat()) - \(datasource[indexPath.row].description ?? "Session")"
		if let net = datasource[indexPath.row].net {
			cell.rightLabel.text = net.currencyFormat()
		}
		
		return cell
	}
}
class TutorEarningsTableCellView : BaseTableViewCell {
    
    let leftLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createSize(16)
        label.adjustsFontSizeToFitWidth = true
		
        return label
    }()
    
    let rightLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createSize(16)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
		
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

class TutorEarningsTableViewBackground : BaseView {

    let label : UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("No earnings yet!", 20, .white)
            .regular("\n\nPayment information will load here once you have had your first session!", 16, .white)
        
        label.attributedText = formattedString
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(260)
            make.centerX.equalToSuperview()
        }
    }
}

