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
    
    let tokenUrl = "http://api.tidycoder.com/token"
    var accessToken = ""
    var room: TVIRoom?
    var camera: TVICameraCapturer?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var remoteParticipant: TVIRemoteParticipant?

    let videoSessionView = VideoSessionView()
    
    override func addTimeModal(_ addTimeModal: AddTimeModal, didAdd minutes: Int) {
        super.addTimeModal(addTimeModal, didAdd: minutes)
        sessionNavBar.timeLabel.timeInSeconds += (minutes * 60)
    }
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessionStarts").child(uid).removeValue()
    }
    
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
    
    func fetchToken() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        URLSession.shared.dataTask(with: URL(string: "http://api.tidycoder.com/twilio/token/\(uid)")!) { data, _, error in
            guard error == nil, let data = data else {
                print(error.debugDescription)
                return
            }
            var json: [String: Any]?
            do {
                json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error)
            }
            
            if let json = json, let token = json["token"] as? String {
                print("Fetched new token: ", token)
                self.accessToken = token
                self.connect()
            }
            
        }.resume()
    }
    
    func connect() {
        prepareLocalMedia()
        
        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = TVIConnectOptions(token: accessToken) { builder in
            
            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [TVILocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [TVILocalVideoTrack]()
            
            // Use the preferred encoding parameters
            if let encodingParameters = TwilioSettings.shared.getEncodingParameters() {
                builder.encodingParameters = encodingParameters
            }
            
            // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
            // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.
            builder.roomName = "This"
        }
        
        // Connect to the Room using the options we provided.
        room = TwilioVideo.connect(with: connectOptions, delegate: self)
        
    }
    
    override func didUpdateTime(_ time: Int) {
        super.didUpdateTime(time)
        guard let length = sessionLengthInSeconds else { return }
        if time == Int(length) {
            stopTwilio()
        }
    }
    
    override func observeSessionEvents() {
        super.observeSessionEvents()
        socket.on(SocketEvents.pauseSession) { data, _ in
            print("Printing data:", data)
            guard let dict = data[0] as? [String: Any] else {
                return
            }
            guard let pausedById = dict["pausedBy"] as? String else { return }
            self.showPauseModal(pausedById: pausedById)
        }
        
        socket.on(SocketEvents.unpauseSession) { _, _ in
            self.pauseSessionModal?.dismiss()
            self.sessionNavBar.timeLabel.startTimer()
            self.resumeTwilio()
        }
        
        socket.on(SocketEvents.endSession) { _, _ in
            self.showEndSession()
        }
    }
    
    func resumeTwilio() {
        room?.localParticipant?.localVideoTracks.forEach({ (publication) in
            publication.localTrack?.isEnabled = true
        })
        room?.localParticipant?.localAudioTracks.forEach({ (publication) in
            publication.localTrack?.isEnabled = true
        })
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
    
    func startPreview() {
        
        // Preview our local camera track in the local video preview view.
        camera = TVICameraCapturer(source: .frontCamera, delegate: self)
        localVideoTrack = TVILocalVideoTrack(capturer: camera!, enabled: true, constraints: nil, name: "Camera")
        if localVideoTrack == nil {
            print("Failed to create video track")
        } else {
            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(videoSessionView.previewView)
            
            // We will flip camera on tap.
            DispatchQueue.main.sync {
                let tap = UITapGestureRecognizer(target: self, action: #selector(VideoSessionVC.flipCamera))
                self.videoSessionView.previewView.addGestureRecognizer(tap)
            }
        }
    }
    
    @objc func flipCamera() {
        if camera?.source == .frontCamera {
            camera?.selectSource(.backCameraWide)
        } else {
            camera?.selectSource(.frontCamera)
        }
    }
    
    func prepareLocalMedia() {
        // Create an audio track.
        if localAudioTrack == nil {
            localAudioTrack = TVILocalAudioTrack(options: nil, enabled: true, name: "Microphone")
        }
        
        // Create a video track which captures from the camera.
        if localVideoTrack == nil {
            startPreview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = videoSessionView
        setupButtonActions()
        //        removeStartData()
        fetchToken()
        loadSession()
    }
    
    func setupButtonActions() {
        videoSessionView.endSessionButton.addTarget(self, action: #selector(showEndModal), for: .touchUpInside)
        videoSessionView.pauseSessionButton.addTarget(self, action: #selector(pauseSession), for: .touchUpInside)
        videoSessionView.sessionNavBar.timeLabel.delegate = self
    }
    
    func stopTwilio() {
        room?.localParticipant?.localVideoTracks.forEach({ (publication) in
            publication.localTrack?.isEnabled = false
        })
        room?.localParticipant?.localAudioTracks.forEach({ (publication) in
            publication.localTrack?.isEnabled = false
        })
    }
    
    override func showPauseModal(pausedById: String) {
        super.showPauseModal(pausedById: pausedById)
        stopTwilio()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        room?.disconnect()
    }
    
}

extension VideoSessionVC: TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        print("Zach: Connected to room...")
        if room.remoteParticipants.count > 0 {
            remoteParticipant = room.remoteParticipants[0]
            remoteParticipant?.delegate = self
        }
        
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIRemoteParticipant) {
        if remoteParticipant == nil {
            remoteParticipant = participant
            remoteParticipant?.delegate = self
        }
        
    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIRemoteParticipant) {
        if remoteParticipant == participant {
            cleanupRemoteParticipant()
        }
    }
    
    func cleanupRemoteParticipant() {
        if remoteParticipant != nil {
            if (remoteParticipant?.videoTracks.count)! > 0 {
                let remoteVideoTrack = remoteParticipant?.remoteVideoTracks[0].remoteTrack
                remoteVideoTrack?.removeRenderer(videoSessionView.remoteView)
            }
        }
    }
}

extension VideoSessionVC: TVIRemoteParticipantDelegate, TVICameraCapturerDelegate {
    func subscribed(to videoTrack: TVIRemoteVideoTrack, publication: TVIRemoteVideoTrackPublication, for participant: TVIRemoteParticipant) {
        
        if remoteParticipant == participant {
            videoTrack.addRenderer(videoSessionView.remoteView)
        }
    }
    
    func unsubscribed(from videoTrack: TVIRemoteVideoTrack, publication: TVIRemoteVideoTrackPublication, for participant: TVIRemoteParticipant) {
        if remoteParticipant == participant {
            videoTrack.removeRenderer(videoSessionView.remoteView)
        }
    }
    
}


