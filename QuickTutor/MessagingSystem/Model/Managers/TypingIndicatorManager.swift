//
//  TypingIndicatorManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase
import SocketIO

class TypingIndicatorManager {
    
    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(true), .forceWebsockets(true)])
    var socket: SocketIOClient!
    var collectionView: ConversationCollectionView!
    var roomKey: String!
    var chatPartner: User!
    var typingTimer: Timer!
    var shouldEmitTypingEvent = true
    weak var typingDismissalTimer: Timer?
    
    func connect() {
        socket = manager.defaultSocket
        socket.connect()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        socket.on(clientEvent: .connect) { _, _ in
            let joinData = ["roomKey": self.roomKey, "uid": uid]
            self.socket.emit("joinRoom", joinData)
        }
        
        socket.on("startedTyping") { (data, ack) in
            guard let dict = data[0] as? [String: Any], let typingUserId = dict["typingUserId"] as? String else { return }
            guard let uid = Auth.auth().currentUser?.uid, typingUserId != uid else { return }
            self.showTypingIndicator()
        }
        
        socket.on("stoppedTyping") { (data, ack) in
            guard let dict = data[0] as? [String: Any], let typingUserId = dict["typingUserId"] as? String else { return }
            guard let uid = Auth.auth().currentUser?.uid, typingUserId != uid else { return }
            self.collectionView.typingHeightAnchor?.constant = 0
            self.collectionView.layoutTypingLabelIfNeeded()
        }
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func showTypingIndicator() {
        collectionView.showTypingIndicator()
    }
    
    func hideTypingIndicator() {
        collectionView.hideTypingIndicator()
    }
    
    func startTypingIndicatorDismissalTimer() {
        typingDismissalTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
            self.collectionView.typingHeightAnchor?.constant = 0
            self.collectionView.layoutTypingLabelIfNeeded()
        })
        typingDismissalTimer?.fire()
    }
    
    func emitTypingEventIfNeeded() {
        guard shouldEmitTypingEvent else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        shouldEmitTypingEvent = false
        socket.emit("startedTyping", ["typingUserId": uid, "roomKey": roomKey])
    }
    
    func setupTypingTimer() {
        typingTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            self.shouldEmitTypingEvent = true
        })
        typingTimer.fire()
    }
    
    func emitStopTyping() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        shouldEmitTypingEvent = false
        socket.emit("stoppedTyping", ["roomKey": roomKey, "typingUserId": uid])
    }
    
    init(roomKey: String, collectionView: ConversationCollectionView) {
        self.roomKey = roomKey
        self.collectionView = collectionView
        setupTypingTimer()
    }
}
