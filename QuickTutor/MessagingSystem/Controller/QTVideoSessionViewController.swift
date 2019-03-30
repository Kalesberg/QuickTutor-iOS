//
//  QTVideoSessionViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 3/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import TwilioVideo
import Lottie
import Firebase
import SocketIO

class QTVideoSessionViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var cameraPreview: TVIVideoView!
    @IBOutlet var cameraPreviewTop: NSLayoutConstraint!
    @IBOutlet var cameraPreviewTrailing: NSLayoutConstraint!
    @IBOutlet var cameraPreviewLeading: NSLayoutConstraint!
    @IBOutlet var cameraPreviewBottom: NSLayoutConstraint!
    @IBOutlet weak var partnerView: TVIVideoView!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomSheetViewBottom: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var flipCameraImageView: UIImageView!
    @IBOutlet weak var flipCameraButton: DimmableButton!
    @IBOutlet weak var pauseImageView: UIImageView!
    @IBOutlet weak var pauseButton: DimmableButton!
    @IBOutlet weak var shareFileImageView: UIImageView!
    @IBOutlet weak var shareFileButton: DimmableButton!
    @IBOutlet weak var reportImageView: UIImageView!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var animationView: LOTAnimationView!
    
    // Parameters
    var sessionId: String!
    
    // Static variables
    static var controller: QTVideoSessionViewController {
        return QTVideoSessionViewController(nibName: String(describing: QTVideoSessionViewController.self), bundle: nil)
    }
    
    enum QTBottomMenuStatus {
        case expanded, collapsed, hidden
    }
    
    // Variables
    var partnerId: String?
    var sessionLengthInSeconds: Double?
    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(true), .forceWebsockets(true)])
    var socket: SocketIOClient!
    var sessionManager: SessionManager?
    var twilioSessionManager: TwilioSessionManager?
    
    var bottomMenuStatus: QTBottomMenuStatus = .collapsed {
        didSet {
            menuButton.tintColor = .white
            switch bottomMenuStatus {
            case .expanded:
                menuButton.setImage(UIImage(named: "ic_arrow_down")?.withRenderingMode(.alwaysTemplate), for: .normal)
                menuButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
                self.bottomSheetView.layoutIfNeeded()
                let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut, animations: nil)
                animator.addAnimations {
                    self.bottomSheetViewBottom.constant = 0
                    self.view.layoutIfNeeded()
                }
                animator.startAnimation()
                break
            case .collapsed:
                menuButton.setImage(UIImage(named: "moreIcon"), for: .normal)
                menuButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 16.5, bottom: 12, right: 16.5)
                self.bottomSheetView.layoutIfNeeded()
                let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn, animations: nil)
                animator.addAnimations {
                    self.bottomSheetViewBottom.constant = -120
                    self.view.layoutIfNeeded()
                }
                animator.startAnimation()
                break
            case .hidden:
                menuButton.setImage(UIImage(named: "moreIcon"), for: .normal)
                menuButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 16.5, bottom: 12, right: 16.5)
                self.bottomSheetView.layoutIfNeeded()
                let animator = UIViewPropertyAnimator(duration: 0.15, curve: .easeIn, animations: nil)
                animator.addAnimations {
                    self.bottomSheetViewBottom.constant = -200
                    self.view.layoutIfNeeded()
                }
                animator.startAnimation()
                break
            }
        }
    }
    
    var behavior: VideoSessionPartnerFeedBehavior!
    
    var addTimeModal: AddTimeModal?
    var sessionOnHoldModal: SessionOnHoldModal?
    var acceptAddTimeModal: AcceptAddTimeModal?
    var endSessionModal: EndSessionModal?
    var pauseSessionModal: PauseSessionModal?
    var connectionLostModal: PauseSessionModal?
    var reportTypeModal: ReportTypeModal?
    
    var minutesToAdd = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        InProgressSessionManager.shared.removeObservers()
        PostSessionManager.shared.removeObservers()
        BackgroundSoundManager.shared.sessionInProgress = true
        expireSession()
        
        // Updated the startedAt of a session because the session is able to start early than expected.
        Database.database().reference()
            .child("sessions")
            .child(sessionId)
            .updateChildValues(["startedAt": Date().timeIntervalSince1970])
        
        updateUI()
        setupTwilio()
        setupActions()
        
        DataService.shared.getSessionById(sessionId) { session in
            AnalyticsService.shared.logSessionStart(session)
            self.updatePartnerInformation(session: session)
        }
        
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
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        sessionManager?.stopSessionRuntime()
        sessionManager = nil
        socket.disconnect()
        NotificationManager.shared.enableAllNotifcations()
        twilioSessionManager?.stop()
        twilioSessionManager?.disconnect()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    // MARK: - Actions
    @IBAction func onCloseButtonClicked(_ sender: Any) {
        showEndModal()
    }
    
    @IBAction func onClickMenuButtonClicked(_ sender: Any) {
        if bottomMenuStatus == .collapsed {
            bottomMenuStatus = .expanded
        } else {
            bottomMenuStatus = .collapsed
        }
    }
    
    @IBAction func onFlipCamerButtonClicked(_ sender: Any) {
        guard let manager = twilioSessionManager else { return }
        manager.flipCamera()
    }
    
    @IBAction func onClickPauseButtonClicked(_ sender: Any) {
        guard let manager = sessionManager else { return }
        if manager.isPaused {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard manager.pausedBy == uid else { return }
            manager.unpauseSession()
        } else {
            manager.pauseSession()
        }
    }
    
    @IBAction func onShareFileButtonClicked(_ sender: Any) {
        
    }
    
    @IBAction func onReportButtonClicked(_ sender: Any) {
        guard let id = partnerId else { return }
        reportTypeModal = ReportTypeModal()
        reportTypeModal?.chatPartnerId = id
        
        reportTypeModal?.show()
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
        durationLabel.text = timeString
    }
    
    @objc
    func handleDidTapPartnerView(_ gesture: UITapGestureRecognizer) {
        if bottomMenuStatus == .hidden {
            bottomMenuStatus = .collapsed
        } else {
            bottomMenuStatus = .hidden
        }
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
    
    func expireSession() {
        guard let id = sessionId else { return }
        Database.database().reference().child("sessions").child(id).child("status").setValue("completed")
    }
    
    
    func setupTwilio() {
        guard let id = sessionId else { return }
        DispatchQueue.main.async {
            self.twilioSessionManager = TwilioSessionManager(previewView: self.cameraPreview, remoteView: self.partnerView, sessionId: id)
            self.twilioSessionManager?.delegate = self
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackgrounded), name: Notifications.didEnterBackground.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleForegrounded), name: Notifications.didEnterForeground.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateDuration(notification:)), name: NSNotification.Name("com.qt.updateTime"), object: nil)
    }
    
    func setupActions() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDidTapPartnerView(_:)))
        partnerView.addGestureRecognizer(gesture)
        partnerView.isUserInteractionEnabled = true
    }
    
    func updateUI() {
        
        animationView.animation = "loadingNew"
        animationView.loopAnimation = true
        animationView.play()
        
        bottomMenuStatus = .collapsed
        menuButton.layer.cornerRadius = 18
        menuButton.clipsToBounds = true
        menuButton.layer.borderColor = Colors.grayText80.cgColor
        menuButton.layer.borderWidth = 0.5
        
        closeButton.layer.cornerRadius = 18
        closeButton.clipsToBounds = true
        
        bottomSheetView.cornerRadius(corners: [UIRectCorner.topLeft, UIRectCorner.topRight], radius: 5.0)
        
        flipCameraImageView.overlayTintColor(color: UIColor.white)
        pauseImageView.overlayTintColor(color: UIColor.white)
        shareFileImageView.overlayTintColor(color: UIColor.white)
        reportImageView.overlayTintColor(color: UIColor.white)
        
        behavior = VideoSessionPartnerFeedBehavior()
        behavior.view = cameraPreview
        behavior.delegate = self
    }
    
    func updatePartnerInformation(session: Session) {
        // Get the partner name.
        self.partnerId = session.partnerId()
        if let partnerId = self.partnerId {
            DataService.shared.getUserOfOppositeTypeWithId(partnerId, completion: { user in
                // Set the partner name.
                self.usernameLabel.text = user?.formattedName
                
                // Set the partner avatar.
                self.avatarImageView.sd_setImage(with: user?.profilePicUrl)
            })
        }
    }
    
    func hideLoadingAnimation() {
        view.sendSubviewToBack(animationView)
        animationView.stop()
        animationView.isHidden = true
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
    
    func showEndModal() {
        endSessionModal = EndSessionModal(frame: .zero)
        endSessionModal?.delegate = self
        endSessionModal?.show()
    }
    
    func pauseSession() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        socket.emit(SocketEvents.pauseSession, ["pausedBy": uid, "roomKey": sessionId!])
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
    
    func showSessionOnHoldModal() {
        sessionOnHoldModal = SessionOnHoldModal(frame: .zero)
        sessionOnHoldModal?.delegate = self
        sessionOnHoldModal?.show()
    }
    
    func dismissAllModals() {
        addTimeModal?.dismiss()
        sessionOnHoldModal?.dismiss()
        acceptAddTimeModal?.dismiss()
        endSessionModal?.dismiss()
        pauseSessionModal?.dismiss()
        connectionLostModal?.dismiss()
        reportTypeModal?.dismiss()
    }
}

