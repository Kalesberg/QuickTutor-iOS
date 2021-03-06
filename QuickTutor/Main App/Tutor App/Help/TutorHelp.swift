//
//  Help.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import Foundation
import UIKit

class TutorHelp: BaseViewController {
    override var contentView: LearnerHelpView {
        return view as! LearnerHelpView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(CustomHelpTableViewCell.self, forCellReuseIdentifier: "helpCell")
        navigationItem.title = "Help"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func loadView() {
        view = LearnerHelpView()
    }

    var options = ["Accounts & payments", "Guide", "Handbook"]

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func handleNavigation() {}
}

extension TutorHelp: UITableViewDataSource, UITableViewDelegate {
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
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(TutorAccountPayments(), animated: true)
        case 1:
            navigationController?.pushViewController(TutorQTGuide(), animated: true)
        case 2:
            navigationController?.pushViewController(TutorHandook(), animated: true)
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
