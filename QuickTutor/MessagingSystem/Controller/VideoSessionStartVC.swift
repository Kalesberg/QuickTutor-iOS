//
//  VideoSessionStartVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class VideoSessionStartVC: BaseSessionStartVC {
    
    var audioPlayer: AVPlayer?
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playRingingSound()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.audioPlayer?.currentItem, queue: .main) { _ in
            self.audioPlayer?.seek(to: kCMTimeZero)
            self.audioPlayer?.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.pause()
        audioPlayer = nil
    }
    
    func playRingingSound() {
        guard let uid = Auth.auth().currentUser?.uid, initiatorId == uid else { return }
        guard let url = Bundle.main.url(forResource: "phone-ring", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            audioPlayer = try AVPlayer(url: url)
            
            guard let player = audioPlayer else { return }
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
