//
//  SystemMessage.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/28/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Foundation

class SystemMessage: BaseMessage {
    var text: String!
    
    init(text: String) {
        super.init()
        self.text = text
    }
}
