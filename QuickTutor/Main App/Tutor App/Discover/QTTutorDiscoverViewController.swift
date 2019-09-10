//
//  QTTutorDiscoverViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/2/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorDiscoverViewController: UIViewController {

    // MARK: - Properties
    let contentView: QTTutorDiscoverMainView = {
        let view = QTTutorDiscoverMainView()
        return view
    }()
    
    
    // MARK: - Functions
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedNewsItemTapped(_:)), name: NotificationNames.TutorDiscoverPage.newsItemTapped, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedApplyToOpportunity(_:)), name: NotificationNames.TutorDiscoverPage.applyToOpportunity, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedTutorCategoryTapped(_:)), name: NotificationNames.TutorDiscoverPage.tutorCategoryTapped, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedTipTapped(_:)), name: NotificationNames.TutorDiscoverPage.tipTapped, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedTutorShareUrlCopied(_:)), name: NotificationNames.TutorDiscoverPage.tutorShareUrlCopied, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedTutorShareProfileTapped(_:)), name: NotificationNames.TutorDiscoverPage.tutorShareProfileTapped, object: nil)
    }
    
    
    // MARK: - Notifications
    @objc
    func onReceivedNewsItemTapped(_ notification: Notification) {
        
    }
    
    @objc
    func onReceivedApplyToOpportunity(_ notification: Notification) {
        if let userInfo = notification.userInfo, let quickRequest = userInfo["quickRequest"] as? QTQuickRequestModel {
            let controller = QTTutorDiscoverOpportunityApplyViewController.applyController
            controller.quickRequest = quickRequest
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc
    func onReceivedTutorCategoryTapped(_ notification: Notification) {
        
    }
    
    @objc
    func onReceivedTipTapped(_ notification: Notification) {
        
    }
    
    @objc
    func onReceivedTutorShareUrlCopied(_ notification: Notification) {
        
    }
    
    @objc
    func onReceivedTutorShareProfileTapped(_ notification: Notification) {
        
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = contentView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(hidden: false)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObservers()
    }
}
