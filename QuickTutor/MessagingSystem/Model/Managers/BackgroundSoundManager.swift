//
//  BackgroundSoundManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import AVFoundation

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
        self.backgroundTask = app.beginBackgroundTask() {
            self.app.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
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
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
        } catch _ {
        }
        
        self.audioPlayer = try? AVAudioPlayer(contentsOf: soundFilePath as URL)
        
        self.audioEngine.reset()
        self.audioPlayer.play()
        
        self.app.endBackgroundTask(self.backgroundTask)
        self.backgroundTask = app.beginBackgroundTask() {
            self.app.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
        }
    }
}
