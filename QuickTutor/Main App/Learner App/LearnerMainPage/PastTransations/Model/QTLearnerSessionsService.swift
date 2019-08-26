//
//  QTLearnerSessionsService.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class QTLearnerSessionsService {

    static let shared = QTLearnerSessionsService()
    
    var timer: Timer?
    var pendingSessions = [Session]()
    var upcomingSessions = [Session]()
    var pastSessions = [Session]()
    var userSessionsRef: DatabaseReference?
    var userSessionsHandle: DatabaseHandle?
    
    @objc func fetchSessions() {
        pendingSessions.removeAll()
        upcomingSessions.removeAll()
        pastSessions.removeAll()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        
        Database
            .database()
            .reference()
            .child("userSessions")
            .child(uid)
            .child(userTypeString)
            .queryLimited(toLast: 10).observeSingleEvent(of: .value) { snapshot in
                
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
                        
                        if session.status == "pending" && session.startTime > Date().timeIntervalSince1970 {
                            if !self.pendingSessions.contains(where: { $0.id == session.id }) {
                                self.pendingSessions.append(session)
                            }
                            self.attemptReloadOfTable()
                            return
                        }
                        
                        if session.startTime < Date().timeIntervalSince1970 && session.status == "completed" {
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
                self.attemptReloadOfTable()
            } else if let index = self.upcomingSessions.firstIndex(where: { $0.id == id }) {
                if "cancelled" == session.status {
                    self.upcomingSessions.remove(at: index)
                    self.attemptReloadOfTable()
                }
            }
        }
    }
    
    @objc func handleReloadTable() {
        NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.reloadSessions, object: nil, userInfo: nil)
    }
}
