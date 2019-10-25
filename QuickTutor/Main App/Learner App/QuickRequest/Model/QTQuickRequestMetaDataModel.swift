//
//  QTQuickRequestMetaDataModel.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 10/16/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import ObjectMapper

class QTQuickRequestMetaDataModel: Mappable {
    var createdAt: Double!
    var senderId: String!
    var quickRequestId: String!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        createdAt       <- map["createdAt"]
        senderId        <- map["senderId"]
        quickRequestId  <- map["quickRequestId"]
    }
}
