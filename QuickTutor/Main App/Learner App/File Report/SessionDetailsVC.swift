//
//  SessionOptions.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseUI
import Foundation
import SDWebImage
import UIKit

class SessionDetailsView: MainLayoutHeader {
    var tableView = UITableView()
    var sessionHeader = FileReportSessionView()

    override func configureView() {
        addSubview(tableView)
        addSubview(sessionHeader)
        super.configureView()

        header.text = "Session Details"

        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
    }

    override func applyConstraints() {
        super.applyConstraints()

        sessionHeader.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(85)
        }

        tableView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(sessionHeader.snp.bottom)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }

}

class SessionDetailsVC: BaseViewController {
    override var contentView: SessionDetailsView {
        return view as! SessionDetailsView
    }

    let options = ["My tutor cancelled", "My tutor was late", "My tutor was unprofessional", "Harrassment", "Other"]

    var datasource: UserSession! {
        didSet {
            setHeader()
        }
    }

    let storageRef = Storage.storage().reference(forURL: Constants.STORAGE_URL)

    var localTimeZoneAbbreviation: String {
        return TimeZone.current.abbreviation() ?? ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "File Report"
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(CustomFileReportTableViewCell.self, forCellReuseIdentifier: "fileReportCell")
    }

    override func viewDidLayoutSubviews() {
        contentView.sessionHeader.applyGradient(firstColor: Colors.purple.cgColor, secondColor: Colors.purple.cgColor, angle: 110, frame: contentView.sessionHeader.bounds)
    }

    override func loadView() {
        view = SessionDetailsView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func getFormattedTime(unixTime: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }

    private func getFormattedDate(unixTime: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
        dateFormatter.dateFormat = "d-MMM"
        return dateFormatter.string(from: date)
    }

    private func setHeader() {
        let startTime = getFormattedTime(unixTime: TimeInterval(datasource.startTime))
        let endTime = getFormattedTime(unixTime: TimeInterval(datasource.endTime))
        let date = getFormattedDate(unixTime: TimeInterval(datasource.date)).split(separator: "-")

        if datasource.name == "" {
            contentView.sessionHeader.nameLabel.text = "User no longer exists."
        } else {
            let name = datasource.name.split(separator: " ")
            if name.count == 2 {
                contentView.sessionHeader.nameLabel.text = "with \(String(name[0]).capitalized) \(String(name[1]).capitalized.prefix(1))."
            } else {
                contentView.sessionHeader.nameLabel.text = "with \(String(name[0]).capitalized)"
            }
        }
        contentView.sessionHeader.profilePic.sd_setImage(with: storageRef.child("student-info").child(datasource.otherId).child("student-profile-pic1"), placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
        contentView.sessionHeader.subjectLabel.text = datasource.subject
        contentView.sessionHeader.monthLabel.text = String(date[1])
        contentView.sessionHeader.dayLabel.text = String(date[0])
        contentView.sessionHeader.sessionInfoLabel.text = "\(startTime) - \(endTime)"
        let sessionCost = String(format: "$%.2f", (datasource.cost / 100))
        contentView.sessionHeader.sessionInfoLabel.text = "\(startTime) - \(endTime) \(sessionCost)"
    }

    override func handleNavigation() {}
}

extension SessionDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomFileReportTableViewCell = tableView.dequeueReusableCell(withIdentifier: "fileReportCell", for: indexPath) as! CustomFileReportTableViewCell
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let next = TutorCancelledVC()
            next.datasource = datasource
            navigationController?.pushViewController(next, animated: true)
        case 1:
            let next = TutorLateVC()
            next.datasource = datasource
            navigationController?.pushViewController(next, animated: true)
        case 2:
            let next = TutorUnprofessionalVC()
            next.datasource = datasource
            navigationController?.pushViewController(next, animated: true)
        case 3:
            let next = TutorHarassmentVC()
            next.datasource = datasource
            navigationController?.pushViewController(next, animated: true)
        case 4:
            let next = TutorOtherVC()
            next.datasource = datasource
            navigationController?.pushViewController(next, animated: true)
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
