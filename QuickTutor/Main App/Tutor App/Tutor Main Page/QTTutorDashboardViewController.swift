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

struct TopSubcategory {
    var subcategory = ""
    let hours: Int
    let numSessions: Int
    let rating: Double
    let subjects: String
    
    init(dictionary: [String: Any]) {
        hours = dictionary["hr"] as? Int ?? 0
        numSessions = dictionary["nos"] as? Int ?? 0
        rating = dictionary["r"] as? Double ?? 0.0
        subjects = dictionary["sbj"] as? String ?? ""
    }
}

class QTTutorDashboardViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tutorSettingsButton: UIButton!
    
    var refreshControl = UIRefreshControl()
    
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
            if let topSubject = topSubject, !topSubject.isEmpty {
                headerView.subjectLabel.text = topSubject.capitalizingFirstLetter()
                return
            } else if topSubject == nil {
                findTopSubjects()
            }
        }
    }
    
    struct QTDashboardDimension {
        static let sectionHeaderViewHeight: CGFloat = 54
        static let rowHeight: CGFloat = 224
    }
    
    let headerView: QTTutorDashboardHeaderView = QTTutorDashboardHeaderView.view
    let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    var durationView: QTTutorDashboardDurationView?
    
    static var controller: QTTutorDashboardViewController {
        return QTTutorDashboardViewController(nibName: String(describing: QTTutorDashboardViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerPushNotification()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.barTintColor = Colors.newScreenBackground
        navigationController?.navigationBar.backgroundColor = Colors.newScreenBackground
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
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        
        headerView.avatarImageView.isUserInteractionEnabled = true
        headerView.avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapTutorProfileImageView)))
        
        if #available(iOS 11.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.tintColor = Colors.purple
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set table header view
        tableView.tableHeaderView = headerView
        
        tutorSettingsButton.cornerRadius(corners: [.topLeft, .topRight], radius: 3)
        tutorSettingsButton.clipsToBounds = true
        tutorSettingsButton.setupTargets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshData()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Show the tab bar.
        hideTabBar(hidden: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideTabBar(hidden: false)
    }
    
    private func registerPushNotification() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.registerForPushNotifications(application: UIApplication.shared)
    }

    // MARK: - Actions
    @IBAction func onClickTutorSettingsButton(_ sender: Any) {
        let controller = TutorEditProfileVC()
        controller.automaticScroll = true
        controller.hidesBottomBarWhenPushed = true
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc
    func onTapTutorProfileImageView () {
        let images = createLightBoxImages()
        presentLightBox(images)
    }
    
    @objc func refreshData() {
        tutor = CurrentUser.shared.tutor
        initUserBasicInformation()
        getSessions()
        getEarnings()
        
        // End the animation of refersh control
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.refreshControl.endRefreshing()
        })
    }
    
    // MARK: - Functions
    func initUserBasicInformation() {
        guard let tutor = self.tutor else { return }
        
        headerView.nameLabel.text = tutor.formattedName
        topSubject = tutor.featuredSubject
        headerView.avatarImageView.sd_setImage(with: tutor.profilePicUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        headerView.hourlyRateLabel.text = "$\(String(describing: tutor.price ?? 5))/hr"
        headerView.ratingLabel.text = "\(String(describing: tutor.tRating ?? 5.0))"
        headerView.subjectsLabel.text = "\(tutor.subjects?.count ?? 0)"
        headerView.sessionsLabel.text = "\(tutor.tNumSessions ?? 0)"
        headerView.learnersLabel.text = "\(tutor.learners.count)"
    }
    
    func getEarnings() {
        // Get earnings from stripe
        StripeService.retrieveBalanceTransactionList(acctId: CurrentUser.shared.tutor.acctId) { _, transactions in
            guard let transactions = transactions else {
                return
            }
            self.transactions = transactions.data.filter({ (transactions) -> Bool in
                if transactions.amount != nil && transactions.amount! > 0 {
                    return true
                }
                return false
            })
        }
    }
    
    func getSessions() {
        guard let tutor = self.tutor else {
            return
        }
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
        
        FirebaseData.manager.fetchTutor(tutor.uid, isQuery: false) { (tutor) in
            guard let tutor = tutor else { return }
            self.topSubject = tutor.featuredSubject
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
            for dayIndex in 1...7 {
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
            for dayIndex in 1...31 {
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
            for weekIndex in 1...13 {
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
            for monthIndex in 1...13 {
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
        
        let fiteredSessions = sessions.filter({$0.startTime > Double(unit)})
        switch durationType {
        case .week:
            var sessionCount: Double = 00
            var hours: Double = 00
            for dayIndex in 1...7 {
                sessionCount = 0
                hours = 0
                mergeUnit = unit + Double(dayIndex * 86_400)
                nextMergeUnit = unit + Double((dayIndex + 1) * 86_400)
                fiteredSessions
                    .filter({$0.endTime >= Double(mergeUnit) && $0.endTime < Double(nextMergeUnit)})
                    .forEach({sessionCount += 1; hours += fabs(Double($0.endTime - $0.startTime)) / 3_600 })
                sessionsChartData.append(QTTutorDashboardChartData(valueY: sessionCount, date: mergeUnit))
                hoursChartData.append(QTTutorDashboardChartData(valueY: hours, date: mergeUnit))
            }
        case .month:
            var sessionCount: Double = 00
            var hours: Double = 00
            for dayIndex in 1...31 {
                sessionCount = 0
                hours = 0
                mergeUnit = unit + Double(dayIndex * 86_400)
                nextMergeUnit = unit + Double((dayIndex + 1) * 86_400)
                fiteredSessions
                    .filter({$0.endTime >= Double(mergeUnit) && $0.endTime < Double(nextMergeUnit)})
                    .forEach({sessionCount += 1; hours += fabs(Double($0.endTime - $0.startTime)) / 3_600 })
                sessionsChartData.append(QTTutorDashboardChartData(valueY: sessionCount, date: mergeUnit))
                hoursChartData.append(QTTutorDashboardChartData(valueY: hours, date: mergeUnit))
            }
        case .quarter:
            var sessionCount: Double = 00
            var hours: Double = 00
            for weekIndex in 1...13 {
                sessionCount = 0
                hours = 0
                mergeUnit = unit + Double(weekIndex * 604_800)
                nextMergeUnit = unit + Double((weekIndex + 1) * 604_800)
                fiteredSessions
                    .filter({$0.endTime >= Double(mergeUnit) && $0.endTime < Double(nextMergeUnit)})
                    .forEach({sessionCount += 1; hours += fabs(Double($0.endTime - $0.startTime)) / 3_600 })
                sessionsChartData.append(QTTutorDashboardChartData(valueY: sessionCount, date: mergeUnit))
                hoursChartData.append(QTTutorDashboardChartData(valueY: hours, date: mergeUnit))
            }
        case .year:
            var sessionCount: Double = 00
            var hours: Double = 00
            for monthIndex in 0...12 {
                sessionCount = 0
                hours = 0
                mergeUnit = unit + Double(monthIndex * 2_629_743)
                nextMergeUnit = unit + Double((monthIndex + 1) * 2_629_743)
                fiteredSessions
                    .filter({$0.endTime >= Double(mergeUnit) && $0.endTime < Double(nextMergeUnit)})
                    .forEach({sessionCount += 1; hours += fabs(Double($0.endTime - $0.startTime)) / 3_600 })
                sessionsChartData.append(QTTutorDashboardChartData(valueY: sessionCount, date: mergeUnit))
                hoursChartData.append(QTTutorDashboardChartData(valueY: hours, date: mergeUnit))
            }
            break
        }
        self.hoursChartData = hoursChartData
        self.sessionsChartData = sessionsChartData
    }
 
    func createLightBoxImages() -> [LightboxImage] {
        guard let tutor = self.tutor else { return [] }
        
        var images = [LightboxImage]()
        tutor.images.forEach({ (arg) in
            let (_, imageUrl) = arg
            guard let url = URL(string: imageUrl) else { return }
            images.append(LightboxImage(imageURL: url))
        })
        return images
    }
    
    func presentLightBox(_ images: [LightboxImage]) {
        let controller = LightboxController(images: images, startIndex: 0)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDelegate
extension QTTutorDashboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        durationView = QTTutorDashboardDurationView.view
        
        durationView?.durationDidSelect = { type in
            self.durationType = type
            self.filterEarnsings(type)
            self.filterSessionsAndHours(type)
            tableView.reloadData()
        }
        durationView?.setData(durationType: durationType)
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

// MARK: -
extension QTTutorDashboardViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            // If the duration section view is at the top of screen, will show the drop shadow
            if scrollView.contentOffset.y >= headerView.frame.height {
                self.durationView?.layer.applyShadow(color: UIColor.black.cgColor,
                                                     opacity: 0.2,
                                                     offset: CGSize(width: 0, height: 10),
                                                     radius: 10)
                return
            }
            
            // If the content offset of tableview is about zero, will hide the drop shadow
            if scrollView.contentOffset.y <= headerView.frame.height / 2 {
                self.durationView?.layer.shadowOpacity = 0.0
            }
        }
    }
}

// MARK: - QTProfileDelegate
extension QTTutorDashboardViewController: QTProfileDelegate {
    func didUpdateLearnerProfile(learner: AWLearner) {
        
    }
    
    func didUpdateTutorProfile(tutor: AWTutor) {
        self.tutor = tutor
        initUserBasicInformation()
    }
}
