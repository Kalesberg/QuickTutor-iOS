//
//  MessagetTimebreakCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class MessageGapTimestampCell: SystemMessageCell {
    
    let line: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray
        return view
    }()
    
    var textFieldWithAnchor: NSLayoutConstraint?
    
    func updateUI(message: MessageBreakTimestamp) {
        textField.attributedText = message.customAttributedString
        textFieldWithAnchor?.constant = message.text.estimateFrameForFontSize(12).width + 30
        layoutIfNeeded()
    }
    
    override func setupViews() {
        super.setupViews()
        setupLine()
    }
    
    override func setupTextField() {
        textField.textAlignment = .center
        textField.textColor = .white
        textField.font = Fonts.createBlackSize(12)
        textField.backgroundColor = Colors.darkBackground
        addSubview(textField)
        textField.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
        textFieldWithAnchor = textField.widthAnchor.constraint(equalToConstant: 100)
        textFieldWithAnchor?.isActive = true
        layoutIfNeeded()
        addConstraint(NSLayoutConstraint(item: textField, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: -25))
    }
    
    func setupLine() {
        insertSubview(line, at: 0)
        line.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        addConstraint(NSLayoutConstraint(item: line, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
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
