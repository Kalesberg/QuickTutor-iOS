//
//  TeacherKeyboardAccessory.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class TeacherKeyboardAccessory: KeyboardAccessory {
    let sendPictureButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "mediaIcon"), for: .normal)
        button.contentMode = .center
        button.tintColor = Colors.lightGrey
        return button
    }()
    
    override func setupLeftAccessoryView() {
        super.setupLeftAccessoryView()
        setupButtonStackView()
        sendPictureButton.addTarget(self, action: #selector(choosePicture), for: .touchUpInside)
    }
    
    override func setupButtonStackView() {
        super.setupButtonStackView()
        addConstraint(NSLayoutConstraint(item: sendPictureButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 25))
        addConstraint(NSLayoutConstraint(item: sendPictureButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 25))
        buttonStackView.insertArrangedSubview(sendPictureButton, at: 0)
    }

    @objc func choosePicture() {
        delegate?.handleSendingImage()
    }
    
}
