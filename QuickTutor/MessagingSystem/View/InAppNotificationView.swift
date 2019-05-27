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
    
    var pushNotification: PushNotification?
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSemiBoldSize(14)
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(12)
        label.textAlignment = .left
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.numberOfLines = 2
        label.text = "Do you have time for a session?"
        return label
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
        
        let accountType: UserType  = pushNotification?.receiverAccountType == "learner" ? .tutor : .learner
        
        if let partnerId = pushNotification?.partnerId() {
            UserFetchService.shared.getUserWithId(partnerId, type: accountType) { (user) in
                guard let user = user else { return }
                self.profileImageView.sd_setImage(with: user.profilePicUrl, placeholderImage: nil)
            }
        }
        
        titleLabel.text = title
        guard let message = alertData["body"] as? String, !message.isEmpty else { return }
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
        if pushNotification?.category == .message {
            guard NotificationManager.shared.messageNotificationsEnabled else { return false }
        }
        guard NotificationManager.shared.disabledNotificationForUid != pushNotification?.partnerId() else { return false}
        return true
    }
    
    private func setupInitialPosition() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(self)
        self.anchor(top: nil, left: window.leftAnchor, bottom: nil, right: window.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 86)
        customTopAnchor = self.topAnchor.constraint(equalTo: window.topAnchor, constant: -100)
        customTopAnchor?.isActive = true
    }
    
    private func animateOntoScreen() {
        let deltaY = UIApplication.shared.statusBarFrame.height + 100
        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.transform = CGAffineTransform(translationX: 0, y: deltaY)
        }.startAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
        setupContainerView()
        setupTitleLabel()
        setupMessageLabel()
        setupImagePreviewView()
        setupTapRecognizer()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newBackground
        layer.cornerRadius = 5
        addShadow()
    }
    
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
    }
    
    func setupContainerView() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
    
    func setupTitleLabel() {
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
    }
    
    func setupMessageLabel() {
        containerView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func setupImagePreviewView() {
        addSubview(imagePreviewView)
        imagePreviewView.snp.makeConstraints { make in
            make.edges.equalTo(profileImageView.snp.edges)
        }
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
        let deltaY = UIApplication.shared.statusBarFrame.height + 100
        UIViewPropertyAnimator(duration: 0.25, curve: .easeIn) {
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
