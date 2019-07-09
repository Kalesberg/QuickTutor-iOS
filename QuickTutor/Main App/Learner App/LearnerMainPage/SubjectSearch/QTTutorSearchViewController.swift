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
    
    
    var filteredUsers = [UsernameQuery]()
    var searchTimer: Timer?
    
    
    // MARK: - Lifecycle
    static var controller: QTTutorSearchViewController {
        return QTTutorSearchViewController(nibName: String(describing: QTTutorSearchViewController.self), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(QTTutorSearchTableViewCell.nib, forCellReuseIdentifier: QTTutorSearchTableViewCell.reuseIdentifier)
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
        
        setupDelegates()
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
            filteredUsers.removeAll()
            self.tableView.reloadData()
            return
        }
        
        filteredUsers.removeAll()
        self.tableView.reloadData()
        
        self.noResultView.isHidden = true
        indicatorView.startAnimation(updatedText: "Search for \"\(searchText)\"")
        
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false
            , block: { (_) in
                
                let group = DispatchGroup()
                group.enter()
                let ref: DatabaseReference! = Database.database().reference().child("tutor-info")
                ref.queryOrdered(byChild: "usr").queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText.lowercased() + "\u{f8ff}").queryLimited(toFirst: 50).observeSingleEvent(of: .value) { snapshot in
                    
                        for snap in snapshot.children {
                            guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid else { continue }
                            let usernameQuery = UsernameQuery(snapshot: child)
                            self.filteredUsers.append(usernameQuery)
                        }
                    
                        group.leave()
                }
                
                group.enter()
                ref.queryOrdered(byChild: "nm")
                    .queryStarting(atValue: searchText.lowercased())
                    .queryEnding(atValue: searchText.lowercased() + "\u{f8ff}")
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
                
                group.notify(queue: DispatchQueue.main, execute: {
                    DispatchQueue.main.async {
                        if self.filteredUsers.count == 0 {
                            self.noResultView.isHidden = false
                            self.indicatorView.stopAnimation()
                        }
                        self.tableView.reloadData()
                    }
                })
        })
    }
    
    func goToTutorProfileScreen(tutorId: String) {
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
    
}

// MARK: - UITableViewDelegate
extension QTTutorSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.growSemiShrink {
            let user = self.filteredUsers[indexPath.row]
            
            let item = QTRecentSearchModel()
            item.type = .people
            item.name1 = user.name
            item.name2 = user.username
            item.imageUrl = user.imageUrl
            QTUtils.shared.saveRecentSearch(search: item)
            
            self.goToTutorProfileScreen(tutorId: user.uid)
        }
    }
}

// MARK: - UITableViewDataSource
extension QTTutorSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredUsers.count > 0 {
            indicatorView.stopAnimation()
        }
        
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QTTutorSearchTableViewCell.reuseIdentifier,
                                                 for: indexPath) as! QTTutorSearchTableViewCell
        let user = filteredUsers[indexPath.row]
        cell.setData(user: user)
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension QTTutorSearchViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_: UIScrollView) {
        NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchDismissKeyboard), object: nil)
    }
}
