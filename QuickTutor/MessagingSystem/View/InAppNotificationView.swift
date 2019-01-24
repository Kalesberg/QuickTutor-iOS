//
//  InAppNotificationView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 9/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import UserNotifications

class InAppNotificationView: UIView {
    
    var customTopAnchor: NSLayoutConstraint?
    
    var notification: UNNotification? {
        didSet {
            updateUI()
        }
    }
    
    var pushNotification: PushNotification!
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 22
        iv.clipsToBounds = true
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(14)
        label.textAlignment = .left
        label.textColor = .white
        label.text = "Zach F."
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(12)
        label.textAlignment = .left
        label.textColor = .white
        label.text = "Do you have time for a session?"
        return label
    }()
    
    let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.purple.darker(by: 15)
        view.layer.cornerRadius = 3
        return view
    }()
    
    let imagePreviewView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    func updateUI() {
        guard let notification = notification, let userInfo = notification.request.content.userInfo as? [String: Any], let apsData = userInfo["aps"] as? [String: Any],
            let alertData = apsData["alert"] as? [String: Any],
            let title = alertData["title"] as? String else {
                print("Parsing error")
                return
        }
        
        pushNotification = PushNotification(userInfo: userInfo)
        
        let accountType: UserType  = pushNotification.receiverAccountType == "learner" ? .tutor : .learner
        
        if let partnerId = pushNotification.partnerId() {
            DataService.shared.getUserWithId(partnerId, type: accountType) { (user) in
                guard let user = user else { return }
                self.profileImageView.sd_setImage(with: user.profilePicUrl, placeholderImage: nil)
            }
        }
        
        titleLabel.text = title
        guard let message = alertData["body"] as? String else { return }
        messageLabel.text = message
        addImagePreview()
    }
    
    func show() {
        guard shouldShowNotification() else { return }
        setupInitialPosition()
        animateOntoScreen()
    }
    
    private func shouldShowNotification() -> Bool {
        guard NotificationManager.shared.notificationsEnabled else { return false }
        if pushNotification.category == .message {
            guard NotificationManager.shared.messageNotificationsEnabled else { return false }
        }
        guard NotificationManager.shared.disabledNotificationForUid != pushNotification.partnerId() else { return false}
        return true
    }
    
    private func setupInitialPosition() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(self)
        self.anchor(top: nil, left: window.leftAnchor, bottom: nil, right: window.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 68)
        customTopAnchor = self.topAnchor.constraint(equalTo: window.topAnchor, constant: -75)
        customTopAnchor?.isActive = true
    }
    
    private func animateOntoScreen() {
        let deltaY = UIApplication.shared.statusBarFrame.height + 75
        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.transform = CGAffineTransform(translationX: 0, y: deltaY)
        }.startAnimation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.dismiss()
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func addImagePreview() {
        guard let userInfo = notification?.request.content.userInfo as? [String: Any],
            let apsData = userInfo["aps"] as? [String: Any],
            let attachmentURLAsString = apsData["attachment-url"] as? String,
            let attachmentURL = URL(string: attachmentURLAsString) else {
                return
        }
        imagePreviewView.sd_setImage(with: attachmentURL, completed: nil)
        
    }
    
    func setupTapRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }
    
    @objc func handleTap() {
        guard let notification = notification, let userInfo = notification.request.content.userInfo as? [String: Any] else {
            return
        }
        
        NotificationManager.shared.handleInAppPushNotification(userInfo: userInfo)
    }
    
    func setupViews() {
        setupMainView()
        setupProfileImageView()
        setupTitleLabel()
        setupMessageLabel()
        setupImagePreviewView()
        setupTapRecognizer()
    }
    
    func setupMainView() {
        backgroundColor = Colors.purple
        layer.cornerRadius = 8
        addShadow()
    }
    
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 3
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 12, paddingRight: 0, width: 44, height: 0)
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 40, width: 0, height: 17)
    }
    
    func setupMessageLabel() {
        addSubview(messageLabel)
        messageLabel.anchor(top: titleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 12, paddingRight: 40, width: 0, height: 0)
    }
    
    func setupImagePreviewView() {
        addSubview(imagePreviewView)
        imagePreviewView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 12, paddingRight: 12, width: 44, height: 0)
    }
    
    func setupSwipeRecognizer() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipe.direction = .up
        addGestureRecognizer(swipe)
    }
    
    @objc func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {
        dismiss()
    }
    
    func dismiss() {
        let deltaY = UIApplication.shared.statusBarFrame.height + 75
        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.transform = CGAffineTransform(translationX: 0, y: -deltaY)
        }.startAnimation()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupSwipeRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
