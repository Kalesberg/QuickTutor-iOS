
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
import Stripe
import AVFoundation
import AVKit
import MobileCoreServices
import QuickLook

enum QTConnectionStatus: String {
    case pending, declined, accepted, expired
}

class ConversationVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var messagingManagerDelegate: ConversationManagerDelegate?
    var conversationManager = ConversationManager()
    var typingIndicatorManager: TypingIndicatorManager?
    var documentUploadManager: DocumentUploadManager?
    var metaData: ConversationMetaData?
    var addPaymentModal: AddPaymentModal?
    

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
    var subject: String?
    var connectionStatus: QTConnectionStatus? = .declined

    // MARK: Layout Views -
    let messagesCollection: ConversationCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
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


    lazy var titleView = CustomTitleView(frame: CGRect.zero)

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
        view.backgroundColor = Colors.newScreenBackground
        edgesForExtendedLayout = []
        studentKeyboardAccessory.delegate = self
        teacherKeyboardAccessory.delegate = self
        studentKeyboardAccessory.messageTextview.delegate = self
        teacherKeyboardAccessory.messageTextview.delegate = self
    }
    
    @objc func textFieldDidChangeText(_ sender: UITextView) {
        if studentKeyboardAccessory.messageTextview.text.isEmpty && teacherKeyboardAccessory.messageTextview.text.isEmpty {
            typingIndicatorManager?.emitStopTyping()
        }
    }

    private func setupMessagesCollection() {
        messagesCollection.dataSource = self
        messagesCollection.delegate = self
        view.addSubview(messagesCollection)
        messagesCollection.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: view.getBottomAnchor(), right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 7.5, paddingRight: -60, width: 0, height: 0)
    }

    private func setupEmptyBackground() {
        view.addSubview(emptyCellBackground)
        emptyCellBackground.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 60, paddingRight: 0, width: 0, height: 0)
    }

    private func setupNavBar() {
        setupTitleView()
        setUpMenuButton()
    }
    
    func setUpMenuButton(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "ic_dots_horizontal"),
            style: .plain,
            target: self,
            action: #selector(handleRightViewTapped)
        )
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
            actionSheet = FileReportActionsheet(bottomLayoutMargin: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, name: String(firstName))
        } else {
            actionSheet = FileReportActionsheet(bottomLayoutMargin: 0, name: String(firstName))
        }
        actionSheet?.isConnected = connectionRequestAccepted
        actionSheet?.parentViewController = self
        actionSheet?.partnerId = chatPartner.uid
        actionSheet?.subject = subject
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
    
    func showAccessoryView(_ show: Bool) {
        inputAccessoryView?.isHidden = !show
    }

    @objc func paginateMessages() {
        conversationManager.loadPreviousMessagesByTimeStamp(limitedTo: 50, completion: { _ in })
    }

    // MARK: Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        messagesCollection.layoutTypingLabelIfNeeded()
        studentKeyboardAccessory.chatView.delegate = self
        listenForSessionUpdates()
        loadAWUsers()
        addCustomTitleView()
        setupDocumentUploadManager()
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
    
    func setupDocumentUploadManager() {
        documentUploadManager = DocumentUploadManager(receiverId: receiverId)
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
        titleView.isUserInteractionEnabled = true
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
                controller.subject = self.subject
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            FirebaseData.manager.fetchLearner(receiverId) { (learner) in
                guard let learner = learner else { return }
                let controller = QTProfileViewController.controller
                let tutor = AWTutor(dictionary: [:])
                controller.user = tutor.copy(learner: learner)
                controller.profileViewType = .learner
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardObservers()
        setupDocumentObserver()
        navigationController?.setNavigationBarHidden(false, animated: false)
        CardService.shared.checkForPaymentMethod()
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
            if let fooOffset = self.conversationManager.messages.firstIndex(where: { (message) -> Bool in
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
        guard let testIndex = conversationManager.messages.firstIndex(where: { !($0 is UserMessage || $0 is MessageBreakTimestamp) }) else { return }
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
            typingIndicatorManager?.hideTypingIndicator(force: true)
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
    
    func getConnectionPendingStatus(_ connectionRequestId: String?, completion: @escaping ((Bool) -> (Void))) {
        guard let id = connectionRequestId else {
            completion(false)
            return
        }
        Database.database().reference().child("connectionRequests").child(id).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            guard let status = value["status"] as? String else {
                completion(false)
                return
            }
            
            self.connectionStatus = QTConnectionStatus(rawValue: status)
            completion(status.compare("pending") == ComparisonResult.orderedSame)
        }
    }
    
    func setupKeyboardObservers() {
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
            messagesCollection.updateBottomValues(0)
        } else {
            var keyboardHeight = keyboardViewEndFrame.height
            if #available(iOS 11.0, *) {
                keyboardHeight -= UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
            }
            
            let typingIndicatorHeight: CGFloat = 48
            keyboardHeight -= typingIndicatorHeight
            let bottom = keyboardHeight > 0 ? keyboardHeight : 0
            messagesCollection.updateBottomValues(bottom)
        }
        let indexPath = IndexPath(item: conversationManager.messages.count - 1, section: 0)
        messagesCollection.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    func setupDocumentObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDocumentUploadStarted), name: NotificationNames.Documents.didStartUpload, object: nil)
        
    }
    
    @objc func handleDocumentUploadStarted() {
        displayLoadingOverlay(verticalOffset: -50)
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
    
    func currentUserHasPayment() -> Bool {
        guard AccountService.shared.currentUserType == .learner else {
            return true
        }
        
        guard CurrentUser.shared.learner.hasPayment else {
            addPaymentModal = AddPaymentModal()
            addPaymentModal?.delegate = self
            addPaymentModal?.show()
            return false
        }
        
        return true
    }
    
    @objc func showCardManager() {
        let next = CardManagerViewController()
        navigationController?.pushViewController(next, animated: true)
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
        
        let cellId = message.type.rawValue
        
        switch message.type {
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageMessageCell
            cell.delegate = imageMessageAnimator
            cell.updateUI(message: message)
            cell.profileImageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            return cell
        case .sessionRequest:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SessionRequestCell
            cell.updateUI(message: message)
            cell.delegate = self
            cell.indexPath = [indexPath]
            cell.profileImageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            return cell
        case .connectionRequest:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ConnectionRequestCell
            cell.chatPartner = chatPartner
            cell.updateUI(message: message)
            cell.profileImageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            return cell
        case .video:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! VideoMessageCell
            cell.updateUI(message: message)
            cell.profileImageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            return cell
        case .text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserMessageCell
            cell.bubbleView.backgroundColor = .clear
            cell.updateUI(message: message)
            cell.bubbleWidthAnchor?.constant = cell.textView.text.estimateFrameForFontSize(14).width + 30
            cell.profileImageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            return cell
        case .document:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DocumentMessageCell
            cell.updateUI(message: message)
            cell.profileImageView.sd_setImage(with: chatPartner.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            return cell
        default:
            return UICollectionViewCell()
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let message = conversationManager.messages[indexPath.item] as? UserMessage else {
            if conversationManager.messages[indexPath.item] is MessageBreakTimestamp {
                return CGSize(width: UIScreen.main.bounds.width + 60, height: 55)
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
            height += 55
        }
        
        if message.documenUrl != nil {
            height = 54
        }
        return CGSize(width: UIScreen.main.bounds.width + 60, height: height)
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
        guard let userMessage = conversationManager.messages[indexPath.item] as? UserMessage else { return }
        if let videoUrl = userMessage.videoUrl {
            let player = AVPlayer(url: URL(string: videoUrl)!)
            let vc = AVPlayerViewController()
            vc.player = player
            present(vc, animated: true) {
                vc.player?.play()
            }
        } else if let fileDownloadUrl = userMessage.documenUrl {
            guard let url = URL(string: fileDownloadUrl) else { return }
            documentUploadManager?.displayFileAtUrl(url, fromViewController: self)
        } else {
            openLinkIfNeeded(message: userMessage)
        }

    }
    
    func openLinkIfNeeded(message: UserMessage) {
        let links = message.getLinksInText()
        links.forEach { (link) in
            if let url = URL(string: link) {
                UIApplication.shared.open(url)
            }
        }
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
            
            // hide accessory view if a user is tutor.
            if AccountService.shared.currentUserType == .tutor {
                showAccessoryView(false)
                return
            }
            
            // if there is no any message, set connection request mode.
            guard conversationManager.messages.count > 0 else {
                conversationManager.isFinishedPaginating = true
                enterConnectionRequestMode()
                return
            }
            
            // Check the connection request has been declined or pending.
            let connectionRequests = conversationManager.messages.filter({$0.type == .connectionRequest})
            
            if let message = connectionRequests.first as? UserMessage, let requestId = message.connectionRequestId {
                conversationManager.isFinishedPaginating = true
                getConnectionPendingStatus(requestId) { (pending) -> (Void) in
                    if pending {
                        self.updateAsPendingConnection()
                    } else {
                        self.enterConnectionRequestMode()
                    }
                }
            }
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
        if let _ = message.documenUrl {
            removeDocumentLoadingAnimationIfNeeded()
        }
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
    
    func removeDocumentLoadingAnimationIfNeeded() {
        dismissOverlay()
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
        }
    }

    func shareUsernameForUserId() {
        studentKeyboardAccessory.toggleActionView()
        DynamicLinkFactory.shared.createLink(userId: receiverId, subject: subject) { shareUrl in
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
            MessageService.shared.sendImageMessage(imageUrl: url, imageWidth: message.data["imageWidth"] as! CGFloat, imageHeight: message.data["imageHeight"] as! CGFloat, receiverId: receiverId, completion: {
                self.emptyCellBackground.removeFromSuperview()
            })
            return
        }

        if let connectionStatus = self.connectionStatus {
            switch connectionStatus {
            case .accepted:
                guard let text = message.text else { return }
                MessageService.shared.sendTextMessage(text: text, receiverId: receiverId) {
                    self.emptyCellBackground.removeFromSuperview()
                }
                return
            case .pending:
                break
            default:
                guard let text = message.text else { return }
                MessageService.shared.sendConnectionRequestToId(text: text, receiverId)
                exitConnectionRequestMode()
            }
        }
    }
    
    func handleFileUpload() {
        documentUploadManager?.showDocumentBrowser(onViewController: self)
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
    func sessionRequestCellShouldStartSession(cell: SessionRequestCell) -> Bool {
        return currentUserHasPayment()
    }
    
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
        self.resignFirstResponder()
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
        Database.database().reference().child("sessions").child(id).updateChildValues(["status" : "cancelled", "cancelledById": uid])
        DataService.shared.getSessionById(id) { session in
            let chatPartnerId = session.partnerId()
            Database.database().reference().child("sessionCancels").child(chatPartnerId).child(uid).setValue(1)
            self.markDataStale(sessionId: id, partnerId: chatPartnerId)
        }

        cancelSessionModal?.dismiss()
        self.becomeFirstResponder()
        guard let index = cancelSessionIndex else { return }
        messagesCollection.reloadItems(at: [index])
    }
    
    func handleConfirm() {
        showCardManager()
        self.becomeFirstResponder()
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
    
    func handleNevermind() {
        self.becomeFirstResponder()
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
        conversationManager.loadPreviousMessagesByTimeStamp(limitedTo: 50) { messages in
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
