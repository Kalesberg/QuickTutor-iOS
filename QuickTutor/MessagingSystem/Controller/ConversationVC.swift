
//
//  ConversationVC.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class ConversationVC: UICollectionViewController, CustomNavBarDisplayer {
    
    var messagingManagerDelegate: ConversationManagerDelegate?
    var conversationManager = ConversationManager()
    var metaData: ConversationMetaData?
    
    var receiverId: String!
    var chatPartner: User!
    var connectionRequestAccepted = false
    var conversationRead = false
    var shouldRequestSession = false
    var canSendMessages = true
    var headerHeight = 30
    
    // MARK: Layout Views -
    var navBar: ZFNavBar = {
        let bar = ZFNavBar()
        bar.leftAccessoryView.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        bar.rightAccessoryView.setImage(#imageLiteral(resourceName: "fileReportFlag"), for: .normal)
        return bar
    }()
    
    let messagesCollection: ConversationCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = ConversationCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return cv
    }()
    
    var emptyCellBackground: EmptyConversationBackground = {
        let background = EmptyConversationBackground()
        return background
    }()
    
    lazy var imageMessageAnimator: ImageMessageAnimator = {
        let animator = ImageMessageAnimator(parentViewController: self)
        animator.delegate = self
        return animator
    }()
    
    lazy var imageMessageSender: ImageMessageSender = {
        let sender = ImageMessageSender(parentViewController: self)
        return sender
    }()
    
    let typingIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.notificationRed
        return view
    }()
    
    var actionSheet: FileReportActionsheet?
    let studentKeyboardAccessory = StudentKeyboardAccessory()
    let teacherKeyboardAccessory = TeacherKeyboardAccessory()
    
    var cancelSessionModal: CancelSessionModal?
    var cancelSessionIndex: IndexPath?
    var typingIndicatorHeightAnchor: NSLayoutConstraint?
    var typingIndicatorBottomAnchor: NSLayoutConstraint?
    
    let tutorial = MessagingSystemTutorial()
    
    func setupViews() {
        setupNavBar()
        setupMainView()
        setupTypingIdicatorView()
        setupMessagesCollection()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        edgesForExtendedLayout = []
        studentKeyboardAccessory.delegate = self
        teacherKeyboardAccessory.delegate = self
        studentKeyboardAccessory.messageTextview.delegate = self
        teacherKeyboardAccessory.messageTextview.delegate = self
    }
    
    func setupTypingIdicatorView() {
        view.addSubview(typingIndicatorView)
        typingIndicatorView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        typingIndicatorHeightAnchor = typingIndicatorView.heightAnchor.constraint(equalToConstant: 0)
        typingIndicatorHeightAnchor?.isActive = true
        
        typingIndicatorBottomAnchor = typingIndicatorView.bottomAnchor.constraint(equalTo: view.getBottomAnchor(), constant: 50)
        typingIndicatorBottomAnchor?.isActive = true
    }
    
    private func setupMessagesCollection() {
        messagesCollection.dataSource = self
        messagesCollection.delegate = self
        collectionView = messagesCollection
        collectionView?.anchor(top: navBar.bottomAnchor, left: view.leftAnchor, bottom: typingIndicatorView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupEmptyBackground() {
        view.addSubview(emptyCellBackground)
        emptyCellBackground.anchor(top: navBar.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 60, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 300)
    }
    
    private func setupNavBar() {
        addNavBar()
        setupTitleView()
    }
    
    private func setupTitleView() {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        let titleView = CustomTitleView(frame: frame)
        if let partner = chatPartner {
            titleView.updateUI(user: partner)
        }
        
        navBar.addSubview(titleView)
        titleView.anchor(top: navBar.titleView.topAnchor, left: nil, bottom: navBar.titleView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.addConstraint(NSLayoutConstraint(item: titleView, attribute: .centerX, relatedBy: .equal, toItem: navBar, attribute: .centerX, multiplier: 1, constant: 0))
        guard let profilePicUrl = chatPartner?.profilePicUrl else { return }
        titleView.imageView.imageView.sd_setImage(with: profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
    }

    
    func handleLeftViewTapped() {
        pop()
    }
    
    func handleRightViewTapped() {
        showReportSheet()
    }
    
    @objc func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showReportSheet() {
        becomeFirstResponder()
        resignFirstResponder()

		let firstName = chatPartner.formattedName.split(separator: " ")[0]
		if #available(iOS 11.0, *) {
			actionSheet = FileReportActionsheet(bottomLayoutMargin: view.safeAreaInsets.bottom, name: String(firstName))
        } else {
			actionSheet = FileReportActionsheet(bottomLayoutMargin: 0, name: String(firstName))
        }
        actionSheet?.partnerId = chatPartner.uid
        actionSheet?.show()
    }
    
    func enterConnectionRequestMode() {
        navBar.rightAccessoryView.isHidden = true
        studentKeyboardAccessory.showQuickChatView()
        setupEmptyBackground()
        setActionViewUsable(false)
        headerHeight = 0
        self.messagesCollection.collectionViewLayout.invalidateLayout()
    }
    
    func exitConnectionRequestMode() {
        navBar.rightAccessoryView.isHidden = false
        studentKeyboardAccessory.hideQuickChatView()
        emptyCellBackground.removeFromSuperview()
    }
    
    func setActionViewUsable(_ result: Bool) {
        if let keyboardAccessory = inputAccessoryView as? StudentKeyboardAccessory {
            keyboardAccessory.actionButton.isEnabled = result
        }
    }
    
    @objc func paginateMessages() {
        conversationManager.loadPreviousMessagesByTimeStamp(limit: 50, completion: {_ in })
    }
    
    // MARK: Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        scrollToBottom(animated: false)
        setupKeyboardObservers()
        studentKeyboardAccessory.chatView.delegate = self
        listenForSessionUpdates()
        
        imageMessageSender.receiverId = receiverId
        DataService.shared.getConversationMetaDataForUid(receiverId) { (metaDataIn) in
            self.conversationManager.chatPartnerId = self.receiverId
            self.conversationManager.delegate = self
            self.conversationManager.metaData = metaDataIn
            self.metaData = metaDataIn
            self.conversationManager.setup()
            if self.metaData?.lastMessageId != nil {
                self.exitConnectionRequestMode()
            } else {
                self.enterConnectionRequestMode()
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        if shouldRequestSession {
            handleSessionRequest()
        }
        
        tutorial.showIfNeeded()
        conversationManager.readReceiptManager?.markConversationRead()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setMessageTextViewCoverHidden(_ result: Bool) {
        guard let keyboardAccessory = inputAccessoryView as? StudentKeyboardAccessory else { return }
        result ? keyboardAccessory.hideTextViewCover() : keyboardAccessory.showTextViewCover()
    }
    
    func listenForSessionUpdates() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("userSessions").child(uid).child(userTypeString).observe(.childChanged) { snapshot in
            print("Data needs reload")
			self.reloadSessionWithId(snapshot.ref.key!)
            snapshot.ref.setValue(1)
        }
    }
    
    func reloadSessionWithId(_ id: String) {
        DataService.shared.getSessionById(id) { session in
            if let fooOffset = self.conversationManager.messages.index(where: { (message) -> Bool in
                guard let userMessage = message as? UserMessage else { return false }
                return userMessage.sessionRequestId == id
            }) {
                // do something with fooOffset
                let indexPath = IndexPath(item: fooOffset, section: 0)
                let cell = self.messagesCollection.cellForItem(at: indexPath) as? SessionRequestCell
                if session.status == "accepted" {
                    cell?.updateAsAccepted()
                } else if session.status == "declined" {
                    cell?.updateAsDeclined()
                } else if session.status == "cancelled" {
                    cell?.updateAsCancelled()
				} else if session.status == "pending" {
					cell?.updateAsPending()
				}
            } else {
                // item could not be found
            }
        }
    }
    
    func scrollToBottom(animated: Bool) {
        guard conversationManager.messages.count > 0 else { return }
        let index = IndexPath(row: conversationManager.messages.count - 1, section: 0)
        messagesCollection.scrollToItem(at: index, at: .bottom, animated: animated)
    }
    
    func removeCurrentStatusLabel() {
        guard let testIndex = conversationManager.messages.index(where: {!($0 is UserMessage)}) else { return }
        conversationManager.messages.remove(at: testIndex)
    }
    
    @objc func addMessageStatusLabel() {
        guard let index = conversationManager.getStatusMessageIndex() else { return }
        self.removeCurrentStatusLabel()
        let statusMessage = SystemMessage(text: "Delivered")
        print("Inserting read message at index: \(index). Conversation manager has \(conversationManager.messages.count) messages.")

        if index > conversationManager.messages.count {
            conversationManager.messages.append(statusMessage)
        } else {
            conversationManager.messages.insert(statusMessage, at: index)
        }
        self.updateStatusLabel()
        messagesCollection.reloadData()
    }
    
    func updateStatusLabel() {
        guard let index = conversationManager.getStatusMessageIndex() else { return }
        let indexPath = IndexPath(item: index, section: 0)
        let cell = messagesCollection.cellForItem(at: indexPath) as? SystemMessageCell
        cell?.markAsRead()
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeFirstResponder), name: NSNotification.Name(rawValue: "actionSheetDismissed"), object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        guard conversationManager.messages.count > 0 else { return }
        let indexPath = IndexPath(item: conversationManager.messages.count - 1, section: 0)
        messagesCollection.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    override var inputAccessoryView: UIView? {
        return AccountService.shared.currentUserType == .tutor ? teacherKeyboardAccessory : studentKeyboardAccessory
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension ConversationVC: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversationManager.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let message = conversationManager.messages[indexPath.item] as? UserMessage else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "systemMessage", for: indexPath) as! SystemMessageCell
            cell.textField.text = conversationRead ? "Seen" : "Delivered"
            return cell
        }
        
        if message.imageUrl != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageMessage", for: indexPath) as! ImageMessageCell
            cell.bubbleWidthAnchor?.constant = 200
            cell.delegate = imageMessageAnimator
            cell.updateUI(message: message)
            cell.profileImageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            return cell
        }
        
        if message.sessionRequestId != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sessionMessage", for: indexPath) as! SessionRequestCell
            
            cell.updateUI(message: message)
            cell.bubbleWidthAnchor?.constant = 220
            cell.delegate = self
            cell.indexPath = [indexPath]
            cell.profileImageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            
            return cell
        }
        
        if message.connectionRequestId != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "connectionRequest", for: indexPath) as! ConnectionRequestCell
            cell.bubbleWidthAnchor?.constant = 220
            cell.chatPartner = chatPartner
            cell.updateUI(message: message)
            cell.profileImageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textMessage", for: indexPath) as! UserMessageCell
        cell.updateUI(message: message)
        cell.bubbleWidthAnchor?.constant = cell.textView.text.estimateFrameForFontSize(14).width + 20
        cell.profileImageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let message = conversationManager.messages[indexPath.item] as? UserMessage else {
            return CGSize(width: UIScreen.main.bounds.width, height: 15)
        }
        
        var height: CGFloat = 0
        
        if let text = message.text {
            height = text.estimateFrameForFontSize(14).height + 20
            
        }
        
        if let imageWidth = message.data["imageWidth"] as? CGFloat, let imageHeight = message.data["imageHeight"] as? CGFloat {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        if message.sessionRequestId != nil {
            height = 173
        }
        
        if message.connectionRequestId != nil {
            height += 50
        }
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView()}
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "paginationHeader", for: indexPath) as! ConversationPaginationHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: CGFloat(headerHeight))
    }
}

