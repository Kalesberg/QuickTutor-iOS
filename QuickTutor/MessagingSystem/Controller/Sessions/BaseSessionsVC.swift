//
//  BaseSessionsVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import SkeletonView

class BaseSessionsVC: UIViewController {
    
    var pendingSessions = [Session]()
    var upcomingSessions = [Session]()
    var pastSessions = [Session]()
    
    let refreshControl = UIRefreshControl()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.newScreenBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    var addPaymentModal: AddPaymentModal?
    var cancelSessionModal: CancelSessionModal?
    var collectionViewBottomAnchor: NSLayoutConstraint?
    var userSessionsRef: DatabaseReference?
    var userSessionsHandle: DatabaseHandle?
    var connectionIds = [String]()
    
    private var isLoading: Bool = false
    
    override func viewDidLoad() {
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        CardService.shared.checkForPaymentMethod()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupViews() {
        setupMainView()
        setupCollectionView()
        
        view.isSkeletonable = true
        fetchSessions()
        
        collectionView.prepareSkeleton { _ in
            self.view.showAnimatedSkeleton(usingColor: Colors.gray)
        }
        
        
        // Update connectionIds
        self.connectionIds.removeAll()
        self.fetchConnections({ (ids) in
            // Save connection ids.
            if !ids.isEmpty {
                self.connectionIds.append(contentsOf: ids)
                self.toggleEmptyState(on: false)
            }
        })
        
        listenForSessionUpdates()
        listenForConnections()
        setupRefreshControl()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.newScreenBackground
        navigationItem.title = "Sessions"
        navigationController?.navigationBar.barTintColor = Colors.newNavigationBarBackground
        navigationController?.view.backgroundColor = Colors.newNavigationBarBackground
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.insertSubview(collectionView, at: 0)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionViewBottomAnchor = collectionView.bottomAnchor.constraint(equalTo: view.getBottomAnchor(), constant: 0)
        collectionViewBottomAnchor?.isActive = true
        collectionView.register(BasePendingSessionCell.self, forCellWithReuseIdentifier: "pendingSessionCell")
        collectionView.register(BasePastSessionCell.self, forCellWithReuseIdentifier: "pastSessionCell")
        collectionView.register(BaseUpcomingSessionCell.self, forCellWithReuseIdentifier: "upcomingSessionCell")
        collectionView.register(EmptySessionCell.self, forCellWithReuseIdentifier: "emptyCell")
        collectionView.register(SessionHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
    }
    
    func setupRefreshControl() {
        if #available(iOS 11.0, *) {
            // Extend the view to the top of screen.
            self.edgesForExtendedLayout = UIRectEdge.top
            self.extendedLayoutIncludesOpaqueBars = true
            self.navigationController?.navigationBar.isTranslucent = false
        }
        
        refreshControl.tintColor = Colors.purple
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshSessions), for: .valueChanged)
    }
    
    @objc func fetchSessions() {
        
        if isLoading { return }
        isLoading = true
        
        pendingSessions.removeAll()
        upcomingSessions.removeAll()
        pastSessions.removeAll()
//        collectionView.reloadData()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        
        Database
            .database()
            .reference()
            .child("userSessions")
            .child(uid)
            .child(userTypeString)
            .queryLimited(toLast: 10).observeSingleEvent(of: .value) { snapshot in
                if let snap = snapshot.children.allObjects as? [DataSnapshot], snap.isEmpty {
                    self.toggleEmptyState(on: true && self.connectionIds.isEmpty)
                }
                
                if let ref = self.userSessionsRef, let handle = self.userSessionsHandle {
                    ref.removeObserver(withHandle: handle)
                    self.userSessionsRef = nil
                    self.userSessionsHandle = nil
                }
                
                self.userSessionsRef = Database.database().reference().child("userSessions").child(uid).child(userTypeString)
                self.userSessionsHandle = self.userSessionsRef?.observe(.childAdded) { snapshot in
                    
                    if !snapshot.exists() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            // TODO: end of loading
                        }
                    }
                    
                    DataService.shared.getSessionById(snapshot.key, completion: { session in
                        if session.type.compare(QTSessionType.quickCalls.rawValue) == .orderedSame {
                            return
                        }
                        
                        guard session.status != "cancelled",
                            session.status != "declined",
                            session.status != "expired",
                            !session.isExpired() else {
                                self.attemptReloadOfTable()
                                return
                        }
                        
                        if session.status == "pending" {
                            if !self.pendingSessions.contains(where: { $0.id == session.id }) {
                                self.pendingSessions.append(session)
                            }
                            self.attemptReloadOfTable()
                            return
                        }
                        
                        if session.isPast {
                            if !self.pastSessions.contains(where: { $0.id == session.id }) {
                                self.pastSessions.insert(session, at: 0)
                            }
                            self.attemptReloadOfTable()
                            return
                        }
                        
                        if session.status == "accepted" {
                            if !self.upcomingSessions.contains(where: { $0.id == session.id }) {
                                self.upcomingSessions.append(session)
                            }
                            self.attemptReloadOfTable()
                            return
                        }
                    })
                }
        }
    }
    
    fileprivate func attemptReloadOfTable() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    @objc func handleReloadTable() {
        self.pastSessions = self.pastSessions.sorted(by: { $0.startTime > $1.startTime })
        DispatchQueue.main.async(execute: {
            
            self.view.hideSkeleton()
            
            self.updateTabBarBadge()
            self.collectionView.reloadData()
            self.toggleEmptyState(on: self.pendingSessions.count
                + self.upcomingSessions.count
                + self.pastSessions.count == 0
                && self.connectionIds.isEmpty)
            
            self.isLoading = false
        })
    }
    
    private func updateTabBarBadge() {
        guard let rootVC = tabBarController?.viewControllers?[2] else { return }
        
        let badgeCount = pendingSessions.count + upcomingSessions.count
        if 0 < badgeCount {
            rootVC.tabBarItem.badgeColor = .qtAccentColor
            rootVC.tabBarItem.badgeValue = 9 < badgeCount ? "9+" : "\(badgeCount)"
            // Update the badge position
            if let tabBarController = rootVC.tabBarController {
                tabBarController.adjustBadgePosition(tabBarItemView: tabBarController.tabBar.subviews[3])
            }
        } else {
            rootVC.tabBarItem.badgeValue = nil
        }
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
            if let fooOffset = self.pendingSessions.firstIndex(where: { $0.id == id }) {
                // do something with fooOffset
                self.pendingSessions.remove(at: fooOffset)
                if session.status == "accepted" {
                    self.upcomingSessions.append(session)
                    self.createSessionLocalNotification(session: session)
                } else if "cancelled" == session.status {
                    self.removeSessionLocalNotification(session: session)
                }
                self.handleReloadTable()
            } else if let index = self.upcomingSessions.firstIndex(where: { $0.id == id }) {
                if "cancelled" == session.status {
                    self.upcomingSessions.remove(at: index)
                    self.removeSessionLocalNotification(session: session)
                    self.handleReloadTable()
                }
            }
        }
    }
    
    private func createSessionLocalNotification(session: Session) {
        let diffTimeInterval = session.startTime - Date().timeIntervalSince1970 - 600
        
        if diffTimeInterval < 0 { return }
        
        let content = UNMutableNotificationContent()
        content.title = "QuickTutor"
        content.body = "Your session begins in ten minutes, grab a cup of coffee and get ready ☕️"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: diffTimeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: session.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func removeSessionLocalNotification(session: Session) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [session.id])
    }
    
    @objc func refreshSessions() {
        // Start the animation of refresh control
        refreshControl.layoutIfNeeded()
        refreshControl.beginRefreshing()
        
        fetchSessions()
        
        // End the animation of refersh control
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.refreshControl.endRefreshing()
            
            // Update the content offset of collection view for refersh control
            var top: CGFloat = 0
            if #available(iOS 11.0, *) {
                top = self.collectionView.adjustedContentInset.top - (self.collectionViewBottomAnchor?.constant ?? 0)
            }
            let y = self.refreshControl.frame.minY + top
            self.collectionView.setContentOffset(CGPoint(x: 0, y: -y), animated:true)
        })
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(showConversation(notification:)), name: Notification.Name(rawValue: "sendMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showCancelModal), name: Notification.Name(rawValue: "com.qt.cancelSession"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestSession(notification:)), name: Notification.Name(rawValue: "requestSession"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProfile(_:)), name: Notification.Name(rawValue: "com.qt.viewProfile"), object: nil)
        
    }
    
    func toggleEmptyState(on: Bool) {
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard !pendingSessions.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
                cell.setLabelToPending()
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pendingSessionCell", for: indexPath) as! BasePendingSessionCell
            cell.updateUI(session: pendingSessions[indexPath.item])
            return cell
        }
        
        if indexPath.section == 1 {
            guard !upcomingSessions.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
                cell.setLabelToUpcoming()
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingSessionCell", for: indexPath) as! BaseUpcomingSessionCell
            return cell
        }
        
        guard !pastSessions.isEmpty else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
            cell.setLabelToPast()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pastSessionCell", for: indexPath) as! BasePastSessionCell
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return pendingSessions.isEmpty ? 1 : pendingSessions.count
        } else if section == 1 {
            return upcomingSessions.isEmpty ? 1 : upcomingSessions.count
        } else {
            return pastSessions.isEmpty ? 1 : pastSessions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    var headerTitles = ["Pending", "Upcoming", "Past"]
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId", for: indexPath) as! SessionHeaderCell
        header.titleLabel.text = headerTitles[indexPath.section]
        return header
    }
    
    var selectedCell: BaseSessionCell? = nil
    var selectedPastCell: BasePastSessionCell? = nil
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var sessions = [Session]()
        switch indexPath.section {
        case 0:
            sessions = pendingSessions
        case 1:
            sessions = upcomingSessions
        default:
            sessions = pastSessions
        }
        
        guard !isLoading, indexPath.item < sessions.count, let cell = collectionView.cellForItem(at: indexPath) as? BaseSessionCell else { return }
        selectedCell?.actionView.hideActionContainerView()
        selectedPastCell?.toggleStarView(isShow: true)
        selectedCell = cell
        cell.actionView.showActionContainerView()
        if let pastCell = cell as? BasePastSessionCell {
            selectedPastCell = pastCell
            pastCell.toggleStarView(isShow: false)
        }
    }
    
    @objc func showProfile(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let uid = userInfo["uid"] as? String else { return }
        if AccountService.shared.currentUserType == .learner {
            FirebaseData.manager.fetchTutor(uid, isQuery: false, { tutor in
                guard let tutor = tutor else { return }
                DispatchQueue.main.async {
                    let controller = QTProfileViewController.controller
                    controller.user = tutor
                    controller.profileViewType = .tutor
                    controller.isPresentedFromSessionScreen = true
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            })
        } else {
            FirebaseData.manager.fetchLearner(uid) { (learner) in
                guard let learner = learner else { return }
                DispatchQueue.main.async {
                    let controller = QTProfileViewController.controller
                    let tutor = AWTutor(dictionary: [:])
                    controller.user = tutor.copy(learner: learner)
                    controller.profileViewType = .learner
                    controller.isPresentedFromSessionScreen = true
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    @objc func showConversation(notification: Notification) {
        guard let userInfo = notification.userInfo, let uid = userInfo["uid"] as? String else { return }
        AccountService.shared.currentUserType == .learner ? getTutor(uid: uid) : getStudent(uid: uid)
    }
    
    private func getStudent(uid: String) {
        if uid.isEmpty {return;}
        UserFetchService.shared.getStudentWithId(uid) { student in
            let vc = ConversationVC()
            vc.receiverId = uid
            vc.chatPartner = student!
            vc.connectionRequestAccepted = true
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func getTutor(uid: String) {
        if uid.isEmpty { return }
        
        UserFetchService.shared.getTutorWithId(uid) { tutor in
            // the result tutor can be null, because there are some ghost users, so if there is no tutor (/it's a ghost tutor), will just return.
            guard let tutor = tutor else { return }
            let vc = ConversationVC()
            vc.receiverId = uid
            vc.chatPartner = tutor
            vc.connectionRequestAccepted = true
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func requestSession(notification: Notification) {
        guard let userInfo = notification.userInfo, let uid = userInfo["uid"] as? String else { return }
        FirebaseData.manager.fetchTutor(uid, isQuery: false) { (tutor) in
            guard let tutor = tutor else { return }
            let vc = SessionRequestVC()
            vc.tutor = tutor
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func showCancelModal(notification: Notification) {
        guard let userInfo = notification.userInfo, let sessionId = userInfo["sessionId"] as? String else { return }
        cancelSessionModal = CancelSessionModal(frame: .zero)
        cancelSessionModal?.delegate = self
        cancelSessionModal?.sessionId = sessionId
        cancelSessionModal?.show()
    }
}

extension BaseSessionsVC: NewMessageDelegate {
    func showConversationWithUser(user: User, isConnection: Bool) {
        let vc = ConversationVC()
        vc.receiverId = user.uid
        vc.connectionRequestAccepted = isConnection
        vc.chatPartner = user
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension BaseSessionsVC: CustomModalDelegate {
    func handleNevermind() {}
    
    func handleConfirm() {
        let next = CardManagerViewController()
        next.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(next, animated: true)
    }
    
    func handleCancel(id: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessions").child(id).updateChildValues(["status" : "cancelled", "cancelledById": uid])
        DataService.shared.getSessionById(id) { session in
            if let chatPartnerId = session.partnerId() {
                Database.database().reference().child("sessionCancels").child(chatPartnerId).child(uid).setValue(1)
                
                // Cancells session
                let userTypeString = AccountService.shared.currentUserType.rawValue
                let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
                Database.database().reference().child("userSessions").child(uid)
                    .child(userTypeString).child(session.id).setValue(-1)
                Database.database().reference().child("userSessions").child(chatPartnerId)
                    .child(otherUserTypeString).child(session.id).setValue(-1)
            }
        }
        cancelSessionModal?.dismiss()
    }
}

extension BaseSessionsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 80)
    }
}

// MARK: - Functions related with connection
extension BaseSessionsVC {
    func fetchConnections(_ completion: (([String]) -> ())?) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("connections").child(uid).child(userTypeString).observeSingleEvent(of: .value) { snapshot in
            guard let connections = snapshot.value as? [String: Any] else {
                if let completion = completion {
                    completion([])
                }
                return
            }
            
            if let completion = completion {
                completion(connections.map({$0.key}))
            }
        }
    }
    
    func listenForConnections() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        
        // Listen chanages in connections
        Database.database().reference()
            .child("connections")
            .child(uid)
            .child(userTypeString)
            .observe(.childChanged) { snapshot in
                
                // Update connectionIds
                self.connectionIds.removeAll()
                self.fetchConnections({ (ids) in
                    // Save connection ids.
                    if !ids.isEmpty {
                        self.connectionIds.append(contentsOf: ids)
                        self.toggleEmptyState(on: false)
                    }
                })
        }
    }
}
