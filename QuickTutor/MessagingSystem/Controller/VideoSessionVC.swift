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
    
    let sessionNavBar: SessionNavBar = {
        let bar = SessionNavBar()
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
    
    let cameraFeedView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    func setupViews() {
        setupMainView()
        setupRemoteView()
        setupPreviewView()
        setupNavBar()
        setupPauseSessionButton()
        setupEndSessionButton()
        setupCameraFeedView()
    }
    
    func setupMainView() {
        view.backgroundColor = .black
    }
    
    func setupNavBar()  {
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
        previewView.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150 * (16/9) - 30)
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
        endSessionModal?.show()
    }
    
    @objc func pauseSession() {
        guard let uid = Auth.auth().currentUser?.uid, let id = partnerId else { return }
        Database.database().reference().child("sessionEvents").child(uid).child("pausedBy").setValue(uid)
        Database.database().reference().child("sessionEvents").child(id).child("pausedBy").setValue(uid)
    }
    
    @objc func showPauseModal(pausedById: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        sessionNavBar.timeLabel.timer?.invalidate()
        pauseSessionModal?.delegate = self
        DataService.shared.getUserOfOppositeTypeWithId(partnerId ?? "") { (user) in
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
    
    func setupCameraFeedView() {
        view.addSubview(cameraFeedView)
        cameraFeedView.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150 * (16/9) - 30)
    }
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessionStarts").child(uid).removeValue()
    }
    
    func loadSession() {
        guard let id = sessionId else { return }
        DataService.shared.getSessionById(id) { (session) in
            self.partnerId = session.partnerId()
        }
    }
    
    func fetchToken() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        URLSession.shared.dataTask(with: URL(string: "http://api.tidycoder.com/token/\(uid)")!) { (data, respoonse, error) in
            guard error == nil, let data = data else {
                print(error.debugDescription)
                return
            }
            var json: [String: Any]?
            do {
                json =  try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
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
        self.prepareLocalMedia()

        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = TVIConnectOptions.init(token: accessToken) { (builder) in
            
            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [TVILocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [TVILocalVideoTrack]()
            
            // Use the preferred encoding parameters
            if let encodingParameters = Settings.shared.getEncodingParameters() {
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessionEvents").child(uid).observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else { return }
            if let pausedById = value["pausedBy"] as? String {
                self.showPauseModal(pausedById: pausedById)
                self.sessionNavBar.timeLabel.timer?.invalidate()
                self.sessionNavBar.timeLabel.timer = nil
            } else {
                self.pauseSessionModal?.dismiss()
            }
            
            Database.database().reference().child("sessionEvents").child(uid).observe(.childRemoved, with: { (snapshot) in
                    self.pauseSessionModal?.dismiss()
                    self.sessionNavBar.timeLabel.startTimer()
            })

        }
    }
    
    func startPreview() {
        
        // Preview our local camera track in the local video preview view.
        camera = TVICameraCapturer(source: .frontCamera, delegate: self)
        localVideoTrack = TVILocalVideoTrack.init(capturer: camera!, enabled: true, constraints: nil, name: "Camera")
        if (localVideoTrack == nil) {
            print("Failed to create video track")
        } else {
            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(self.previewView)
            
            // We will flip camera on tap.
            let tap = UITapGestureRecognizer(target: self, action: #selector(VideoSessionVC.flipCamera))
            self.previewView.addGestureRecognizer(tap)
        }
    }
    
    @objc func flipCamera() {
        if (self.camera?.source == .frontCamera) {
            self.camera?.selectSource(.backCameraWide)
        } else {
            self.camera?.selectSource(.frontCamera)
        }
    }
    
    func prepareLocalMedia() {
        // Create an audio track.
        if (localAudioTrack == nil) {
            localAudioTrack = TVILocalAudioTrack.init(options: nil, enabled: true, name: "Microphone")
        }
        
        // Create a video track which captures from the camera.
        if (localVideoTrack == nil) {
            self.startPreview()
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
}

extension VideoSessionVC: TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        print("Zach: Connected to room...")
        if (room.remoteParticipants.count > 0) {
            self.remoteParticipant = room.remoteParticipants[0]
            self.remoteParticipant?.delegate = self
        }
        
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == nil) {
            self.remoteParticipant = participant
            self.remoteParticipant?.delegate = self
        }

    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == participant) {
            cleanupRemoteParticipant()
        }
    }
    
    func cleanupRemoteParticipant() {
        if ((self.remoteParticipant) != nil) {
            if ((self.remoteParticipant?.videoTracks.count)! > 0) {
                let remoteVideoTrack = self.remoteParticipant?.remoteVideoTracks[0].remoteTrack
                remoteVideoTrack?.removeRenderer(self.remoteView)
            }
        }
    }
}

extension VideoSessionVC: TVICameraCapturerDelegate {
    
}

extension VideoSessionVC: TVIRemoteParticipantDelegate {
    func subscribed(to videoTrack: TVIRemoteVideoTrack, publication: TVIRemoteVideoTrackPublication, for participant: TVIRemoteParticipant) {
        
        if (self.remoteParticipant == participant) {
            videoTrack.addRenderer(self.remoteView)
        }
    }
    
    func unsubscribed(from videoTrack: TVIRemoteVideoTrack, publication: TVIRemoteVideoTrackPublication, for participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == participant) {
            videoTrack.removeRenderer(self.remoteView)
        }
    }
    
}

extension VideoSessionVC: PauseSessionModalDelegate {
    func unpauseSession() {
        guard let uid = Auth.auth().currentUser?.uid, let id = partnerId else { return }
        Database.database().reference().child("sessionEvents").child(uid).child("pausedBy").removeValue()
        Database.database().reference().child("sessionEvents").child(id).child("pausedBy").removeValue()
    }
}

class Settings: NSObject {
    
    var audioCodec: TVIAudioCodec?
    var videoCodec: TVIVideoCodec?
    
    var maxAudioBitrate = UInt()
    var maxVideoBitrate = UInt()
    
    func getEncodingParameters() -> TVIEncodingParameters?  {
        if maxAudioBitrate == 0 && maxVideoBitrate == 0 {
            return nil;
        } else {
            return TVIEncodingParameters(audioBitrate: maxAudioBitrate, videoBitrate: maxVideoBitrate)
        }
    }
    
    private override init() {
        // Can't initialize a singleton
    }
    
    // MARK: Shared Instance
    static let shared = Settings()
}

