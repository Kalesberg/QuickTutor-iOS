//
//  SessionManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase
import SocketIO

protocol SessionManagerDelegate {
    func sessionManager(_ sessionManager: SessionManager, userId: String, didPause session: Session)
    func sessionManager(_ sessionManager: SessionManager, didUnpause session: Session)
    func sessionManager(_ sessionManager: SessionManager, didEnd session: Session)
    func sessionManagerSessionTimeDidExpire(_ sessionManager: SessionManager)
    func sessionManagerShouldShowEndSessionModal(_ sessionManager: SessionManager)
}

class SessionManager {
    
    var sessionId: String!
    var session: Session!
    
    var sessionLengthInSeconds = 0.0
    var sessionRuntime = 0.0
    var timer: Timer?
    
    var delegate: SessionManagerDelegate?
    var socket = SocketClient.shared.socket!

    //MARK: Session events -
    func loadSession() {
        DataService.shared.getSessionById(sessionId) { session in
            self.session = session
            self.sessionId = session.id
            self.sessionLengthInSeconds = session.endTime - session.startTime
        }
    }
    
    func expireSession() {
        Database.database().reference().child("sessions").child(sessionId).child("status").setValue("expired")
    }
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessionStarts").child(uid).removeValue()
    }
    
    @objc func pauseSession() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        socket.emit(SocketEvents.pauseSession, ["pausedBy": uid, "roomKey": sessionId])
    }
    
    @objc func unpauseSession() {
        socket.emit(SocketEvents.unpauseSession, ["roomKey": sessionId])
    }
    
    @objc func endSession() {
        delegate?.sessionManagerShouldShowEndSessionModal(self)
    }
    
    func endSocketSession() {
        socket.emit(SocketEvents.endSession, ["roomKey": sessionId!])
    }
    
    //MARK: Session clock -
    func startSessionRuntime() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementSessionRuntime), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func stopSessionRuntime() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
    
    @objc func incrementSessionRuntime() {
        guard !sessionRuntimeExpired() else {
            delegate?.sessionManagerSessionTimeDidExpire(self)
            return
        }
        sessionRuntime += 1.0
        postUpdatedTimeNotification()
    }
    
    func postUpdatedTimeNotification() {
        let info = ["timeString": getFormattedRuntimeString()]
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "com.qt.updateTime"), object: nil, userInfo: info))
    }
    
    func getFormattedRuntimeString() -> String {
        let hours = sessionLengthInSeconds / 60 / 60
        let minutes = (sessionLengthInSeconds - hours * 60 * 60) / 60
        let seconds = sessionLengthInSeconds - (sessionLengthInSeconds - hours * 60 * 60) - (sessionLengthInSeconds - minutes * 60)
        return "\(hours):\(minutes):\(seconds * -1)"
    }
    
    func sessionRuntimeExpired() -> Bool {
        return sessionRuntime >= sessionLengthInSeconds
    }
    
    //MARK: Sockets -
    func observeSocketEvents() {
        socket.on(SocketEvents.pauseSession) { data, _ in
            guard let dict = data[0] as? [String: Any], let pausedById = dict["pausedBy"] as? String else { return }
            self.delegate?.sessionManager(self, userId: pausedById, didPause: self.session)
        }
        
        socket.on(SocketEvents.unpauseSession) { _, _ in
            self.delegate?.sessionManager(self, didUnpause: self.session)
        }
        
        socket.on(SocketEvents.endSession) { _, _ in
            self.delegate?.sessionManager(self, didEnd: self.session)
        }
    }
    
    init(sessionId: String) {
        self.sessionId = sessionId
        loadSession()
        observeSocketEvents()
        
    }
    
    
}