// MARK: - VideoSessionPartnerFeedBehaviorDelegate
extension QTVideoSessionViewController: VideoSessionPartnerFeedBehaviorDelegate {
    func partnerFeedDidFinishAnimating(_ partnerFeed: UIView, to cornerPosition: CardPosition) {
        cameraPreviewTop?.isActive = false
        cameraPreviewBottom?.isActive = false
        cameraPreviewLeading?.isActive = false
        cameraPreviewTrailing?.isActive = false
        switch cornerPosition {
        case .topLeft:
            cameraPreviewTop?.isActive = true
            cameraPreviewTop.constant = 20
            cameraPreviewLeading?.isActive = true
            cameraPreviewLeading.constant = 20
        case .topRight:
            cameraPreviewTop?.isActive = true
            cameraPreviewTop.constant = 20
            cameraPreviewTrailing?.isActive = true
            cameraPreviewTrailing.constant = 20
        case .bottomRight:
            cameraPreviewBottom?.isActive = true
            cameraPreviewBottom.constant = 20
            cameraPreviewTrailing?.isActive = true
            cameraPreviewTrailing.constant = 20
        case .bottomLeft:
            cameraPreviewBottom?.isActive = true
            cameraPreviewBottom.constant = 20
            cameraPreviewLeading?.isActive = true
            cameraPreviewLeading.constant = 20
        }
        
        self.view.layoutIfNeeded()
    }
}

