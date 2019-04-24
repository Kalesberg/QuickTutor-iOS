//
//  QTCloseAccountReasonViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 4/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTCloseAccountReasonViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    static var controller: QTCloseAccountReasonViewController {
        return QTCloseAccountReasonViewController(nibName: String(describing: QTCloseAccountReasonViewController.self), bundle: nil)
    }
    
    // Parameters
    var closeAccountType: QTCloseAccountType!
    
    let reasons = ["I have privacy concerns.", "I don't find QuickTutor useful.", "QuickTutor is confusing to use.", "I don't have a reason."]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Close Account"
        setupReasonTable()
    }

    // MARK: - Actions
    
    // MARK: - Functions
    func setupReasonTable() {
        
        // Register tableviewcells.
        tableView.register(QTCloseAccountReasonTableViewCell.nib, forCellReuseIdentifier: QTCloseAccountReasonTableViewCell.reuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set heights of cells.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 57
        tableView.tableFooterView = nil
    }
}

extension QTCloseAccountReasonViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = QTCloseAccountSubmitViewController.controller
        controller.reason = reasons[indexPath.row]
        controller.closeAccountType = closeAccountType
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension QTCloseAccountReasonViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let cell = tableView.dequeueReusableCell(withIdentifier: QTCloseAccountReasonTableViewCell.reuseIdentifier, for: indexPath) as? QTCloseAccountReasonTableViewCell {
            cell.setData(reason: reasons[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
        
        cell.selectionStyle = .none
        return cell
    }
}

