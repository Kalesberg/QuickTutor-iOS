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
    
    var durationType: QTTutorDashboardDurationType = QTTutorDashboardDurationType.month
    var tutor: AWTutor?
    var transactions = [BalanceTransaction.Data]() {
        didSet {
            var unit: TimeInterval = 00
            var mergeUnit: TimeInterval = 00
            var chartData = [QTTutorDashboardChartData]()
            
            switch durationType {
            case .week:
                unit = NSDate().timeIntervalSince1970 - 604_800 // subctract 7 days
            case .month:
                unit = NSDate().timeIntervalSince1970 - 2_629_743 // subctract 30.43685 days
            case .quarter:
                unit = NSDate().timeIntervalSince1970 - 7_889_229 // subctract 3 months
            case .year:
                unit = NSDate().timeIntervalSince1970 - 31_556_926 // subctract 365.2422 days
            }
            
            let fiteredTransactions = transactions.filter({$0.created > Int(unit)})
            switch durationType {
            case .week, .month:
                var benefit: Double = 00
                for dayIndex in 0...6 {
                    mergeUnit = unit + Double(dayIndex * 86_400)
                    fiteredTransactions
                        .filter({$0.created > Int(mergeUnit)})
                        .forEach({ benefit += Double($0.net ?? 0)})
                    chartData.append(QTTutorDashboardChartData(valueY: benefit, date: mergeUnit))
                }
            case .quarter:
                var benefit: Double = 00
                for weekIndex in 0...12 {
                    mergeUnit = unit + Double(weekIndex * 604_800)
                    fiteredTransactions
                        .filter({$0.created > Int(mergeUnit)})
                        .forEach({ benefit += Double($0.net ?? 0)})
                    chartData.append(QTTutorDashboardChartData(valueY: benefit, date: mergeUnit))
                }
            case .year:
                var benefit: Double = 00
                for monthIndex in 0...11 {
                    mergeUnit = unit + Double(monthIndex * 2_629_743)
                    fiteredTransactions
                        .filter({$0.created > Int(mergeUnit)})
                        .forEach({ benefit += Double($0.net ?? 0)})
                    chartData.append(QTTutorDashboardChartData(valueY: benefit, date: mergeUnit))
                }
                break
            }
            
            earningsChartData = chartData
        }
    }
    
    var sessions = [UserSession]() {
        didSet {
            
            var unit: TimeInterval = 00
            var mergeUnit: TimeInterval = 00
            var sessionsChartData = [QTTutorDashboardChartData]()
            var hoursChartData = [QTTutorDashboardChartData]()
            
            switch durationType {
            case .week:
                unit = NSDate().timeIntervalSince1970 - 604_800 // subctract 7 days
            case .month:
                unit = NSDate().timeIntervalSince1970 - 2_629_743 // subctract 30.43685 days
            case .quarter:
                unit = NSDate().timeIntervalSince1970 - 7_889_229 // subctract 3 months
            case .year:
                unit = NSDate().timeIntervalSince1970 - 31_556_926 // subctract 365.2422 days
            }
            
            let fiteredSessions = sessions.filter({$0.endedAt > unit})
            switch durationType {
            case .week, .month:
                var sessionCount: Double = 00
                var hours: Double = 00
                for dayIndex in 0...6 {
                    mergeUnit = unit + Double(dayIndex * 86_400)
                    fiteredSessions
                        .filter({$0.endedAt > mergeUnit})
                        .forEach({sessionCount += 1; hours += $0.endedAt - $0.startedAt })
                    sessionsChartData.append(QTTutorDashboardChartData(valueY: sessionCount, date: mergeUnit))
                    hoursChartData.append(QTTutorDashboardChartData(valueY: hours, date: mergeUnit))
                }
            case .quarter:
                var sessionCount: Double = 00
                var hours: Double = 00
                for weekIndex in 0...12 {
                    mergeUnit = unit + Double(weekIndex * 604_800)
                    fiteredSessions
                        .filter({$0.endedAt > mergeUnit})
                        .forEach({sessionCount += 1; hours += $0.endedAt - $0.startedAt })
                    sessionsChartData.append(QTTutorDashboardChartData(valueY: sessionCount, date: mergeUnit))
                    hoursChartData.append(QTTutorDashboardChartData(valueY: hours, date: mergeUnit))
                }
            case .year:
                var sessionCount: Double = 00
                var hours: Double = 00
                for monthIndex in 0...11 {
                    mergeUnit = unit + Double(monthIndex * 2_629_743)
                    fiteredSessions
                        .filter({$0.endedAt > mergeUnit})
                        .forEach({sessionCount += 1; hours += $0.endedAt - $0.startedAt })
                    sessionsChartData.append(QTTutorDashboardChartData(valueY: sessionCount, date: mergeUnit))
                    hoursChartData.append(QTTutorDashboardChartData(valueY: hours, date: mergeUnit))
                }
                break
            }
            self.hoursChartData = hoursChartData
            self.sessionsChartData = sessionsChartData
        }
    }
    
    var earningsChartData = [QTTutorDashboardChartData]() {
        didSet {
            tableView.reloadData()
        }
    }
    var sessionsChartData = [QTTutorDashboardChartData]() {
        didSet {
            // Update hours and sessions chart data
            tableView.reloadData()
        }
    }
    var hoursChartData = [QTTutorDashboardChartData]()
    var topSubject: String? {
        didSet {
            headerView.subjectLabel.text = topSubject == nil || topSubject?.isEmpty ?? true ? self.tutor?.subjects?.first : topSubject
        }
    }
    
    struct QTDashboardDimension {
        static let headerViewHeight: CGFloat = 252
        static let sectionHeaderViewHeight: CGFloat = 54
        static let rowHeight: CGFloat = 224
    }
    
    let headerView: QTTutorDashboardHeaderView = QTTutorDashboardHeaderView.load()
    let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    
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
        
        self.tutor = CurrentUser.shared.tutor
        
        initUserBasicInformation()
        findTopSubjects()
        getSessions()
        getEarnings()
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
        guard let tutor = self.tutor else { return }
        
        let reference = storageRef.child("student-info").child(tutor.uid).child("student-profile-pic1")
        headerView.nameLabel.text = tutor.formattedName
        headerView.subjectLabel.text = topSubject == nil || topSubject?.isEmpty ?? true ? tutor.subjects?.first : topSubject
        headerView.avatarImageView.sd_setImage(with: reference)
        headerView.hourlyRateLabel.text = "$\(String(describing: tutor.price ?? 0)) per hour"
        headerView.ratingLabel.text = "\(String(describing: tutor.tRating ?? 5.0))"
        headerView.subjectsLabel.text = "\(tutor.subjects?.count ?? 0)"
        headerView.sessionsLabel.text = "\(tutor.tNumSessions ?? 0)"
    }
    
    func getEarnings() {
        // Get earnings from stripe
        Stripe.retrieveBalanceTransactionList(acctId: CurrentUser.shared.tutor.acctId) { _, transactions in
            guard let transactions = transactions else { return }
            self.transactions = transactions.data.filter({ (transactions) -> Bool in
                if transactions.amount != nil && transactions.amount! > 0 {
                    return true
                }
                return false
            })
        }
    }
    
    func getSessions() {
        guard let tutor = self.tutor else { return }
        FirebaseData.manager.fetchUserSessions(uid: tutor.uid, type: "tutor") { sessions in
            guard let sessions = sessions else { return }
            self.sessions = sessions
        }
    }
    
    private func findTopSubjects() {
        guard let tutor = tutor else { return }
        func bayesianEstimate(C: Double, r: Double, v: Double, m: Double) -> Double {
            return (v / (v + m)) * ((r + Double((m / (v + m)))) * C)
        }
        
        FirebaseData.manager.fetchSubjectsTaught(uid: tutor.uid) { subcategoryList in
            let avg = subcategoryList.map({ $0.rating / 5 }).average
            let topSubcategory = subcategoryList.sorted {
                return bayesianEstimate(C: avg, r: $0.rating / 5, v: Double($0.numSessions), m: 0) > bayesianEstimate(C: avg, r: $1.rating / 5, v: Double($1.numSessions), m: 10)
                }.first
            guard let subcategory = topSubcategory?.subcategory else {
                self.topSubject = nil
                return
            }
            self.topSubject = subcategory
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
                             chartData: sessionsChartData)
            } else if indexPath.row == 1 {
                cell.setData(chartType: .earnings,
                             durationType: durationType,
                             chartData: earningsChartData)
            } else {
                cell.setData(chartType: .hours,
                             durationType: durationType,
                             chartData: hoursChartData)
            }
            cell.selectionStyle = .none
            cell.gestureRecognizers = nil
            return cell
        }
        
        return UITableViewCell()
    }
    
}