// MARK: - TwilioSessionManagerDelegate
extension QTVideoSessionViewController: TwilioSessionManagerDelegate {
    func twilioSessionManagerDidReceiveVideoData(_ twilioSessionManager: TwilioSessionManager) {
        hideLoadingAnimation()
    }
}

// MARK: - SessionManagerDelegate
extension QTVideoSessionViewController: SessionManagerDelegate {
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
        // continueOutOfSession()
        /*AccountService.shared.currentUserType == .learner ? showAddTimeModal() : showSessionOnHoldModal()*/
    }
    
    func sessionManagerShouldShowEndSessionModal(_ sessionManager: SessionManager) {
        showEndModal()
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
        
        guard let session = self.sessionManager?.session else { return }
        self.updatePartnerInformation(session: session)
    }
}

// MARK: - AddTimeModalDelegate
extension QTVideoSessionViewController: AddTimeModalDelegate {
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

// MARK: - EndSessionModalDelegate
extension QTVideoSessionViewController: EndSessionModalDelegate {
    func endSessionModalDidConfirm(_ endSessionModal: EndSessionModal) {
        sessionManager?.endSocketSession()
    }
}

// MARK: - PauseSessionModalDelegate
extension QTVideoSessionViewController: PauseSessionModalDelegate {
    func pauseSessionModalShouldEndSession(_ pauseSessionModal: PauseSessionModal) {
        showEndModal()
    }
    
    func pauseSessionModalDidUnpause(_ pauseSessionModal: PauseSessionModal) {
        socket.emit(SocketEvents.unpauseSession, ["roomKey": sessionId!])
    }
}

// MARK: - AcceptAddTimeDelegate
extension QTVideoSessionViewController: AcceptAddTimeDelegate {
    func didAccept() {
        guard let id = sessionManager?.session.id else { return }
        socket.emit(SocketEvents.addTimeRequestAnswered, ["didAccept": true, "roomKey": id])
    }
    
    func didDecline() {
        guard let id = sessionManager?.session.id else { return }
        socket.emit(SocketEvents.addTimeRequestAnswered, ["didAccept": false, "roomKey": id])
    }
}