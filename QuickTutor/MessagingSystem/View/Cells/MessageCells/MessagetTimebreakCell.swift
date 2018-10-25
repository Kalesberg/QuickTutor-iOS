//
//  MessagetTimebreakCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class MessageGapTimestampCell: SystemMessageCell {
    
    func updateUI(message: MessageBreakTimestamp) {
        textField.attributedText = message.customAttributedString
    }
    
    override func setupTextField() {
        textField.textAlignment = .center
        textField.textColor = Colors.grayText
        textField.font = Fonts.createSize(12)
        addSubview(textField)
        textField.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 15)
        addConstraint(NSLayoutConstraint(item: textField, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: -25))
    }
    
    func updateTimeLabel(timeStamp: Double) {
        let timestampDate = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        textField.text = textField.text ?? "" + dateFormatter.string(from: timestampDate)
    }
}
