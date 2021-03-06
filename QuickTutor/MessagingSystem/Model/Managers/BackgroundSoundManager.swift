//
//  BackgroundSoundManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import AVFoundation
import Foundation

class BackgroundSoundManager {
    static let shared = BackgroundSoundManager()
    private init() {}

    var sessionInProgress = false

    let app = UIApplication.shared

    var backgroundTask: UIBackgroundTaskIdentifier!

    var audioPlayer: AVAudioPlayer!

    var audioEngine = AVAudioEngine()

    func start() {
        guard sessionInProgress else { return }
        backgroundTask = app.beginBackgroundTask {
            self.app.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskIdentifier(rawValue: convertFromUIBackgroundTaskIdentifier(UIBackgroundTaskIdentifier.invalid))
        }

        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BackgroundSoundManager.checkTime), userInfo: nil, repeats: true)
    }

    @objc func checkTime() {
        print("Background time remaining: \(app.backgroundTimeRemaining)")

        if app.backgroundTimeRemaining < 20 {
            playSound()
        }
    }

    func playSound() {
        print("Play silent sound and reset remaining time")

        let soundFilePath = NSURL(string: Bundle.main.path(forResource: "background", ofType: "mp3")!)!

        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default, options: AVAudioSession.CategoryOptions.mixWithOthers)
        } catch _ {}

        audioPlayer = try? AVAudioPlayer(contentsOf: soundFilePath as URL)

        audioEngine.reset()
        audioPlayer.play()

        app.endBackgroundTask(backgroundTask)
        backgroundTask = app.beginBackgroundTask {
            self.app.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskIdentifier(rawValue: convertFromUIBackgroundTaskIdentifier(UIBackgroundTaskIdentifier.invalid))
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIBackgroundTaskIdentifier(_ input: UIBackgroundTaskIdentifier) -> Int {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
