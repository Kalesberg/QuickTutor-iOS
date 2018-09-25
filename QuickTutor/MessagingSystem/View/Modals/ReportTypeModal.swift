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
    let reportTypeStrings = ["Innapropriate Messages", "Innapropriate Photos", "Harassment", "Fake Profile"]
    var reportSuccessfulModal: ReportSuccessfulModal?
    var chatPartnerId: String?

    let tableView: UITableView = {
        let tv = UITableView()
        tv.register(SessionTableCell.self, forCellReuseIdentifier: "cellId")
        tv.backgroundColor = .red
        tv.isScrollEnabled = false
        return tv
    }()

    override func setupViews() {
        super.setupViews()
        setupTableView()
    }

    override func setupTitleLabel() {
        super.setupTitleLabel()
        titleLabel.text = "Report"
    }

    private func setupTableView() {
        background.addSubview(tableView)
        tableView.anchor(top: titleBackground.bottomAnchor, left: background.leftAnchor, bottom: background.bottomAnchor, right: background.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ReportTypeModal: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SessionTableCell
        cell.textLabel?.text = reportTypeStrings[indexPath.row]
        cell.backgroundColor = Colors.navBarColor
        cell.textLabel?.font = Fonts.createBoldSize(13)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 41
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            reportForReason(.inappropriateMessages)
        case 1:
            reportForReason(.inappropriatePhotos)
        case 2:
            reportForReason(.harassment)
        case 3:
            reportForReason(.fakeProfile)
        default:
            break
        }
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

enum ReportType: String {
    case inappropriateMessages = "innapropriate messages"
    case inappropriatePhotos = "innapropriate photos"
    case harassment
    case fakeProfile = "fake profile"
}
