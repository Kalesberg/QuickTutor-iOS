//
//  MessageBreakTimestamp.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class MessageBreakTimestamp: SystemMessage {
    
    var customAttributedString: NSAttributedString!
    
    init(attributedText: NSAttributedString) {
        super.init(text: "")
        self.customAttributedString = attributedText
    }
    
}
