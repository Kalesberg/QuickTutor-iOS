//
//  BaseSessionVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

protocol AddTimeModalDelegate {
    func addTimeModalDidDecline(_ addTimeModal: AddTimeModal)
    func addTimeModal(_ addTimeModal: AddTimeModal, didAdd minutes: Int)
}

class BaseSessionVC: UIViewController, AddTimeModalDelegate, SessionManagerDelegate {
    
    lazy var sessionNavBar: SessionNavBar = {
        let bar = SessionNavBar()
//        bar.timeLabel.delegate = self
        return bar
    }()
    
    var partnerId: String?
    var sessionId: String?
    var session: Session?
    var sessionLengthInSeconds: Double?
    var socket = SocketClient.shared.socket!
    var sessionManager: SessionManager?
    
    var addTimeModal: AddTimeModal?
    var sessionOnHoldModal: SessionOnHoldModal?
    var acceptAddTimeModal: AcceptAddTimeModal?
    var endSessionModal: EndSessionModal?
    var pauseSessionModal: PauseSessionModal?

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
    
    func observeSessionEvents() {
        socket.on("requestAddTime") { (data, ack) in
            guard let dict = data[0] as? [String: Any] else { return }
            guard let id = dict["id"] as? String else { return }
            guard id != Auth.auth().currentUser?.uid else { return }
            self.showAcceptAddTimeModal()
        }
        
        socket.on(SocketEvents.addTimeRequestAnswered) { (data, ack) in
            guard let dict = data[0] as? [String: Any] else { return }
            guard let answer = dict["didAccept"] as? Bool else { return }
            if answer {
                
            } else {
                self.continueOutOfSession()
            }
            self.sessionOnHoldModal?.dismiss()
            self.addTimeModal?.dismiss()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeSessionEvents()
        guard let id = sessionId else { return }
        sessionManager = SessionManager(sessionId: id)
        sessionManager?.delegate = self
    }
    
    func addTimeModalDidDecline(_ addTimeModal: AddTimeModal) {
        addTimeModal.dismiss()
        sessionOnHoldModal?.dismiss()
        continueOutOfSession()
    }
    
    func addTimeModal(_ addTimeModal: AddTimeModal, didAdd minutes: Int) {
        print("Should add time.")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let id = session?.id else { return }
        addTimeModal.dismiss()
        sessionOnHoldModal?.dismiss()
        socket.emit(SocketEvents.requestAddTime, ["id": uid, "roomKey": id])
    }
    
//    func didUpdateTime(_ time: Int) {
//        print("Time: \(time), Length in seconds: \(sessionLengthInSeconds)")
//        guard let length = sessionLengthInSeconds else { return }
//        if time == Int(length) {
//            stopSessionTime()
//            
//            guard AccountService.shared.currentUserType == .learner else {
//                sessionOnHoldModal = SessionOnHoldModal(frame: .zero)
//                sessionOnHoldModal?.show()
//                return
//            }
//            showAddTimeModal()
//        }
//    }
    
    @objc func continueOutOfSession() {
        if AccountService.shared.currentUserType == .learner {
            let vc = AddTipVC()
            vc.partnerId = sessionManager?.session.partnerId()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = SessionCompleteVC()
            vc.partnerId = sessionManager?.session.partnerId()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func sessionManagerSessionTimeDidExpire(_ sessionManager: SessionManager) {
        
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
        continueOutOfSession()
    }
    
    func sessionManagerShouldShowEndSessionModal(_ sessionManager: SessionManager) {
        self.showEndModal()
    }
}

extension BaseSessionVC: PauseSessionModalDelegate {
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
        socket.emit(SocketEvents.addTimeRequestAnswered, [])
    }
    
    func didDecline() {
        socket.emit(SocketEvents.addTimeRequestAnswered, [])
    }
}
