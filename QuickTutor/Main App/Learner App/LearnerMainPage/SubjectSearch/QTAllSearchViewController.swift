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
        self.isHidden = false
    }
    
    func stopAnimation() {
        indicatorLabel.text = ""
        indicatorView.stopAnimating()
        self.isHidden = true
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

class HLSuggestedSectionHeaderView: UIView {
    let suggestedLabel: UILabel = {
        let label = UILabel()
        label.text = "Suggested"
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
        self.addSubview(suggestedLabel)
        suggestedLabel.translatesAutoresizingMaskIntoConstraints = false
        suggestedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18).isActive = true
        suggestedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16).isActive = true
        suggestedLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

class QTAllSearchViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    var searchFilter: SearchFilter?
    
    private var aryTutorIds: [QTTutorSubjectInterface] = []
    private var aryTutors: [AWTutor] = []
    private var aryConnectedTutorIds: [String] = []
    private var aryRecentedTutorIds: [String] = []
    private let limit = 5
    private var _observing = false
    
    var allSubjects = [(String, String)]()
    var recentSearches: [QTRecentSearchModel] = []
    var filteredUsers = [UsernameQuery]()
    var resultUsers = [UsernameQuery]()
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
    lazy var suggestedSectionHeaderView = HLSuggestedSectionHeaderView()
    lazy var recentSectionHeaderView = HLRecentSectionHeaderView()

    
    static var controller: QTAllSearchViewController {
        return QTAllSearchViewController(nibName: String(describing: QTAllSearchViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(QTRecentSearchTableViewCell.nib, forCellReuseIdentifier: QTRecentSearchTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 66
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = Colors.newNavigationBarBackground
        tableView.separatorStyle = .none
        
        // Add indicator view
        self.view.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        indicatorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        indicatorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        allSubjects = SubjectStore.shared.loadTotalSubjectList() ?? []
        recentSearches = QTUtils.shared.getRecentSearches()
        getRecentTutorIds()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupDelegates()
        
        loadConnectedTutors() {
            self.loadLearnerRelativeTutorIds() {
                self.loadTutors()
            }
        }
    }
    private func getRecentTutorIds(){
        aryRecentedTutorIds.removeAll()
        for recent in recentSearches {
            if let recentUid = recent.uid {
                aryRecentedTutorIds.append(recentUid)
            }
        }
    }
    private func loadConnectedTutors(completion: @escaping () -> Void) {
        if 0 == CurrentUser.shared.learner.connectedTutorsCount {
            completion()
            return
        }
        
        FirebaseData.manager.fetchLearnerConnections(uid: CurrentUser.shared.learner.uid) { aryConnectedTutorIds in
            if let aryConnectedTutorIds = aryConnectedTutorIds {
                self.aryConnectedTutorIds = aryConnectedTutorIds
            }
            completion()
        }
    }
    
    private func loadLearnerRelativeTutorIds(completion: @escaping () -> Void) {
        guard let interests = CurrentUser.shared.learner.interests else { return }
        
        // load same subjects tutors
        var categories: [String] = []
        var subcategories: [String] = []
        let interestsGroup = DispatchGroup()
        for interest in interests {
            if let category = SubjectStore.shared.findCategoryBy(subject: interest),
                !categories.contains(category) {
                categories.append(category)
            }
            if let subcategory = SubjectStore.shared.findSubCategory(subject: interest),
                !subcategories.contains(subcategory) {
                subcategories.append(subcategory)
            }
            
            interestsGroup.enter()
            TutorSearchService.shared.getTutorIdsBySubject(interest) { tutorIds in
                guard let tutorIds = tutorIds else {
                    interestsGroup.leave()
                    return
                }
                tutorIds.forEach { tutorId in
                    if CurrentUser.shared.learner.uid != tutorId,
                    !self.aryConnectedTutorIds.contains(tutorId),
                    !self.aryRecentedTutorIds.contains(tutorId),
                        !self.aryTutorIds.contains(where: { $0.tutorId == tutorId }) {
                        self.aryTutorIds.append(QTTutorSubjectInterface(tutorId: tutorId, subject: interest))
                    }
                }
                interestsGroup.leave()
            }
        }
        
        interestsGroup.notify(queue: .main) {
            // load same subcategory tutors
            let subcategoriesGroup = DispatchGroup()
            for subcategory in subcategories {
                subcategoriesGroup.enter()
                TutorSearchService.shared.getTutorIdsBySubcategory(subcategory) { tutorIds in
                    guard let tutorIds = tutorIds else {
                        subcategoriesGroup.leave()
                        return
                    }
                    tutorIds.forEach { tutorId in
                        if CurrentUser.shared.learner.uid != tutorId,
                            !self.aryConnectedTutorIds.contains(tutorId),
                            !self.aryTutorIds.contains(where: { $0.tutorId == tutorId }) {
                            self.aryTutorIds.append(QTTutorSubjectInterface(tutorId: tutorId, subcategory: subcategory))
                        }
                    }
                    subcategoriesGroup.leave()
                }
            }
            subcategoriesGroup.notify(queue: .main) {
                // load same category tutors
                let categoriesGroup = DispatchGroup()
                for category in categories {
                    categoriesGroup.enter()
                    TutorSearchService.shared.getTutorIdsByCategory(category) { tutorIds in
                        guard let tutorIds = tutorIds else {
                            categoriesGroup.leave()
                            return
                        }
                        tutorIds.forEach { tutorId in
                            if CurrentUser.shared.learner.uid != tutorId,
                                !self.aryConnectedTutorIds.contains(tutorId),
                                !self.aryTutorIds.contains(where: { $0.tutorId == tutorId }) {
                                self.aryTutorIds.append(QTTutorSubjectInterface(tutorId: tutorId, category: category))
                            }
                        }
                        categoriesGroup.leave()
                    }
                }
                categoriesGroup.notify(queue: .main) {
                    completion()
                }
            }
        }
    }
    
    private func loadTutors() {
        _observing = true
        let tutorsGroup = DispatchGroup()
        var tutors: [AWTutor] = []
        var tutorsCount = self.aryTutors.count
        
        while tutorsCount < limit && !self.aryTutorIds.isEmpty {
            tutorsGroup.enter()
            FirebaseData.manager.fetchTutor(aryTutorIds[0].tutorId, isQuery: false) { tutor in
                guard let tutor = tutor else {
                    tutorsGroup.leave()
                    return
                }
                tutors.append(tutor)
                tutorsGroup.leave()
            }
            self.aryTutorIds.remove(at: 0)
            tutorsCount += 1
        }
        tutorsGroup.notify(queue: .main) {
            self._observing = false
            self.aryTutorIds = Array(self.aryTutorIds.dropFirst(self.limit))
            self.aryTutors.append(contentsOf: tutors)
            if !self.aryTutorIds.isEmpty && self.aryTutors.count < self.limit {
                self.loadTutors()
                return
            }
            self.tableView.reloadData()
        }
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
            getRecentTutorIds()
            self.loadTutors()
            self.tableView.reloadData()
            return
        }
        
        isSearchMode = true
        filteredSubjects.removeAll()
        filteredUsers.removeAll()
        aryTutors.removeAll()
        self.tableView.reloadData()
        self.unknownSubject = nil
        
        indicatorView.startAnimation(updatedText: "Searching for \"\(searchText)\"")
        
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false
            , block: { (_) in
                
                self.resultUsers.removeAll()
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
                        self.resultUsers.append(usernameQuery)
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
                            if self.resultUsers.contains(where: {$0.username.compare(usernameQuery.username) == ComparisonResult.orderedSame}) {
                                continue
                            }
                            self.resultUsers.append(usernameQuery)
                        }
                        
                        group.leave()
                    })
                
                self.filteredSubjects = self.allSubjects.filter({ $0.0.lowercased().starts(with: searchText.lowercased())}).sorted(by: {$0.0 < $1.0})
                
                group.notify(queue: DispatchQueue.main, execute: {
                    self.filteredUsers = self.resultUsers
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
            DispatchQueue.main.async {
              self.dismissOverlay()
            }
            guard let tutor = tutor else { return }
            DispatchQueue.main.async {
                let controller = QTProfileViewController.controller//TutorCardVC()
                controller.subject = tutor.featuredSubject
                controller.profileViewType = .tutor
                controller.user = tutor
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
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func sendEmail(subject: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["subjects@quicktutor.com"])
            mail.setMessageBody("<p>I’m submitting a topic: <b>\(subject)</b></p>", isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
            let ac = UIAlertController(title: nil, message: "Sign into an email on the mail app to submit a topic.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(ac, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDelegate
extension QTAllSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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

            if indexPath.section == 0 {
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
            }else{
                let objTutor = aryTutors[indexPath.row]
                let item: QTRecentSearchModel = QTRecentSearchModel()
                item.uid = objTutor.uid
                item.type = .people
                item.name1 = objTutor.name
                item.name2 = objTutor.username
                item.imageUrl = objTutor.profilePicUrl.absoluteString
                self.aryTutors.remove(at: indexPath.row)
                self.loadTutors()
                self.goToTutorProfileScreen(tutorId: objTutor.uid)
                QTUtils.shared.saveRecentSearch(search: item)
            }
            
        }
        
        /*cell?.growSemiShrink {
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
            
        }*/
    }
}

// MARK: - UITableViewDataSource
extension QTAllSearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearchMode  {
            return 1
        }
        return 2
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSearchMode {
            return nil
        }
        
        if section == 0 {
            if recentSearches.isEmpty {
                return nil
            }
            
            return recentSectionHeaderView

        } else {
            if aryTutors.isEmpty {
                return nil
            }
            return suggestedSectionHeaderView
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearchMode  {
            return .leastNonzeroMagnitude
        }
        if section == 0 && recentSearches.isEmpty {
            return .leastNonzeroMagnitude
        }
        
        if section == 1 && aryTutors.isEmpty {
            return .leastNonzeroMagnitude
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode {
            if filteredSubjects.count + filteredUsers.count > 0 {
                indicatorView.stopAnimation()
            }
            return filteredSubjects.count + filteredUsers.count
        }
    
        if section == 1 {
            return aryTutors.count
        }
        
        return recentSearches.count
       
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
            if indexPath.section == 0 {
                item = recentSearches[indexPath.row]
            }else{
                let objTutor = aryTutors[indexPath.row]
                item.uid = objTutor.uid
                item.type = .people
                item.name1 = objTutor.name
                item.name2 = objTutor.username
                item.imageUrl = objTutor.profilePicUrl.absoluteString
            }
            cell.deleteButton.isHidden = false
        }
        cell.onDeleteHandler = { recentSearch in
            if let recentSearch = recentSearch {
                if indexPath.section == 0 {
                    QTUtils.shared.removeRecentSearch(search: recentSearch)
                    self.recentSearches = QTUtils.shared.getRecentSearches()
                    self.getRecentTutorIds()
                    self.tableView.reloadData()
                }else{
                    self.aryTutors.remove(at: indexPath.row)
                    self.loadTutors()
                }
            }
        }
        cell.setData(recentSearch: item)
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
