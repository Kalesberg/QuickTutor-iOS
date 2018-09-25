//
//  VideoSessionStartVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import AVFoundation
import Firebase
import UIKit

class VideoSessionStartVC: BaseSessionStartVC {
    var audioPlayer: AVPlayer?

    override func updateTitleLabel() {
        guard let uid = Auth.auth().currentUser?.uid, let username = partnerUsername else { return }
        // Online Automatic
        if startType == "automatic" && session?.type == "online" {
            titleLabel.text = "Video calling \(username)..."
        }

        // Online Manual Started By Current User
        if startType == "manual" && session?.type == "online" && initiatorId == uid {
            titleLabel.text = "Video calling \(username)..."
        }

        // Online Manual Started By Other User
        if startType == "manual" && session?.type == "online" && initiatorId != uid {
            titleLabel.text = "\(username) is Video Calling..."
            confirmButton.isHidden = false
        }
    }

    override func setupViews() {
        super.setupViews()
        setupObservers()
    }

    func setupObservers() {
        socket.on(SocketEvents.manualStartAccetped) { _, _ in
            let vc = VideoSessionVC()
            vc.sessionId = self.sessionId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playRingingSound()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem, queue: .main) { _ in
            self.audioPlayer?.seek(to: CMTime.zero)
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
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.moviePlayback, options: AVAudioSession.CategoryOptions.mixWithOthers)
            //            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            audioPlayer = AVPlayer(url: url)

            guard let player = audioPlayer else { return }
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
