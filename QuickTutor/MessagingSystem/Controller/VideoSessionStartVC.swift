//
//  VideoSessionStartVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class VideoSessionStartVC: BaseSessionStartVC {
    
    override func updateTitleLabel() {
        guard let uid = Auth.auth().currentUser?.uid, let username = partnerUsername else { return }
        //Online Automatic
        if startType == "automatic" && session?.type == "online" {
            self.titleLabel.text = "Video calling \(username)..."
        }
        
        //Online Manual Started By Current User
        if startType == "manual" && session?.type == "online" && initiatorId == uid {
            self.titleLabel.text = "Video calling \(username)..."
        }
        
        //Online Manual Started By Other User
        if startType == "manual" && session?.type == "online" && initiatorId != uid {
            self.titleLabel.text = "\(username) is Video Calling..."
            self.confirmButton.isHidden = false
        }
    }
    
}
