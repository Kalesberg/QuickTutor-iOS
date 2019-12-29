//
//  QTTutorSearchViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 7/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseDatabase

class QTTutorSearchViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    lazy var indicatorView: HLActivityIndicatorView = HLActivityIndicatorView()
    lazy var noResultView: HLNoResultView = HLNoResultView()
    lazy var recentSectionHeaderView = HLRecentSectionHeaderView()
    lazy var suggestedSectionHeaderView = HLSuggestedSectionHeaderView()
    
    private var aryTutorIds: [QTTutorSubjectInterface] = []
    private var aryTutors: [AWTutor] = []
    private var aryConnectedTutorIds: [String] = []
    private var aryRecentedTutorIds: [String] = []
    private let limit = 5
    private var _observing = false
    
    var searchFilter: SearchFilter?
    var filteredUsers = [UsernameQuery]()
    var resultUsers = [UsernameQuery]()
    var searchTimer: Timer?
    var recentSearches: [QTRecentSearchModel] = []
    var isSearchMode: Bool = false
    
    // MARK: - Lifecycle
    static var controller: QTTutorSearchViewController {
        return QTTutorSearchViewController(nibName: String(describing: QTTutorSearchViewController.self), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(QTTutorSearchTableViewCell.nib, forCellReuseIdentifier: QTTutorSearchTableViewCell.reuseIdentifier)
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
        
        // Add no result view
        tableView.addSubview(noResultView)
        noResultView.translatesAutoresizingMaskIntoConstraints = false
        noResultView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        noResultView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        noResultView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
        noResultView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        recentSearches = QTUtils.shared.getRecentTutors()
        getRecentTutorIds()
        
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
        if let searchText = notification.userInfo?[QTNotificationName.quickSearchPeople] as? String {
            tutorSearch(searchText: searchText)
        }
    }
    
    @objc
    func handleQuickSearchClearSearchKey(_ notification: Notification) {
        tutorSearch(searchText: "")
    }
    
    // MARK: - Functions
    func setupDelegates() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSearch(_:)),
                                               name: NSNotification.Name(QTNotificationName.quickSearchPeople),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleQuickSearchClearSearchKey(_:)),
                                               name: NSNotification.Name(QTNotificationName.quickSearchClearSearchKey),
                                               object: nil)
    }
    
    func tutorSearch(searchText: String) {
        if searchText.isEmpty {
            searchTimer?.invalidate()
            self.noResultView.isHidden = true
            self.indicatorView.stopAnimation()
            self.isSearchMode = false
            self.recentSearches = QTUtils.shared.getRecentTutors()
            getRecentTutorIds()
            filteredUsers.removeAll()
            self.loadTutors()
            self.tableView.reloadData()
            return
        }
        
        self.isSearchMode = true
        self.filteredUsers.removeAll()
        self.aryTutors.removeAll()
        self.tableView.reloadData()
        
        self.noResultView.isHidden = true
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
                            if self.resultUsers.contains(where: {$0.username.compare(usernameQuery.username) == .orderedSame}) {
                                continue
                            }
                            self.resultUsers.append(usernameQuery)
                        }
                        
                        group.leave()
                })
                
                group.notify(queue: DispatchQueue.main, execute: {
                    DispatchQueue.main.async {
                        self.filteredUsers = self.resultUsers
                        if self.filteredUsers.count == 0 && self.isSearchMode {
                            self.noResultView.isHidden = false
                            self.indicatorView.stopAnimation()
                            self.tableView.reloadData()
                            return
                        }
                        
                        self.noResultView.isHidden = true
                        self.tableView.reloadData()
                    }
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
                
                let item = QTRecentSearchModel()
                item.uid = tutor.uid
                item.type = .people
                item.name1 = tutor.name
                item.name2 = tutor.username
                item.imageUrl = tutor.profilePicUrl.absoluteString
                QTUtils.shared.saveRecentSearch(search: item)
                
                let controller = QTProfileViewController.controller//TutorCardVC()
                controller.subject = tutor.featuredSubject
                controller.profileViewType = .tutor
                controller.user = tutor
                self.navigationController?.pushViewController(controller, animated: true)
            }
        })
    }
    
}

// MARK: - UITableViewDelegate
extension QTTutorSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.isSearchMode {
            let user = self.filteredUsers[indexPath.row]
            let item = QTRecentSearchModel()
            item.uid = user.uid
            item.type = .people
            item.name1 = user.name
            item.name2 = user.username
            item.imageUrl = user.imageUrl
            QTUtils.shared.saveRecentSearch(search: item)
            self.goToTutorProfileScreen(tutorId: user.uid)
        } else {
            if indexPath.section == 1 {
                let user = self.recentSearches[indexPath.row]
                QTUtils.shared.saveRecentSearch(search: user)
                if let uid  = user.uid {
                    self.goToTutorProfileScreen(tutorId: uid)
                }
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
        
        /*let cell = tableView.cellForRow(at: indexPath)
        cell?.growSemiShrink {
            if self.isSearchMode {
                let user = self.filteredUsers[indexPath.row]
                let item = QTRecentSearchModel()
                item.uid = user.uid
                item.type = .people
                item.name1 = user.name
                item.name2 = user.username
                item.imageUrl = user.imageUrl
                QTUtils.shared.saveRecentSearch(search: item)
                self.goToTutorProfileScreen(tutorId: user.uid)
            } else {
                let user = self.recentSearches[indexPath.row]
                QTUtils.shared.saveRecentSearch(search: user)
                if let uid  = user.uid {
                    self.goToTutorProfileScreen(tutorId: uid)
                }
            }
        }*/
    }
}

// MARK: - UITableViewDataSource
extension QTTutorSearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearchMode  {
            return 1
        }
        return 2
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSearchMode || recentSearches.isEmpty {
            return nil
        }
        
        if section == 1 {
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
        if isSearchMode {
            return .leastNonzeroMagnitude
        }
        
        if section == 1 && recentSearches.isEmpty {
            return .leastNonzeroMagnitude
        }
        
        if section == 0 && aryTutors.isEmpty {
            return .leastNonzeroMagnitude
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode {
            if filteredUsers.count > 0 {
                indicatorView.stopAnimation()
            }
            
            return filteredUsers.count
        }
        
        if section == 0 {
            return aryTutors.count
        }
        return recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearchMode {
            let cell = tableView.dequeueReusableCell(withIdentifier: QTTutorSearchTableViewCell.reuseIdentifier,
                                                     for: indexPath) as! QTTutorSearchTableViewCell
            let user = filteredUsers[indexPath.row]
            cell.setData(user: user)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: QTRecentSearchTableViewCell.reuseIdentifier,
                                                     for: indexPath) as! QTRecentSearchTableViewCell
            cell.deleteButton.isHidden = false
            
            if indexPath.section == 1 {
                cell.setData(recentSearch: recentSearches[indexPath.row])
            }else{
                let objTutor = aryTutors[indexPath.row]
                let item: QTRecentSearchModel = QTRecentSearchModel()
                item.uid = objTutor.uid
                item.type = .people
                item.name1 = objTutor.name
                item.name2 = objTutor.username
                item.imageUrl = objTutor.profilePicUrl.absoluteString
                cell.setData(recentSearch: item)
            }
            
            cell.onDeleteHandler = { recentSearch in
                if let recentSearch = recentSearch {
                    if indexPath.section == 1 {
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
            return cell
        }
    }
}

// MARK: - UIScrollViewDelegate
extension QTTutorSearchViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_: UIScrollView) {
        NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchDismissKeyboard), object: nil)
    }
}
