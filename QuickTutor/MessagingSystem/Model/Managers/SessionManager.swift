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
    func sessionManager(_ sessionManager: SessionManager, userLostConnection uid: String)
    func sessionManager(_ sessionManager: SessionManager, userConnectedWith uid: String)
}

class SessionManager {
    
    var sessionId: String!
    var session: Session!
    
    var sessionLengthInSeconds = 0
    var sessionRuntime = 0
    var timer: Timer?
    
    var delegate: SessionManagerDelegate?
    var socket: SocketIOClient!

    //MARK: Session events -
    func loadSession() {
        DataService.shared.getSessionById(sessionId) { session in
            self.session = session
            self.sessionId = session.id
            self.sessionLengthInSeconds = Int(session.endTime - session.startTime)
            self.sessionRuntime = session.runTime
            self.startSessionRuntime()
            self.markSessionAsInProgress()
        }
    }
    
    func markSessionAsInProgress() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            InProgressSessionManager.shared.markSessionAsInProgress(sessionId: self.session.id, partnerId: self.session.partnerId())
        }
    }
    
    func expireSession() {
        Database.database().reference().child("sessions").child(sessionId).child("status").setValue("completed")
    }
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessionStarts").child(uid).removeValue()
        Database.database().reference().child("sessionStarts").child(session.partnerId()).removeValue()
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
    
    func markDataStale(partnerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        Database.database().reference().child("userSessions").child(uid)
            .child(userTypeString).child(sessionId).setValue(0)
        Database.database().reference().child("userSessions").child(partnerId)
            .child(otherUserTypeString).child(sessionId).setValue(0)
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
            timer?.invalidate()
            timer = nil
            return
        }
        sessionRuntime += 1
        postUpdatedTimeNotification()
    }
    
    func postUpdatedTimeNotification() {
        let info = ["timeString": getFormattedRuntimeString()]
        let notification = Notification(name: Notification.Name(rawValue: "com.qt.updateTime"), object: nil, userInfo: info)
        NotificationCenter.default.post(notification)
        Database.database().reference().child("sessions").child(session.id).child("runTime").setValue(sessionRuntime)
    }
    
    func getFormattedRuntimeString() -> String {
        let hours = sessionRuntime / 60 / 60
        let minutes = (sessionRuntime - hours * 60 * 60) / 60
        let seconds = sessionRuntime - (sessionRuntime - hours * 60 * 60) - (sessionRuntime - minutes * 60)
        let secondsString = String(seconds)
        var decimalPlaceString = ""
        print(secondsString)
        if secondsString.count == 2 {
            decimalPlaceString = "0"
        }
        return "\(hours):\(minutes):\(decimalPlaceString)\(seconds * -1)"
    }
    
    func sessionRuntimeExpired() -> Bool {
        return sessionRuntime >= sessionLengthInSeconds
    }
    
    var connectionLost = false
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
            InProgressSessionManager.shared.removeSessionFromInProgress(sessionId: self.sessionId, partnerId: self.session.partnerId())
            self.delegate?.sessionManager(self, didEnd: self.session)
        }
        
        socket.on(SocketEvents.partnerDisconnected) { (data, ack) in
            guard !self.connectionLost else { return }
            self.connectionLost = true
            self.delegate?.sessionManager(self, userLostConnection: "lostConnection")
        }
        
        socket.on(SocketEvents.newConnection) { (data, ack) in
            guard let dict = data[0] as? [String: Any], let connectionUid = dict["uid"] as? String else { return }
            self.connectionLost = false
            print("New connection:", connectionUid)
            self.delegate?.sessionManager(self, userConnectedWith: connectionUid)
        }
        
    }
    
    init(sessionId: String, socket: SocketIOClient) {
        self.sessionId = sessionId
        self.socket = socket
        loadSession()
        observeSocketEvents()
    }
    
    init(sessionId: String) {
        self.sessionId = sessionId
        loadSession()
    }
    
        
}
