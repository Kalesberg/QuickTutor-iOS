//
//  SocketClient.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SocketIO

let socketUrl = "35.231.239.116"

// class SocketBuilder {
//
//    static let shared = SocketBuilder()
//
//    private init() {}
//
//    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(true), .forceWebsockets(true)])
//    var socket: SocketIOClient?
//
//    func create(id: String) -> SocketIOClient {
//        let socket = manager.defaultSocket
//        socket.connect()
//        socket.on(clientEvent: .connect) { (data, ack) in
//            socket.emit("joinRoom", id)
//        }
//        self.socket = socket
//        return socket
//    }
// }

// class SocketClient {
//    static let shared = SocketClient()
//    var customManager: CustomSocketManager!
//    private init () {}
//
//    let manager = SocketManager(socketURL: URL(string: "https://tidycoder.com")!, config: [.log(true), .forceWebsockets(true)])
//    var socket: SocketIOClient!
//
//    var sessionId: String!
//
//    func connect() {
//        socket = manager.defaultSocket
//        socket.connect()
//        addSocketActions()
//    }
//
//    func disconnect() {
//        socket.disconnect()
//    }
//
//    func joinRoom(_ roomKey: String) {
//        socket.emit("joinRoom", roomKey)
//    }
//
//    func addSocketActions() {
//        socket.on(clientEvent: .connect) { (data, ack) in
//            print("Socket Connected")
//        }
//
//        socket.on(SocketEvents.pauseSession) { (data, ack) in
//
//        }
//
//        socket.on(SocketEvents.manualStartAccetped) { (data, ack) in
//            guard let value = data[0] as? [String: Any] else { return }
//            if let type = value["sessionType"] as? String {
//                if type == "online" {
//                    let vc = VideoSessionVC()
//                    vc.sessionId = value["sessionId"] as? String
//                    navigationController.pushViewController(vc, animated: true)
//                } else {
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "manualStartAccepted"), object: nil)
//                    guard let confirmedUsers = value["confirmedBy"] as? [String: Any], confirmedUsers.count == 2 else { return }
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showConfirmMeetup"), object: nil)
//                }
//            }
//        }
//    }
//    
//}

protocol CustomSocketManager {
    func pauseSession(pausedBy: String)
}

extension CustomSocketManager {
    func pauseSession(pausedBy: String) {}
}

struct SocketEvents {
    static let pauseSession = "pauseSession"
    static let unpauseSession = "unpauseSession"
    static let endSession = "endSession"
    static let manualStartAccetped = "manualStartAccepted"
    static let meetupConfirmed = "meetupConfirmed"
    static let requestAddTime = "requestAddTime"
    static let addTimeRequestAnswered = "addTimeRequestAnswered"
    static let cancelSession = "cancelSession"
    static let partnerDisconnected = "userDisconnected"
    static let newConnection = "newConnection"
}
