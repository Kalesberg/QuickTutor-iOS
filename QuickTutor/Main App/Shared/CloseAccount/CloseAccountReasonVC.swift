//
//  CloseAccountReason.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class CloseAccountReasonView: MainLayoutTitleBackButton {
    let warningLabel = WarningLabel()

    let headerLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(18)
        label.adjustsFontSizeToFitWidth = true
        label.text = "Please select a reason for closing your account."
        label.textColor = .white
        label.textAlignment = .center

        return label
    }()

    let tableView: UITableView = {
        let tableView = UITableView()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.isScrollEnabled = false
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)

        return tableView
    }()

    override func configureView() {
        addSubview(warningLabel)
        addSubview(headerLabel)
        addSubview(tableView)
        super.configureView()

        navbar.backgroundColor = Colors.qtRed
        statusbarView.backgroundColor = Colors.qtRed
        title.label.text = "Close Account"
    }

    override func applyConstraints() {
        super.applyConstraints()

        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom).inset(-20)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
        }

        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(warningLabel.snp.bottom).inset(-30)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(headerLabel.snp.bottom).inset(-30)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

class CloseAccountReasonVC: BaseViewController {
    override var contentView: CloseAccountReasonView {
        return view as! CloseAccountReasonView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(CustomHelpTableViewCell.self, forCellReuseIdentifier: "helpCell")
    }

    var options = ["I have privacy concerns.", "I don't find QuickTutor useful.", "QuickTutor is confusing to use.", "I don't have a reason."]

    override func loadView() {
        view = CloseAccountReasonView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func handleNavigation() {}
}

extension CloseAccountReasonVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomHelpTableViewCell = tableView.dequeueReusableCell(withIdentifier: "helpCell") as! CustomHelpTableViewCell
        insertBorder(cell: cell)

        cell.textLabel?.text = options[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let next = CloseAccountSubmissionVC()
        next.contentView.reasonLabel.text = options[indexPath.row]
        next.reason = options[indexPath.row]
        navigationController?.pushViewController(next, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func insertBorder(cell: UITableViewCell) {
        let border = UIView(frame: CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
        border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        cell.contentView.addSubview(border)
    }
}
