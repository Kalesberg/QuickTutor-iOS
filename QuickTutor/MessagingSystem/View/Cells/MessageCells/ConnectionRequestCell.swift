//
//  ConnectionRequestCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/6/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase
import UIKit

class ConnectionRequestCell: UserMessageCell {
    var status: String?
    var connectionRequestId: String?

    let mockBubbleViewBackground: UIView = {
        let view = UIView()
        view.layer.borderColor = Colors.gray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        return view
    }()
    
    var mockBubbleViewHeightAnchor: NSLayoutConstraint?
    
    override var bubbleWidthAnchor: NSLayoutConstraint? {
        return bubbleView.widthAnchor.constraint(equalToConstant: 285)
    }

    let buttonView = SessionRequestCellButtonView()

    override func setupViews() {
        super.setupViews()
        setupMockBubbleViewBackground()
        setupButtonView()
        if #available(iOS 11.0, *) {
            bubbleView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }

    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        userMessage = message
        let textHeight = message.text?.estimateFrameForFontSize(14, extendedWidth: true, width: 285).height ?? 40
        let height = textHeight + 20
        updateMockBubbleViewHeight(height)
        guard let requestId = message.connectionRequestId else { return }
        connectionRequestId = requestId
        loadFromRequest()

    }
    
    override func setupBubbleViewAsSentMessage() {
        super.setupBubbleViewAsSentMessage()
        bubbleView.backgroundColor = .clear
        bubbleView.layer.shadowOpacity = 0
        mockBubbleViewBackground.applyDefaultShadow()
        buttonView.applyDefaultShadow()
    }

    func setupMockBubbleViewBackground() {
        addSubview(mockBubbleViewBackground)
        mockBubbleViewBackground.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        mockBubbleViewHeightAnchor = mockBubbleViewBackground.heightAnchor.constraint(equalToConstant: 40)
        mockBubbleViewHeightAnchor?.isActive = true
        layoutIfNeeded()
        bubbleView.layer.borderWidth = 0
        bubbleView.layer.shadowOpacity = 0
        mockBubbleViewBackground.applyDefaultShadow()
        buttonView.applyDefaultShadow()
    }
    
    func updateMockBubbleViewHeight(_ height: CGFloat) {
        mockBubbleViewHeightAnchor?.constant = height
        layoutIfNeeded()
    }

    func setupForTeacherView() {
        buttonView.isUserInteractionEnabled = true
        buttonView.setRightButtonToPrimaryUI()
        buttonView.setLeftButtonToSecondaryUI()
        buttonView.setupAsDoubleButton()
        buttonView.setButtonTitles("Decline", "Accept")
        buttonView.auxillaryButton.addTarget(self, action: #selector(approveConnectionRequest), for: .touchUpInside)
        buttonView.mainButton.addTarget(self, action: #selector(denyConnectionRequest), for: .touchUpInside)
    }
    
    func setupButtonViewAsAccepted() {
        buttonView.setupAsSingleButton()
        buttonView.isUserInteractionEnabled = false
        buttonView.setButtonTitles("Connection request accepted.")
        buttonView.setLeftButtonToSecondaryUI()
    }
    
    func setupButtonViewAsDeclined() {
        buttonView.setupAsSingleButton()
        buttonView.isUserInteractionEnabled = false
        buttonView.setButtonTitles("Connection request declined.")
        buttonView.setLeftButtonToSecondaryUI()
    }
    
    func setupButtonViewAsPending() {
        buttonView.setupAsSingleButton()
        buttonView.isUserInteractionEnabled = false
        buttonView.setButtonTitles("Connection request pending.")
        buttonView.setLeftButtonToSecondaryUI()
    }
    
    func setupButtonView() {
        addSubview(buttonView)
        buttonView.anchor(top: mockBubbleViewBackground.bottomAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        setupButtonViewAsPending()
    }

    func loadFromRequest() {
        guard let id = connectionRequestId else { return }
        Database.database().reference().child("connectionRequests").child(id).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                return
            }
            guard let status = value["status"] as? String else { return }
            self.status = status
            self.setStatusLabel()
        }
    }

    @objc func approveConnectionRequest() {
        guard let id = connectionRequestId else { return }
        guard let uid = Auth.auth().currentUser?.uid, let receiverId = chatPartner?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        Database.database().reference().child("connectionRequests").child(id).child("status").setValue("accepted")
        let values = ["/\(uid)/\(userTypeString)/\(receiverId)": 1, "/\(receiverId)/\(otherUserTypeString)/\(uid)": 1]
        Database.database().reference().child("connections").updateChildValues(values)
        updateMetaDataConnection()
        setupButtonViewAsAccepted()
        status = "accepted"
        setStatusLabel()
    }

    func updateMetaDataConnection() {
        guard let uid = Auth.auth().currentUser?.uid, let receiverId = chatPartner?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(receiverId).child("connected").setValue(true)
        Database.database().reference().child("conversationMetaData").child(receiverId).child(otherUserTypeString).child(uid).child("connected").setValue(true)
        updateMetaDataForAccepted()
    }
    
    func updateMetaDataForAccepted() {
        guard let partnerId = chatPartner?.uid else { return }
        MessageService.shared.sendInvisibleMessage(text: "Connection request accepted", receiverId: partnerId) { (messageId) in
            
        }
    }

    @objc func denyConnectionRequest() {
        guard let id = connectionRequestId else { return }
        Database.database().reference().child("connectionRequests").child(id).child("status").setValue("declined")
        setupButtonViewAsDeclined()
        status = "declined"
        setStatusLabel()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        guard let partnerId = chatPartner?.uid else { return }
        Database.database().reference().child("conversations").child(uid).child(userTypeString).child(partnerId).removeValue()
        Database.database().reference().child("conversations").child(partnerId).child(otherUserTypeString).child(id).removeValue()
    }

    func setStatusLabel() {
        guard let status = self.status else { return }

        if status == "pending" && AccountService.shared.currentUserType == .tutor {
            setupForTeacherView()
        } else {
            setupButtonViewAsPending()
        }
        switch status {
        case "pending":
            break
        case "declined":
            setupButtonViewAsDeclined()
        case "accepted":
            setupButtonViewAsAccepted()
        case "expired":
            break
//            statusLabel.text = "Connection Request Expired"
        default:
            break
        }
    }
    
}
