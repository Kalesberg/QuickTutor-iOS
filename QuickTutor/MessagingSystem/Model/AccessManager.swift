//
//  AccessManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import AVFoundation
import Foundation

class AccessManager {
    var parentController: UIViewController

    func checkCameraAccess() -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            return true
        } else {
            let alert = UIAlertController(title: "Camera Required", message: "Camera access is required for video sessions.", preferredStyle: .alert)

            // Add "OK" Button to alert, pressing it will bring you to the settings app
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            // Show the alert with animation
            parentController.present(alert, animated: true)
            return false
        }
    }

    func checkMicrophoneAccess() -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            return true
        } else {
            let alert = UIAlertController(title: "Microphone Required", message: "Microphone access is required for video sessions", preferredStyle: .alert)

            // Add "OK" Button to alert, pressing it will bring you to the settings app
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            // Show the alert with animation
            parentController.present(alert, animated: true)
            return false
        }
    }

    init(parentController: UIViewController) {
        self.parentController = parentController
    }
}
