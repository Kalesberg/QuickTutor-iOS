//
//  QTConfirmMeetUpViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 3/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Lottie
import AVFoundation
import Firebase
import SocketIO

class QTConfirmMeetUpViewController: QTSessionBaseViewController {

    // MARK: - Properties
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusImageView: QTCustomImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet weak var slidingView: QTCustomView!
    @IBOutlet weak var slidingButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var animationView: LOTAnimationView!
    @IBOutlet weak var waitingLabel: UILabel!
    
    var session: Session?
    var partner: User?
    var startPoint: CGFloat = 0.0
    var endPoint: CGFloat = 0.0
    var placeholderPoint: CGFloat = 0.0
    
    static var controller: QTConfirmMeetUpViewController {
        return QTConfirmMeetUpViewController(nibName: String(describing: QTConfirmMeetUpViewController.self), bundle: nil)
    }
    
    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(true), .forceWebsockets(true)])
    var socket: SocketIOClient!
    var startAccepted = false
    var confirmedByParnter = false
    var confirmedByUser = false
    
    // MARK: - Parameters
    var sessionId: String!
    var partnerId: String!
    
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
        NotificationManager.shared.disableAllNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        socket.disconnect()
        NotificationManager.shared.enableAllNotifcations()
    }
    
    // MARK: - Actions
    @IBAction func onClickCancelButton(_ sender: UIButton) {
        guard let id = sessionId else { return }
        socket.emit(SocketEvents.cancelSession, ["roomKey": id])
    }
    
    @objc
    func handleDidPan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .cancelled, .ended, .failed:
            var location = sender.location(in: slidingView)
            location.x = location.x + sender.velocity(in: slidingView).x
            location.y = location.y + sender.velocity(in: slidingView).y
            moveToNearestCornerTo(location)
            break
        case .began:
            break
        case .changed:
            let location = sender.location(in: slidingView)
            let xPos = location.x
            if startPoint >= xPos {
                slidingButton.center.x = startPoint
                return
            } else if xPos > endPoint {
                slidingButton.center.x = endPoint
                moveToNearestCornerTo(CGPoint(x: endPoint, y: slidingButton.center.y))
                return
            }
            slidingButton.center.x = xPos
            slidingButton.layoutIfNeeded()
            break
        default:
            break
        }
    }
    
    // MARK: - Functions
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
    
    func updateUI() {
        guard let sessionId = sessionId else { return }
        
        startPoint = slidingButton.bounds.size.width / 2 + 2
        endPoint = slidingView.bounds.size.width - slidingButton.bounds.size.width / 2 - 2
        placeholderPoint = slidingView.bounds.size.width / 2
        
        let userType = AccountService.shared.currentUserType == .learner ? "tutor" : "learner"
        waitingLabel.text = "Waiting for your \(userType) to confirm..."
        waitingLabel.isHidden = true
        slidingView.isHidden = false
        animationView.isHidden = true
        
        slidingButton.layer.cornerRadius = 19
        slidingButton.clipsToBounds = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDidPan(sender:)))
        panGesture.minimumNumberOfTouches = 1
        slidingButton.addGestureRecognizer(panGesture)
        
        // Need to activate after get session info.
        slidingButton.isEnabled = false
        slidingButton.alpha = 0.5
        
        // Set the active status of user.
        self.statusImageView.backgroundColor = Colors.gray
        
        // Get the session information.
        DataService.shared.getSessionById(sessionId) { (session) in
            // Activate slidingButton
            self.slidingButton.isEnabled = true
            self.slidingButton.alpha = 1.0
            self.session = session

            // Get the partner name.
            self.partnerId = self.session?.partnerId()
            if let partnerId = self.partnerId {
                // Set the active status of user.
                UserStatusService.shared.getUserStatus(partnerId) { status in
                    self.statusImageView.backgroundColor = status?.status == .online ? Colors.purple : Colors.gray
                }
                
                UserFetchService.shared.getUserOfOppositeTypeWithId(partnerId, completion: { user in
                    self.partner = user
                    // Set the partner name.
                    self.usernameLabel.text = user?.formattedName

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
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    func moveToNearestCornerTo(_ point: CGPoint) {
        if point.x > placeholderPoint {
            UIView.animate(withDuration: 0.2, animations: {
                self.slidingButton.center.x = self.endPoint
                self.slidingButton.layoutIfNeeded()
            }) { (completed) in
                if completed {
                    self.confirmMeetUp()
                }
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.slidingButton.center.x = self.slidingButton.bounds.size.width / 2 + 2
                self.slidingButton.layoutIfNeeded()
            }
        }
    }
    
    func confirmManualStart() {
        removeStartData()
        let data = ["roomKey": sessionId!, "sessionId": sessionId!, "sessionType": (session?.type)!]
        socket.emit(SocketEvents.manualStartAccetped, data)
    }
    
    func setupObservers() {
        socket.on(SocketEvents.meetupConfirmed) { data, _ in
            guard let uid = Auth.auth().currentUser?.uid,
                let value = data.first as? [String: Any],
                let confirmedBy = value["confirmedBy"] as? String else { return }
            
            if confirmedBy == uid {
                self.confirmedByUser = true
            } else {
                self.confirmedByParnter = true
            }
            
            if self.confirmedByUser,
                self.confirmedByParnter {
                self.proceedToSession()
            }
        }        
    }
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid, let sessionId = session?.id, let partnerId = partnerId else { return }
        Database.database().reference().child("sessionStarts").child(uid).child(sessionId).removeValue()
        Database.database().reference().child("sessionStarts").child(partnerId).child(sessionId).removeValue()
    }
    
    func proceedToSession() {
        // Get the duration of the session.
        guard let session = self.session else {
            return
        }
        let duration = session.endTime - session.startTime
        // Update the session start time and end time.
        self.updateSessionStartTime(sessionId: self.sessionId, duration: duration)
        
        let vc = QTInPersonSessionViewController.controller
        vc.sessionId = sessionId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func confirmMeetUp() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        waitingLabel.isHidden = false
        slidingView.isHidden = true
        animationView.isHidden = false
        animationView.animation = "loadingNew"
        animationView.loopAnimation = true
        animationView.play()
        socket.emit(SocketEvents.meetupConfirmed, ["roomKey": sessionId!, "confirmedBy": uid])
    }
}
