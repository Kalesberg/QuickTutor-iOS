//
//  LearnerMainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import Foundation
import UIKit

var categories: [Category] = Category.categories

class LearnerMainPageVC: UIViewController {
    
    let refreshControl = UIRefreshControl()
    
    let contentView: LearnerMainPageVCView = {
        let view = LearnerMainPageVCView()
        return view
    }()
    
    var helpAlert: QTQuickRequestAlertModal?
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerPushNotification()
        setupRefreshControl()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(hidden: false)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func registerPushNotification() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.registerForPushNotifications(application: UIApplication.shared)
    }
    
    func setupRefreshControl() {
        refreshControl.tintColor = Colors.purple
        if #available(iOS 10.0, *) {
            contentView.collectionView.refreshControl = refreshControl
        } else {
            contentView.collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refershData), for: .valueChanged)
    }
    
    @objc func refershData() {
        contentView.collectionView.reloadData()
        // Start the animation of refresh control
        self.refreshControl.beginRefreshing()
    
        // End the animation of refersh control
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func handleSearchTap() {
        let controller = QTQuickSearchViewController.controller
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: false)
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFeatuedSectionTap(_:)), name: NotificationNames.LearnerMainFeed.featuredSectionTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCategorySectionTap(_:)), name: NotificationNames.LearnerMainFeed.categoryTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTopTutorTapped(_:)), name: NotificationNames.LearnerMainFeed.topTutorTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSeeAllTopTutorsTapped(_:)), name: NotificationNames.LearnerMainFeed.seeAllTopTutorsTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSuggestedTutorTapped(_:)), name: NotificationNames.LearnerMainFeed.suggestedTutorTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleActiveTutorCellTapped(_:)), name: NotificationNames.LearnerMainFeed.activeTutorCellTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleActiveTutorMessageButtonTapped(_:)), name: NotificationNames.LearnerMainFeed.activeTutorMessageButtonTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecentSearchCellTapped(_:)), name: NotificationNames.LearnerMainFeed.recentSearchCellTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleQuickRequestTapped(_:)), name: NotificationNames.LearnerMainFeed.quickRequestCellTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRequestSession(_:)), name: NotificationNames.LearnerMainFeed.requestSession, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleQuickSearchTapped(_:)), name: NotificationNames.LearnerMainFeed.quickSearchTapped, object: nil)
    }
    
    @objc func handleFeatuedSectionTap(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let item = userInfo["featuredItem"] as? MainPageFeaturedItem else { return }
        let vc = CategorySearchVC()
        if let subject = item.subject {
            vc.subject = subject
            vc.navigationItem.title = subject.capitalized
        } else if let subcategoryTitle = item.subcategoryTitle {
            vc.subcategory = subcategoryTitle
            vc.navigationItem.title = subcategoryTitle.capitalized
        } else if let cateogryTitle = item.categoryTitle {
            vc.category = cateogryTitle
            vc.navigationItem.title = cateogryTitle
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleCategorySectionTap(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let category = userInfo["category"] as? String,
            let objCategory = Category.category(for: category) else { return }
        let learnerDiscoverCategoryVC = QTLearnerDiscoverCategoryViewController(nibName: String(describing: QTLearnerDiscoverCategoryViewController.self), bundle: nil)
        learnerDiscoverCategoryVC.category = objCategory
        learnerDiscoverCategoryVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(learnerDiscoverCategoryVC, animated: true)
    }
    
    @objc func handleTopTutorTapped(_ notification: Notification) {
        showTutorProfileFromNotification(notification)
    }
    
    @objc func handleSeeAllTopTutorsTapped(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let tutors = userInfo["tutors"] as? [AWTutor] else { return }
        let next = CategorySearchVC()
        next.datasource = tutors
        next.navigationItem.title = "Rising Talents"
        next.loadedAllTutors = true
        next.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(next, animated: true)
    }
    
    @objc func handleSuggestedTutorTapped(_ notification: Notification) {
        showTutorProfileFromNotification(notification)
    }
    
    @objc func handleActiveTutorCellTapped(_ notification: Notification) {
        showTutorProfileFromNotification(notification)
    }
    
    @objc func handleActiveTutorMessageButtonTapped(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let uid = userInfo["uid"] as? String else { return }
        UserFetchService.shared.getTutorWithId(uid) { tutor in
            guard let tutor = tutor else { return }
            
            DispatchQueue.main.async {
                let vc = ConversationVC()
                vc.receiverId = uid
                vc.chatPartner = tutor
                vc.connectionRequestAccepted = true
                vc.isRecentAcitivy = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func handleQuickRequestTapped(_ notification: Notification) {
        // Check whether or not this learner has already posted 3 quickrequests in 24 hours.
        guard let learnerId = CurrentUser.shared.learner.uid else { return }
        QTQuickRequestService.shared.canSendQuickRequest(senderId: learnerId) { (available) in
            if available {
                DispatchQueue.main.async {
                    // Go to quick request screen
                    let vc = QTQuickRequestTypeViewController.controller
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.helpAlert = QTQuickRequestAlertModal(frame: .zero)
                    self.helpAlert?.set("QuickRequest",
                                   "Daily Maximum Reached.")
                    self.helpAlert?.show()
                }
            }
        }
    }
    
    private func showTutorProfileFromNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let uid = userInfo["uid"] as? String else { return }
        FirebaseData.manager.fetchTutor(uid, isQuery: false, { (tutor) in
            guard let tutor = tutor else { return }
            DispatchQueue.main.async {
                let controller = QTProfileViewController.controller
                controller.subject = tutor.featuredSubject
                controller.profileViewType = .tutor
                controller.user = tutor
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
        })

    }
    
    @objc func handleRecentSearchCellTapped(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let subject = userInfo["subject"] as? String else { return }
        let vc = CategorySearchVC()
        vc.subject = subject
        vc.navigationItem.title = subject.capitalized
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleRequestSession(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let uid = userInfo["uid"] as? String else { return }
        FirebaseData.manager.fetchTutor(uid, isQuery: false) { (tutor) in
            guard let tutor = tutor else { return }
            let vc = SessionRequestVC()
            vc.tutor = tutor
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func handleQuickSearchTapped(_ notification: Notification) {
        
    }
    
    
    func listenForSessionUpdates() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("userSessions").child(uid).child(userTypeString).observe(.childChanged) { snapshot in
            print("Data needs reload")
            self.reloadSessionWithId(snapshot.ref.key!)
            snapshot.ref.setValue(1)
        }
    }
    
    func reloadSessionWithId(_ id: String) {
        DataService.shared.getSessionById(id) { session in
            if let fooOffset = QTLearnerSessionsService.shared.pendingSessions.firstIndex(where: { $0.id == id }) {
                // do something with fooOffset
                QTLearnerSessionsService.shared.pendingSessions.remove(at: fooOffset)
                if session.status == "accepted" {
                    QTLearnerSessionsService.shared.upcomingSessions.append(session)
                } else if "cancelled" == session.status {
                    
                }
                self.contentView.handleReloadSessions()
            } else if let index = QTLearnerSessionsService.shared.upcomingSessions.firstIndex(where: { $0.id == id }) {
                if "cancelled" == session.status {
                    QTLearnerSessionsService.shared.upcomingSessions.remove(at: index)
                    self.contentView.handleReloadSessions()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
