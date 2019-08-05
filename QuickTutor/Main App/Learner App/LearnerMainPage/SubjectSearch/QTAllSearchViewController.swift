//
//  QTAllSearchViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 7/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MessageUI


class HLActivityIndicatorView: UIView {
    let indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = Colors.purple
        return indicator
    }()
    
    let indicatorLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = Colors.purple
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureViews() {
        self.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        indicatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4).isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        self.addSubview(indicatorLabel)
        indicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        indicatorLabel.leadingAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: 8).isActive = true
        indicatorLabel.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor).isActive = true
        indicatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16).isActive = true
    }
    
    func startAnimation(updatedText: String) {
        indicatorLabel.text = updatedText
        indicatorView.startAnimating()
    }
    
    func stopAnimation() {
        indicatorLabel.text = ""
        indicatorView.stopAnimating()
    }
    
}

class HLNoResultView: UIView {
    let noResultLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = Colors.purple
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureViews() {
        self.addSubview(noResultLabel)
        noResultLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        noResultLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        noResultLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4).isActive = true
        noResultLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16).isActive = true
        noResultLabel.text = "No results found"
    }
}

class HLRecentSectionHeaderView: UIView {
    let recentLabel: UILabel = {
        let label = UILabel()
        label.text = "Recent"
        label.font = Fonts.createMediumSize(19)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureViews() {
        self.addSubview(recentLabel)
        recentLabel.translatesAutoresizingMaskIntoConstraints = false
        recentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        recentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16).isActive = true
        recentLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

class QTAllSearchViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    var searchFilter: SearchFilter?
    
    var allSubjects = [(String, String)]()
    var recentSearches: [QTRecentSearchModel] = []
    var filteredUsers = [UsernameQuery]()
    var filteredSubjects = [(String, String)]()
    var isSearchMode: Bool = false
    var searchTimer: Timer?
    var unknownSubject: String? {
        didSet {
            if let unknownSubject = unknownSubject, !unknownSubject.isEmpty {
                self.tableView.setUnknownSubjectView(unknownSubject) {
                    self.sendEmail(subject: unknownSubject)
                }
            } else {
                self.tableView.removeUnknownSubjectView()
            }
        }
    }
    
    lazy var indicatorView: HLActivityIndicatorView = HLActivityIndicatorView()
    lazy var recentSectionHeaderView = HLRecentSectionHeaderView()
    
    static var controller: QTAllSearchViewController {
        return QTAllSearchViewController(nibName: String(describing: QTAllSearchViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(QTRecentSearchTableViewCell.nib, forCellReuseIdentifier: QTRecentSearchTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 65
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.backgroundColor = Colors.newNavigationBarBackground
        tableView.separatorStyle = .none
        
        // Add indicator view
        tableView.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        indicatorView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        indicatorView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
        
        allSubjects = SubjectStore.shared.loadTotalSubjectList() ?? []
        recentSearches = QTUtils.shared.getRecentSearches()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupDelegates()
    }

    // MARK: - Actions
    @objc
    func handleSearch(_ notification: Notification) {
        if let searchText = notification.userInfo?[QTNotificationName.quickSearchAll] as? String {
            searchAll(searchText: searchText)
        }
    }
    
    @objc
    func handleQuickSearchClearSearchKey(_ notification: Notification) {
        searchAll(searchText: "")
    }
    
    // MARK: - Functions
    func setupDelegates() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSearch(_:)),
                                               name: NSNotification.Name(QTNotificationName.quickSearchAll),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleQuickSearchClearSearchKey(_:)),
                                               name: NSNotification.Name(QTNotificationName.quickSearchClearSearchKey),
                                               object: nil)
    }
    