extension ConversationVC: ConversationManagerDelegate {
    func conversationManager(_ conversationManager: ConversationManager, didLoad messages: [BaseMessage]) {
        print("ConversationVC has: \(self.conversationManager.messages.count) messages.")
        messagesCollection.reloadData()
        conversationManager.isFinishedPaginating = true
        addMessageStatusLabel()
    }
    
    func conversationManager(_ conversationManager: ConversationManager, didUpdate readByIds: [String]) {
        if readByIds.contains(self.receiverId) {
            self.conversationRead = true
            self.updateStatusLabel()
        } else {
            self.conversationRead = false
        }
    }
    
    func conversationManager(_ convesationManager: ConversationManager, didUpdateConnection connected: Bool) {
        if connected {
            updateAsConnected()
        } else {
            guard conversationManager.messages.count > 0 else { return }
            updateAsPendingConnection()
        }
    }
    
    func conversationManager(_ conversationManager: ConversationManager, didLoadAll messages: [BaseMessage]) {
        headerHeight = 0
    }
    
    func updateAsConnected() {
        canSendMessages = true
        connectionRequestAccepted = true
        exitConnectionRequestMode()
        setMessageTextViewCoverHidden(true)
        setActionViewUsable(true)
        messagesCollection.reloadData()
    }
    
