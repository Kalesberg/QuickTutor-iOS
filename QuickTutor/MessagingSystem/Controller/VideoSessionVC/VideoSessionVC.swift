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
        sessionNavBar.timeLabel.timeInSeconds += (minutes * 60)
    }
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessionStarts").child(uid).removeValue()
    }
    
    override func stopSessionTime() {
        videoSessionView.sessionNavBar.timeLabel.timer?.invalidate()
        videoSessionView.sessionNavBar.timeLabel.timer = nil    }
    
    func loadSession() {
        guard let id = sessionId else { return }
        DataService.shared.getSessionById(id) { session in
            self.partnerId = session.partnerId()
            self.session = session
            self.sessionId = session.id
            self.sessionLengthInSeconds = session.endTime - session.startTime
//            self.expireSession()
        }
    }
    
    func expireSession() {
        guard let id = self.session?.id else { return }
        Database.database().reference().child("sessions").child(id).child("status").setValue("expired")
    }
    
    override func didUpdateTime(_ time: Int) {
        super.didUpdateTime(time)
        guard let length = sessionLengthInSeconds else { return }
        if time == Int(length) {
            twilioSessionManager?.stop()
        }
    }
    
    override func observeSessionEvents() {
        super.observeSessionEvents()
        socket.on(SocketEvents.pauseSession) { data, _ in
            print("Printing data:", data)
            self.stopSessionTime()
            guard let dict = data[0] as? [String: Any] else {
                return
            }
            guard let pausedById = dict["pausedBy"] as? String else { return }
            self.showPauseModal(pausedById: pausedById)
        }
        
        socket.on(SocketEvents.unpauseSession) { _, _ in
            self.pauseSessionModal?.dismiss()
            self.videoSessionView.sessionNavBar.timeLabel.startTimer()
            self.twilioSessionManager?.resume()
        }
        
        socket.on(SocketEvents.endSession) { _, _ in
            self.showEndSession()
        }
    }

    
    @objc func showEndSession() {
        if AccountService.shared.currentUserType == .learner {
            let vc = AddTipVC()
            vc.partnerId = partnerId
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = SessionCompleteVC()
            vc.partnerId = partnerId
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = videoSessionView
        setupButtonActions()
        //        removeStartData()
        setupTwilio()
        loadSession()
    }
    
    func setupTwilio() {
        twilioSessionManager = TwilioSessionManager(previewView: videoSessionView.previewView, remoteView: videoSessionView.remoteView)

    }
    
    func setupButtonActions() {
        videoSessionView.endSessionButton.addTarget(self, action: #selector(showEndModal), for: .touchUpInside)
        videoSessionView.pauseSessionButton.addTarget(self, action: #selector(pauseSession), for: .touchUpInside)
        videoSessionView.sessionNavBar.timeLabel.delegate = self
    }
    
    override func showPauseModal(pausedById: String) {
        super.showPauseModal(pausedById: pausedById)
        twilioSessionManager?.stop()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        twilioSessionManager?.room?.disconnect()
    }
    
}
