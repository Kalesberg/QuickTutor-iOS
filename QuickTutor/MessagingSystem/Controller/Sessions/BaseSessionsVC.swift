//
//  BaseSessionsVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class BaseSessionsVC: UIViewController {
    
    var pendingSessions = [Session]()
    var upcomingSessions = [Session]()
    var pastSessions = [Session]()
    
    let refreshControl = UIRefreshControl()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    var addPaymentModal = AddPaymentModal()
    var cancelSessionModal: CancelSessionModal?
    var collectionViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        fetchSessions()
        listenForSessionUpdates()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        navigationItem.title = "Sessions"
        navigationController?.navigationBar.barTintColor = Colors.newBackground
        navigationController?.view.backgroundColor = Colors.darkBackground
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true            
        }
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionViewBottomAnchor = collectionView.bottomAnchor.constraint(equalTo: view.getBottomAnchor(), constant: 0)
        collectionViewBottomAnchor?.isActive = true
        collectionView.register(BasePendingSessionCell.self, forCellWithReuseIdentifier: "pendingSessionCell")
        collectionView.register(BasePastSessionCell.self, forCellWithReuseIdentifier: "pastSessionCell")
        collectionView.register(BaseUpcomingSessionCell.self, forCellWithReuseIdentifier: "upcomingSessionCell")
        collectionView.register(EmptySessionCell.self, forCellWithReuseIdentifier: "emptyCell")
        collectionView.register(SessionHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
    }
    
    func setupRefreshControl() {
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshSessions), for: .valueChanged)
    }
    
    @objc func fetchSessions() {
        pendingSessions.removeAll()
        upcomingSessions.removeAll()
        pastSessions.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("userSessions").child(uid).child(userTypeString).observe(.childAdded) { snapshot in
            DataService.shared.getSessionById(snapshot.key, completion: { session in
                guard session.status != "cancelled" && session.status != "declined" && !session.isExpired() else {
                    self.attemptReloadOfTable()
                    return
                }
                
                if session.status == "pending" && session.startTime > Date().timeIntervalSince1970 {
                    if !self.pendingSessions.contains(where: { $0.id == session.id }) {
                        self.pendingSessions.append(session)
                    }
                    self.attemptReloadOfTable()
                    return
                }
                
                if session.startTime < Date().timeIntervalSince1970 || session.status == "completed" {
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
    
    fileprivate func attemptReloadOfTable() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    @objc func handleReloadTable() {
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
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
                }
                self.collectionView.reloadData()
            } else {
                // item could not be found
            }
        }
    }
    
    @objc func refreshSessions() {
        refreshControl.beginRefreshing()
        fetchSessions()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.refreshControl.endRefreshing()
        })
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(showConversation(notification:)), name: Notification.Name(rawValue: "sendMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showCancelModal), name: Notification.Name(rawValue: "com.qt.cancelSession"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestSession(notification:)), name: Notification.Name(rawValue: "requestSession"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProfile(_:)), name: Notification.Name(rawValue: "com.qt.viewProfile"), object: nil)
        
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
        guard let cell = collectionView.cellForItem(at: indexPath) as? BaseSessionCell else { return }
        selectedCell?.actionView.hideActionContainerView()
        selectedPastCell?.toggleStarViewHidden()
        selectedCell = cell
        cell.actionView.showActionContainerView()
        if let pastCell = cell as? BasePastSessionCell {
            selectedPastCell = pastCell
            pastCell.toggleStarViewHidden()
        }
    }
    
    @objc func showProfile(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let uid = userInfo["uid"] as? String else { return }
        if AccountService.shared.currentUserType == .learner {
            FirebaseData.manager.fetchTutor(uid, isQuery: false, { tutor in
                guard let tutor = tutor else { return }
                let controller = QTProfileViewController.controller
                controller.user = tutor
                controller.profileViewType = .tutor
                controller.isPresentedFromSessionScreen = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
        } else {
            FirebaseData.manager.fetchLearner(uid) { (learner) in
                guard let learner = learner else { return }
                let controller = QTProfileViewController.controller
                let tutor = AWTutor(dictionary: [:])
                controller.user = tutor.copy(learner: learner)
                controller.profileViewType = .learner
                controller.isPresentedFromSessionScreen = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @objc func showConversation(notification: Notification) {
        guard let userInfo = notification.userInfo, let uid = userInfo["uid"] as? String else { return }
        AccountService.shared.currentUserType == .learner ? getTutor(uid: uid) : getStudent(uid: uid)
    }
    
    private func getStudent(uid: String) {
        DataService.shared.getStudentWithId(uid) { student in
            let vc = ConversationVC()
            vc.receiverId = uid
            vc.chatPartner = student!
            vc.connectionRequestAccepted = true
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func getTutor(uid: String) {
        DataService.shared.getTutorWithId(uid) { tutor in
            let vc = ConversationVC()
            vc.receiverId = uid
            vc.chatPartner = tutor!
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
        let next = CardManagerVC()
        navigationController?.pushViewController(next, animated: true)
    }
    
    func handleCancel(id: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessions").child(id).child("status").setValue("cancelled")
        DataService.shared.getSessionById(id) { session in
            let chatPartnerId = session.partnerId()
            Database.database().reference().child("sessionCancels").child(chatPartnerId).child(uid).setValue(1)
        }
        cancelSessionModal?.dismiss()
        fetchSessions()
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
