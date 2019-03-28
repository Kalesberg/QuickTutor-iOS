//
//  QTInPersonSessionViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 3/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import SocketIO

class QTInPersonSessionViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var smallAvatarImageView: QTCustomImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var finishView: UIView!
    @IBOutlet weak var durationCountLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var bottomSheetView: UIView!
    
    static var controller: QTInPersonSessionViewController {
        return QTInPersonSessionViewController(nibName: String(describing: QTInPersonSessionViewController.self), bundle: nil)
    }
    
    var session: Session?
    var partnerId: String?
    var partner: User?
    var partnerUsername: String?
    
    var sessionLengthInSeconds: Double?
    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(true), .forceWebsockets(true)])
    var socket: SocketIOClient!
    var sessionManager: SessionManager?
    
    var pauseSessionModal: PauseSessionModal?
    var connectionLostModal: PauseSessionModal?
    var sessionOnHoldModal: SessionOnHoldModal?
    var addTimeModal: AddTimeModal?
    var acceptAddTimeModal: AcceptAddTimeModal?
    
    var minutesToAdd = 0
    var isFinishViewOpened = false
    
    // MARK: - Parameters
    var sessionId: String!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        updateUI()
        
        InProgressSessionManager.shared.removeObservers()
        PostSessionManager.shared.removeObservers()
        BackgroundSoundManager.shared.sessionInProgress = true
        expireSession()
        
        // Updated the startedAt of a session because the session is able to start early than expected.
        Database.database().reference().child("sessions").child(sessionId!).updateChildValues(["startedAt": Date().timeIntervalSince1970])
        
        guard let session = sessionManager?.session else { return }
        AnalyticsService.shared.logSessionStart(session)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNotifications()
        DispatchQueue.main.async {
            self.socket = self.manager.defaultSocket
            self.socket.connect()
            self.observeSessionEvents()
            guard let id = self.sessionId else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            self.socket.on(clientEvent: .connect) { _, _ in
                let joinData = ["roomKey": id, "uid": uid]
                self.socket.emit("joinRoom", joinData)
            }
            self.sessionManager = SessionManager(sessionId: id, socket: self.socket)
            self.sessionManager?.delegate = self
        }
        NotificationManager.shared.disableAllNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        sessionManager?.stopSessionRuntime()
        
        sessionManager = nil
        socket.disconnect()
        NotificationManager.shared.enableAllNotifcations()
    }
    
    // MARK: - Actions
    @IBAction func onPauseButtonClicked(_ sender: Any) {
        guard let manager = sessionManager else { return }
        manager.pauseSession()
    }
    
    @IBAction func onFinishButtonClicked(_ sender: Any) {
        isFinishViewOpened = true
        finishView.isHidden = false
        timerView.isHidden = true
        pauseButton.isHidden = true
    }
    
    @IBAction func onCancelButtonClicked(_ sender: Any) {
        isFinishViewOpened = false
        // Set the subject.
        durationLabel.text = session?.subject
        finishView.isHidden = true
        timerView.isHidden = false
        pauseButton.isHidden = false
    }
    
    @IBAction func onEndSessionButtonClicked(_ sender: Any) {
        sessionManager?.endSocketSession()
    }
    
    @objc
    func handleBackgrounded() {
        guard let manager = sessionManager, !manager.isPaused else { return }
        sessionManager?.isPausedBySystem = true
        sessionManager?.pauseSession()
    }
    
    @objc
    func handleForegrounded() {
        guard let manager = sessionManager, manager.isPausedBySystem else { return }
        sessionManager?.isPausedBySystem = false
        sessionManager?.unpauseSession()
    }
    
    @objc
    func handleUpdateDuration(notification: Notification) {
        guard let info = notification.userInfo as? [String: Any], let timeString = info["timeString"] as? String else { return }
        if isFinishViewOpened {
            durationLabel.text = timeString
        }
        durationCountLabel.text = timeString
    }
    
    
    // MARK: - Functions
    func observeSessionEvents() {
        socket.on(SocketEvents.requestAddTime) { data, _ in
            guard let dict = data[0] as? [String: Any] else { return }
            guard let id = dict["id"] as? String else { return }
            guard id != Auth.auth().currentUser?.uid else { return }
            guard let seconds = dict["seconds"] as? Int else { return }
            self.minutesToAdd = seconds / 60
            self.showAcceptAddTimeModal()
            self.sessionOnHoldModal?.dismiss()
        }
        
        socket.on(SocketEvents.addTimeRequestAnswered) { data, _ in
            guard let dict = data[0] as? [String: Any] else { return }
            guard let answer = dict["didAccept"] as? Bool else { return }
            if answer {
                self.sessionManager?.sessionLengthInSeconds += (self.minutesToAdd * 60)
                self.sessionManager?.startSessionRuntime()
            } else {
                self.sessionManager?.endSocketSession()
            }
            self.sessionOnHoldModal?.dismiss()
            self.addTimeModal?.dismiss()
        }
    }
    
    func updateUI() {
        
        pauseButton.layer.cornerRadius = 18
        pauseButton.clipsToBounds = true
        pauseButton.setupTargets()
        pauseButton.setImage(UIImage(named: "ic_pause")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        pauseButton.imageView?.overlayTintColor(color: UIColor.white)
        
        finishButton.layer.cornerRadius = 3
        finishButton.clipsToBounds = true
        finishButton.setupTargets()
        
        bottomSheetView.cornerRadius(corners: [.topLeft, .topRight], radius: 5)
        
        // Get the session information.
        DataService.shared.getSessionById(sessionId) { (session) in
            self.session = session
            
            // Get the partner name.
            self.partnerId = self.session?.partnerId()
            if let partnerId = self.partnerId {
                DataService.shared.getUserOfOppositeTypeWithId(partnerId, completion: { user in
                    self.partner = user
                    // Set the partner name.
                    self.usernameLabel.text = user?.formattedName
                    
                    // Set the partner avatar.
                    self.avatarImageView.sd_setImage(with: user?.profilePicUrl)
                    self.smallAvatarImageView.sd_setImage(with: user?.profilePicUrl)
                })
            }
            // Set the subject.
            self.durationLabel.text = session.subject
        }
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackgrounded), name: Notifications.didEnterBackground.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleForegrounded), name: Notifications.didEnterForeground.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateDuration(notification:)), name: NSNotification.Name("com.qt.updateTime"), object: nil)
    }
    
    func expireSession() {
        guard let id = sessionId else { return }
        Database.database().reference().child("sessions").child(id).child("status").setValue("completed")
    }
    
    func continueOutOfSession() {
        BackgroundSoundManager.shared.sessionInProgress = false
        dismissAllModals()
        PostSessionManager.shared.sessionDidEnd(sessionId: sessionId!, partnerId: partnerId!)
        guard let runTime = sessionManager?.sessionRuntime,
            let partnerId = sessionManager?.session.partnerId(),
            let subject = sessionManager?.session.subject,
            let session = sessionManager?.session
            else {
                return
        }
        let minimumSessionPrice = 5.0 //$5
        let costOfSession = minimumSessionPrice + ((session.price / 60) / 60) * Double(runTime)
        
        if AccountService.shared.currentUserType == .learner {
            let vc = QTRatingReviewViewController.controller //SessionReview()
            
            vc.session = session
            vc.sessionId = sessionId
            vc.costOfSession = costOfSession
            vc.partnerId = partnerId
            vc.runTime = runTime
            vc.subject = subject
            
            Database.database().reference().child("sessions").child(sessionId!).child("cost").setValue(costOfSession)
            Database.database().reference().child("sessions").child(sessionId!).updateChildValues(["endedAt": Date().timeIntervalSince1970])
            print("Michael: continueing out of session")
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = QTRatingReviewViewController.controller//SessionReview()
            vc.session = session
            vc.sessionId = sessionId
            vc.costOfSession = costOfSession
            vc.partnerId = partnerId
            vc.runTime = runTime
            vc.subject = subject
            Database.database().reference().child("sessions").child(sessionId!).child("cost").setValue(costOfSession)
            Database.database().reference().child("sessions").child(sessionId!).updateChildValues(["endedAt": Date().timeIntervalSince1970])
            print("Michael: continueing out of session")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showPauseModal(pausedById: String) {
        guard pauseSessionModal == nil else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        pauseSessionModal?.delegate = self
        DataService.shared.getUserOfOppositeTypeWithId(sessionManager?.session.partnerId() ?? "test") { user in
            guard let username = user?.formattedName else { return }
            self.pauseSessionModal = PauseSessionModal(frame: .zero)
            if pausedById == uid {
                self.pauseSessionModal?.pausedByCurrentUser()
            }
            self.pauseSessionModal?.partnerUsername = username
            self.pauseSessionModal?.delegate = self
            self.pauseSessionModal?.pausedById = pausedById
            self.pauseSessionModal?.show()
            if let type = self.sessionManager?.session.type {
                self.pauseSessionModal?.setupEndSessionButtons(type: type)
            }
        }
    }
    
    func showConnectionLostModal(pausedById: String) {
        connectionLostModal?.delegate = self
        DataService.shared.getUserOfOppositeTypeWithId(sessionManager?.session.partnerId() ?? "test") { user in
            guard let username = user?.formattedName else { return }
            self.connectionLostModal = PauseSessionModal(frame: .zero)
            self.connectionLostModal?.setupAsLostConnection()
            self.connectionLostModal?.partnerUsername = username
            self.connectionLostModal?.delegate = self
            self.connectionLostModal?.pausedById = pausedById
            self.connectionLostModal?.show()
            if let type = self.sessionManager?.session.type {
                self.connectionLostModal?.setupEndSessionButtons(type: type)
            }
        }
    }
    
    func showSessionOnHoldModal() {
        sessionOnHoldModal = SessionOnHoldModal(frame: .zero)
        sessionOnHoldModal?.delegate = self
        sessionOnHoldModal?.show()
    }
    
    func showAddTimeModal() {
        addTimeModal = AddTimeModal(frame: .zero)
        addTimeModal?.delegate = self
        addTimeModal?.show()
    }
    
    func showAcceptAddTimeModal() {
        acceptAddTimeModal = AcceptAddTimeModal(frame: .zero)
        acceptAddTimeModal?.delegate = self
        acceptAddTimeModal?.show()
    }
    
    func dismissAllModals() {
        addTimeModal?.dismiss()
        sessionOnHoldModal?.dismiss()
        acceptAddTimeModal?.dismiss()
        pauseSessionModal?.dismiss()
        connectionLostModal?.dismiss()
    }
}

// MARK: - SessionManagerDelegate
extension QTInPersonSessionViewController: SessionManagerDelegate {
    func sessionManager(_ sessionManager: SessionManager, userId: String, didPause session: Session) {
        sessionManager.stopSessionRuntime()
        showPauseModal(pausedById: userId)
    }
    
    func sessionManager(_ sessionManager: SessionManager, didUnpause session: Session) {
        sessionManager.startSessionRuntime()
        pauseSessionModal?.dismiss()
        pauseSessionModal = nil
    }
    
    func sessionManager(_ sessionManager: SessionManager, didEnd session: Session) {
        sessionId = session.id
        partnerId = session.partnerId()
        continueOutOfSession()
    }
    
    func sessionManagerSessionTimeDidExpire(_ sessionManager: SessionManager) {
        sessionManager.endSocketSession()
    }
    
    func sessionManagerShouldShowEndSessionModal(_ sessionManager: SessionManager) {
        self.onFinishButtonClicked(self.finishButton)
    }
    
    func sessionManager(_ sessionManager: SessionManager, userLostConnection uid: String) {
        sessionManager.stopSessionRuntime()
        if viewIfLoaded?.window != nil {
            showConnectionLostModal(pausedById: uid)
        }
    }
    
    func sessionManager(_ sessionManager: SessionManager, userConnectedWith uid: String) {
        sessionManager.startSessionRuntime()
        pauseSessionModal?.dismiss()
        guard let myUid = Auth.auth().currentUser?.uid else { return }
        if uid != myUid {
            connectionLostModal?.dismiss()
        }
    }
}

// MARK: - PauseSessionModalDelegate
extension QTInPersonSessionViewController: PauseSessionModalDelegate {
    func pauseSessionModalShouldEndSession(_ pauseSessionModal: PauseSessionModal) {
        self.onFinishButtonClicked(self.finishButton)
    }
    
    func pauseSessionModalDidUnpause(_ pauseSessionModal: PauseSessionModal) {
        socket.emit(SocketEvents.unpauseSession, ["roomKey": sessionId!])
    }
}

// MARK: - AcceptAddTimeDelegate
extension QTInPersonSessionViewController: AcceptAddTimeDelegate {
    func didAccept() {
        guard let id = sessionManager?.session.id else { return }
        socket.emit(SocketEvents.addTimeRequestAnswered, ["didAccept": true, "roomKey": id])
    }
    
    func didDecline() {
        guard let id = sessionManager?.session.id else { return }
        socket.emit(SocketEvents.addTimeRequestAnswered, ["didAccept": false, "roomKey": id])
    }
}

// MARK: - AddTimeModalDelegate
extension QTInPersonSessionViewController: AddTimeModalDelegate {
    func addTimeModalDidDecline(_ addTimeModal: AddTimeModal) {
        addTimeModal.dismiss()
        sessionOnHoldModal?.dismiss()
        sessionManager?.endSocketSession()
    }
    
    func addTimeModal(_ addTimeModal: AddTimeModal, didAdd minutes: Int) {
        print("Should add time.")
        minutesToAdd += minutes
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let id = sessionManager?.session?.id else { return }
        addTimeModal.dismiss()
        sessionOnHoldModal?.dismiss()
        socket.emit(SocketEvents.requestAddTime, ["id": uid, "roomKey": id, "seconds": minutes * 60])
    }
}
