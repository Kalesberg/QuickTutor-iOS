//
//  QTTutorDashboardViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 1/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseUI
import Charts

class QTTutorDashboardViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tutorSettingView: QTCustomView!
    @IBOutlet weak var tableView: UITableView!
    
    let headerView: QTTutorDashboardHeaderView = QTTutorDashboardHeaderView.load()
    let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    
    var durationType: QTTutorDashboardDurationType = QTTutorDashboardDurationType.month
    var datasource = [BalanceTransaction.Data]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    struct QTDashboardDimension {
        static let headerViewHeight: CGFloat = 252
        static let sectionHeaderViewHeight: CGFloat = 54
        static let rowHeight: CGFloat = 224
    }
    
    static func load() -> QTTutorDashboardViewController {
        return QTTutorDashboardViewController(nibName: String(describing: QTTutorDashboardViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        // Register a resuable cell and set dimensions for table view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QTTutorDashboardTableViewCell.nib,
                           forCellReuseIdentifier: QTTutorDashboardTableViewCell.reuseIdentifier)
        tableView.tableHeaderView = headerView
        tableView.sectionHeaderHeight = QTDashboardDimension.sectionHeaderViewHeight
        tableView.estimatedSectionHeaderHeight = QTDashboardDimension.sectionHeaderViewHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = QTDashboardDimension.rowHeight
        tableView.separatorStyle = .none
        
        // Get earnings from stripe
        Stripe.retrieveBalanceTransactionList(acctId: CurrentUser.shared.tutor.acctId) { _, transactions in
            guard let transactions = transactions else { return }
            self.datasource = transactions.data.filter({ (transactions) -> Bool in
                if transactions.amount != nil && transactions.amount! > 0 {
                    return true
                }
                return false
            })
        }
        
        initUserBasicInformation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Set table header view
        tableView.tableHeaderView?.bounds.size = CGSize(width: tableView.frame.width,
                                                        height: QTDashboardDimension.headerViewHeight)
        tableView.reloadData()
    }

    // MARK: - Actions
    @IBAction func onTutorSettingsViewTapped(_ sender: Any) {
    }
    
    // MARK: - Functions
    func initUserBasicInformation() {
        guard let tutor = CurrentUser.shared.tutor else { return }
        
        let reference = storageRef.child("student-info").child(tutor.uid).child("student-profile-pic1")
        headerView.nameLabel.text = tutor.formattedName
        headerView.subjectLabel.text = tutor.topSubject == nil || tutor.topSubject?.isEmpty ?? true ? tutor.subjects?.first : tutor.topSubject
        headerView.avatarImageView.sd_setImage(with: reference)
        headerView.hourlyRateLabel.text = "$\(String(describing: tutor.price ?? 0)) per hour"
        headerView.ratingLabel.text = "\(String(describing: tutor.tRating ?? 5.0))"
        headerView.subjectsLabel.text = "\(tutor.subjects?.count ?? 0)"
        headerView.sessionsLabel.text = "\(tutor.tNumSessions ?? 0)"
    }
    
    private func getYearlyEarnings() {
        var thisYearTotal: Int = 0
        
        let year = Calendar.current.component(.year, from: Date())
        
        if let firstOfYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1)) {
            let firstDay = firstOfYear.timeIntervalSince1970
            for transaction in datasource {
                guard let net = transaction.net else { continue }
                if transaction.created > Int(firstDay) {
                    thisYearTotal += net
                }
            }
            let formattedString = NSMutableAttributedString()
            
            formattedString
                .bold("\(thisYearTotal.currencyFormat())", 45, .white)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            formattedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, formattedString.length))
            
            
        }
    }
    
}

// MARK: - UITableViewDelegate
extension QTTutorDashboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let durationView: QTTutorDashboardDurationView = QTTutorDashboardDurationView.load()
        
        durationView.durationDidSelect = { type in
            self.durationType = type
            tableView.reloadData()
        }
        durationView.setData(durationType: durationType)
        return durationView
    }
}

// MARK: - UITableViewDataSource
extension QTTutorDashboardViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: QTTutorDashboardTableViewCell? = tableView.dequeueReusableCell(withIdentifier: QTTutorDashboardTableViewCell.reuseIdentifier,
                                                 for: indexPath) as? QTTutorDashboardTableViewCell
        if let cell = cell {
            
            if indexPath.row == 0 {
                cell.setData(chartType: .sessions,
                             durationType: durationType,
                             chartData: [])
            } else if indexPath.row == 1 {
                var unit: TimeInterval = 00
                switch durationType {
                case .week:
                    unit = NSDate().timeIntervalSince1970 - 604_800 // subctract 7 days
                case .month:
                    unit = NSDate().timeIntervalSince1970 - 2_629_743 // substract 30 days
                case .quarter:
                    unit = NSDate().timeIntervalSince1970 - 7_889_229
                case .year:
                    unit = NSDate().timeIntervalSince1970 - 31_556_916
                }
                
                cell.setData(chartType: .earnings,
                             durationType: durationType,
                             chartData: datasource
                                .filter({$0.created > Int(unit)})
                                .map({ data -> QTTutorDashboardChartData in
                                    return QTTutorDashboardChartData(valueY: Double(data.net ?? 0), date: TimeInterval(data.created))
                                })
                )
            } else {
                cell.setData(chartType: .hours,
                             durationType: durationType,
                             chartData: [])
            }
            cell.selectionStyle = .none
            cell.gestureRecognizers = nil
            return cell
        }
        
        return UITableViewCell()
    }
    
}
