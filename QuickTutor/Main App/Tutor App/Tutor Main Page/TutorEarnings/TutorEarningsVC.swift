//
//  TutorEarnings.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorEarnings: BaseViewController {
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

        displayLoadingOverlay()
        Stripe.retrieveBalanceTransactionList(acctId: CurrentUser.shared.tutor.acctId) { _, transactions in
            guard let transactions = transactions else { return }
            self.datasource = transactions.data.sorted { return $0.created < $1.created }
            self.dismissOverlay()
        }

        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self

        contentView.tableView.register(TutorEarningsTableCellView.self, forCellReuseIdentifier: "tutorEarningsTableCellView")
    }

    private func getYearlyEarnings() {
        var thisYearTotal: Int = 0

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
            formattedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, formattedString.length))

            contentView.label.attributedText = formattedString
            contentView.label.textAlignment = .center
            contentView.label.numberOfLines = 0
        }
    }

    private func getEarnings() {
        var last7Days: Int = 0
        var last30Days: Int = 0
        var allTime: Int = 0

        let lastWeek = NSDate().timeIntervalSince1970 - 604_800 // subctract 7 days
        let lastMonth = NSDate().timeIntervalSince1970 - 2_629_743 // substract 30 days

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
        formattedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, formattedString.length))

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

extension TutorEarnings: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tutorEarningsTableCellView", for: indexPath) as! TutorEarningsTableCellView

        if indexPath.row % 2 == 0 {
            cell.backgroundColor = Colors.registrationDark
        }
		
        cell.leftLabel.attributedText = NSMutableAttributedString()
			.bold("\(datasource[indexPath.row].description ?? "Tutoring Session")\n", 14, UIColor(hex: "22C755"))
            .regular("\(datasource[indexPath.row].created.earningsDateFormat())", 14, .white)

        if let net = datasource[indexPath.row].net {
            cell.rightLabel.text = net.currencyFormat()
        }

		return cell
    }
}
