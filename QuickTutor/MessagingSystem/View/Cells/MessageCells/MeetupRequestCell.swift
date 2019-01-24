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
    func sessionRequestCellShouldRequestSession(cell: SessionRequestCell)
    func sessionRequestCell(cell: SessionRequestCell, shouldCancel session: SessionRequest)
    func sessionRequestCell(cell: SessionRequestCell, shouldAddToCalendar session: SessionRequest)
    func updateAfterCellButtonPress(indexPath: [IndexPath]?)
}

class SessionRequestCell: UserMessageCell {
    var sessionRequest: SessionRequest?
    var delegate: SessionRequestCellDelegate?
    var indexPath: [IndexPath]?

    let titleLabel: UILabel = {
        let label = UILabel()
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
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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

    let sessionTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(12)
        label.numberOfLines = 0
        return label
    }()

    let buttonView = SessionRequestCellButtonView()

    var priceLabelWidthAnchor: NSLayoutConstraint?

    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        getSessionRequestWithId(message.sessionRequestId!)
        userMessage = message
    }

    func getSessionRequestWithId(_ id: String) {
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
        print("Loaded.")
        guard let subject = sessionRequest?.subject, let price = sessionRequest?.price, let date = sessionRequest?.formattedDate(), let startTime = sessionRequest?.formattedStartTime(), let endTime = sessionRequest?.formattedEndTime(), let type = sessionRequest?.type else { return }
        subjectLabel.text = subject
        priceLabel.text = "$\(price)0"
        sessionTypeLabel.text = type == "online" ? "Online" : "In-Person"
        dateTimeLabel.text = "\(date) \n\(startTime) - \(endTime)"
        setStatusLabel()
        if let constant = priceLabel.text?.estimateFrameForFontSize(12).width {
            priceLabelWidthAnchor = priceLabel.widthAnchor.constraint(equalToConstant: constant + 15)
            priceLabelWidthAnchor?.isActive = true
            layoutIfNeeded()
        }
        guard let id = Auth.auth().currentUser?.uid else { return }
        if userMessage?.senderId != id && sessionRequest?.status == "pending" {
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
        let startDate = NSDate(timeIntervalSince1970: TimeInterval(session.startTime!))
        let endDate = NSDate(timeIntervalSince1970: TimeInterval(session.endTime!))
        let predicate = eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        for singleEvent in existingEvents {
            if singleEvent.title == "QuickTutor session: \(session.subject ?? "")" && singleEvent.startDate == startDate as Date && singleEvent.endDate == endDate as Date {
                return true
            }
        }
        return false
    }

    func updateAsAccepted() {
        buttonView.removeAllButtonActions()

        titleBackground.backgroundColor = Colors.green
        titleLabel.text = "Request Accepted"
        updateButtonViewAsAccepted()

        if eventAlreadyExists(session: sessionRequest) {
            buttonView.removeAllButtonActions()
            buttonView.setupAsAccepted(eventAlreadyAdded: true)
        } else {
            buttonView.setupAsAccepted(eventAlreadyAdded: false)
            buttonView.setButtonActions(#selector(SessionRequestCell.addToCalendar), target: self)
        }
    }

    func updateAsDeclined() {
        buttonView.removeAllButtonActions()

        titleBackground.backgroundColor = Colors.qtRed
        titleLabel.text = "Request Declined"
        dimContent()
        buttonView.setupAsDeclined()

        if AccountService.shared.currentUserType == .learner {
            buttonView.setButtonActions(#selector(SessionRequestCell.requestSession), target: self)
        }
    }

    func updateAsPending() {
        buttonView.removeAllButtonActions()

        titleBackground.backgroundColor = Colors.purple
        titleLabel.text = "Request Pending"
        buttonView.setupAsPending()

        if AccountService.shared.currentUserType == .learner {
            buttonView.setButtonActions(#selector(SessionRequestCell.cancelSession), target: self)
        }
    }

    func updateAsCancelled() {
        buttonView.removeAllButtonActions()

        titleBackground.backgroundColor = Colors.grayText
        titleLabel.text = "Request Cancelled"
        buttonView.setupAsCancelled()
        dimContent()
        buttonView.setupAsCancelled()

        if AccountService.shared.currentUserType == .learner {
            buttonView.setButtonActions(#selector(SessionRequestCell.requestSession), target: self)
        }
    }
    
    func updateAsExpired() {
        buttonView.removeAllButtonActions()
        
        titleBackground.backgroundColor = Colors.grayText
        titleLabel.text = "Request Expired"
        buttonView.setupAsExpired()
        dimContent()
        buttonView.setupAsExpired()
        
        if AccountService.shared.currentUserType == .learner {
            buttonView.setButtonActions(#selector(SessionRequestCell.requestSession), target: self)
        }
    }

    func updateButtonViewAsAccepted() {
        buttonView.removeAllButtonActions()

        if eventAlreadyExists(session: sessionRequest) {
            buttonView.removeAllButtonActions()
            buttonView.setupAsAccepted(eventAlreadyAdded: true)
        } else {
            buttonView.setupAsAccepted(eventAlreadyAdded: false)
            buttonView.setButtonActions(#selector(SessionRequestCell.addToCalendar), target: self)
        }
    }

    func updateAsCompleted() {
        buttonView.removeAllButtonActions()
        titleBackground.backgroundColor = Colors.green
        titleLabel.text = "Session Complete"
        buttonView.setupAsSingleButton()
        buttonView.setButtonTitles("Completed")
        buttonView.setButtonTitleColors(Colors.grayText)
        dimContent()
    }

    func dimContent() {
        let amount: CGFloat = 40
        subjectLabel.textColor = UIColor.white.darker(by: amount)
        dateTimeLabel.textColor = UIColor.white.darker(by: amount)
        priceLabel.textColor = UIColor.white.darker(by: amount)
        priceLabel.backgroundColor = Colors.navBarGreen.darker(by: 30)
        sessionTypeLabel.textColor = UIColor.white.darker(by: amount)
    }

    func resetDim() {
        subjectLabel.textColor = .white
        dateTimeLabel.textColor = .white
        priceLabel.textColor = .white
        priceLabel.backgroundColor = Colors.navBarGreen
        sessionTypeLabel.textColor = .white
    }

    override func setupViews() {
        super.setupViews()
        setupMainView()
        setupTitleLabel()
        setupTitleBackground()
        setupSubjectLabel()
        setupDateTimeLabel()
        setupPriceLabel()
        setupSessionTypeLabel()
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

    func setupSessionTypeLabel() {
        addSubview(sessionTypeLabel)
        sessionTypeLabel.anchor(top: dateTimeLabel.bottomAnchor, left: bubbleView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 140, height: 10)
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
        buttonView.setupAsAccepted(eventAlreadyAdded: false)
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
        layer.borderColor = Colors.gray.cgColor
        layer.borderWidth = 2
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

    func setupAsAccepted(eventAlreadyAdded: Bool) {
        setupAsSingleButton()
        setButtonTitleColors(Colors.navBarGreen)
        setButtonTitles(eventAlreadyAdded ? "Event Added to Calendar" : "Add to Calendar")
    }

    func setupAsDeclined() {
        if AccountService.shared.currentUserType == .learner {
            setupAsSingleButton()
            setButtonTitleColors(Colors.navBarGreen)
            setButtonTitles("Request a new session")
        } else {
            setupAsSingleButton()
            setButtonTitleColors(Colors.grayText)
            setButtonTitles("You declined this session")
        }
    }

    func setupAsReceived() {
        setupAsDoubleButton()
        setButtonTitleColors(Colors.qtRed, Colors.navBarGreen)
        setButtonTitles("Decline", "Accept")
    }

    func setupAsPending() {
        setupAsSingleButton()
        setButtonTitleColors(Colors.grayText)
        setButtonTitles("Cancel request")
    }

    func setupAsCancelled() {
        if AccountService.shared.currentUserType == .learner {
            setupAsSingleButton()
            setButtonTitleColors(Colors.navBarGreen)
            setButtonTitles("Request a new session")
        } else {
            setupAsSingleButton()
            setButtonTitleColors(Colors.grayText)
            setButtonTitles("This session was cancelled")
        }
    }
    
    func setupAsExpired() {
        if AccountService.shared.currentUserType == .learner {
            setupAsSingleButton()
            setButtonTitleColors(Colors.navBarGreen)
            setButtonTitles("Request a new session")
        } else {
            setupAsSingleButton()
            setButtonTitleColors(Colors.grayText)
            setButtonTitles("This session expired")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
