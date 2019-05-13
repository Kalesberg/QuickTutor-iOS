//
//  BaseSessionVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import SocketIO
import UIKit

protocol AddTimeModalDelegate {
    func addTimeModalDidDecline(_ addTimeModal: AddTimeModal)
    func addTimeModal(_ addTimeModal: AddTimeModal, didAdd minutes: Int)
}

class BaseSessionVC: UIViewController, AddTimeModalDelegate, SessionManagerDelegate {

    var partnerId: String?
    var sessionId: String?
    var sessionLengthInSeconds: Double?
    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(true), .forceWebsockets(true)])
    var socket: SocketIOClient!
    var sessionManager: SessionManager?

    var addTimeModal: AddTimeModal?
    var sessionOnHoldModal: SessionOnHoldModal?
    var acceptAddTimeModal: AcceptAddTimeModal?
    var endSessionModal: EndSessionModal?
    var pauseSessionModal: PauseSessionModal?
    var connectionLostModal: PauseSessionModal?

    var minutesToAdd = 0

    @objc func showEndModal() {
        endSessionModal = EndSessionModal(frame: .zero)
        endSessionModal?.delegate = self
        endSessionModal?.show()
    }

    @objc func pauseSession() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        socket.emit(SocketEvents.pauseSession, ["pausedBy": uid, "roomKey": sessionId!])
    }

    @objc func showPauseModal(pausedById: String) {
        guard pauseSessionModal == nil else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        pauseSessionModal?.delegate = self
        UserFetchService.shared.getUserOfOppositeTypeWithId(sessionManager?.session.partnerId() ?? "test") { user in
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

    @objc func showConnectionLostModal(pausedById: String) {
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

    @objc func showAddTimeModal() {
        addTimeModal = AddTimeModal(frame: .zero)
        addTimeModal?.delegate = self
        addTimeModal?.show()
    }

    @objc func showAcceptAddTimeModal() {
        acceptAddTimeModal = AcceptAddTimeModal(frame: .zero)
        acceptAddTimeModal?.delegate = self
        acceptAddTimeModal?.show()
    }

    func showSessionOnHoldModal() {
        sessionOnHoldModal = SessionOnHoldModal(frame: .zero)
        sessionOnHoldModal?.delegate = self
        sessionOnHoldModal?.show()
    }

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
                self.continueOutOfSession()
            }
            self.sessionOnHoldModal?.dismiss()
            self.addTimeModal?.dismiss()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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

    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackgrounded), name: Notifications.didEnterBackground.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleForegrounded), name: Notifications.didEnterForeground.name, object: nil)
    }

    @objc func handleBackgrounded() {}

    @objc func handleForegrounded() {}

    func addTimeModalDidDecline(_ addTimeModal: AddTimeModal) {
        addTimeModal.dismiss()
        sessionOnHoldModal?.dismiss()
        sessionManager?.endSocketSession()
    }

    func addTimeModal(_ addTimeModal: AddTimeModal, didAdd minutes: Int) {
        minutesToAdd += minutes
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let id = sessionManager?.session?.id else { return }
        addTimeModal.dismiss()
        sessionOnHoldModal?.dismiss()
        socket.emit(SocketEvents.requestAddTime, ["id": uid, "roomKey": id, "seconds": minutes * 60])
    }

    @objc func continueOutOfSession() {
        BackgroundSoundManager.shared.sessionInProgress = false
        sessionOnHoldModal?.dismiss()
        pauseSessionModal?.dismiss()
        connectionLostModal?.dismiss()
        PostSessionManager.shared.sessionDidEnd(sessionId: sessionId!, partnerId: partnerId!)
        if let session = sessionManager?.session, let runtime = sessionManager?.sessionRuntime {
            session.runTime = runtime
            showRatingViewControllerForSession(session, sessionId: sessionId)
        }
    }
    
    func expireSession() {
        guard let id = sessionId else { return }
        Database.database().reference().child("sessions").child(id).child("status").setValue("completed")
    }
    
    func sessionManagerSessionTimeDidExpire(_ sessionManager: SessionManager) {
        continueOutOfSession()
        //        AccountService.shared.currentUserType == .learner ? showAddTimeModal() : showSessionOnHoldModal()
    }
    
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
        PostSessionManager.shared.sessionDidEnd(sessionId: session.id, partnerId: session.partnerId())
        sessionId = session.id
        partnerId = session.partnerId()
        continueOutOfSession()
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
    }
}

extension BaseSessionVC: PauseSessionModalDelegate {
    func pauseSessionModalShouldEndSession(_ pauseSessionModal: PauseSessionModal) {
        showEndModal()
    }
    
    func pauseSessionModalDidUnpause(_ pauseSessionModal: PauseSessionModal) {
        socket.emit(SocketEvents.unpauseSession, ["roomKey": sessionId!])
    }
}

extension BaseSessionVC: EndSessionModalDelegate {
    func endSessionModalDidConfirm(_ endSessionModal: EndSessionModal) {
        sessionManager?.endSocketSession()
    }
}

extension BaseSessionVC: AcceptAddTimeDelegate {
    func didAccept() {
        guard let id = sessionManager?.session.id else { return }
        socket.emit(SocketEvents.addTimeRequestAnswered, ["didAccept": true, "roomKey": id])
    }

    func didDecline() {
        guard let id = sessionManager?.session.id else { return }
        socket.emit(SocketEvents.addTimeRequestAnswered, ["didAccept": false, "roomKey": id])
    }
}