    func searchAll(searchText: String) {
        if searchText.isEmpty {
            searchTimer?.invalidate()
            isSearchMode = false
            self.unknownSubject = nil
            self.indicatorView.stopAnimation()
            filteredSubjects.removeAll()
            filteredUsers.removeAll()
            recentSearches = QTUtils.shared.getRecentSearches()
            self.tableView.reloadData()
            return
        }
        
        isSearchMode = true
        filteredSubjects.removeAll()
        filteredUsers.removeAll()
        self.tableView.reloadData()
        self.unknownSubject = nil
        
        indicatorView.startAnimation(updatedText: "Search for \"\(searchText)\"")
        
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false
            , block: { (_) in

                let group = DispatchGroup()
                group.enter()
                let ref: DatabaseReference! = Database.database().reference().child("tutor-info")
                ref.queryOrdered(byChild: "usr")
                    .queryStarting(atValue: searchText.lowercased())
                    .queryEnding(atValue: searchText.lowercased() + "\u{f8ff}")
                    .queryLimited(toFirst: 50)
                    .observeSingleEvent(of: .value) { snapshot in
                    for snap in snapshot.children {
                        guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid else { continue }
                        let usernameQuery = UsernameQuery(snapshot: child)
                        self.filteredUsers.append(usernameQuery)
                    }

                    group.leave()
                }
                
                group.enter()
                ref.queryOrdered(byChild: "nm")
                    .queryStarting(atValue: searchText.capitalized)
                    .queryEnding(atValue: searchText.capitalized + "\u{f8ff}")
                    .queryLimited(toFirst: 50)
                    .observeSingleEvent(of: .value, with: { snapshot in
                        
                        for snap in snapshot.children {
                            guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid else { continue }
                            let usernameQuery = UsernameQuery(snapshot: child)
                            if self.filteredUsers.contains(where: {$0.username.compare(usernameQuery.username) == ComparisonResult.orderedSame}) {
                                continue
                            }
                            self.filteredUsers.append(usernameQuery)
                        }
                        
                        group.leave()
                    })
                
                self.filteredSubjects = self.allSubjects.filter({ $0.0.lowercased().starts(with: searchText.lowercased())}).sorted(by: {$0.0 < $1.0})
                
                group.notify(queue: DispatchQueue.main, execute: {
                    if self.filteredSubjects.count + self.filteredUsers.count == 0 && self.isSearchMode {
                        self.unknownSubject = searchText
                        self.indicatorView.stopAnimation()
                        self.tableView.reloadData()
                        return
                    }
                    
                    self.tableView.reloadData()
                })
        })
    }
    
    func goToTutorProfileScreen(tutorId: String) {
        NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchDismissKeyboard), object: nil)
        displayLoadingOverlay()
        FirebaseData.manager.fetchTutor(tutorId, isQuery: false, { (tutor) in
            self.dismissOverlay()
            guard let tutor = tutor else { return }
            let controller = QTProfileViewController.controller//TutorCardVC()
            controller.subject = tutor.featuredSubject
            controller.profileViewType = .tutor
            controller.user = tutor
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        })
    }
    
    func goToCategorySearchScreen(subject: String) {
        NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchDismissKeyboard), object: nil)
        let vc = CategorySearchVC()
        vc.subject = subject
        AnalyticsService.shared.logSubjectTapped(subject)
        if "english as second language" == subject.lowercased() {
            vc.navigationItem.title = "ESL"
        } else {
            vc.navigationItem.title = subject
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func sendEmail(subject: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["subjects@quicktutor.com"])
            mail.setMessageBody("<p>I’m submitting a subject: <b>\(subject)</b></p>", isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
}

// MARK: - UITableViewDelegate
extension QTAllSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.growSemiShrink {
            if self.isSearchMode {
                if self.filteredSubjects.count > indexPath.row {
                    let subject = self.filteredSubjects[indexPath.row].0
                    
                    let item = QTRecentSearchModel()
                    item.type = .subject
                    item.name1 = SubjectStore.shared.findCategoryBy(subject: subject) ?? ""
                    item.name2 = subject
                    QTUtils.shared.saveRecentSearch(search: item)
                    
                    self.goToCategorySearchScreen(subject: subject)
                } else {
                    let user = self.filteredUsers[indexPath.row - self.filteredSubjects.count]
                    
                    let item = QTRecentSearchModel()
                    item.uid = user.uid
                    item.type = .people
                    item.name1 = user.name
                    item.name2 = user.username
                    item.imageUrl = user.imageUrl
                    QTUtils.shared.saveRecentSearch(search: item)
                    
                    self.goToTutorProfileScreen(tutorId: user.uid)
                }
            } else {
                let item = self.recentSearches[indexPath.row]
                if item.type == QTRecentSearchType.subject {
                    if let subject = item.name2 {
                        self.goToCategorySearchScreen(subject: subject)
                    }
                } else {
                    if let uid = item.uid {
                        self.goToTutorProfileScreen(tutorId: uid)
                    }
                }
                QTUtils.shared.saveRecentSearch(search: item)
            }
            
        }
    }
}

// MARK: - UITableViewDataSource
extension QTAllSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSearchMode || recentSearches.isEmpty {
            return nil
        }
        return recentSectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearchMode || recentSearches.isEmpty {
            return 0
        }
        
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode {
            if filteredSubjects.count + filteredUsers.count > 0 {
                indicatorView.stopAnimation()
            }
        }
        
        return isSearchMode ? (filteredSubjects.count + filteredUsers.count) : recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QTRecentSearchTableViewCell.reuseIdentifier,
                                                 for: indexPath) as! QTRecentSearchTableViewCell
        var item: QTRecentSearchModel = QTRecentSearchModel()
        if isSearchMode {
            if filteredSubjects.count > indexPath.row {
                let subject = filteredSubjects[indexPath.row].0
                item.type = .subject
                item.name1 = SubjectStore.shared.findCategoryBy(subject: subject) ?? ""
                item.name2 = subject
            } else {
                let user = filteredUsers[indexPath.row - filteredSubjects.count]
                item.uid = user.uid
                item.type = .people
                item.name1 = user.name
                item.name2 = user.username
                item.imageUrl = user.imageUrl
            }
            cell.deleteButton.isHidden = true
        } else {
            item = recentSearches[indexPath.row]
            cell.deleteButton.isHidden = false
        }
        cell.onDeleteHandler = { recentSearch in
            if let recentSearch = recentSearch {
                QTUtils.shared.removeRecentSearch(search: recentSearch)
                self.recentSearches = QTUtils.shared.getRecentSearches()
                self.tableView.reloadData()
            }
        }
        cell.setData(recentSearch: item)
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension QTAllSearchViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_: UIScrollView) {
        NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchDismissKeyboard), object: nil)
    }
}

// MARK: - UnknownSubjectView
extension UITableView {
    func setUnknownSubjectView(_ subject: String, didSubmitButtonClicked: (() -> ())?) {
        let noSearchResultsView = QuickSearchNoResultsView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        noSearchResultsView.didSubmitButtonClicked = didSubmitButtonClicked
        noSearchResultsView.setupViews(subject: subject.trimmingCharacters(in: .whitespacesAndNewlines))
        self.backgroundView = noSearchResultsView
    }
    
    func removeUnknownSubjectView() {
        self.backgroundView = nil
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension QTAllSearchViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
