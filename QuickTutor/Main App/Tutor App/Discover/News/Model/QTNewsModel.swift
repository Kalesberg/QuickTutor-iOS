//
//  QTNewsModel.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/3/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTNewsModel {

    var uid:            String!
    var title:          String!
    var description:    String!
    var image:          URL!
    var contents:       [QTNewsContentModel]!
    var updatedAt:      Double!
    var type:           QTNewsType!
    
    var dictionaryRepresentation: [String: Any] {
        var dictionary = [String: Any]()
        dictionary["uid"] = uid
        dictionary["title"] = title
        dictionary["description"] = description
        dictionary["image"] = image.absoluteString
        dictionary["contents"] = contents.map({$0.dictionaryRepresentation})
        dictionary["updatedAt"] = updatedAt
        dictionary["type"] = type
        return dictionary
    }
    
    init(data: [String: Any]) {
        uid = data["uid"] as? String ?? ""
        title = data["title"] as? String ?? ""
        description = data["description"] as? String ?? ""
        image = URL(string: data["image"] as? String ?? "")
        
        if let values = data["contents"] as? [[String: Any]] {
            if contents == nil {
                contents = [QTNewsContentModel]()
            }
            for value in values {
                 contents.append(QTNewsContentModel(data: value))
            }
        }
        updatedAt = data["updatedAt"] as? Double ?? 0.0
        type = QTNewsType(rawValue: data["type"] as! String)
    }
}

class QTNewsContentModel {
    var title: String!
    var description: String!
    
    var dictionaryRepresentation: [String: Any] {
        var dictionary = [String: Any]()
        dictionary["title"] = title
        dictionary["description"] = description
        return dictionary
    }
    
    init(data: [String: Any]) {
        title = data["title"] as? String ?? ""
        description = data["description"] as? String ?? ""
    }
}
