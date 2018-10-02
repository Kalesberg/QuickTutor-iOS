//
//  SystemMessageCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class SystemMessageCell: BaseMessageCell {
    let textField: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.systemFont(ofSize: 12)
        textfield.textColor = .white
        textfield.text = "Delivered"
        textfield.textAlignment = .right
        textfield.isUserInteractionEnabled = false
        return textfield
    }()

    override func setupViews() {
        setupTextField()
    }

    func setupTextField() {
        addSubview(textField)
        textField.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 15)
    }

    func updateUI(message: SystemMessage) {
        textField.text = message.text
    }

    @objc func markAsRead() {
        guard textField.text != "Seen" else { return }
        UIView.animate(withDuration: 0.1, animations: {
            self.textField.alpha = 0
        }) { _ in
            self.completeMarkAsRead()
        }
    }

    func completeMarkAsRead() {
        textField.text = "Seen"
        UIView.animate(withDuration: 0.1) {
            self.textField.alpha = 1
        }
    }
}