    func updateAsPendingConnection() {
        canSendMessages = false
        setActionViewUsable(false)
        setMessageTextViewCoverHidden(false)
    }
    
    
    func conversationManager(_ conversationManager: ConversationManager, didReceive message: UserMessage) {
        messagesCollection.reloadData()
        let _ = conversationManager.getStatusMessageIndex()
        if message.senderId == conversationManager.uid {
            self.addMessageStatusLabel()
        }
        setActionViewUsable(true)
        if message.connectionRequestId != nil && conversationManager.isConnected == false {
            updateAsPendingConnection()
        }
        studentKeyboardAccessory.hideQuickChatView()
        scrollToBottom(animated: false)
        exitConnectionRequestMode()
        guard viewIfLoaded?.window != nil else { return }
        conversationManager.readReceiptManager?.markConversationRead()
    }
}

// MARK: Plus button actions -
extension ConversationVC: KeyboardAccessoryViewDelegate {
    func handleSendingImage() {
        studentKeyboardAccessory.hideActionView()
        imageMessageSender.handleSendingImage()
    }
    
    func handleSessionRequest() {
        studentKeyboardAccessory.messageTextview.resignFirstResponder()
        studentKeyboardAccessory.hideActionView()
        showSessionRequestView()
    }
    
    func showSessionRequestView() {
        resignFirstResponder()
        FirebaseData.manager.fetchRequestSessionData(uid: receiverId) { requestData in
            guard let requestData = requestData else { return }
            let requestSessionModal = RequestSessionModal(uid: self.receiverId, requestData: requestData)
            requestSessionModal.frame = self.view.bounds
            self.view.addSubview(requestSessionModal)
        }
        
    }
    
