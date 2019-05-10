//
//  Message.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/24/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase
import UIKit

class UserMessage: BaseMessage {
    var text: String?
    var data: [String: Any]
    var timeStamp: NSNumber
    var senderId: String
    var receiverId: String
    var imageUrl: String?
    var sessionRequestId: String?
    var connectionRequestId: String?
    var videoUrl: String?
    var documenUrl: String?
    var user: User?

    override init(dictionary: [String: Any]) {
        data = dictionary
        text = dictionary["text"] as? String
        timeStamp = dictionary["timestamp"] as! NSNumber
        senderId = dictionary["senderId"] as! String
        receiverId = dictionary["receiverId"] as? String ?? ""
        imageUrl = dictionary["imageUrl"] as? String
        sessionRequestId = dictionary["sessionRequestId"] as? String
        connectionRequestId = dictionary["connectionRequestId"] as? String
        videoUrl = dictionary["videoUrl"] as? String
        documenUrl = dictionary["documentUrl"] as? String
        super.init(dictionary: dictionary)
        updateMessageType()
    }
    
    func updateMessageType() {
        type = .text
        if let _ = imageUrl {
            type = .image
        }
        if let _ = videoUrl {
            type = .video
        }
        if let _ = connectionRequestId {
            type = .connectionRequest
        }
        if let _ = sessionRequestId {
            type = .sessionRequest
        }
        if let _ = documenUrl {
            type = .document
        }
    }

    func partnerId() -> String {
        guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
        return senderId == uid ? receiverId : senderId
    }
    
    func getLinksInText() -> [String] {
        guard let input = text else { return [] }
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        var urls = [String]()
        for match in matches {
            guard let range = Range(match.range, in: input) else { continue }
            let url = input[range]
            var urlString = String(url)
            if !urls.contains("http") {
                urlString = "http://" + urlString
            }
            urls.append(urlString)
        }
        return urls
    }
}
