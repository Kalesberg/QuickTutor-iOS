//
//  BaseMessage.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/28/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Foundation

//enum MessageType {
//    case text, image, sessionRequest, connectionRequest, readRecieptLabel
//}

enum MessageType: String {
    case text = "textMessage"
    case image = "imageMessage"
    case sessionRequest = "sessionRequestMessage"
    case connectionRequest = "connectionRequestMessage"
    case readReceiptLabel = "readReceiptMessage"
}

//class MessageBuilder {
//    func loadFromData(_ data: [String: Any]) -> Message {
//        if let _ = data["connectionRequestId"] as? String {
//            return ConnectionRequestMessage(dictionary: data)
//        } else if let _ = data["sessionRequestId"] as? String {
//            return SessionRequestMessage(dictionary: data)
//        } else if let _ = data["imageUrl"] as? String {
//            return ImageMessage(dictionary: data)
//        } else {
//            return TextMessage(dictionary: data)
//        }
//    }
//}

class BaseMessage {
    var type: MessageType
    var uid: String!
    var timestamp: NSNumber!
    var isRead = false

    init() {
        type = .text
    }
}

class ImageMessage: UserMessage {}

class TextMessage: UserMessage {}

class ConnectionRequestMessage: UserMessage {}

class SessionRequestMessage: UserMessage {}

