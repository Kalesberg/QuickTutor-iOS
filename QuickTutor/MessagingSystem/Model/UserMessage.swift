//
//  Message.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/24/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase


class UserMessage: BaseMessage {

    var text: String?
    var data: [String: Any]
    var timeStamp: NSNumber
    var senderId: String
    var receiverId: String
    var imageUrl: String?
    var sessionRequestId: String?
    var connectionRequestId: String?
    var user: User?

    init(dictionary: [String: Any]) {
        data = dictionary
        text = dictionary["text"] as? String
        timeStamp = dictionary["timestamp"] as! NSNumber
        senderId = dictionary["senderId"] as! String
        receiverId = dictionary["receiverId"] as? String ?? ""
        imageUrl = dictionary["imageUrl"] as? String
        sessionRequestId = dictionary["sessionRequestId"] as? String
        connectionRequestId = dictionary["connectionRequestId"] as? String
    }

    func partnerId() -> String {
        guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
        return senderId == uid ? receiverId : senderId
    }
}
