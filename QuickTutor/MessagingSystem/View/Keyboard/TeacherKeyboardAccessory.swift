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
        button.setImage(#imageLiteral(resourceName: "cameraIcon"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.tintColor = Colors.lightGrey
        return button
    }()
    
    override func setupLeftAccessoryView() {
        leftAccessoryView = sendPictureButton
        addSubview(sendPictureButton)
        sendPictureButton.anchor(top: nil, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 8, paddingRight: 0, width: 34, height: 34)
        sendPictureButton.addTarget(self, action: #selector(choosePicture), for: .touchUpInside)
    }
    
    @objc func choosePicture() {
        delegate?.handleSendingImage()
    }
    
}
