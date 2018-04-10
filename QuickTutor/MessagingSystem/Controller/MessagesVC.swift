//
//  ViewController.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class MessagesVC: MainPage, CustomNavBarDisplay {
    
    let mainCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.register(MessagesContentCell.self, forCellWithReuseIdentifier: "messagesContentCell")
        cv.register(LearnerSessionsContentCell.self, forCellWithReuseIdentifier: "learnerSessionsContentCell")
        cv.register(TutorSessionContentCell.self, forCellWithReuseIdentifier: "tutorSessionsContentCell")
        cv.alwaysBounceHorizontal = false
        cv.alwaysBounceHorizontal = false
        cv.isPagingEnabled = true
        cv.allowsSelection = false
        cv.isScrollEnabled = false
        return cv
    }()
    
    let messageSessionControl: MessagingSystemToggle = {
        let control = MessagingSystemToggle()
        return control
    }()
    
    let alert = CancelSessionModal()
    let blackView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isOpaque = false
        navigationController?.navigationBar.isTranslucent = false
        edgesForExtendedLayout = []
    }
    
    func setupViews() {
        setupMainView()
        setupMessageSessionControl()
        setupCollectionView()
        setupNavBar()
        setupObservers()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        edgesForExtendedLayout = []
    }
    
    private func setupCollectionView() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        view.addSubview(mainCollectionView)
        mainCollectionView.anchor(top: messageSessionControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 29, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupNavBar() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationItem.backBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "newMessageIcon"), style: .plain, target: self, action: #selector(showContacts))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backItem?.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settingsIcon"), style: .plain, target: self, action: #selector(showSettings))
    }
    
    private func setupMessageSessionControl() {
        view.addSubview(messageSessionControl)
        messageSessionControl.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 130, paddingLeft: 45, paddingBottom: 0, paddingRight: 45, width: 0, height: 25)
        messageSessionControl.delegate = self
    }
    
    @objc func showContacts() {
        let vc = NewMessageVC()
        vc.delegate = self
        let navVC = CustomNavVC(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func showSettings() {
        let vc = SettingsVC()
        let navVC = CustomNavVC(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(showConversation(notification:)), name: Notification.Name(rawValue: "sendMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showCancelModal), name: Notification.Name(rawValue: "cancelSession"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestSession(notification:)), name: Notification.Name(rawValue: "requestSession"), object: nil)
    }
    
    @objc func showConversation(notification: Notification) {
        guard let userInfo = notification.userInfo, let uid = userInfo["uid"] as? String else { return }
        DataService.shared.getStudentWithId(uid) { (tutor) in
            let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
            vc.receiverId = uid
            vc.chatPartner = tutor!
            vc.connectionRequestAccepted = true
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func requestSession(notification: Notification) {
        guard let userInfo = notification.userInfo, let uid = userInfo["uid"] as? String else { return }
        DataService.shared.getStudentWithId(uid) { (tutor) in
            let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
            vc.receiverId = uid
            vc.chatPartner = tutor!
            vc.connectionRequestAccepted = true
            vc.shouldRequestSession = true
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    @objc func showCancelModal() {
        addBlackView()
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(alert)
        alert.delegate = self
        alert.anchor(top: nil, left: window.leftAnchor, bottom: nil, right: window.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 207)
        window.addConstraint(NSLayoutConstraint(item: alert, attribute: .centerY, relatedBy: .equal, toItem: window, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func addBlackView() {
        blackView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(blackView)
        blackView.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(removeAlert))
        blackView.addGestureRecognizer(dismiss)
    }
    
    @objc func removeAlert() {
        alert.removeFromSuperview()
        blackView.removeFromSuperview()
    }
    
}


extension MessagesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messagesContentCell", for: indexPath) as! MessagesContentCell
            cell.parentViewController = self
            return cell
        } else {
            
            if userType == "tutor" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tutorSessionsContentCell", for: indexPath) as! TutorSessionContentCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "learnerSessionsContentCell", for: indexPath) as! LearnerSessionsContentCell
                return cell
            }
        }
    }
}

extension MessagesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}

extension MessagesVC: NewMessageDelegate {
    func showConversationWithUser(user: User, isConnection: Bool) {
        let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.receiverId = user.uid
        vc.connectionRequestAccepted = isConnection
        vc.chatPartner = user
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MessagesVC: SegmentedViewDelegate {
    func scrollTo(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        mainCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}

extension MessagesVC: CancelModalDelegate {
    func handleNevermind() {
        blackView.removeFromSuperview()
        alert.removeFromSuperview()
    }
}
