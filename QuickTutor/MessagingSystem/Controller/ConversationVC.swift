//
//  ConversationVC.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class ConversationVC: UICollectionViewController, CustomNavBarDisplayer {
    
    var navBar: ZFNavBar = {
        let bar = ZFNavBar()
        bar.leftAccessoryView.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        bar.rightAccessoryView.setImage(#imageLiteral(resourceName: "fileReportFlag"), for: .normal)
        return bar
    }()
    
    var messagingManagerDelegate: ConversationManagerDelegate?
    var conversationManager = ConversationManager()
    
    var messages = [BaseMessage]()
    var receiverId: String!
    var chatPartner: User!
    var statusMessageIndex = -1
    var connectionRequestAccepted = false
    var shouldSetupForConnectionRequest = false
    var conversationRead = false
    var shouldRequestSession = false
    var canSendMessages = true
    
    // MARK: Layout Views -
    let messagesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.alwaysBounceVertical = true
        cv.keyboardDismissMode = .interactive
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cv.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cv.showsVerticalScrollIndicator = false
        cv.register(UserMessageCell.self, forCellWithReuseIdentifier: "textMessage")
        cv.register(SystemMessageCell.self, forCellWithReuseIdentifier: "systemMessage")
        cv.register(SessionRequestCell.self, forCellWithReuseIdentifier: "sessionMessage")
        cv.register(ImageMessageCell.self, forCellWithReuseIdentifier: "imageMessage")
        cv.register(ConnectionRequestCell.self, forCellWithReuseIdentifier: "connectionRequest")
        return cv
    }()
	
	var tutor : AWTutor!
	var learner : AWLearner!
	
    lazy var emptyCellBackground: EmptyMessagesBackground = {
        let background = EmptyMessagesBackground()
        return background
    }()
    
    var actionSheet: FileReportActionsheet?
    
    let studentKeyboardAccessory = StudentKeyboardAccessory()
    let teacherKeyboardAccessory = TeacherKeyboardAccessory()
    lazy var imageMessageAnimator: ImageMessageAnimator = {
        let animator = ImageMessageAnimator(parentViewController: self)
        return animator
    }()
    
    lazy var imageMessageSender: ImageMessageSender = {
        let sender = ImageMessageSender(parentViewController: self)
        return sender
    }()
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupNavBar()
        setupMainView()
        setupMessagesCollection()
        setupEmptyBackground()
        conversationManager.chatPartnerId = receiverId
        conversationManager.loadMessages()
        conversationManager.delegate = ConversationManagerFacade()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        edgesForExtendedLayout = []
        studentKeyboardAccessory.delegate = self
        teacherKeyboardAccessory.delegate = self
    }
    
    private func setupMessagesCollection() {
        messagesCollection.dataSource = self
        messagesCollection.delegate = self
        collectionView = messagesCollection
        collectionView?.anchor(top: navBar.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupEmptyBackground() {
        view.addSubview(emptyCellBackground)
        emptyCellBackground.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 300)
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
		
		if AccountService.shared.currentUserType == .learner {
			titleView.tutor = tutor
		} else {
			titleView.learner = learner
		}
		
        navBar.addSubview(titleView)
        titleView.anchor(top: navBar.titleView.topAnchor, left: nil, bottom: navBar.titleView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.addConstraint(NSLayoutConstraint(item: titleView, attribute: .centerX, relatedBy: .equal, toItem: navBar, attribute: .centerX, multiplier: 1, constant: 0))
        guard let profilePicUrl = chatPartner?.profilePicUrl else { return }
        titleView.imageView.imageView.loadImage(urlString: profilePicUrl)

    }
    
    func teardownConnectionRequest() {
        self.studentKeyboardAccessory.hideQuickChatView()
        self.emptyCellBackground.removeFromSuperview()
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
        actionSheet = FileReportActionsheet(bottomLayoutMargin: view.safeAreaInsets.bottom)
        actionSheet?.partnerId = chatPartner.uid
        actionSheet?.show()
    }
    
    // MARK: Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadMessages()
        scrollToBottom(animated: false)
        listenForReadReceipts()
        setupKeyboardObservers()
        studentKeyboardAccessory.chatView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        if shouldRequestSession {
            handleSessionRequest()
        }
        
        if shouldSetupForConnectionRequest {
            self.studentKeyboardAccessory.showQuickChatView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadMessages() {
        let uid = AccountService.shared.currentUser.uid!
        Database.database().reference().child("conversations").child(uid).child(receiverId).observe(.childAdded) { snapshot in
            self.teardownConnectionRequest()
            let messageId = snapshot.key
            DataService.shared.getMessageById(messageId, completion: { message in
                self.messages.append(message)
                self.messagesCollection.reloadData()
                if message.senderId == uid {
                    self.removeCurrentStatusLabel()
                    self.addMessageStatusLabel(atIndex: self.messages.endIndex)
                }
                self.checkIfMessageIsConnectionRequest(message)
                self.studentKeyboardAccessory.hideQuickChatView()
                self.scrollToBottom(animated: false)
            })
            self.markConversationRead()
        }
    }
    
    func checkIfMessageIsConnectionRequest(_ message: UserMessage) {
        let uid = AccountService.shared.currentUser.uid!
        if message.connectionRequestId != nil {
            self.canSendMessages = false
            Database.database().reference().child("connections").child(uid).child(message.partnerId()).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let value = snapshot.value as? Bool else {
                    return
                }
                if value {
                    self.canSendMessages = true
                } else {
                    self.canSendMessages = false
                }
            })
            self.connectionRequestAccepted = true
        }

    }
    
    func checkForConnection(completion: @escaping (Bool) ->() ) {
        let uid = AccountService.shared.currentUser.uid!
        Database.database().reference().child("connections").child(uid).child(receiverId).observeSingleEvent(of: .value) { snapshot in
            guard (snapshot.value as? Int) != nil else {
                self.connectionRequestAccepted = false
                completion(false)
                return
            }
            self.connectionRequestAccepted = true
            completion(true)
        }
    }
    
    func scrollToBottom(animated: Bool) {
        guard messages.count > 0 else { return }
        let index = IndexPath(row: messages.count - 1, section: 0)
        messagesCollection.scrollToItem(at: index, at: .bottom, animated: animated)
    }
    
    func removeCurrentStatusLabel() {
        guard statusMessageIndex != -1 else { return }
        messages.remove(at: statusMessageIndex)
        statusMessageIndex += 1
    }
    
    @objc func addMessageStatusLabel(atIndex index: Int) {
        let statusMessage = SystemMessage(text: "Delivered")
        messages.insert(statusMessage, at: index)
        statusMessageIndex = index
        self.updateStatusLabel()
        messagesCollection.reloadData()
    }
    
    func updateStatusLabel() {
        let indexPath = IndexPath(item: statusMessageIndex, section: 0)
        let cell = messagesCollection.cellForItem(at: indexPath) as? SystemMessageCell
        cell?.markAsRead()
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeFirstResponder), name: NSNotification.Name(rawValue: "actionSheetDismissed"), object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(item: messages.count - 1, section: 0)
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
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let message = messages[indexPath.item] as? UserMessage else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "systemMessage", for: indexPath) as! SystemMessageCell
            cell.textField.text = conversationRead ? "Seen" : "Delivered"
            return cell
        }
        
        if message.imageUrl != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageMessage", for: indexPath) as! ImageMessageCell
            cell.bubbleWidthAnchor?.constant = 200
            cell.delegate = imageMessageAnimator
            cell.updateUI(message: message)
            cell.profileImageView.loadImage(urlString: chatPartner?.profilePicUrl ?? "")
            return cell
        }
        
        if message.sessionRequestId != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sessionMessage", for: indexPath) as! SessionRequestCell
            cell.updateUI(message: message)
            cell.profileImageView.loadImage(urlString: chatPartner?.profilePicUrl ?? "")
            return cell
        }
        
        if message.connectionRequestId != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "connectionRequest", for: indexPath) as! ConnectionRequestCell
            cell.bubbleWidthAnchor?.constant = 200
            cell.chatPartner = chatPartner
            cell.updateUI(message: message)
            cell.profileImageView.loadImage(urlString: chatPartner?.profilePicUrl ?? "")
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textMessage", for: indexPath) as! UserMessageCell
        cell.updateUI(message: message)
        cell.bubbleWidthAnchor?.constant = cell.textView.text.estimateFrameForFontSize(14).width + 20
        cell.profileImageView.loadImage(urlString: chatPartner?.profilePicUrl ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let message = messages[indexPath.item] as? UserMessage else {
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
            height = 145
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let message = messages[indexPath.item] as? UserMessage, let sessionRequestId = message.sessionRequestId else {
            return
        }
//        let vc = ViewSessionRequestVC()
//        vc.sessionRequestId = sessionRequestId
//        vc.senderId = message.senderId
//        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: Plus button actions -
extension ConversationVC: KeyboardAccessoryViewDelegate {
    func handleSendingImage() {
        imageMessageSender.handleSendingImage()
    }
    
    func handleSessionRequest() {
        studentKeyboardAccessory.messageTextview.resignFirstResponder()
        studentKeyboardAccessory.hideActionView()
        showSessionRequestView()
    }
    
    func showSessionRequestView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let sessionView = SessionRequestView()
        sessionView.delegate = self
        sessionView.chatPartnerId = receiverId
        window.addSubview(sessionView)
        resignFirstResponder()
        sessionView.anchor(top: nil, left: window.leftAnchor, bottom: nil, right: window.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 600)
        window.addConstraint(NSLayoutConstraint(item: sessionView, attribute: .centerY, relatedBy: .equal, toItem: window, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func shareUsernameForUserId() {
        studentKeyboardAccessory.toggleActionView()
        DynamicLinkFactory.shared.createLinkForUserId(receiverId) { shareUrl in
            guard let shareUrlString = shareUrl?.absoluteString else { return }
            let ac = UIActivityViewController(activityItems: [shareUrlString], applicationActivities: nil)
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    func handleMessageSend(message: UserMessage) {
        sendMessage(message: message)
    }
    
    func sendMessage(message: UserMessage) {
        guard canSendMessages else { return }
        if let url = message.imageUrl {
            DataService.shared.sendImageMessage(imageUrl: url, imageWidth: message.data["imageWidth"] as! CGFloat, imageHeight: message.data["imageHeight"] as! CGFloat, receiverId: receiverId, completion: {
                self.invalidateReceiverReceipt()
                self.emptyCellBackground.removeFromSuperview()
                self.scrollToBottom(animated: true)
            })
            return
        }
        
        guard connectionRequestAccepted || messages.count == 0, let text = message.text else { return }
        
        guard connectionRequestAccepted else {
            DataService.shared.sendConnectionRequestToId(text: text, receiverId)
            self.emptyCellBackground.removeFromSuperview()
            return
        }
        
        DataService.shared.sendTextMessage(text: text, receiverId: receiverId) {
            self.invalidateReceiverReceipt()
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

// MARK: Read Receipts -
extension ConversationVC {
    
    func listenForReadReceipts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("readReceipts").child(uid).child(receiverId).observe(.value) { snapshot in
            guard let read = snapshot.value as? Bool else { return }
            if read {
                self.conversationRead = true
                self.updateStatusLabel()
            } else {
                self.conversationRead = false
            }
        }
    }
    
    func markConversationRead() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard viewIfLoaded?.window != nil else { return }
        Database.database().reference().child("readReceipts").child(receiverId).child(uid).setValue(true)
    }
    
    func invalidateReceiverReceipt() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("readReceipts").child(uid).child(receiverId).setValue(false)
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
