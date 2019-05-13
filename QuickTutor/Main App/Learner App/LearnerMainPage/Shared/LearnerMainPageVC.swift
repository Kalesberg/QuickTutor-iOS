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
    
    let contentView: LearnerMainPageVCView = {
        let view = LearnerMainPageVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func configureView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSearchTap))
        contentView.searchBar.addGestureRecognizer(tap)
    }

    @objc func handleSearchTap() {
        let nav = navigationController
        DispatchQueue.main.async {
            nav?.pushViewController(QuickSearchVC(), animated: false)
        }
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFeatuedSectionTap(_:)), name: NotificationNames.LearnerMainFeed.featuredSectionTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCategorySectionTap(_:)), name: NotificationNames.LearnerMainFeed.categoryTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTopTutorTapped(_:)), name: NotificationNames.LearnerMainFeed.topTutorTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSeeAllTopTutorsTapped(_:)), name: NotificationNames.LearnerMainFeed.seeAllTopTutorsTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSuggestedTutorTapped(_:)), name: NotificationNames.LearnerMainFeed.suggestedTutorTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleActiveTutorCellTapped(_:)), name: NotificationNames.LearnerMainFeed.activeTutorCellTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleActiveTutorMessageButtonTapped(_:)), name: NotificationNames.LearnerMainFeed.activeTutorMessageButtonTapped, object: nil)
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
            next.navigationItem.title = categoryType.title
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
        next.navigationItem.title = "Top Tutors"
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
        DataService.shared.getTutorWithId(uid) { tutor in
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
            let controller = QTProfileViewController.controller
            controller.subject = tutor.featuredSubject
            controller.profileViewType = .tutor
            controller.user = tutor
            self.navigationController?.pushViewController(controller, animated: true)
        })

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
