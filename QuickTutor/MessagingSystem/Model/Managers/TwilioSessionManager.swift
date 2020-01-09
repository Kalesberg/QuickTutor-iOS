//
//  TwilioSessionManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import TwilioVideo

protocol TwilioSessionManagerDelegate {
    func twilioSessionManagerDidReceiveVideoData(_ twilioSessionManager: TwilioSessionManager)
}

class TwilioSessionManager: NSObject {
    let tokenUrl = "http://35.231.239.116"
    var sessionId: String!
    var accessToken = ""
    var room: TVIRoom?
    var camera: TVICameraCapturer?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var remoteParticipant: TVIRemoteParticipant?
    var delegate: TwilioSessionManagerDelegate?

    var remoteView: TVIVideoView!
    var previewView: TVIVideoView!

    func fetchAccessToken() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        URLSession.shared.dataTask(with: URL(string: "http://35.231.239.116/twilio/token/\(uid)")!) { data, _, error in
            
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
            builder.roomName = self.sessionId
        }

        // Connect to the Room using the options we provided.
        room = TwilioVideo.connect(with: connectOptions, delegate: self)
    }
    
    func disconnect() {
        room?.disconnect()
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
                let tap = UITapGestureRecognizer(target: self, action: #selector(TwilioSessionManager.flipCamera))
                tap.numberOfTapsRequired = 1
                self.previewView.addGestureRecognizer(tap)
            }
        }
    }

    @objc func flipCamera() {
        print("tapping")
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

    func stop() {
        room?.localParticipant?.localVideoTracks.forEach({ publication in
            publication.localTrack?.isEnabled = false
        })
        room?.localParticipant?.localAudioTracks.forEach({ publication in
            publication.localTrack?.isEnabled = false
        })
    }

    private override init() {}

    init(previewView: TVIVideoView, remoteView: TVIVideoView, sessionId: String) {
        super.init()
        self.previewView = previewView
        self.remoteView = remoteView
        self.remoteView.delegate = self
        self.sessionId = sessionId
        fetchAccessToken()
    }
}

extension TwilioSessionManager: TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        print("Zach: Connected to room...")
        if room.remoteParticipants.count > 0 {
            remoteParticipant = room.remoteParticipants[0]
            remoteParticipant?.delegate = self
        }
        resume()
        
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIRemoteParticipant) {
        remoteParticipant = participant
        remoteParticipant?.delegate = self
        if (remoteParticipant?.videoTracks.count)! > 0 {
            let remoteVideoTrack = remoteParticipant?.remoteVideoTracks[0].remoteTrack
            remoteVideoTrack?.addRenderer(remoteView)
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
    
    func resume() {
        room?.localParticipant?.localVideoTracks.forEach({ (publication) in
            publication.localTrack?.isEnabled = true
        })
        room?.localParticipant?.localAudioTracks.forEach({ (publication) in
            publication.localTrack?.isEnabled = true
        })
    }
    
    func listenForVideoStream() {
        
    }
    
    
}

extension TwilioSessionManager: TVIRemoteParticipantDelegate, TVICameraCapturerDelegate {
    func subscribed(to videoTrack: TVIRemoteVideoTrack, publication: TVIRemoteVideoTrackPublication, for participant: TVIRemoteParticipant) {
        
        if remoteParticipant == participant {
            videoTrack.addRenderer(remoteView)
        }
    }
    
    func cameraCapturer(_ capturer: TVICameraCapturer, didStartWith source: TVICameraCaptureSource) {
        self.previewView.shouldMirror = (source == .frontCamera)
    }
    
    func unsubscribed(from videoTrack: TVIRemoteVideoTrack, publication: TVIRemoteVideoTrackPublication, for participant: TVIRemoteParticipant) {
        if remoteParticipant == participant {
            videoTrack.removeRenderer(remoteView)
        }
    }

}

extension TwilioSessionManager: TVIVideoViewDelegate {
    func videoViewDidReceiveData(_ view: TVIVideoView) {
        delegate?.twilioSessionManagerDidReceiveVideoData(self)
    }
}
