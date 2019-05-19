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
    @IBOutlet weak var endSessionTitleLabel: UILabel!
    @IBOutlet weak var endSessionMessageLabel: UILabel!
    @IBOutlet weak var durationCountLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var pauseLabel: UILabel!
    @IBOutlet weak var inProgressLabel: UILabel!
    @IBOutlet weak var pauseBlurView: UIVisualEffectView!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottomSheetView.cornerRadius(corners: [.topLeft, .topRight], radius: 5)
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
        
        if manager.isPaused {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard manager.pausedBy == uid else { return }
            manager.unpauseSession()
        } else {
            manager.pauseSession()
        }
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
        durationLabel.textColor = Colors.purple
        finishView.isHidden = true
        timerView.isHidden = false
        pauseButton.isHidden = false
    }
    
    @IBAction func onEndSessionButtonClicked(_ sender: Any) {
        sessionManager?.endSocketSession()
    }
    
    @objc
    func handleUpdateDuration(notification: Notification) {
        guard let info = notification.userInfo as? [String: Any], let timeString = info["timeString"] as? String else { return }
        if isFinishViewOpened {
            durationLabel.text = timeString
            durationLabel.textColor = Colors.grayText80
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
        
        pauseButton.layer.cornerRadius = 20
        pauseButton.clipsToBounds = true
        pauseButton.setupTargets()
        pauseButton.setImage(UIImage(named: "ic_pause")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        pauseButton.imageView?.overlayTintColor(color: UIColor.white)
        pauseButton.backgroundColor = Colors.brightRed
        
        finishButton.layer.cornerRadius = 3
        finishButton.clipsToBounds = true
        finishButton.setupTargets()
        
        if AccountService.shared.currentUserType == .tutor {
            endSessionTitleLabel.text = "End the session?"
            endSessionMessageLabel.text = "Please make sure that your learner is ready to end the session."
        } else {
            endSessionTitleLabel.text = "End the session"
            endSessionMessageLabel.text = "Are you sure you’d like to end the session early?"
        }
        
        // Get the session information.
        DataService.shared.getSessionById(sessionId) { (session) in
            self.session = session
            
            // Get the partner name.
            self.partnerId = self.session?.partnerId()
            if let partnerId = self.partnerId {
                UserFetchService.shared.getUserOfOppositeTypeWithId(partnerId, completion: { user in
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
            self.durationLabel.textColor = Colors.purple
        }
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    func setupNotifications() {
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
        if let session = sessionManager?.session, let runtime = sessionManager?.sessionRuntime {
            session.runTime = runtime
            showRatingViewControllerForSession(session, sessionId: sessionId)
        }
    }
    
    func showPauseModal(pausedById: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserFetchService.shared.getUserOfOppositeTypeWithId(sessionManager?.session.partnerId() ?? "test") { user in
            guard let username = user?.formattedName else { return }
            // Show the pause blur view
            self.pauseBlurView.isHidden = false
            
            // Configure the pause label and the pause button
            if pausedById == uid {
                self.pauseLabel.text = "Paused"
                self.pauseButton.setImage(UIImage(named: "ic_play"), for: .normal)
                self.pauseButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 10)
                self.pauseButton.backgroundColor = Colors.purple
            } else {
                self.pauseLabel.text = "\(username) paused"
                self.pauseButton.isHidden = true
            }
            
            // Hide the in progress label
            self.inProgressLabel.isHidden = true
        }
    }
    
    func showConnectionLostModal(pausedById: String) {
        connectionLostModal?.delegate = self
        UserFetchService.shared.getUserOfOppositeTypeWithId(sessionManager?.session.partnerId() ?? "test") { user in
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
    
    func hidePauseModal() {
        // Hide the pause blur view
        self.pauseBlurView.isHidden = true
        
        // Reset the pause button
        self.pauseButton.isHidden = false
        self.pauseButton.setImage(UIImage(named: "ic_pause"), for: .normal)
        self.pauseButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        self.pauseButton.backgroundColor = Colors.brightPurple
        // Show the in progress label
        inProgressLabel.isHidden = false
    }
    
    func dismissAllModals() {
        addTimeModal?.dismiss()
        sessionOnHoldModal?.dismiss()
        acceptAddTimeModal?.dismiss()
        connectionLostModal?.dismiss()
        hidePauseModal()
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
        
        // Reset pause button
        hidePauseModal()
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
        hidePauseModal()
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
        
        hidePauseModal()
        
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
