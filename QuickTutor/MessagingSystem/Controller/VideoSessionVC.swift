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

class VideoSessionVC: UIViewController {
    
    let tokenUrl = "http://api.tidycoder.com/token"
    var accessToken = ""
    var room: TVIRoom?
    var camera: TVICameraCapturer?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var remoteParticipant: TVIRemoteParticipant?
    var endSessionModal: EndSessionModal?
    var pauseSessionModal: PauseSessionModal?
    var partnerId: String?
    var sessionId: String?
    var session: Session?
    var sessionLengthInSeconds: Double?
    let socket = SocketClient.shared.socket!
    
    var remoteView: TVIVideoView = {
        let view = TVIVideoView()
        view.contentMode = .scaleAspectFill
        view.shouldMirror = true
        return view
    }()
    
    let previewView: TVIVideoView = {
        let view = TVIVideoView()
        view.contentMode = .scaleAspectFill
        view.shouldMirror = true
        return view
    }()
    
    let previewBorderView: UIView = {
        let view = UIView()
        view.layer.borderColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple.cgColor : Colors.tutorBlue.cgColor
        view.layer.borderWidth = 3
        return view
    }()
    
    lazy var sessionNavBar: SessionNavBar = {
        let bar = SessionNavBar()
        bar.timeLabel.delegate = self
        return bar
    }()
    
    let statusBarCover: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.learnerPurple
        return view
    }()
    
    let pauseSessionButton: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "pauseSessionButton"), for: .normal)
        return button
    }()
    
    let endSessionButton: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFill
        button.setImage(#imageLiteral(resourceName: "endSessionButton"), for: .normal)
        return button
    }()
    
    func setupViews() {
        setupMainView()
        setupRemoteView()
        setupPreviewView()
        setupPreviewBorderView()
        setupNavBar()
        setupPauseSessionButton()
        setupEndSessionButton()
    }
    
    func setupMainView() {
        view.backgroundColor = .black
    }
    
    func setupNavBar() {
        view.addSubview(sessionNavBar)
        sessionNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 70)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: sessionNavBar.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupRemoteView() {
        view.addSubview(remoteView)
        remoteView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupPreviewView() {
        view.addSubview(previewView)
        previewView.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 3, paddingBottom: 3, paddingRight: 0, width: 150, height: 150 * (16 / 9) - 30)
    }
    
    func setupPreviewBorderView() {
        view.insertSubview(previewBorderView, belowSubview: previewBorderView)
        previewBorderView.anchor(top: previewView.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: previewView.rightAnchor, paddingTop: -3, paddingLeft: 0, paddingBottom: 0, paddingRight: -3, width: 0, height: 0)
    }
    
    func setupPauseSessionButton() {
        view.addSubview(pauseSessionButton)
        pauseSessionButton.anchor(top: sessionNavBar.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 35, height: 35)
        pauseSessionButton.addTarget(self, action: #selector(pauseSession), for: .touchUpInside)
    }
    
    func setupEndSessionButton() {
        view.addSubview(endSessionButton)
        endSessionButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 15, width: 97, height: 35)
        endSessionButton.addTarget(self, action: #selector(showEndModal), for: .touchUpInside)
    }
    
    @objc func showEndModal() {
        endSessionModal = EndSessionModal(frame: .zero)
        endSessionModal?.delegate = self
        endSessionModal?.show()
    }
    
    @objc func pauseSession() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        socket.emit(SocketEvents.pauseSession, ["pausedBy": uid, "roomKey": sessionId!])
    }
    
    @objc func showPauseModal(pausedById: String) {
        room?.localParticipant?.localVideoTracks.forEach({ (publication) in
            publication.localTrack?.isEnabled = false
        })
        room?.localParticipant?.localAudioTracks.forEach({ (publication) in
            publication.localTrack?.isEnabled = false
        })
        guard let uid = Auth.auth().currentUser?.uid else { return }
        sessionNavBar.timeLabel.timer?.invalidate()
        pauseSessionModal?.delegate = self
        DataService.shared.getUserOfOppositeTypeWithId(partnerId ?? "") { user in
            guard let username = user?.username else { return }
            self.pauseSessionModal = PauseSessionModal(frame: .zero)
            if pausedById == uid {
                self.pauseSessionModal?.pausedByCurrentUser()
            }
            self.pauseSessionModal?.partnerUsername = username
            self.pauseSessionModal?.delegate = self
            self.pauseSessionModal?.pausedById = pausedById
            self.pauseSessionModal?.show()
        }
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
            self.sessionLengthInSeconds = session.endTime - session.startTime
            print("Session lasts", self.sessionLengthInSeconds, "seconds.")
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
    
    func observeSessionEvents() {
        socket.on(SocketEvents.pauseSession) { data, _ in
            print("Printing data:", data)
            guard let dict = data[0] as? [String: Any] else {
                return
            }
            guard let pausedById = dict["pausedBy"] as? String else { return }
            self.showPauseModal(pausedById: pausedById)
            self.sessionNavBar.timeLabel.timer?.invalidate()
            self.sessionNavBar.timeLabel.timer = nil
        }
        
        socket.on(SocketEvents.unpauseSession) { _, _ in
            self.pauseSessionModal?.dismiss()
            self.sessionNavBar.timeLabel.startTimer()
            self.resumeSession()
        }
        
        socket.on(SocketEvents.endSession) { _, _ in
            self.showEndSession()
        }
        
    }
    
    func resumeSession() {
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
            localVideoTrack!.addRenderer(previewView)
            
            // We will flip camera on tap.
            DispatchQueue.main.sync {
                let tap = UITapGestureRecognizer(target: self, action: #selector(VideoSessionVC.flipCamera))
                self.previewView.addGestureRecognizer(tap)
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
        setupViews()
        removeStartData()
        fetchToken()
        observeSessionEvents()
        loadSession()
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
                remoteVideoTrack?.removeRenderer(remoteView)
            }
        }
    }
}

extension VideoSessionVC: TVIRemoteParticipantDelegate, TVICameraCapturerDelegate {
    func subscribed(to videoTrack: TVIRemoteVideoTrack, publication: TVIRemoteVideoTrackPublication, for participant: TVIRemoteParticipant) {
        
        if remoteParticipant == participant {
            videoTrack.addRenderer(remoteView)
        }
    }
    
    func unsubscribed(from videoTrack: TVIRemoteVideoTrack, publication: TVIRemoteVideoTrackPublication, for participant: TVIRemoteParticipant) {
        if remoteParticipant == participant {
            videoTrack.removeRenderer(remoteView)
        }
    }
    
}

extension VideoSessionVC: PauseSessionModalDelegate {
    func unpauseSession() {
        socket.emit(SocketEvents.unpauseSession, ["roomKey": sessionId!])
    }
}

extension VideoSessionVC: EndSessionModalDelegate {
    func endSession() {
        socket.emit(SocketEvents.endSession, ["roomKey": sessionId!])
    }
}

extension VideoSessionVC: CountdownTimerDelegate {
    func didUpdateTime(_ time: Int) {
        guard let length = sessionLengthInSeconds else { return }
        if time == Int(length) {
            print("Time's up")
        }
    }
}
