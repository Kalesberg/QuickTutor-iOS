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

enum QTAnimatorStyle {
    case presenting, dismissing
}

class QTQuickCallDialogAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var animationStyle: QTAnimatorStyle?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let animationStyle = animationStyle else { return }
        
        if .presenting == animationStyle {
            if let toVC = transitionContext.viewController(forKey: .to) as? QTStartQuickCallViewController {
                containerView.addSubview(toVC.view)
                toVC.view.frame = containerView.frame
                if let contentView = toVC.view.subviews.last {
                    contentView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                        contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: { completed in
                        transitionContext.completeTransition(completed)
                    })
                }
            }
        } else {
            if let fromVC = transitionContext.viewController(forKey: .from) {
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                    containerView.alpha = 0
                }, completion: { completed in
                    fromVC.view.removeFromSuperview()
                    transitionContext.completeTransition(completed)
                })
            }
        }
    }
}

class QTStartQuickCallViewController: QTSessionBaseViewController, QTStartQuickCallModalNavigation {
    
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var hangUpButton: QTCustomButton!
    @IBOutlet weak var pickUpButton: QTCustomButton!
    
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
    
    static var controller: QTStartQuickCallViewController {
        return QTStartQuickCallViewController(nibName: String(describing: QTStartQuickCallViewController.self), bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        transitioningDelegate = self
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        transitioningDelegate = self
        modalPresentationStyle = .overCurrentContext
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupSocket()
        setupObservers()
        
        #if targetEnvironment(simulator)
        // for sim only
        #else
        checkPermissions()
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
        
        if let initiatorId = initiatorId {
            pickUpButton.isHidden = AccountService.shared.currentUser.uid == initiatorId
        }
        
        avatarImageView.superview?.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 4)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        
        // Activate pickUpButton after get session info.
        pickUpButton.isEnabled = false
        pickUpButton.alpha = 0.5
        
        // Get the session information.
        DataService.shared.getSessionById(sessionId) { (session) in
            self.session = session
            // Activate pickUpButton
            self.pickUpButton.isEnabled = true
            self.pickUpButton.alpha = 1.0
            
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
                        
                        self.setData(initiatorId: self.initiatorId,
                                     partnerName: partnerName,
                                     partnerProfilePicture: profilePictureUrl,
                                     subject: subject,
                                     price: price)
                    }
                })
            }
        }
        
        animateZoomInOut()
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
    
    private func animateZoomInOut() {
        UIView.animate(withDuration: 1.5, animations: {
            self.avatarImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 1.5, animations: {
                self.avatarImageView.transform = .identity
            }, completion: { _ in
                self.animateZoomInOut()
            })
        })
    }
    
    private func animateRotate(_ sender: UIView?, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2) {
            sender?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        UIView.animate(withDuration: 0.2, delay: 0.15, options: .curveEaseIn, animations: {
            sender?.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
        }, completion: { _ in
            completion?()
        })
    }
    
    // MARK: - Actions
    @IBAction func onHangUpButtonClicked(_ sender: Any) {
        animateRotate(sender as? UIView)
        socket.emit(SocketEvents.cancelSession, ["roomKey": sessionId])
        socket.disconnect()
        self.removeStartData()
    self.navigationController?.popToViewController(QTRequestQuickCallViewController.controller, animated: false)
    }
    
    @IBAction func onPickUpButtonClicked(_ sender: Any) {
        guard let session = session else { return }
        
        animateRotate(sender as? UIView)
        removeStartData()
        let data = ["roomKey": sessionId, "sessionId": sessionId, "sessionType": session.type]
        socket.emit(SocketEvents.manualStartAccetped, data)
    }
    
    // MARK: - Functions
    private func setData(initiatorId: String,
                         partnerName: String,
                         partnerProfilePicture: URL,
                         subject: String,
                         price: Double) {
        usernameLabel.text = partnerName
        if initiatorId == AccountService.shared.currentUser.uid {
            reasonLabel.text = "\(subject.capitalized) for \(price.currencyFormat(precision: 2, divider: 1))"
        } else {
            reasonLabel.text = "is calling you for help \nwith \(subject.capitalized)..."
        }
        
        avatarImageView.sd_setImage(with: partnerProfilePicture)
    }
    
    func setupObservers() {
        socket.on(SocketEvents.manualStartAccetped) { _, _ in
            self.dismiss(animated: true, completion: {
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
            self.dismiss(animated: false, completion: {})
        }
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid, let partnerId = partnerId else { return }
        Database.database().reference().child("sessionStarts").child(uid).child(sessionId).removeValue()
        Database.database().reference().child("sessionStarts").child(partnerId).child(sessionId).removeValue()
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
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
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
        let resource = isInitiator ? "phone-ring" : "quickcalls_ringtone"
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

extension QTStartQuickCallViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = QTQuickCallDialogAnimator()
        animator.animationStyle = .presenting
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = QTQuickCallDialogAnimator()
        animator.animationStyle = .dismissing
        
        return animator
    }
}
