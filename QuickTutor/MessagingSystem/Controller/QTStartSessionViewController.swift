//
//  QTStartSessionViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 3/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import SocketIO
import AVFoundation

enum QTSessionType: String {
    case online = "online"
    case inPersion = "in-person"
}

enum QTSessionStartType: String {
    case automatic
    case manual
}

class QTStartSessionViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet weak var cancelButton: DimmableButton!
    @IBOutlet weak var acceptButton: DimmableButton!
    
    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(true), .forceWebsockets(true)])
    var socket: SocketIOClient!
    var startType: QTSessionStartType?
    var session: Session?
    var partnerId: String?
    var partner: User?
    var partnerUsername: String?
    let addPaymentModal = AddPaymentModal()
    var meetupConfirmed = false
    
    var audioPlayer: AVPlayer?
    
    static var controller: QTStartSessionViewController {
        return QTStartSessionViewController(nibName: String(describing: QTStartSessionViewController.self), bundle: nil)
    }
    
    // MARK: - Parameters
    var initiatorId: String?
    var sessionId: String!
    var sessionType: QTSessionType!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupSocket()
        if sessionType == .online {
            setupObservers()
        }
        updateUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if targetEnvironment(simulator)
        // for sim only
        #else
        guard checkPermissions() else { return }
        #endif
        NotificationManager.shared.disableAllNotifications()
        
        if sessionType == .online {
            playRingingSound()
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem, queue: .main) { _ in
                self.audioPlayer?.seek(to: CMTime.zero)
                self.audioPlayer?.play()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        socket.disconnect()
        NotificationManager.shared.enableAllNotifcations()
        
        if sessionType == .online {
            audioPlayer?.pause()
            audioPlayer = nil
        }
    }
    
    // MARK: - Actions
    @IBAction func onCancelButtonClicked(_ sender: Any) {
        guard let id = sessionId else { return }
        socket.emit(SocketEvents.cancelSession, ["roomKey": id])
    }
    
    @IBAction func onAcceptButtonClicked(_ sender: Any) {
        currentUserHasPayment { (hasPayment) in
            guard hasPayment else { return }
            self.removeStartData()
            let data = ["roomKey": self.sessionId!, "sessionId": self.sessionId!, "sessionType": (self.session?.type)!]
            print(data)
            self.socket.emit(SocketEvents.manualStartAccetped, data)
        }
    }
    
    // MARK: - Functions
    func setupObservers() {
        socket.on(SocketEvents.manualStartAccetped) { _, _ in
            let vc = QTVideoSessionViewController.controller
            vc.sessionId = self.sessionId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setupSocket() {
        socket = manager.defaultSocket
        socket.connect()
        guard let id = sessionId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        socket.on(clientEvent: .connect) { _, _ in
            let joinData = ["roomKey": id, "uid": uid]
            self.socket.emit("joinRoom", joinData)
        }
        
        socket.on(SocketEvents.cancelSession) { _, _ in
            print("should cancel session")
            self.socket.disconnect()
            self.removeStartData()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    func updateUI() {
        guard let initiatorId = initiatorId else {
            return
        }
        
        // Update the status label.
        if AccountService.shared.currentUser.uid == initiatorId {
            // If I've requested to start this session
            statusLabel.text = sessionType == .online ?
                "Calling..." : "Starting session..."
            
            acceptButton.isHidden = true
        } else {
            // If a partner has requested to start this session
            statusLabel.text = sessionType == .online ?
                "Wants to start a video session" : "Would like to meet up"
            
            acceptButton.isHidden = false
        }
        
        cancelButton.layer.cornerRadius = 3
        cancelButton.clipsToBounds = true
        acceptButton.layer.cornerRadius = 3
        cancelButton.clipsToBounds = true
        
        // Get the session information.
        DataService.shared.getSessionById(sessionId) { (session) in
            self.session = session
            
            // Get the partner name.
            self.partnerId = self.session?.partnerId()
            if let partnerId = self.partnerId {
                DataService.shared.getUserOfOppositeTypeWithId(partnerId, completion: { user in
                    self.partner = user
                    self.partnerUsername = user?.formattedName
                    // Set the partner name.
                    self.userNameLabel.text = user?.formattedName
                    
                    // Set the partner avatar.
                    self.avatarImageView.sd_setImage(with: user?.profilePicUrl)
                })
            }
            
            // Get duration and hourly rate.
            self.hourlyRateLabel.text = self.getDurationAndHourlyRate(session: session)
            
            // Set the subject.
            self.subjectLabel.text = session.subject
        }
    }
    
    func getDurationAndHourlyRate(session: Session?) -> String? {
        guard let session = session else { return nil}
        let lengthInSeconds = session.endTime - session.startTime
        let lengthInMinutes = Int(lengthInSeconds / 60)
        return "\(Int(lengthInMinutes)) \(lengthInMinutes == 1 ? "Min" : "Mins"), $\(Int(session.price))/hr"
    }
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid, let sessionId = session?.id, let partnerId = partnerId else { return }
        Database.database().reference().child("sessionStarts").child(uid).child(sessionId).removeValue()
        Database.database().reference().child("sessionStarts").child(partnerId).child(sessionId).removeValue()
    }
    
    func currentUserHasPayment(completion: @escaping (Bool) -> Void) {
        guard AccountService.shared.currentUserType == .learner else {
            completion(true)
            return
        }
        
        guard CurrentUser.shared.learner.hasPayment else {
            print("Needs card")
            completion(false)
            self.onCancelButtonClicked(self.cancelButton)
            self.addPaymentModal.show()
            return
        }
        
        completion(true)
    }
    
    func checkPermissions() -> Bool {
        if checkCameraAccess() && checkMicrophoneAccess() {
            return true
        } else {
            return false
        }
    }
    
    func checkCameraAccess() -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            return true
        } else {
            let alert = UIAlertController(title: "Camera Required", message: "Camera access is required for video sessions.", preferredStyle: .alert)
            
            // Add "OK" Button to alert, pressing it will bring you to the settings app
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            // Show the alert with animation
            present(alert, animated: true)
            return false
        }
    }
    
    func checkMicrophoneAccess() -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            return true
        } else {
            let alert = UIAlertController(title: "Microphone Required", message: "Microphone access is required for video sessions", preferredStyle: .alert)
            
            // Add "OK" Button to alert, pressing it will bring you to the settings app
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            // Show the alert with animation
            present(alert, animated: true)
            return false
        }
    }
    
    func playRingingSound() {
        guard let uid = Auth.auth().currentUser?.uid, initiatorId == uid else { return }
        guard let url = Bundle.main.url(forResource: "phone-ring", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.moviePlayback, options: AVAudioSession.CategoryOptions.mixWithOthers)
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
