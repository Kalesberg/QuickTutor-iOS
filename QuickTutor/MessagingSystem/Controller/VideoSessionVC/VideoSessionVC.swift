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

    let videoSessionView = VideoSessionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
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
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        twilioSessionManager?.disconnect()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func setupView() {
        self.view = videoSessionView
    }
    
    func setupTwilio() {
        guard let id = sessionId else { return }
        DispatchQueue.main.async {
            self.twilioSessionManager = TwilioSessionManager(previewView: self.videoSessionView.cameraPreviewView, remoteView: self.videoSessionView.partnerFeed, sessionId: id)
            self.twilioSessionManager?.delegate = self
        }
    }
    
    func setupButtonActions() {
        videoSessionView.endButton.addTarget(self, action: #selector(VideoSessionVC.handleEndSession), for: .touchUpInside)
        videoSessionView.pauseButton.addTarget(self, action: #selector(VideoSessionVC.handleSessionPause), for: .touchUpInside)
        videoSessionView.swapCameraButton.addTarget(self, action: #selector(VideoSessionVC.swapCamera), for: .touchUpInside)
    }
    
    override func handleBackgrounded() {
        super.handleBackgrounded()
        guard let manager = sessionManager, !manager.isPaused else { return }
        sessionManager?.isPausedBySystem = true
        sessionManager?.pauseSession()
    }
    
    override func handleForegrounded() {
        super.handleForegrounded()
        guard let manager = sessionManager, manager.isPausedBySystem else { return }
        sessionManager?.isPausedBySystem = false
        sessionManager?.unpauseSession()
    }
    
    @objc func handleEndSession() {
        guard let manager = sessionManager else { return }
        manager.endSession()
    }
    
    @objc func handleSessionPause() {
        guard let manager = sessionManager else { return }
        if manager.isPaused {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard manager.pausedBy == uid else { return }
           videoSessionView.pauseButton.setImage(UIImage(named: "newPauseSessionButton"), for: .normal)
            manager.unpauseSession()
        } else {
            manager.pauseSession()
            videoSessionView.pauseButton.setImage(UIImage(named: "unpauseSessionButtonWhite"), for: .normal)

        }
    }
    
    @objc func swapCamera() {
        guard let manager = twilioSessionManager else { return }
        manager.flipCamera()
    }
    
    override func showPauseModal(pausedById: String) {
    }
    
    override func sessionManagerSessionTimeDidExpire(_ sessionManager: SessionManager) {
        
    }
    
    override func sessionManager(_ sessionManager: SessionManager, didUnpause session: Session) {
        super.sessionManager(sessionManager, didUnpause: session)
        videoSessionView.unpause()
        twilioSessionManager?.resume()
    }
    
    override func sessionManager(_ sessionManager: SessionManager, userId: String, didPause session: Session) {
        sessionManager.stopSessionRuntime()
        videoSessionView.pause()
        twilioSessionManager?.stop()
    }
    
    override func sessionManager(_ sessionManager: SessionManager, userConnectedWith uid: String) {
        sessionManager.startSessionRuntime()
//        twilioSessionManager?.connect()
        twilioSessionManager?.resume()
        videoSessionView.unpause()
        videoSessionView.hideLoadingAnimation()
    }
    
    override func sessionManager(_ sessionManager: SessionManager, userLostConnection uid: String) {
        sessionManager.stopSessionRuntime()
        if viewIfLoaded?.window != nil {
            self.videoSessionView.pause()
            self.videoSessionView.showLoadingAnimation()
        }
    }
}

extension VideoSessionVC: TwilioSessionManagerDelegate {
    func twilioSessionManagerDidReceiveVideoData(_ twilioSessionManager: TwilioSessionManager) {
        videoSessionView.hideLoadingAnimation()
    }
}
