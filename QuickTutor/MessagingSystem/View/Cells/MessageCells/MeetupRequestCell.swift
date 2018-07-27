//
//  SessionRequestCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

protocol SessionRequestCellDelegate {
    func sessionRequestCellShouldRequestSession(cell: SessionRequestCell)
    func sessionRequestCell(cell: SessionRequestCell, shouldCancel session: SessionRequest)
}

class SessionRequestCell: UserMessageCell {
    
    var sessionRequest: SessionRequest?
    var delegate: SessionRequestCellDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "You requested a session"
        label.font = Fonts.createBoldSize(16)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let titleBackground: UIView = {
        let view = UIView()
        if #available(iOS 11.0, *) {
            view.layer.cornerRadius = 4
            view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        }
        return view
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(14)
        return label
    }()
    
    let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(12)
        label.numberOfLines = 0
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = Colors.green
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.font = Fonts.createSize(12)
        label.clipsToBounds = true
        return label
    }()
    
    let buttonView = SessionRequestCellButtonView()
    
    var priceLabelWidthAnchor: NSLayoutConstraint?
    
    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        getSessionRequestWithId(message.sessionRequestId!)
        self.userMessage = message
    }
    
    func getSessionRequestWithId(_ id: String) {
//        guard sessionCache[id] == nil else {
//            print("this one has already be loaded")
//            sessionRequest = sessionCache[id]
//            loadFromRequest()
//            return
//        }
        Database.database().reference().child("sessions").child(id).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let sessionRequest = SessionRequest(data: value)
            sessionRequest.id = id
            self.sessionRequest = sessionRequest
            self.loadFromRequest()
            sessionCache[id] = sessionRequest
        }
    }
    
    func loadFromRequest() {
        guard let subject = sessionRequest?.subject, let price = sessionRequest?.price, let date = sessionRequest?.formattedDate(), let startTime = sessionRequest?.formattedStartTime(), let endTime = sessionRequest?.formattedEndTime() else { return }
        subjectLabel.text = subject
        priceLabel.text = "$\(price)0"
        dateTimeLabel.text = "\(date) \n\(startTime) - \(endTime)"
        setStatusLabel()
        if let constant = priceLabel.text?.estimateFrameForFontSize(12).width {
            priceLabelWidthAnchor = priceLabel.widthAnchor.constraint(equalToConstant: constant + 15)
            priceLabelWidthAnchor?.isActive = true
            self.layoutIfNeeded()
        }
        guard let id = Auth.auth().currentUser?.uid else { return }
        if self.userMessage?.senderId != id && sessionRequest?.status == "pending" {
            setupAsTeacherView()
            buttonView.setupAsReceived()
            buttonView.setButtonActions(#selector(SessionRequestCell.declineSessionRequest), #selector(SessionRequestCell.acceptSessionRequest), target: self)
        }
    }
    
    func setStatusLabel() {
        guard let status = self.sessionRequest?.status else { return }
        switch status {
        case "pending":
            updateAsPending()
            buttonView.setupAsPending()
            buttonView.setButtonActions(#selector(SessionRequestCell.cancelSession), target: self)
        case "declined":
            updateAsDenied()
            buttonView.setupAsDenied()
            buttonView.setButtonActions(#selector(SessionRequestCell.requestSession), target: self)
        case "accepted":
            updateAsAccepted()
            buttonView.setupAsAccepted()
        case "expired":
            updateAsCancelled()
            buttonView.setupAsCancelled()
        case "cancelled":
            updateAsCancelled()
            buttonView.setupAsCancelled()
            buttonView.setButtonActions(#selector(SessionRequestCell.requestSession), target: self)
        default:
            break
        }
    }
    
    func updateAsAccepted() {
        titleBackground.backgroundColor = Colors.green
        titleLabel.text = "Request Accepted"
    }
    
    func updateAsDenied() {
        titleBackground.backgroundColor = Colors.qtRed
        titleLabel.text = "Request Denied"
        dimContent()
    }
    
    func updateAsPending() {
        titleBackground.backgroundColor = Colors.learnerPurple
        titleLabel.text = "Request Pending"
    }
    
    func updateAsCancelled() {
        titleBackground.backgroundColor = Colors.grayText
        titleLabel.text = "Request Cancelled"
        dimContent()
    }
    
    func dimContent() {
        let amount: CGFloat = 40
        subjectLabel.textColor = UIColor.white.darker(by: amount)
        dateTimeLabel.textColor = UIColor.white.darker(by: amount)
        priceLabel.textColor = UIColor.white.darker(by: amount)
        priceLabel.backgroundColor = Colors.navBarGreen.darker(by: 30)
    }
    
    func resetDim() {
        subjectLabel.textColor = .white
        dateTimeLabel.textColor = .white
        priceLabel.textColor = .white
        priceLabel.backgroundColor = Colors.navBarGreen
    }
    
    override func setupViews() {
        super.setupViews()
        setupMainView()
        setupTitleLabel()
        setupTitleBackground()
        setupSubjectLabel()
        setupDateTimeLabel()
        setupPriceLabel()
        setupButtonView()
    }
    
    func setupMainView() {
        bubbleView.clipsToBounds = true
        bubbleView.layer.cornerRadius = 8
        bubbleView.layer.masksToBounds = true
        bubbleView.backgroundColor = Colors.navBarColor
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 35)
    }
    
    func setupTitleBackground() {
        insertSubview(titleBackground, belowSubview: titleLabel)
        titleBackground.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 35)
    }
    
    func setupSubjectLabel() {
        addSubview(subjectLabel)
        subjectLabel.anchor(top: titleLabel.bottomAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 18)
    }
    
    func setupDateTimeLabel() {
        addSubview(dateTimeLabel)
        dateTimeLabel.anchor(top: subjectLabel.bottomAnchor, left: bubbleView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 140, height: 40)
    }
    
    func setupPriceLabel() {
        addSubview(priceLabel)
        priceLabel.anchor(top: titleLabel.bottomAnchor, left: nil, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 26, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 20)
    }
    
    func setupAsTeacherView() {
        updateStatusAndTitleLabels()
//        rearrangeInfoLabels()
    }
    
    func updateStatusAndTitleLabels() {
        titleLabel.text = "Request Received"
        guard sessionRequest?.status == "pending" else { return }
    }
    
    func rearrangeInfoLabels() {
        priceLabel.removeConstraints(priceLabel.constraints)
        priceLabel.anchor(top: nil, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 50, paddingRight: 30, width: 0, height: 20)
        
//        statusBackground.removeConstraints(statusBackground.constraints)
//        statusBackground.anchor(top: nil, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    func setupButtonView() {
        addSubview(buttonView)
        buttonView.anchor(top: nil, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
        buttonView.setButtonTitles("Decline", "Accept")
        buttonView.setButtonTitleColors(Colors.qtRed, Colors.navBarGreen)
        buttonView.setupAsSingleButton()
    }
    
    @objc func handleButtonAction(sender: UIButton) {
        guard let sessionRequestId = self.sessionRequest?.id, sessionRequest?.status == "pending" else { return }
        let valueToSet = sender.tag == 0 ? "accepted" : "declined"
        Database.database().reference().child("sessions").child(sessionRequestId).child("status").setValue(valueToSet)
        sessionCache.removeValue(forKey: sessionRequestId)
    }
    
    @objc func acceptSessionRequest() {
        guard let sessionRequestId = self.sessionRequest?.id, sessionRequest?.status == "pending" else { return }
        Database.database().reference().child("sessions").child(sessionRequestId).child("status").setValue("accepted")
        sessionCache.removeValue(forKey: sessionRequestId)
        buttonView.setupAsAccepted()
        updateAsAccepted()
    }
    
    @objc func declineSessionRequest() {
        guard let sessionRequestId = self.sessionRequest?.id, sessionRequest?.status == "pending" else { return }
        Database.database().reference().child("sessions").child(sessionRequestId).child("status").setValue("declined")
        sessionCache.removeValue(forKey: sessionRequestId)
        buttonView.setupAsDenied()
        updateAsDenied()
    }
    
    @objc func requestSession() {
		print("Request.")
        delegate?.sessionRequestCellShouldRequestSession(cell: self)
    }
    
    @objc func cancelSession() {
		print("Cancel")
        guard let request = sessionRequest else { return }
        delegate?.sessionRequestCell(cell: self, shouldCancel: request)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetDim()
        buttonView.removeAllButtonActions()
    }
    
}

class SessionRequestCellButtonView: UIView {
    
    lazy var buttons = [leftButton, rightButton]
    lazy var mainButton = leftButton
    lazy var auxillaryButton = rightButton
    
    let leftButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.navBarColor
        button.titleLabel?.font = Fonts.createBoldSize(12)
        return button
    }()
    
    let rightButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.navBarColor
        button.titleLabel?.font = Fonts.createBoldSize(12)
        return button
    }()
    
    var leftButtonWidthAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupMainView()
        setupRightButton()
        setupLeftButton()
    }
    
    func setupMainView() {
        backgroundColor = .black
        clipsToBounds = true
        if #available(iOS 11.0, *) {
            layer.cornerRadius = 4
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    func setupRightButton() {
        addSubview(rightButton)
        rightButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 109.5, height: 0)
    }
    
    func setupLeftButton() {
        addSubview(leftButton)
        leftButton.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        leftButtonWidthAnchor = leftButton.widthAnchor.constraint(equalToConstant: 109.5)
        leftButtonWidthAnchor?.isActive = true
    }
    
    func setupAsSingleButton() {
        leftButtonWidthAnchor?.constant = 220
        layoutIfNeeded()
    }
    
    func setupAsDoubleButton() {
        leftButtonWidthAnchor?.constant = 109.5
    }
    
    func setButtonTitles(_ titles: String...) {
        for x in 0..<titles.count {
            buttons[x].setTitle(titles[x], for: .normal)
        }
    }
    
    func setButtonTitleColors(_ colors: UIColor...) {
        for x in 0..<colors.count {
            buttons[x].setTitleColor(colors[x], for: .normal)
        }
    }
    
    func setButtonActions(_ selectors: Selector..., target: AnyObject) {
        for x in 0..<selectors.count {
            buttons[x].addTarget(target, action: selectors[x], for: .touchUpInside)
        }
    }
    
    func removeAllButtonActions() {
        leftButton.removeTarget(nil, action: nil, for: .allEvents)
        rightButton.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    func setupAsAccepted() {
        setupAsSingleButton()
        setButtonTitleColors(Colors.navBarGreen)
        setButtonTitles("Add to Calender")
    }
    
    func setupAsDenied() {
        setupAsSingleButton()
        setButtonTitleColors(Colors.navBarGreen)
        setButtonTitles("Request a new session?")
    }
    
    func setupAsReceived() {
        setupAsDoubleButton()
        setButtonTitleColors(Colors.qtRed, Colors.navBarGreen)
        setButtonTitles("Decline", "Accept" )
    }
    
    func setupAsPending() {
        setupAsSingleButton()
        setButtonTitleColors(Colors.grayText)
        setButtonTitles("Cancel request")
    }
    
    func setupAsCancelled() {
        setupAsSingleButton()
        setButtonTitleColors(Colors.navBarGreen)
        setButtonTitles("Request a new session?")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
