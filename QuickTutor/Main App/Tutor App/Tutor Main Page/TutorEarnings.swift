//
//  TutorEarnings.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorEarningsView : MainLayoutTitleBackButton {
    
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
	
	let label : UILabel = {
		let label = UILabel()
		return label
	}()
	
    let earningsLabel = UILabel()
    
    let infoContainer : UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.navBarColor
        
        return view
    }()
	
    let imageView : UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "green-pattern").alpha(0.39)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = Colors.green
        
        return view
    }()
    
    let earningsContainer = UIView()
    
    let earnings2018 : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(15)
        label.textColor = .white
        label.text = "2018 EARNINGS"
        label.textAlignment = .center
        
        return label
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
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
		tableView.alwaysBounceVertical = true
        return tableView
    }()
    
    override func configureView() {
        addSubview(imageView)
        imageView.addSubview(label)
        addSubview(infoContainer)
        infoContainer.addSubview(summaryLabel)
        infoContainer.addSubview(earningsLabel)
        addSubview(earningsContainer)
        earningsContainer.addSubview(earnings2018)
        addSubview(tableView)
        addSubview(recentStatementsLabel)
        super.configureView()
        
        navbar.backgroundColor = Colors.green
        statusbarView.backgroundColor = Colors.green
        title.label.text = "Your Earnings"
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        earningsContainer.applyGradient(firstColor: UIColor(hex: "1A943F").cgColor, secondColor: UIColor(hex: "1FB45C").cgColor, angle: 80, frame: earningsContainer.bounds)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom).inset(-1)
            make.width.equalToSuperview()
            make.height.equalTo(110)
            make.centerX.equalToSuperview()
        }
        
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        earningsContainer.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).inset(-1)
        }
        earnings2018.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        infoContainer.snp.makeConstraints { (make) in
            make.top.equalTo(earnings2018.snp.bottom).inset(-1)
            make.height.equalTo(100)
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
            make.height.equalTo(40)
            make.top.equalTo(infoContainer.snp.bottom).inset(-10)
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
		Stripe.retrieveBalanceTransactionList(acctId: CurrentUser.shared.tutor.acctId) { (error, transactions) in
			guard let transactions = transactions else { return }
			self.datasource = transactions.data.sorted { return $0.created < $1.created }
		}
		self.dismissOverlay()
		
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
			let formattedString = NSMutableAttributedString()
			
			formattedString
				.bold("\(thisYearTotal.currencyFormat())", 45, .white)

			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 8
			formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range: NSMakeRange(0, formattedString.length))

			contentView.label.attributedText = formattedString
			contentView.label.textAlignment = .center
			contentView.label.numberOfLines = 0
		}
	}
	
	private func getEarnings() {
		var last7Days : Int = 0
		var last30Days : Int = 0
		var allTime : Int = 0

		let lastWeek = NSDate().timeIntervalSince1970 - 604800 // subctract 7 days
		let lastMonth = NSDate().timeIntervalSince1970 - 2629743 // substract 30 days

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
			.bold(allTime.currencyFormat(), 15, .white)

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
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = Colors.registrationDark
        }
		
        let formattedString = NSMutableAttributedString()
        formattedString
            .regular("\(datasource[indexPath.row].created.earningsDateFormat()) - ", 16, .white)
            .regular("\(datasource[indexPath.row].description ?? "Session")", 16, UIColor(hex: "22C755"))

        cell.leftLabel.attributedText = formattedString
        //cell.leftLabel.text = "\(datasource[indexPath.row].created.earningsDateFormat()) - \(datasource[indexPath.row].description ?? "Session")"
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
        label.font = Fonts.createSize(14)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        
        return label
    }()
    
    let rightLabelContainer : UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor(hex: "1EAD4A")
        view.layer.cornerRadius = 11
        
        return view
    }()
    
    override func configureView() {
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightLabelContainer)
        rightLabelContainer.addSubview(rightLabel)
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
        rightLabelContainer.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15)
            make.width.equalTo(65)
            make.height.equalTo(22)
        }
        rightLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
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

