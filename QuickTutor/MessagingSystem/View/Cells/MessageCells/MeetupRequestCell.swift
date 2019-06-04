//
//  SessionRequestCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import EventKit
import Firebase
import UIKit

protocol SessionRequestCellDelegate {
    func sessionRequestCellShouldStartSession(cell: SessionRequestCell) -> Bool
    func sessionRequestCellShouldRequestSession(cell: SessionRequestCell)
    func sessionRequestCell(cell: SessionRequestCell, shouldCancel session: SessionRequest)
    func sessionRequestCell(cell: SessionRequestCell, shouldAddToCalendar session: SessionRequest)
    func updateAfterCellButtonPress(indexPath: [IndexPath]?)
}

class SessionRequestCell: UserMessageCell {
    var sessionRequest: SessionRequest?
    var delegate: SessionRequestCellDelegate?
    var indexPath: [IndexPath]?
    
    let mockBubbleViewBackground: UIView = {
        let view = UIView()
        view.layer.borderColor = Colors.gray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(12)
        label.textColor = Colors.purple
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let subjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBlackSize(14)
        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(12)
        label.numberOfLines = 0
        return label
    }()
    
    let sessionTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.grayText
        label.textAlignment = .left
        label.font = Fonts.createSize(12)
        label.numberOfLines = 0
        return label
    }()

    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = Fonts.createSize(12)
        return label
    }()

    let sessionTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = Fonts.createSize(12)
        label.numberOfLines = 0
        return label
    }()

    let buttonView = SessionRequestCellButtonView()
    
    override var bubbleWidthAnchor: NSLayoutConstraint? {
        return bubbleView.widthAnchor.constraint(equalToConstant: 285)
    }

    var priceLabelWidthAnchor: NSLayoutConstraint?
    var sessionTimeLabelWidthAnchor: NSLayoutConstraint?

    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        getSessionRequestWithId(message.sessionRequestId!)
        userMessage = message
    }
    
    override func setupBubbleViewAsSentMessage() {
        super.setupBubbleViewAsSentMessage()
        bubbleView.backgroundColor = .clear
    }

    func getSessionRequestWithId(_ id: String) {
        Database.database().reference().child("sessions").child(id).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let sessionRequest = SessionRequest(data: value)
            if sessionRequest.startTime < Date().timeIntervalSince1970 {
                sessionRequest.status = "expired"
            }
            sessionRequest.id = id
            self.sessionRequest = sessionRequest
            self.loadFromRequest()
            sessionCache[id] = sessionRequest
        }
    }

    func loadFromRequest() {
        updateTextData()
        setStatusLabel()
        updatePriceWidthAnchor()
        updateSessionTimeLabelWidthAnchor()

        guard let id = Auth.auth().currentUser?.uid else { return }
        if userMessage?.senderId != id && sessionRequest?.status == "pending" {
            setupAsTeacherView()
            buttonView.setupAsReceived()
            buttonView.setButtonActions(#selector(SessionRequestCell.declineSessionRequest), #selector(SessionRequestCell.acceptSessionRequest), target: self)
        }
    }
    
    func updateTextData() {
        guard let subject = sessionRequest?.subject, let price = sessionRequest?.price, let date = sessionRequest?.formattedDate(), let startTime = sessionRequest?.formattedStartTime(), let endTime = sessionRequest?.formattedEndTime(), let type = sessionRequest?.type else { return }
        subjectLabel.text = subject
        let realPrice = .learner == AccountService.shared.currentUserType ? (price + 0.3) / 0.971 : price
        let priceString = String(format: "%.2f", realPrice)
        priceLabel.text = "$\(priceString)"
        sessionTypeLabel.text = type == "online" ? "Online" : "In-Person"
        dateLabel.text = "\(date)"
        sessionTimeLabel.text = "\(startTime) - \(endTime)"
    }
    
    func updatePriceWidthAnchor() {
        if let constant = priceLabel.text?.estimateFrameForFontSize(12).width {
            priceLabelWidthAnchor = priceLabel.widthAnchor.constraint(equalToConstant: constant + 30)
            priceLabelWidthAnchor?.isActive = true
            layoutIfNeeded()
        }
    }
    
    func updateSessionTimeLabelWidthAnchor() {
        if let constant = sessionTimeLabel.text?.estimateFrameForFontSize(12).width {
            sessionTimeLabelWidthAnchor?.constant = constant + 4
            layoutIfNeeded()
        }
    }

    func setStatusLabel() {
        guard let status = self.sessionRequest?.status else { return }
        switch status {
        case "pending":
            updateAsPending()
        case "declined":
            updateAsDeclined()
        case "accepted":
            updateAsAccepted()
        case "expired":
            updateAsExpired()
        case "cancelled":
            updateAsCancelled()
        case "completed":
            updateAsCompleted()
        default:
            break
        }
    }

    /*
     MARK: // CHECKING FOR EXISTING EVENT
     */
    func eventAlreadyExists(session: SessionRequest?) -> Bool {
        guard let session = session else { return false }
        let eventStore = EKEventStore()
        let startDate = NSDate(timeIntervalSince1970: TimeInterval(session.startTime))
        let endDate = NSDate(timeIntervalSince1970: TimeInterval(session.endTime))
        let predicate = eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        for singleEvent in existingEvents {
            if singleEvent.title == "QuickTutor session: \(session.subject)" && singleEvent.startDate == startDate as Date && singleEvent.endDate == endDate as Date {
                return true
            }
        }
        return false
    }

    func updateAsAccepted() {
        titleLabel.text = "Accepted"
        updateButtonViewAsAccepted()
    }

    func updateAsDeclined() {
        buttonView.removeAllButtonActions()

        titleLabel.text = "Declined"
        dimContent()
        buttonView.setupAsDeclined()

        if AccountService.shared.currentUserType == .learner {
            buttonView.setButtonActions(#selector(SessionRequestCell.requestSession), target: self)
        }
    }

    func updateAsPending() {
        buttonView.removeAllButtonActions()

        titleLabel.text = "Pending"
        buttonView.setupAsPending()

        if AccountService.shared.currentUserType == .learner {
            buttonView.setButtonActions(#selector(SessionRequestCell.cancelSession), target: self)
        }
    }

    func updateAsCancelled() {
        buttonView.removeAllButtonActions()

        titleLabel.text = "Canceled"
        dimContent()
        buttonView.setupAsCancelled()

        if AccountService.shared.currentUserType == .learner {
            buttonView.setButtonActions(#selector(SessionRequestCell.requestSession), target: self)
        }
    }
    
    func updateAsExpired() {
        buttonView.removeAllButtonActions()
        
        titleLabel.text = "Expired"
        dimContent()
        buttonView.setupAsExpired()
        
        if AccountService.shared.currentUserType == .learner {
            buttonView.setButtonActions(#selector(SessionRequestCell.requestSession), target: self)
        }
    }

    func updateButtonViewAsAccepted() {
        buttonView.removeAllButtonActions()
        buttonView.setupAsAccepted()
        buttonView.setButtonActions(#selector(startSession(_:)), target: self)
    }
    
    @objc func startSession(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid, let sessionRequest = sessionRequest, let id = sessionRequest.id, let delegate = self.delegate else { return }
        
        guard delegate.sessionRequestCellShouldStartSession(cell: self) else {
            return
        }
        
        let value = ["startedBy": uid, "startType": "manual", "sessionType": sessionRequest.type]
        Database.database().reference().child("sessionStarts").child(uid).child(id).setValue(value)
        Database.database().reference().child("sessionStarts").child(sessionRequest.partnerId()).child(id).setValue(value)
    }

    func updateAsCompleted() {
        buttonView.removeAllButtonActions()
        titleLabel.text = "Complete"
        buttonView.setupAsSingleButton()
        buttonView.setButtonTitles("Completed")
        buttonView.setButtonTitleColors(.white)
        buttonView.setLeftButtonToSecondaryUI()
        dimContent()
    }

    func dimContent() {
//        let amount: CGFloat = 40
//        subjectLabel.textColor = UIColor.white.darker(by: amount)
//        dateLabel.textColor = UIColor.white.darker(by: amount)
//        timeLabel.textColor = Colors.gray.darker(by: amount)
//        priceLabel.textColor = UIColor.white.darker(by: amount)
//        sessionTypeLabel.textColor = UIColor.white.darker(by: amount)
    }

    func resetDim() {
        subjectLabel.textColor = .white
        dateLabel.textColor = .white
        timeLabel.textColor = Colors.gray
        priceLabel.textColor = .white
        sessionTypeLabel.textColor = .white
    }

    override func setupViews() {
        super.setupViews()
        setupMainView()
        setupMockBubbleViewBackground()
        setupSubjectLabel()
        setupDateLabel()
        setupSessionTimeLabel()
        setupTitleLabel()
        setupPriceLabel()
        setupSessionTypeLabel()
        setupButtonView()
    }

    func setupMainView() {
        bubbleView.clipsToBounds = true
        bubbleView.layer.cornerRadius = 8
        bubbleView.layer.masksToBounds = true
        bubbleView.backgroundColor = Colors.navBarColor
        bubbleView.layer.borderWidth = 0
    }
    
    func setupMockBubbleViewBackground() {
        addSubview(mockBubbleViewBackground)
        mockBubbleViewBackground.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 85)
        bubbleView.layer.shadowOpacity = 0
        mockBubbleViewBackground.applyDefaultShadow()
        buttonView.applyDefaultShadow()
    }

    func setupSubjectLabel() {
        addSubview(subjectLabel)
        subjectLabel.anchor(top: topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 18)
    }
    
    func setupDateLabel() {
        addSubview(dateLabel)
        dateLabel.anchor(top: subjectLabel.bottomAnchor, left: bubbleView.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 140, height: 12)
    }
    
    func setupSessionTimeLabel() {
        addSubview(sessionTimeLabel)
        sessionTimeLabel.anchor(top: dateLabel.bottomAnchor, left: bubbleView.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 12)
        sessionTimeLabelWidthAnchor = sessionTimeLabel.widthAnchor.constraint(equalToConstant: 125)
        sessionTimeLabelWidthAnchor?.isActive = true
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: sessionTimeLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 100, height: 16)
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: sessionTimeLabel, attribute: .centerY, multiplier: 1, constant: 0))
    }

    func setupPriceLabel() {
        addSubview(priceLabel)
        priceLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 0, height: 18)
    }

    func setupSessionTypeLabel() {
        addSubview(sessionTypeLabel)
        sessionTypeLabel.anchor(top: priceLabel.bottomAnchor, left: nil, bottom: nil, right: bubbleView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 100, height: 14)
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
        buttonView.anchor(top: nil, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
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
        guard let sessionRequestId = self.sessionRequest?.id, sessionRequest?.status == "pending" else { print("return"); return }
        Database.database().reference().child("sessions").child(sessionRequestId).child("status").setValue("accepted")
        sessionCache.removeValue(forKey: sessionRequestId)
        buttonView.setupAsAccepted()
        updateAsAccepted()
        markSessionDataStale()
        delegate?.updateAfterCellButtonPress(indexPath: indexPath)
    }

    @objc func declineSessionRequest() {
        guard let sessionRequestId = self.sessionRequest?.id, sessionRequest?.status == "pending" else { return }
        Database.database().reference().child("sessions").child(sessionRequestId).child("status").setValue("declined")
        sessionCache.removeValue(forKey: sessionRequestId)
        buttonView.setupAsDeclined()
        markSessionDataStale()
        delegate?.updateAfterCellButtonPress(indexPath: indexPath)
    }

    @objc func requestSession() {
        delegate?.sessionRequestCellShouldRequestSession(cell: self)
    }

    @objc func cancelSession() {
        guard let request = sessionRequest else { return }
        delegate?.sessionRequestCell(cell: self, shouldCancel: request)
    }

    @objc func addToCalendar() {
        guard let request = sessionRequest else { return }
        delegate?.sessionRequestCell(cell: self, shouldAddToCalendar: request)
    }

    func markSessionDataStale() {
        guard let uid = Auth.auth().currentUser?.uid, let request = sessionRequest, let id = request.id else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        Database.database().reference().child("userSessions").child(uid)
            .child(userTypeString).child(id).setValue(0)
        Database.database().reference().child("userSessions").child(request.partnerId())
            .child(otherUserTypeString).child(id).setValue(0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetDim()
        buttonView.removeAllButtonActions()
        buttonView.setButtonTitleColors(Colors.grayText)
    }
}

class SessionRequestCellButtonView: UIView {
    lazy var buttons = [leftButton, rightButton]
    lazy var mainButton = leftButton
    lazy var auxillaryButton = rightButton

    let leftButton: DimmableButton = {
        let button = DimmableButton()
        button.layer.cornerRadius = 4
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(12)
        return button
    }()

    let rightButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.navBarColor
        button.layer.cornerRadius = 4
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
        backgroundColor = Colors.newScreenBackground
    }

    func setupRightButton() {
        addSubview(rightButton)
        rightButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 135, height: 0)
        
    }

    func setupLeftButton() {
        addSubview(leftButton)
        leftButton.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        leftButtonWidthAnchor = leftButton.widthAnchor.constraint(equalToConstant: 109.5)
        leftButtonWidthAnchor?.isActive = true
    }

    func setupAsSingleButton() {
        leftButtonWidthAnchor?.constant = 285
        layoutIfNeeded()
    }

    func setupAsDoubleButton() {
        leftButtonWidthAnchor?.constant = 135
        
    }

    func setButtonTitles(_ titles: String...) {
        for x in 0 ..< titles.count {
            buttons[x].setTitle(titles[x], for: .normal)
        }
    }

    func setButtonTitleColors(_ colors: UIColor...) {
        for x in 0 ..< colors.count {
            buttons[x].setTitleColor(colors[x], for: .normal)
        }
    }

    func setButtonActions(_ selectors: Selector..., target: AnyObject) {
        for x in 0 ..< selectors.count {
            buttons[x].addTarget(target, action: selectors[x], for: .touchUpInside)
        }
    }

    func removeAllButtonActions() {
        leftButton.removeTarget(nil, action: nil, for: .allEvents)
        rightButton.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    func reapplyDimming() {
        leftButton.setupTargets()
        rightButton.setupTargets()
    }

    func setupAsAccepted() {
        setupAsSingleButton()
        setButtonTitleColors(.white)
        setLeftButtonToPrimaryUI()
        reapplyDimming()
        setButtonTitles("Start Session")
    }

    func setupAsDeclined() {
        if AccountService.shared.currentUserType == .learner {
            setupAsSingleButton()
            setButtonTitleColors(.white)
            setLeftButtonToPrimaryUI()
            reapplyDimming()
            setButtonTitles("Request a new session")
        } else {
            setupAsSingleButton()
            setButtonTitleColors(.white)
            setLeftButtonToSecondaryUI()
            setButtonTitles("You declined this session")
        }
    }

    func setupAsReceived() {
        setupAsDoubleButton()
        setButtonTitleColors(.white, .white)
        setLeftButtonToSecondaryUI()
        
        rightButton.backgroundColor = Colors.purple
        setButtonTitles("Decline", "Accept")
    }

    func setupAsPending() {
        setupAsSingleButton()
        setButtonTitleColors(.white)
        setLeftButtonToSecondaryUI()
        reapplyDimming()
        setButtonTitles("Cancel request")
    }

    func setupAsCancelled() {
        if AccountService.shared.currentUserType == .learner {
            setupAsSingleButton()
            setButtonTitleColors(.white)
            setLeftButtonToPrimaryUI()
            reapplyDimming()
            setButtonTitles("Request a new session")
        } else {
            setupAsSingleButton()
            setButtonTitleColors(.white)
            setLeftButtonToSecondaryUI()
            setButtonTitles("This session was canceled")
        }
    }
    
    func setupAsExpired() {
        if AccountService.shared.currentUserType == .learner {
            setupAsSingleButton()
            setButtonTitleColors(.white)
            setLeftButtonToPrimaryUI()
            reapplyDimming()
            setButtonTitles("Request a new session")
        } else {
            setupAsSingleButton()
            setButtonTitleColors(.white)
            setLeftButtonToSecondaryUI()
            setButtonTitles("This session expired")
        }
    }
    
    func setLeftButtonToSecondaryUI() {
        leftButton.backgroundColor = Colors.darkBackground
        leftButton.layer.borderWidth = 1
        leftButton.layer.borderColor = Colors.gray.cgColor
    }
    
    func setLeftButtonToPrimaryUI() {
        leftButton.backgroundColor = Colors.purple
        leftButton.layer.borderWidth = 0
    }
    
    func setRightButtonToPrimaryUI() {
        rightButton.backgroundColor = Colors.purple
        rightButton.layer.borderWidth = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
