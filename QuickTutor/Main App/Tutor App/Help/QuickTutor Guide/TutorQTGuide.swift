//
//  TutorQTGuide.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorQTGuide: BaseViewController {
    override var contentView: QTGuideView {
        return view as! QTGuideView
    }

    var options = ["Connections", "Sessions", "Service Fee"]

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(CustomHelpTableViewCell.self, forCellReuseIdentifier: "accountPaymentsCell")
    }

    override func loadView() {
        view = QTGuideView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TutorQTGuide: UITableViewDataSource, UITableViewDelegate {
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
            navigationController?.pushViewController(TutorConnections(), animated: true)
        case 1:
            navigationController?.pushViewController(TutorSessions(), animated: true)
        case 2:
            navigationController?.pushViewController(TutorServiceFee(), animated: true)
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
