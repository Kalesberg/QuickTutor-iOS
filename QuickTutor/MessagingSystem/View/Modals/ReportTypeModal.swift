//
//  ReportTypeModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

class ReportTypeModal: BaseCustomModal {
    
    let reportTypeStrings = ["Inappropriate Language", "Inappropriate Action", "Harassment/Bullying", "Impersonation", "Cancel"]
    var reportSuccessfulModal: ReportSuccessfulModal?
    var chatPartnerId: String?

    let tableView: UITableView = {
        let tv = UITableView()
        tv.register(SessionTableCell.self, forCellReuseIdentifier: "cellId")
        tv.isScrollEnabled = false
        tv.separatorStyle = .none
        tv.backgroundColor = Colors.newScreenBackground
        return tv
    }()

    override func setupViews() {
        super.setupViews()
        setupTableView()
        setHeightTo(350)
    }

    override func setupTitleLabel() {
        super.setupTitleLabel()
        titleLabel.text = "Report"
    }

    private func setupTableView() {
        background.addSubview(tableView)
        tableView.anchor(top: titleLabel.bottomAnchor, left: background.leftAnchor, bottom: background.bottomAnchor, right: background.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ReportTypeModal: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SessionTableCell
        cell.button.setTitle(reportTypeStrings[indexPath.row], for: .normal)
        cell.tag = indexPath.row
        cell.delegate = self
        if indexPath.row == 4 {
            cell.button.backgroundColor = Colors.newScreenBackground
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleReportAtIndex(indexPath.row)
    }
    
    func handleReportAtIndex(_ index: Int) {
        switch index {
        case 0:
            reportForReason(.inappropriateLanguage)
        case 1:
            reportForReason(.inappropriateAction)
        case 2:
            reportForReason(.harassment)
        case 3:
            reportForReason(.impersonation)
        default:
            dismiss()
        }
        guard index != 4 else { return }
        dismiss()
        reportSuccessfulModal = ReportSuccessfulModal()
        reportSuccessfulModal?.show()

    }

    func reportForReason(_ reason: ReportType) {
        guard let partnerId = chatPartnerId, let uid = Auth.auth().currentUser?.uid else { return }
        let reportData = ["reportedBy": uid, "reason": reason.rawValue]
        Database.database().reference().child("reports").child(partnerId).childByAutoId().setValue(reportData)
    }
}

extension ReportTypeModal: SessionTableCellDelegate {
    func sessionTableCell(_ cell: SessionTableCell, didSelectItemAt index: Int) {
        handleReportAtIndex(index)
    }
}

enum ReportType: String {
    case inappropriateLanguage = "inappropriate language"
    case inappropriateAction = "inappropriate action"
    case harassment = "harassment or bullying"
    case impersonation = "impersonation"
}
