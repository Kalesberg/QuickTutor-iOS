//
//  QTStartQuickCallViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 5/16/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SocketIO
import FirebaseAuth
import AVFoundation
import FirebaseDatabase

class QTStartQuickCallViewController: UIViewController, QTStartQuickCallModalNavigation {

    // MARK: - Properties
    var sessionId: String!
    var sessionType: QTSessionType!
    var initiatorId: String!
    var startType: QTSessionStartType?
    var parentNavController: UINavigationController?
    
    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(true), .forceWebsockets(true)])
    var socket: SocketIOClient!
    var audioPlayer: AVPlayer?
    var vibrationTimer: Timer?
    
    var partnerId: String?
    var partner: User?
    var session: Session?
    var partnerUsername: String?
    
    var addPaymentModal: AddPaymentModal?
    var quickCallModal: QTQuickCallModal?
    
    static var controller: QTStartQuickCallViewController {
        return QTStartQuickCallViewController(nibName: String(describing: QTStartQuickCallViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .clear
        self.view.isOpaque = false
        
        setupSocket()
        setupObservers()
        
        #if targetEnvironment(simulator)
        // for sim only
        #else
        guard checkPermissions() else { return }
        #endif
        NotificationManager.shared.disableAllNotifications()
        
        if sessionType == .online || sessionType == .quickCalls {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        showQuickCallModal()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        socket.disconnect()
        NotificationManager.shared.enableAllNotifcations()
        
        if sessionType == .online || sessionType == .quickCalls {
            audioPlayer?.pause()
            audioPlayer = nil
        } else {
            vibrationTimer?.invalidate()
        }
    }
    
    // MARK: - Functions
    func showQuickCallModal() {
        quickCallModal = QTQuickCallModal.view
        
        // Get the session information.
        DataService.shared.getSessionById(sessionId) { (session) in
            self.session = session
            
            // Get the partner name.
            self.partnerId = self.session?.partnerId()
            if let partnerId = self.partnerId {
                UserFetchService.shared.getUserOfOppositeTypeWithId(partnerId, completion: { user in
                    self.partner = user
                    self.partnerUsername = user?.formattedName
                    
                    if let partnerName = self.partnerUsername,
                        let profilePictureUrl = user?.profilePicUrl,
                        let subject = self.session?.subject,
                        let price = self.session?.price {
                        
                        self.quickCallModal?.setData(initiatorId: self.initiatorId,
                                                     partnerName: partnerName,
                                                     partnerProfilePicture: profilePictureUrl,
                                                     subject: subject,
                                                     price: price)
                    }
                })
            }
        }
        
        quickCallModal?.didHangUpButtonClicked = {
            self.socket.emit(SocketEvents.cancelSession, ["roomKey": self.sessionId])
        }
        quickCallModal?.didPickUpButtonClicked = {
            // Quick call request requires that users have payment method, so doesn't need to check
            self.removeStartData()
            let data = ["roomKey": self.sessionId!, "sessionId": self.sessionId!, "sessionType": (self.session?.type)!]
            print(data)
            self.socket.emit(SocketEvents.manualStartAccetped, data)
        }
        quickCallModal?.initiatorId = initiatorId
        
        quickCallModal?.show()
    }
    
    func setupObservers() {
        socket.on(SocketEvents.manualStartAccetped) { _, _ in
            self.quickCallModal?.dismiss()
            self.dismiss(animated: true, completion: {
                let vc = QTVideoSessionViewController.controller
                vc.sessionId = self.sessionId
                vc.sessionType = self.sessionType
                self.parentNavController?.delegate = nil
                self.parentNavController?.pushViewController(vc, animated: true)
            })
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
            self.quickCallModal?.dismiss()
            self.dismiss(animated: false, completion: {})
        }
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid, let partnerId = partnerId else { return }
        Database.database().reference().child("sessionStarts").child(uid).child(sessionId).removeValue()
        Database.database().reference().child("sessionStarts").child(partnerId).child(sessionId).removeValue()
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
            guard let sessionType = sessionType else {
                return false
            }
            let message = sessionType == .online ? "sessions" : "call"
            let alert = UIAlertController(title: "Camera Required", message: "Camera access is required for video \(message).", preferredStyle: .alert)
            
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
            guard let sessionType = sessionType else {
                return false
            }
            let message = sessionType == .online ? "sessions" : "call"
            let alert = UIAlertController(title: "Microphone Required", message: "Microphone access is required for video \(message)", preferredStyle: .alert)
            
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
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let isInitiator = initiatorId == uid
        let resource = isInitiator ? "phone-ring" : "qtRingtone"
        let ext = isInitiator ? "mp3" : "aiff"
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

extension QTStartQuickCallViewController: CustomModalDelegate {
    func handleConfirm() {
        NotificationCenter.default.post(name: Notifications.showSessionCardManager.name, object: nil, userInfo: nil)
    }
}

protocol QTStartQuickCallModalNavigation {
    func goToVideoSessionViewController(sessionId: String, sessionType: QTSessionType)
}

extension QTStartQuickCallModalNavigation {
    func goToVideoSessionViewController(sessionId: String, sessionType: QTSessionType) {
        let vc = QTVideoSessionViewController.controller
        vc.sessionId = sessionId
        vc.sessionType = sessionType
        navigationController.pushViewController(vc, animated: true)
    }
}
