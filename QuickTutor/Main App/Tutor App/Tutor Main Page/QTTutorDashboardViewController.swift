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
import FirebaseAuth

class QTTutorDashboardViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tutorSettingView: QTCustomView!
    @IBOutlet weak var tableView: UITableView!
    
    var durationType: QTTutorDashboardDurationType = QTTutorDashboardDurationType.month
    var tutor: AWTutor?
    var transactions = [BalanceTransaction.Data]() {
        didSet {
            filterEarnsings(self.durationType)
        }
    }
    var sessions = [UserSession]() {
        didSet {
            filterSessionsAndHours(self.durationType)
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
            guard let text = topSubject == nil || topSubject?.isEmpty ?? true
                ? self.tutor?.subjects?.first : topSubject else { return }
            headerView.subjectLabel.text = text.capitalizingFirstLetter() + " • "
        }
    }
    
    struct QTDashboardDimension {
        static let headerViewHeight: CGFloat = 252
        static let sectionHeaderViewHeight: CGFloat = 54
        static let rowHeight: CGFloat = 224
    }
    
    let headerView: QTTutorDashboardHeaderView = QTTutorDashboardHeaderView.view
    let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    
    static var controller: QTTutorDashboardViewController {
        return QTTutorDashboardViewController(nibName: String(describing: QTTutorDashboardViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.barTintColor = Colors.darkBackground
        navigationController?.navigationBar.backgroundColor = Colors.darkBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Register a resuable cell and set dimensions for table view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QTTutorDashboardTableViewCell.nib,
                           forCellReuseIdentifier: QTTutorDashboardTableViewCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = QTDashboardDimension.rowHeight
        tableView.sectionHeaderHeight = QTDashboardDimension.sectionHeaderViewHeight
        tableView.separatorStyle = .none
        
        self.tutor = CurrentUser.shared.tutor
        
        initUserBasicInformation()
        findTopSubjects()
        getSessions()
        getEarnings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set table header view
        tableView.tableHeaderView = headerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Actions
    @IBAction func onTutorSettingsViewTapped(_ sender: Any) {
        let controller = TutorEditProfileVC()
        controller.automaticScroll = true
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Functions
    func initUserBasicInformation() {
        guard let tutor = self.tutor else { return }
        
        let reference = storageRef.child("student-info").child(tutor.uid).child("student-profile-pic1")
        headerView.nameLabel.text = tutor.formattedName
        if let text = topSubject == nil || topSubject?.isEmpty ?? true
            ? self.tutor?.subjects?.first : topSubject {
            headerView.subjectLabel.text = text.capitalizingFirstLetter() + " • "
        }
        headerView.avatarImageView.sd_setImage(with: reference)
        headerView.hourlyRateLabel.text = "$\(String(describing: tutor.price ?? 0))/hr"
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
            guard let sessions = sessions else {
                self.filterSessionsAndHours(self.durationType)
                return
            }
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
    
    func filterEarnsings(_ durationType: QTTutorDashboardDurationType) {
        var unit: TimeInterval = 00
        var mergeUnit: TimeInterval = 00
        var nextMergeUnit: TimeInterval = 00
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
        case .week:
            var benefit: Double = 00
            for dayIndex in 0...6 {
                benefit = 0
                mergeUnit = unit + Double(dayIndex * 86_400)
                nextMergeUnit = unit + Double((1 + dayIndex) * 86_400)
                fiteredTransactions
                    .filter({Double($0.created) >= mergeUnit && Double($0.created) < nextMergeUnit})
                    .forEach({ benefit += Double($0.net ?? 0)})
                chartData.append(QTTutorDashboardChartData(valueY: benefit, date: mergeUnit))
            }
        case .month:
            var benefit: Double = 00
            for dayIndex in 0...30 {
                benefit = 0
                mergeUnit = unit + Double(dayIndex * 86_400)
                nextMergeUnit = unit + Double((1 + dayIndex) * 86_400)
                fiteredTransactions
                    .filter({Double($0.created) >= mergeUnit && Double($0.created) < nextMergeUnit})
                    .forEach({ benefit += Double($0.net ?? 0)})
                chartData.append(QTTutorDashboardChartData(valueY: benefit, date: mergeUnit))
            }
        case .quarter:
            var benefit: Double = 00
            for weekIndex in 0...12 {
                benefit = 0
                mergeUnit = unit + Double(weekIndex * 604_800)
                nextMergeUnit = unit + Double((1 + weekIndex) * 604_800)
                fiteredTransactions
                    .filter({Double($0.created) >= mergeUnit && Double($0.created) < nextMergeUnit})
                    .forEach({ benefit += Double($0.net ?? 0)})
                chartData.append(QTTutorDashboardChartData(valueY: benefit, date: mergeUnit))
            }
        case .year:
            var benefit: Double = 00
            for monthIndex in 0...11 {
                benefit = 0
                mergeUnit = unit + Double(monthIndex * 2_629_743)
                nextMergeUnit = unit + Double((1 + monthIndex) * 2_629_743)
                fiteredTransactions
                    .filter({Double($0.created) >= mergeUnit && Double($0.created) < nextMergeUnit})
                    .forEach({ benefit += Double($0.net ?? 0)})
                chartData.append(QTTutorDashboardChartData(valueY: benefit, date: mergeUnit))
            }
            break
        }
        
        earningsChartData = chartData
    }
    
    func filterSessionsAndHours(_ durationType: QTTutorDashboardDurationType) {
        var unit: TimeInterval = 00
        var mergeUnit: TimeInterval = 00
        var nextMergeUnit: TimeInterval = 00
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
        case .week:
            var sessionCount: Double = 00
            var hours: Double = 00
            for dayIndex in 0...6 {
                sessionCount = 0
                hours = 0
                mergeUnit = unit + Double(dayIndex * 86_400)
                nextMergeUnit = unit + Double((dayIndex + 1) * 86_400)
                fiteredSessions
                    .filter({$0.endedAt >= mergeUnit && $0.endedAt < nextMergeUnit})
                    .forEach({sessionCount += 1; hours += ($0.endedAt - $0.startedAt) / 3_600 })
                sessionsChartData.append(QTTutorDashboardChartData(valueY: sessionCount, date: mergeUnit))
                hoursChartData.append(QTTutorDashboardChartData(valueY: hours, date: mergeUnit))
            }
        case .month:
            var sessionCount: Double = 00
            var hours: Double = 00
            for dayIndex in 0...30 {
                sessionCount = 0
                hours = 0
                mergeUnit = unit + Double(dayIndex * 86_400)
                nextMergeUnit = unit + Double((dayIndex + 1) * 86_400)
                fiteredSessions
                    .filter({$0.endedAt >= mergeUnit && $0.endedAt < nextMergeUnit})
                    .forEach({sessionCount += 1; hours += ($0.endedAt - $0.startedAt) / 3_600 })
                sessionsChartData.append(QTTutorDashboardChartData(valueY: sessionCount, date: mergeUnit))
                hoursChartData.append(QTTutorDashboardChartData(valueY: hours, date: mergeUnit))
            }
        case .quarter:
            var sessionCount: Double = 00
            var hours: Double = 00
            for weekIndex in 0...12 {
                sessionCount = 0
                hours = 0
                mergeUnit = unit + Double(weekIndex * 604_800)
                nextMergeUnit = unit + Double((weekIndex + 1) * 604_800)
                fiteredSessions
                    .filter({$0.endedAt >= mergeUnit && $0.endedAt < nextMergeUnit})
                    .forEach({sessionCount += 1; hours += ($0.endedAt - $0.startedAt) / 3_600 })
                sessionsChartData.append(QTTutorDashboardChartData(valueY: sessionCount, date: mergeUnit))
                hoursChartData.append(QTTutorDashboardChartData(valueY: hours, date: mergeUnit))
            }
        case .year:
            var sessionCount: Double = 00
            var hours: Double = 00
            for monthIndex in 0...11 {
                sessionCount = 0
                hours = 0
                mergeUnit = unit + Double(monthIndex * 2_629_743)
                nextMergeUnit = unit + Double((monthIndex + 1) * 2_629_743)
                fiteredSessions
                    .filter({$0.endedAt >= mergeUnit && $0.endedAt < nextMergeUnit})
                    .forEach({sessionCount += 1; hours += ($0.endedAt - $0.startedAt) / 3_600 })
                sessionsChartData.append(QTTutorDashboardChartData(valueY: sessionCount, date: mergeUnit))
                hoursChartData.append(QTTutorDashboardChartData(valueY: hours, date: mergeUnit))
            }
            break
        }
        self.hoursChartData = hoursChartData
        self.sessionsChartData = sessionsChartData
    }
    
}

// MARK: - UITableViewDelegate
extension QTTutorDashboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let durationView: QTTutorDashboardDurationView = QTTutorDashboardDurationView.view
        
        durationView.durationDidSelect = { type in
            self.durationType = type
            self.filterEarnsings(type)
            self.filterSessionsAndHours(type)
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

extension QTTutorDashboardViewController: LearnerWasUpdatedCallBack {
    func learnerWasUpdated(learner: AWLearner!) {
        tutor = tutor?.copy(learner: learner)
        initUserBasicInformation()
    }
}
