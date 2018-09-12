//
//  BaseSessionVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import SocketIO

protocol AddTimeModalDelegate {
    func addTimeModalDidDecline(_ addTimeModal: AddTimeModal)
    func addTimeModal(_ addTimeModal: AddTimeModal, didAdd minutes: Int)
}

class BaseSessionVC: UIViewController, AddTimeModalDelegate, SessionManagerDelegate {
    
    lazy var sessionNavBar: SessionNavBar = {
        let bar = SessionNavBar()
//        bar.timeLabel.delegate = self
        bar.backgroundColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple : Colors.tutorBlue
        return bar
    }()
    
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
    
    @objc func showConnectionLostModal(pausedById: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
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
        socket.on(SocketEvents.requestAddTime) { (data, ack) in
            guard let dict = data[0] as? [String: Any] else { return }
            guard let id = dict["id"] as? String else { return }
            guard id != Auth.auth().currentUser?.uid else { return }
            guard let seconds = dict["seconds"] as? Int else { return }
            self.minutesToAdd = seconds / 60
            self.showAcceptAddTimeModal()
            self.sessionOnHoldModal?.dismiss()
        }
        
        socket.on(SocketEvents.addTimeRequestAnswered) { (data, ack) in
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNotifications()
        socket = manager.defaultSocket
        socket.connect()
        observeSessionEvents()
        guard let id = sessionId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        socket.on(clientEvent: .connect) { (data, ack) in
            let joinData = ["roomKey": id, "uid": uid]
            self.socket.emit("joinRoom", joinData)
        }
        sessionManager = SessionManager(sessionId: id, socket: socket)
        sessionManager?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        sessionManager?.stopSessionRuntime()
        sessionManager = nil
        socket.disconnect()
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
        print("Should add time.")
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
        if AccountService.shared.currentUserType == .learner {
            let vc = AddTipVC()
            vc.sessionId = sessionId
            guard let runtime = sessionManager?.sessionRuntime, let rate = sessionManager?.session.ratePerSecond() else { return }
            vc.costOfSession = Double(runtime) * rate
            vc.partnerId = sessionManager?.session.partnerId()
            Database.database().reference().child("sessions").child(sessionId!).child("cost").setValue(Double(runtime) * rate)
            print("ZACH: continueing out of session")
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = SessionCompleteVC()
            print("ZACH: continueing out of session")
            vc.sessionId = sessionId
            vc.partnerId = sessionManager?.session.partnerId()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func expireSession() {
        guard let id = sessionId else { return }
        Database.database().reference().child("sessions").child(id).child("status").setValue("completed")
    }
    
    func sessionManagerSessionTimeDidExpire(_ sessionManager: SessionManager) {
        AccountService.shared.currentUserType == .learner ? showAddTimeModal() : showSessionOnHoldModal()
    }
    
    func sessionManager(_ sessionManager: SessionManager, userId: String, didPause session: Session) {
        sessionManager.stopSessionRuntime()
        self.showPauseModal(pausedById: userId)
    }
    
    func sessionManager(_ sessionManager: SessionManager, didUnpause session: Session) {
        sessionManager.startSessionRuntime()
        self.pauseSessionModal?.dismiss()
    }
    
    func sessionManager(_ sessionManager: SessionManager, didEnd session: Session) {
        PostSessionManager.shared.sessionDidEnd(sessionId: session.id, partnerId: session.partnerId())
        self.sessionId = session.id
        self.partnerId = session.partnerId()
        continueOutOfSession()
    }
    
    func sessionManagerShouldShowEndSessionModal(_ sessionManager: SessionManager) {
        self.showEndModal()
    }
    
    
    func sessionManager(_ sessionManager: SessionManager, userLostConnection uid: String) {
        sessionManager.stopSessionRuntime()
        if viewIfLoaded?.window != nil {
            self.showConnectionLostModal(pausedById: uid)
        }
    }
    
    func sessionManager(_ sessionManager: SessionManager, userConnectedWith uid: String) {
        sessionManager.startSessionRuntime()
        self.pauseSessionModal?.dismiss()
        guard let myUid = Auth.auth().currentUser?.uid else { return }
        if uid != myUid {
            self.connectionLostModal?.dismiss()
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
