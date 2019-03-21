
//
//  ConversationVC.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import CoreLocation
import Firebase
import UIKit
import SocketIO
import IQKeyboardManager

class ConversationVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var messagingManagerDelegate: ConversationManagerDelegate?
    var conversationManager = ConversationManager()
    var typingIndicatorManager: TypingIndicatorManager?
    var metaData: ConversationMetaData?

    var receiverId: String!
    var chatPartner: User! {
        didSet {
            messagesCollection.chatPartner = chatPartner
        }
    }
    var connectionRequestAccepted = false
    var conversationRead = false
    var shouldRequestSession = false
    var canSendMessages = true
    var headerHeight = 30

    // MARK: Layout Views -
    
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


    let titleViewFrame = CGRect(x: 0, y: 0, width: 100, height: 50)
    lazy var titleView = CustomTitleView(frame: titleViewFrame)

    var actionSheet: FileReportActionsheet?
    let studentKeyboardAccessory = StudentKeyboardAccessory()
    let teacherKeyboardAccessory = TeacherKeyboardAccessory()

    var cancelSessionModal: CancelSessionModal?
    var cancelSessionIndex: IndexPath?

    let tutorial = MessagingSystemTutorial()

    func setupViews() {
        setupNavBar()
        setupMainView()
        setupMessagesCollection()
        addSwipeGestureRegocgnizer()
    }

    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        edgesForExtendedLayout = []
        studentKeyboardAccessory.delegate = self
        teacherKeyboardAccessory.delegate = self
        studentKeyboardAccessory.messageTextview.delegate = self
        teacherKeyboardAccessory.messageTextview.delegate = self
    }
    
    @objc func textFieldDidChangeText(_ sender: UITextView) {
        if studentKeyboardAccessory.messageTextview.text.isEmpty && teacherKeyboardAccessory.messageTextview.text.isEmpty {
            typingIndicatorManager?.emitStopTyping()
            studentKeyboardAccessory.changeSendButtonColor(Colors.gray)
            teacherKeyboardAccessory.changeSendButtonColor(Colors.gray)
        } else {
            guard studentKeyboardAccessory.submitButton.backgroundColor != Colors.purple else { return }
            studentKeyboardAccessory.changeSendButtonColor(Colors.purple)
            teacherKeyboardAccessory.changeSendButtonColor(Colors.purple)
        }
    }

    private func setupMessagesCollection() {
        messagesCollection.dataSource = self
        messagesCollection.delegate = self
        view.addSubview(messagesCollection)
        messagesCollection.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: view.getBottomAnchor(), right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -60, width: 0, height: 0)
    }

    private func setupEmptyBackground() {
        view.addSubview(emptyCellBackground)
        emptyCellBackground.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 60, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 300)
    }

    private func setupNavBar() {
        setupTitleView()
        setUpMenuButton()
    }
    
    func setUpMenuButton(){
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        menuBtn.setImage(UIImage(named:"fileReportFlag"), for: .normal)
        menuBtn.addTarget(self, action: #selector(handleRightViewTapped), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 20)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 20)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    }

    private func setupTitleView() {
        if let partner = chatPartner {
            titleView.updateUI(user: partner)
        }
        guard let profilePicUrl = chatPartner?.profilePicUrl else { return }
        titleView.imageView.imageView.sd_setImage(with: profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
    }

    func handleLeftViewTapped() {
        pop()
    }

    @objc func handleRightViewTapped() {
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
        actionSheet?.isConnected = connectionRequestAccepted
        actionSheet?.parentViewController = self
        actionSheet?.partnerId = chatPartner.uid
        actionSheet?.show()
    }

    func enterConnectionRequestMode() {
        studentKeyboardAccessory.showQuickChatView()
        setupEmptyBackground()
        setActionViewUsable(false)
        headerHeight = 0
        messagesCollection.collectionViewLayout.invalidateLayout()
    }

    func exitConnectionRequestMode() {
        studentKeyboardAccessory.hideQuickChatView()
        emptyCellBackground.removeFromSuperview()
    }

    func setActionViewUsable(_ result: Bool) {
        if let keyboardAccessory = inputAccessoryView as? StudentKeyboardAccessory {
            keyboardAccessory.actionButton.isEnabled = result
        }
    }

    @objc func paginateMessages() {
        conversationManager.loadPreviousMessagesByTimeStamp(limit: 50, completion: { _ in })
    }

    // MARK: Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        messagesCollection.layoutTypingLabelIfNeeded()
        setupKeyboardObservers()
        studentKeyboardAccessory.chatView.delegate = self
        listenForSessionUpdates()
        loadAWUsers()
        addCustomTitleView()

        imageMessageSender.receiverId = receiverId
        DataService.shared.getConversationMetaDataForUid(receiverId) { metaDataIn in
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
        navigationController?.setNavigationBarHidden(false, animated: true)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        if shouldRequestSession {
            handleSessionRequest()
        }
        messagesCollection.scrollToBottom(animated: true)
        tutorial.showIfNeeded()
        conversationManager.readReceiptManager?.markConversationRead()
        NotificationManager.shared.disableConversationNotificationsFor(uid: chatPartner.uid)
        IQKeyboardManager.shared().isEnabled = false
    }
    
    func addCustomTitleView() {
        let navController = navigationController!
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        
        let bannerX = bannerWidth / 2 - titleView.frame.size.width / 2
        let bannerY = bannerHeight / 2 - titleView.frame.size.height / 2
        
//        titleView.frame = CGRect(x: bannerX, y: bannerY - 20, width: bannerWidth, height: bannerHeight)
        titleView.isUserInteractionEnabled = true
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 1
        titleView.addGestureRecognizer(tap)
        navigationItem.titleView = titleView
    }
    
    @objc func handleTap() {
        if AccountService.shared.currentUserType == .learner {
            FirebaseData.manager.fetchTutor(receiverId, isQuery: false) { (tutor) in
                guard let tutor = tutor else { return }
                let controller = QTProfileViewController.controller
                controller.user = tutor
                controller.profileViewType = .tutor
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
//            FirebaseData.manager.fetchLearner(receiverId) { (learner) in
//                guard let learner = learner else { return }
//                let controller = QTProfileViewController.controller
//                controller.user = learner
//                controller.profileViewType = .tutor
//                self.navigationController?.pushViewController(controller, animated: true)
//            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        typingIndicatorManager?.disconnect()
        NotificationManager.shared.enableConversationNotificationsFor(uid: chatPartner.uid)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared().isEnabled = true
    }
    
    func setMessageTextViewCoverHidden(_ result: Bool) {
        guard let keyboardAccessory = inputAccessoryView as? KeyboardAccessory else { return }
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

    func removeCurrentStatusLabel() {
        guard let testIndex = conversationManager.messages.index(where: { !($0 is UserMessage || $0 is MessageBreakTimestamp) }) else { return }
        conversationManager.messages.remove(at: testIndex)
    }

    func moveMessageStatusLabel(message: UserMessage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard message.senderId == uid else {
            updateForReceivedMessage(message)
            return
        }
        UIView.setAnimationsEnabled(false)
        
        messagesCollection.performBatchUpdates({
            removeDeliveredLabel()
            insertNewMessage(message: message)
            addDeliveredLabel()
        }) { (completed) in
            UIView.setAnimationsEnabled(true)
//            self.messagesCollection.layoutTypingLabelIfNeeded()
        }
    }
    
    func removeDeliveredLabel() {
        guard let index = conversationManager.messages.lastIndex(where: { $0 is SystemMessage }) else { return }
        conversationManager.messages.remove(at: index)
        messagesCollection.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func insertNewMessage(message: UserMessage) {
        conversationManager.messages.append(message)
        messagesCollection.insertItems(at: [IndexPath(item: conversationManager.messages.count - 1, section: 0)])
    }
    
    func addDeliveredLabel() {
        guard let index = conversationManager.messages.lastIndex(where: { (baseMessage) -> Bool in
            guard let userMessage = baseMessage as? UserMessage else { return false }
            guard let uid = Auth.auth().currentUser?.uid else { return false }
            return userMessage.senderId == uid
        }) else { return }
        let systemMessage = SystemMessage(text: "Delivered")
        conversationManager.messages.insert(systemMessage, at: index + 1)
        messagesCollection.insertItems(at: [IndexPath(item: index + 1, section: 0)])
    }
    
    func updateForReceivedMessage(_ message: UserMessage) {
        UIView.setAnimationsEnabled(false)
        
        messagesCollection.performBatchUpdates({
            typingIndicatorManager?.hideTypingIndicator()
            conversationManager.messages.append(message)
            let insertionIndexPath = IndexPath(item: conversationManager.messages.count - 1, section: 0)
            messagesCollection.insertItems(at: [insertionIndexPath])
        }) { (completed) in
            UIView.setAnimationsEnabled(true)
            
            self.messagesCollection.layoutTypingLabelIfNeeded()
        }
    }
    
    func addSwipeGestureRegocgnizer() {
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(swipe)
    }
    
    var animator: UIViewPropertyAnimator?
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            break
        case .changed:
            let delta = sender.translation(in: view)
            guard delta.x > -120, delta.x < 0 else { return }
            messagesCollection.transform = CGAffineTransform(translationX: delta.x / 2, y: 0)
        case .ended:
            UIView.animate(withDuration: 0.25) {
                self.messagesCollection.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        default:
            break
        }
    }
    
    func setupAnimator() {
        animator = UIViewPropertyAnimator(duration: 0.25, curve: .linear, animations: {
//            self.collectionView.transform = CGAffineTransform(translationX: delta.x, y: 0)
        })
    }
    
    
    
    @objc func addMessageStatusLabel() {
        guard let index = conversationManager.getStatusMessageIndex() else { return }
        removeCurrentStatusLabel()
        let statusMessage = SystemMessage(text: "Delivered")
        print("Inserting read message at index: \(index). Conversation manager has \(conversationManager.messages.count) messages.")

        if index > conversationManager.messages.count {
            conversationManager.messages.append(statusMessage)
        } else {
            conversationManager.messages.insert(statusMessage, at: index)
        }
        self.updateStatusLabel()
    }
    
    func loadAWUsers() {
        if AccountService.shared.currentUserType == .learner {
            FirebaseData.manager.fetchTutor(receiverId, isQuery: false) { (tutorIn) in
                guard let tutor = tutorIn else { return }
                self.titleView.tutor = tutor
            }
        } else {
            FirebaseData.manager.fetchLearner(receiverId) { (learnerIn) in
                guard let learner = learnerIn else { return }
                self.titleView.learner = learner
            }
        }
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
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnect), name: Notifications.didDisconnect.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChangeText(_:)), name: UITextView.textDidChangeNotification, object: nil)
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard conversationManager.messages.count > 0 else { return }
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            messagesCollection.contentInset = UIEdgeInsets.zero
        } else {
            let heightAdjustment: CGFloat = UIScreen.main.bounds.height > 700 ? 86 : 52
            messagesCollection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - heightAdjustment, right: 0)
        }
        let indexPath = IndexPath(item: conversationManager.messages.count - 1, section: 0)
        messagesCollection.scrollToItem(at: indexPath, at: .top, animated: true)
    }

    
    @objc func handleKeyboardDidShow() {
//        guard conversationManager.messages.count > 0 else { return }
//        messagesCollection.transform = CGAffineTransform(translationX: 0, y: -200)
//        let indexPath = IndexPath(item: conversationManager.messages.count - 1, section: 0)
//        messagesCollection.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc func didDisconnect() {
        messagesCollection.reloadData()
        pop()
    }
    
    override var inputAccessoryView: UIView? {
        return AccountService.shared.currentUserType == .tutor ? teacherKeyboardAccessory : studentKeyboardAccessory
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension ConversationVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversationManager.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let message = conversationManager.messages[indexPath.item] as? UserMessage else {
            if let timeStampMessage = conversationManager.messages[indexPath.item] as? MessageBreakTimestamp {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timestampCell", for: indexPath) as! MessageGapTimestampCell
                cell.updateUI(message: timeStampMessage)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "systemMessage", for: indexPath) as! SystemMessageCell
                cell.textField.text = conversationRead ? "Seen" : "Delivered"
                return cell
            }

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
            cell.bubbleWidthAnchor?.constant = 285
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
        cell.bubbleWidthAnchor?.constant = cell.textView.text.estimateFrameForFontSize(14).width + 30
        cell.profileImageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let message = conversationManager.messages[indexPath.item] as? UserMessage else {
            if conversationManager.messages[indexPath.item] is MessageBreakTimestamp {
                return CGSize(width: UIScreen.main.bounds.width + 60, height: 30)
            }
            return CGSize(width: UIScreen.main.bounds.width + 60, height: 15)
        }
        
        var height: CGFloat = 0
        
        if let text = message.text {
            height = text.estimateFrameForFontSize(14).height + 30
            
        }
        
        if let imageWidth = message.data["imageWidth"] as? CGFloat, let imageHeight = message.data["imageHeight"] as? CGFloat {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        if message.sessionRequestId != nil {
            height = 150
        }
        
        if message.connectionRequestId != nil {
            height += 40
        }
        return CGSize(width: UIScreen.main.bounds.width + 60, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView()}
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "paginationHeader", for: indexPath) as! ConversationPaginationHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: CGFloat(headerHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        titleView.transform = CGAffineTransform(translationX: 0, y: -20)
        titleView.arrow.transform = CGAffineTransform(translationX: 0, y: 20)
    }
    
}

extension ConversationVC: ConversationManagerDelegate {
    func conversationManager(_ conversationManager: ConversationManager, didLoad messages: [BaseMessage]) {
        print("ConversationVC has: \(self.conversationManager.messages.count) messages.")
        messagesCollection.reloadData()
        conversationManager.isFinishedPaginating = true
        addMessageStatusLabel()
        setupTypingInidcatorManagerIfNeeded()
    }
    
    func setupTypingInidcatorManagerIfNeeded() {
        guard typingIndicatorManager == nil else { return }
        guard let roomKey = createRoomKeyForConversation() else { return }
        typingIndicatorManager = TypingIndicatorManager(roomKey: roomKey, collectionView: messagesCollection)
        typingIndicatorManager?.connect()
    }
    
    func createRoomKeyForConversation() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        //Format is learnerId + tutorId
        return AccountService.shared.currentUserType == .learner ? uid + receiverId : receiverId + uid
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
        moveMessageStatusLabel(message: message)
        setActionViewUsable(true)
        if message.connectionRequestId != nil && conversationManager.isConnected == false {
            updateAsPendingConnection()
        }
        studentKeyboardAccessory.hideQuickChatView()
        messagesCollection.scrollToBottom(animated: false)
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
            let vc = SessionRequestVC()
            FirebaseData.manager.fetchTutor(self.receiverId, isQuery: false, { (tutorIn) in
                guard let tutor = tutorIn else { return }
                vc.tutor = tutor
                self.navigationController?.pushViewController(vc, animated: true)
            })
//            guard let requestData = requestData else { return }
//            let requestSessionModal = RequestSessionModal(uid: self.receiverId, requestData: requestData, frame: self.view.bounds)
//            self.view.addSubview(requestSessionModal)
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
        conversationRead = false
        if let url = message.imageUrl {
            DataService.shared.sendImageMessage(imageUrl: url, imageWidth: message.data["imageWidth"] as! CGFloat, imageHeight: message.data["imageHeight"] as! CGFloat, receiverId: receiverId, completion: {
                self.emptyCellBackground.removeFromSuperview()
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
        typingIndicatorManager?.emitTypingEventIfNeeded()
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
            self.markDataStale(sessionId: id, partnerId: chatPartnerId)
        }

        cancelSessionModal?.dismiss()
        guard let index = cancelSessionIndex else { return }
        messagesCollection.reloadItems(at: [index])
    }
    
    func markDataStale(sessionId: String, partnerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        Database.database().reference().child("userSessions").child(uid)
            .child(userTypeString).child(sessionId).setValue(0)
        Database.database().reference().child("userSessions").child(partnerId)
            .child(otherUserTypeString).child(sessionId).setValue(0)
    }
}

extension ConversationVC: ImageMessageAnimatorDelegate {
    func imageAnimatorWillZoomIn(_ imageAnimator: ImageMessageAnimator) {
        studentKeyboardAccessory.messageTextview.resignFirstResponder()
        teacherKeyboardAccessory.messageTextview.resignFirstResponder()
    }
}

extension ConversationVC {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y == 0 else { return }
        conversationManager.loadPreviousMessagesByTimeStamp(limit: 50) { messages in
            let oldOffset = self.messagesCollection.contentSize.height - self.messagesCollection.contentOffset.y

            if messages.count < 49 {
                self.headerHeight = 0
                self.messagesCollection.collectionViewLayout.invalidateLayout()
            }
            self.messagesCollection.layoutIfNeeded()

            self.messagesCollection.contentOffset = CGPoint(x: 0, y: self.messagesCollection.contentSize.height - oldOffset)
        }
    }
}