    func shareUsernameForUserId() {
        studentKeyboardAccessory.toggleActionView()
        DynamicLinkFactory.shared.createLink(userId: receiverId) { shareUrl in
            guard let shareUrlString = shareUrl?.absoluteString else { return }
            let ac = UIActivityViewController(activityItems: [shareUrlString], applicationActivities: nil)
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    func handleMessageSend(message: UserMessage) {
        sendMessage(message: message)
    }
    
    func sendMessage(message: UserMessage) {
        message.user = AccountService.shared.currentUser
        guard canSendMessages else { return }
        self.conversationRead = false
        if let url = message.imageUrl {
            DataService.shared.sendImageMessage(imageUrl: url, imageWidth: message.data["imageWidth"] as! CGFloat, imageHeight: message.data["imageHeight"] as! CGFloat, receiverId: receiverId, completion: {
                self.emptyCellBackground.removeFromSuperview()
                self.scrollToBottom(animated: true)
            })
            return
        }
        
        guard connectionRequestAccepted || conversationManager.messages.count == 0, let text = message.text else { return }
        
        guard connectionRequestAccepted else {
            DataService.shared.sendConnectionRequestToId(text: text, receiverId)
            exitConnectionRequestMode()
            return
        }
        
        DataService.shared.sendTextMessage(text: text, receiverId: receiverId) {
            self.emptyCellBackground.removeFromSuperview()
            self.scrollToBottom(animated: true)
        }
    }
}

extension ConversationVC: SessionRequestViewDelegate {
    func didDismiss() {
        becomeFirstResponder()
    }
}

extension ConversationVC: QuickChatViewDelegate {
    func sendMessage(text: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let message = UserMessage(dictionary: ["text": text, "timestamp": timestamp, "senderId": uid, "connectionRequestId": "1"])
        sendMessage(message: message)
    }
    
}

extension ConversationVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return canSendMessages
    }
}

