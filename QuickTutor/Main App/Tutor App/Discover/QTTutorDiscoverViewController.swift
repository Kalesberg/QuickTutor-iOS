//
//  QTTutorDiscoverViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/2/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTNotificationSnackbarView: UIView {
    
    // MARK: - Properties
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = UIColor.white
        label.textAlignment = .center
        
        return label
    }()
    
    // MARK: - Functions
    func setupNotificationLabel() {
        addSubview(notificationLabel)
        
        notificationLabel.anchor(top: topAnchor,
                                 left: leftAnchor,
                                 bottom: bottomAnchor,
                                 right: rightAnchor,
                                 paddingTop: 0,
                                 paddingLeft: 0,
                                 paddingBottom: 0,
                                 paddingRight: 0,
                                 width: 0,
                                 height: 30)
    }
    
    func setupViews() {
        backgroundColor = Colors.purple
        applyDefaultShadow()
        
        setupNotificationLabel()
    }
    
    func showNotification(text: String) {
        notificationLabel.text = text
    }
    
    // MARK: - Actions
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class QTTutorDiscoverViewController: UIViewController {

    // MARK: - Properties
    let contentView: QTTutorDiscoverMainView = {
        let view = QTTutorDiscoverMainView()
        return view
    }()
    
    lazy var sharedProfileView = QTSharedProfileView()
    lazy var notificationSnackBar = QTNotificationSnackbarView()
    var notificationSnackBarTopConstraint: NSLayoutConstraint?
    
    var tutor: AWTutor?
    
    // MARK: - Functions
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedNewsItemTapped(_:)), name: NotificationNames.TutorDiscoverPage.newsItemTapped, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedApplyToOpportunity(_:)), name: NotificationNames.TutorDiscoverPage.applyToOpportunity, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedTutorCategoryTapped(_:)), name: NotificationNames.TutorDiscoverPage.tutorCategoryTapped, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedTipTapped(_:)), name: NotificationNames.TutorDiscoverPage.tipTapped, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedTutorShareUrlCopied(_:)), name: NotificationNames.TutorDiscoverPage.tutorShareUrlCopied, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceivedTutorShareProfileTapped(_:)), name: NotificationNames.TutorDiscoverPage.tutorShareProfileTapped, object: nil)
    }
    
    func setupShareProfileView() {
        
        if AccountService.shared.currentUser == nil { return }
        
        // Get tutor info
        guard let userId = AccountService.shared.currentUser.uid else { return }
        FirebaseData.manager.fetchTutor(userId, isQuery: false) { (tutor) in
            guard let tutor = tutor else { return }
            self.tutor = tutor
            self.view.insertSubview(self.sharedProfileView, at: 0)
            self.sharedProfileView.translatesAutoresizingMaskIntoConstraints = false
            self.sharedProfileView.anchor(top: nil,
                                          left: self.view.leftAnchor,
                                          bottom: self.view.bottomAnchor,
                                          right: self.view.rightAnchor,
                                          paddingTop: -1000,
                                          paddingLeft: 0,
                                          paddingBottom: 0,
                                          paddingRight: 0,
                                          width: 0,
                                          height: 0)
            self.sharedProfileView.setProfile(withTutor: tutor)
        }
    }
    
    func setupNotificationSnackBar() {
        view.addSubview(notificationSnackBar)
        view.bringSubviewToFront(notificationSnackBar)
        
        notificationSnackBar.anchor(top: nil,
                                    left: view.leftAnchor,
                                    bottom: nil,
                                    right: view.rightAnchor,
                                    paddingTop: 0,
                                    paddingLeft: 0,
                                    paddingBottom: 0,
                                    paddingRight: 0,
                                    width: 0,
                                    height: 0)
        
        notificationSnackBarTopConstraint = notificationSnackBar.topAnchor.constraint(equalTo: self.view.getTopAnchor())
        notificationSnackBarTopConstraint?.constant = -(UIApplication.shared.statusBarFrame.height + 30)
        notificationSnackBarTopConstraint?.isActive = true
    }
    
    func displayNotificationInfo(text: String) {
        notificationSnackBar.showNotification(text: text)
        
        self.notificationSnackBar.alpha = 0
        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.notificationSnackBar.alpha = 1
            self.notificationSnackBarTopConstraint?.constant = 0
        }.startAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
                self.notificationSnackBarTopConstraint?.constant = -(UIApplication.shared.statusBarFrame.height + 30)
                self.notificationSnackBar.alpha = 0
            }.startAnimation()
        }
    }
    
    
    // MARK: - Notifications
    @objc
    func onReceivedNewsItemTapped(_ notification: Notification) {
        if let userInfo = notification.userInfo, let news = userInfo["news"] as? QTNewsModel {
            let controller = QTTutorDiscoverNewsDetailViewController()
            controller.news = news
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
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
        guard let userInfo = notification.userInfo,
            let category = userInfo["category"] as? String else { return }
        
        let vc = QTTutorDiscoverCategoryViewController.controller
        vc.categoryName = category
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func onReceivedTipTapped(_ notification: Notification) {
        if let userInfo = notification.userInfo, let tip = userInfo["tip"] as? QTNewsModel {
            let vc = QTTutorDiscoverTipDetailViewController()
            vc.tip = tip
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc
    func onReceivedTutorShareUrlCopied(_ notification: Notification) {
        guard let user = tutor, let id = user.uid else { return }
        
        let image = self.sharedProfileView.asImage()
        
        guard let data = image.jpegData(compressionQuality: 1.0) else { return }
        
        var subject: String?
        if let featuredSubject = user.featuredSubject, !featuredSubject.isEmpty {
            // Set the featured subject.
            subject = featuredSubject
        } else {
            // Set the first subject
            subject = user.subjects?.first
        }
        
        displayLoadingOverlay()
        FirebaseData.manager.uploadProfilePreviewImage(tutorId: id, data: data) { (error, url) in
            if let message = error?.localizedDescription {
                DispatchQueue.main.async {
                    self.dismissOverlay()
                    AlertController.genericErrorAlert(self, message: message)
                }
                return
            }
            
            DynamicLinkFactory.shared.createLink(userId: id, userName: user.formattedName, subject: subject, profilePreviewUrl: url) { shareUrl in
                guard let shareUrlString = shareUrl?.absoluteString else {
                    DispatchQueue.main.async {
                        self.dismissOverlay()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.dismissOverlay()
                    UIPasteboard.general.string = shareUrlString
                    self.displayNotificationInfo(text: "Link saved")
                }
            }
        }
    }
    
    @objc
    func onReceivedTutorShareProfileTapped(_ notification: Notification) {
        guard let user = tutor, let id = user.uid else { return }
        
        let image = self.sharedProfileView.asImage()
        
        guard let data = image.jpegData(compressionQuality: 1.0) else { return }
        
        var subject: String?
        if let featuredSubject = user.featuredSubject, !featuredSubject.isEmpty {
            // Set the featured subject.
            subject = featuredSubject
        } else {
            // Set the first subject
            subject = user.subjects?.first
        }
        
        displayLoadingOverlay()
        FirebaseData.manager.uploadProfilePreviewImage(tutorId: id, data: data) { (error, url) in
            if let message = error?.localizedDescription {
                DispatchQueue.main.async {
                    self.dismissOverlay()
                    AlertController.genericErrorAlert(self, message: message)
                }
                return
            }
            
            DynamicLinkFactory.shared.createLink(userId: id, userName: user.formattedName, subject: subject, profilePreviewUrl: url) { shareUrl in
                guard let shareUrlString = shareUrl?.absoluteString else {
                    DispatchQueue.main.async {
                        self.dismissOverlay()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.dismissOverlay()
                    let ac = UIActivityViewController(activityItems: [shareUrlString], applicationActivities: nil)
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
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
        setupShareProfileView()
        setupNotificationSnackBar()
    }
}
