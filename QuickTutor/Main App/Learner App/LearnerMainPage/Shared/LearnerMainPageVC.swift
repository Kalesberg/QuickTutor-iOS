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
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerPushNotification()
        configureView()
        setupRefreshControl()
        setupObservers()
        contentView.handleSearchesLoaded()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(hidden: false)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // TODO: Jack remove the following statement when you commit the result.
        let vc = QTQuickRequestTypeViewController.controller
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func registerPushNotification() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.registerForPushNotifications(application: UIApplication.shared)
    }
    
    private func configureView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSearchTap))
        contentView.searchBarContainer.searchBarView.addGestureRecognizer(tap)
        contentView.searchBarContainer.parentVC = self
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.refreshControl.endRefreshing()
        })
    }
    
    @objc func handleSearchTap() {
        navigationController?.pushViewController(QTQuickSearchViewController.controller, animated: false) // QuickSearchVC()
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
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleCategorySectionTap(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let category = userInfo["category"] as? String else { return }
        let next = CategorySearchVC()
        next.category = category
        if let categoryType = CategoryType(rawValue: category) {
            next.navigationItem.title = categoryType.title.capitalizingFirstLetter()
        } else {
            next.navigationItem.title = category.capitalizingFirstLetter()
        }
        navigationController?.pushViewController(next, animated: true)
    }
    
    @objc func handleTopTutorTapped(_ notification: Notification) {
        showTutorProfileFromNotification(notification)
    }
    
    @objc func handleSeeAllTopTutorsTapped(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let tutors = userInfo["tutors"] as? [AWTutor] else { return }
        let next = CategorySearchVC()
        next.datasource = tutors
        next.navigationItem.title = "Rising Talent"
        next.loadedAllTutors = true
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
            let vc = ConversationVC()
            vc.receiverId = uid
            vc.chatPartner = tutor!
            vc.connectionRequestAccepted = true
            self.navigationController?.pushViewController(vc, animated: true)
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
                self.navigationController?.pushViewController(controller, animated: true)
            }
        })

    }
    
    @objc func handleRecentSearchCellTapped(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let subject = userInfo["subject"] as? String else { return }
        let vc = CategorySearchVC()
        vc.subject = subject
        vc.navigationItem.title = subject.capitalized
        navigationController?.pushViewController(vc, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
