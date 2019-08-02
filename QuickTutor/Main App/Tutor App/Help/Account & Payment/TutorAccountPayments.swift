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

    var options = ["Changing my account information", "Updating a payout method", "Payouts and earnings", "I forgot my password", "I have another question"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Accounts & payments"
        
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
        let border = UIView(frame: CGRect(x: 10, y: cell.contentView.frame.size.height - 1.0, width: self.view.frame.width - 20, height: 1))
        border.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 58/255, alpha: 1)
        cell.contentView.addSubview(border)
    }
}
