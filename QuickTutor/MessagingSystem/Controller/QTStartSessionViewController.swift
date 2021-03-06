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
    case inPerson = "in-person"
    case quickCalls = "quick-calls"
}

enum QTSessionStartType: String {
    case automatic
    case manual
}

class QTStartSessionViewController: QTSessionBaseViewController {

    // MARK: - Properties
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(true), .forceWebsockets(true)])
    var socket: SocketIOClient!
    var startType: QTSessionStartType?
    var session: Session?
    var partnerId: String?
    var partner: User?
    var partnerUsername: String?
    var addPaymentModal: AddPaymentModal?
    var meetupConfirmed = false
    
    var audioPlayer: AVPlayer?
    var vibrationTimer: Timer?
    
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
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupSocket()
        setupObservers()
        if sessionType == QTSessionType.online {
        #if targetEnvironment(simulator)
        // for sim only
        #else
            checkPermissions()
        #endif
        }
        NotificationManager.shared.disableAllNotifications()
        
        if sessionType == .online {
            playRingingSound()
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem, queue: .main) { _ in
                self.audioPlayer?.seek(to: CMTime.zero)
                self.audioPlayer?.play()
            }
        } else {
            vibrationTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        socket.disconnect()
        NotificationManager.shared.enableAllNotifcations()
        
        if sessionType == .online {
            audioPlayer?.pause()
            audioPlayer = nil
        } else {
            vibrationTimer?.invalidate()
        }
    }
    
    // MARK: - Actions
    @IBAction func onCancelButtonClicked(_ sender: Any) {
        guard let id = sessionId else { return }
        socket.emit(SocketEvents.cancelSession, ["roomKey": id])
    }
    
    @IBAction func onAcceptButtonClicked(_ sender: Any) {
        guard let _ = session else { return }
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
            if self.sessionType == .online {
                // Get the duration of the session.
                guard let session = self.session else {
                    return
                }
                let duration = session.endTime - session.startTime
                // Update the session start time and end time.
                self.updateSessionStartTime(sessionId: self.sessionId, duration: duration)
                
                let vc = QTVideoSessionViewController.controller
                vc.sessionId = self.sessionId
                vc.sessionType = self.sessionType
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = QTConfirmMeetUpViewController.controller
                vc.sessionId = self.sessionId
                self.navigationController?.pushViewController(vc, animated: true)
            }
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
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    func updateUI() {
        guard let initiatorId = initiatorId else {
            return
        }
        
        // Update the status label.
        if AccountService.shared.currentUser.uid == initiatorId {
            // If I've requested to start this session
            statusLabel.text = (sessionType == .online) ?
                "Calling..." : "Starting session..."
            
            acceptButton.isHidden = true
        } else {
            // If a partner has requested to start this session
            if let sessionType = sessionType {
                switch sessionType {
                case .online:
                    statusLabel.text = "Wants to start a video session"
                case .inPerson:
                    statusLabel.text = "Would like to meet up"
                default:
                    break
                }
            }
            
            acceptButton.isHidden = false
        }
        
        cancelButton.layer.cornerRadius = 3
        cancelButton.clipsToBounds = true
        cancelButton.setupTargets()
        acceptButton.layer.cornerRadius = 3
        acceptButton.clipsToBounds = true
        acceptButton.setupTargets()
        
        // Activate accept button after get session info.
        acceptButton.isEnabled = false
        acceptButton.alpha = 0.5
        
        // Get the session information.
        DataService.shared.getSessionById(sessionId) { (session) in
            self.session = session
            
            // Activate accept button
            self.acceptButton.isEnabled = true
            self.acceptButton.alpha = 1.0
            
            // Get the partner name.
            self.partnerId = self.session?.partnerId()
            if let partnerId = self.partnerId {
                UserFetchService.shared.getUserOfOppositeTypeWithId(partnerId, completion: { user in
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
        let lengthInMinutes = Int(session.duration / 60)
        return "\(Int(lengthInMinutes)) \(lengthInMinutes == 1 ? "Min" : "Mins"), $\(String(format: "%.2f", session.sessionPrice))"
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
            self.onCancelButtonClicked(self.cancelButton)
            addPaymentModal = AddPaymentModal()
            addPaymentModal?.delegate = self
            addPaymentModal?.show()
            completion(false)
            return
        }
        
        completion(true)
    }
    
    func checkPermissions() {
        checkCameraAccess()
        checkMicrophoneAccess()
    }
    
    func checkCameraAccess() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized { return }
        
        AVCaptureDevice.requestAccess(for: .video) { isGranted in
            if !isGranted {
                guard let sessionType = self.sessionType else { return }
                
                let message = sessionType == .online ? "sessions" : "call"
                let alert = UIAlertController(title: "Camera Required", message: "Camera access is required for video \(message).", preferredStyle: .alert)
                
                // Add "OK" Button to alert, pressing it will bring you to the settings app
                alert.addAction(UIAlertAction(title: "Allow Access", style: .default) { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                // Show the alert with animation
                self.present(alert, animated: true)
            }
        }
    }
    
    func checkMicrophoneAccess() {
        if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized { return }
        
        AVCaptureDevice.requestAccess(for: .audio) { isGranted in
            if isGranted { return }
            
            guard let sessionType = self.sessionType else { return }
            let message = sessionType == .online ? "sessions" : "call"
            let alert = UIAlertController(title: "Microphone Required", message: "Microphone access is required for video \(message)", preferredStyle: .alert)
            
            // Add "OK" Button to alert, pressing it will bring you to the settings app
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            })
            // Show the alert with animation
            self.present(alert, animated: true)
        }
    }
    
    func playRingingSound() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let isInitiator = initiatorId == uid
        let resource = isInitiator ? "phone-ring" : "session_ringtone"
        let ext = "mp3"
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext) else { return }

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

extension QTStartSessionViewController: CustomModalDelegate {
    func handleConfirm() {
        NotificationCenter.default.post(name: Notifications.showSessionCardManager.name, object: nil, userInfo: nil)
    }
}
