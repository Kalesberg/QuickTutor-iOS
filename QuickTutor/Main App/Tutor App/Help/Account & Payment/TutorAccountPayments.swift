//
//  TutorAccountPayments.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/23/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorAccountPayments: BaseViewController {
    override var contentView: AccountPaymentsView {
        return view as! AccountPaymentsView
    }

    var options = ["Changing my account information", "Updating a payment method", "Payments and earnings", "I forgot my password", "I have another question"]

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(CustomHelpTableViewCell.self, forCellReuseIdentifier: "accountPaymentsCell")
    }

    override func loadView() {
        view = AccountPaymentsView()
    }

}

extension TutorAccountPayments: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomHelpTableViewCell = tableView.dequeueReusableCell(withIdentifier: "accountPaymentsCell") as! CustomHelpTableViewCell
        insertBorder(cell: cell)

        cell.textLabel?.text = options[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(AccountInfoVC(), animated: true)
        case 1:
            navigationController?.pushViewController(TutorUpdatePayment(), animated: true)
        case 2:
            navigationController?.pushViewController(TutorPaymentEarnings(), animated: true)
        case 3:
            navigationController?.pushViewController(ForgotPasswordVC(), animated: true)
        case 4:
            navigationController?.pushViewController(AnotherQuestionVC(), animated: true)
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func insertBorder(cell: UITableViewCell) {
        let border = UIView(frame: CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
        border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        cell.contentView.addSubview(border)
    }
}