extension ConversationVC: SessionRequestCellDelegate {
    func sessionRequestCellShouldRequestSession(cell: SessionRequestCell) {
        showSessionRequestView()
    }
    func sessionRequestCell(cell: SessionRequestCell, shouldCancel session: SessionRequest) {
        studentKeyboardAccessory.messageTextview.resignFirstResponder()
        cancelSessionModal = CancelSessionModal(frame: .zero)
        guard let id = session.id else { return }
        cancelSessionModal?.sessionId = id
        cancelSessionModal?.delegate = self
        cancelSessionModal?.show()
        guard let indexPath = messagesCollection.indexPath(for: cell) else { return }
        cancelSessionIndex = indexPath
    }
    
    func sessionRequestCell(cell: SessionRequestCell, shouldAddToCalendar session: SessionRequest) {
        let eventManager = EventManager(parentController: self)
        eventManager.addSessionToCalender(session, forCell: cell)
		updateAfterCellButtonPress(indexPath: cell.indexPath)
    }
	
    func updateAfterCellButtonPress(indexPath: [IndexPath]?) {
        guard let paths = indexPath else {
            messagesCollection.reloadData()
            return
        }
        messagesCollection.reloadItems(at: paths)
    }
}

extension ConversationVC: CustomModalDelegate {
    func handleCancel(id: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessions").child(id).child("status").setValue("cancelled")
        DataService.shared.getSessionById(id) { session in
            let chatPartnerId = session.partnerId()
            Database.database().reference().child("sessionCancels").child(chatPartnerId).child(uid).setValue(1)
            SessionManager(sessionId: id).markDataStale(partnerId: chatPartnerId)
        }
        
        cancelSessionModal?.dismiss()
        guard let index = cancelSessionIndex else { return }
        messagesCollection.reloadItems(at: [index])
    }
}

extension ConversationVC: ImageMessageAnimatorDelegate {
    func imageAnimatorWillZoomIn(_ imageAnimator: ImageMessageAnimator) {
        studentKeyboardAccessory.messageTextview.resignFirstResponder()
        teacherKeyboardAccessory.messageTextview.resignFirstResponder()
    }
}

extension ConversationVC {
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y == 0 else { return }
        conversationManager.loadPreviousMessagesByTimeStamp(limit: 50) { (messages) in
            let oldOffset = self.messagesCollection.contentSize.height - self.messagesCollection.contentOffset.y
            
            if messages.count < 49 {
                self.headerHeight = 0
                self.messagesCollection.collectionViewLayout.invalidateLayout()
            }
            self.messagesCollection.reloadData()
            self.messagesCollection.layoutIfNeeded()
            
            self.messagesCollection.contentOffset = CGPoint(x: 0, y: self.messagesCollection.contentSize.height - oldOffset)
        }
    }
}
