//
//  AccountPayments.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import Foundation
import SnapKit
import UIKit

class AccountPaymentsView: LearnerHelpView {
    override func configureView() {
        super.configureView()
    }

    override func applyConstraints() {
        super.applyConstraints()
    }
}

class AccountPaymentsVC: BaseViewController {
    override var contentView: AccountPaymentsView {
        return view as! AccountPaymentsView
    }

    var options = ["Changing my account information", "Payment methods", "Payment options", "I forgot my password", "Why was my payment declined?", "I have another question"]

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(CustomHelpTableViewCell.self, forCellReuseIdentifier: "accountPaymentsCell")
        navigationItem.title = "Accounts & payments"
    }

    override func loadView() {
        view = AccountPaymentsView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AccountPaymentsVC: UITableViewDataSource, UITableViewDelegate {
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
            navigationController?.pushViewController(UpdatePaymentVC(), animated: true)
        case 2:
            navigationController?.pushViewController(PaymentOptionsVC(), animated: true)
        case 3:
            navigationController?.pushViewController(ForgotPasswordVC(), animated: true)
        case 4:
            navigationController?.pushViewController(PaymentDeclinedVC(), animated: true)
        case 5:
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
