//
//  VideoSessionVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import TwilioVideo


class VideoSessionVC: BaseSessionVC {

    let videoSessionView = VideoSessionView()
    var twilioSessionManager: TwilioSessionManager?
    
    override func addTimeModal(_ addTimeModal: AddTimeModal, didAdd minutes: Int) {
        super.addTimeModal(addTimeModal, didAdd: minutes)
//        sessionNavBar.timeLabel.timeInSeconds += (minutes * 60)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupButtonActions()
        setupTwilio()
    }
    
    func setupView() {
        self.view = videoSessionView
    }
    
    func setupTwilio() {
        guard let id = sessionId else { return }
        twilioSessionManager = TwilioSessionManager(previewView: videoSessionView.cameraPreviewView, remoteView: videoSessionView.partnerCameraFeed, sessionId: id)
    }
    
    func setupButtonActions() {
        videoSessionView.endSessionButton.addTarget(self, action: #selector(VideoSessionVC.handleEndSession), for: .touchUpInside)
        videoSessionView.pauseSessionButton.addTarget(self, action: #selector(VideoSessionVC.handleSessionPause), for: .touchUpInside)
    }
    
    @objc func handleEndSession() {
        guard let manager = sessionManager else { return }
        manager.endSession()
    }
    
    @objc func handleSessionPause() {
        guard let manager = sessionManager else { return }
        manager.pauseSession()
    }
    
    override func showPauseModal(pausedById: String) {
        super.showPauseModal(pausedById: pausedById)
        twilioSessionManager?.stop()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        twilioSessionManager?.room?.disconnect()
    }
    
    override func sessionManagerSessionTimeDidExpire(_ sessionManager: SessionManager) {
        
    }
    
    override func sessionManager(_ sessionManager: SessionManager, didUnpause session: Session) {
        super.sessionManager(sessionManager, didUnpause: session)
        self.twilioSessionManager?.resume()
    }

}
