//
//  QTRecentSearchModel.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 7/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import ObjectMapper

class QTRecentSearchModel: Mappable {
    var uid: String? // user id
    var type: QTRecentSearchType!
    var imageUrl: String?
    var name1: String! // category // user name + Intial
    var name2: String? // subcategory // username
    
    required init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        uid             <- map["uid"]
        type            <- map["type"]
        imageUrl        <- map["imageUrl"]
        name1           <- map["name1"]
        name2           <- map["name2"]
    }
}
