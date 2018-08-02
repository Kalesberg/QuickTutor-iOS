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
import AVFoundation
import EventKit

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
    var conversationRead = false
    var shouldRequestSession = false
    var canSendMessages = true
    var cameraAccessAllowed = false
    
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
    
    var tutor: AWTutor!
    var learner: AWLearner!
    
    lazy var emptyCellBackground: UIView = {
        let contentView = UIView()
        let icon: UIImageView = {
            let iv = UIImageView()
            iv.image = #imageLiteral(resourceName: "emptyChatImage")
            iv.contentMode = .scaleAspectFill
            return iv
        }()
        
        let textLabel: UILabel = {
            let label = UILabel()
            label.textColor = Colors.border
            label.textAlignment = .center
            label.numberOfLines = 0
            label.font = Fonts.createSize(11)
            label.text = "Select a custom message, or introduce yourself by typing a message. A tutor must accept your connection request before you are able to message them again"
            return label
        }()
        
        contentView.addSubview(icon)
        contentView.addSubview(textLabel)
        icon.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 140)
        textLabel.anchor(top: icon.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 100)
        contentView.addConstraint(NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        return contentView
    }()
    
    var actionSheet: FileReportActionsheet?
    
    let studentKeyboardAccessory = StudentKeyboardAccessory()
    let teacherKeyboardAccessory = TeacherKeyboardAccessory()
    lazy var imageMessageAnimator: ImageMessageAnimator = {
        let animator = ImageMessageAnimator(parentViewController: self)
        animator.delegate = self
        return animator
    }()
    
    var cancelSessionModal: CancelSessionModal?
    var cancelSessionIndex: IndexPath?
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupNavBar()
        setupMainView()
        setupMessagesCollection()
        conversationManager.chatPartnerId = receiverId
        conversationManager.loadMessages()
        conversationManager.delegate = ConversationManagerFacade()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        edgesForExtendedLayout = []
        studentKeyboardAccessory.delegate = self
        teacherKeyboardAccessory.delegate = self
        studentKeyboardAccessory.messageTextview.delegate = self
        teacherKeyboardAccessory.messageTextview.delegate = self
    }
    
    private func setupMessagesCollection() {
        messagesCollection.dataSource = self
        messagesCollection.delegate = self
        collectionView = messagesCollection
        collectionView?.anchor(top: navBar.bottomAnchor, left: view.leftAnchor, bottom: view.getBottomAnchor(), right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
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
        if #available(iOS 11.0, *) {
            actionSheet = FileReportActionsheet(bottomLayoutMargin: view.safeAreaInsets.bottom)
        } else {
            actionSheet = FileReportActionsheet(bottomLayoutMargin: 0)
        }
        actionSheet?.partnerId = chatPartner.uid
        actionSheet?.show()
    }
    
    func enterConnectionRequestMode() {
        studentKeyboardAccessory.showQuickChatView()
        setupEmptyBackground()
        setActionViewUsable(false)
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
    
    // MARK: Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        checkForConnection { _ in }
        loadMessages()
        scrollToBottom(animated: false)
        listenForReadReceipts()
        setupKeyboardObservers()
        studentKeyboardAccessory.chatView.delegate = self
        listenForSessionUpdates()   
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        if shouldRequestSession {
            handleSessionRequest()
        }
        
        
        if UserDefaults.standard.bool(forKey: "showMessagingSystemTutorial1.0") {
            displayTutorial()
            UserDefaults.standard.set(false, forKey: "showMessagingSystemTutorial1.0")
        }
        if UserDefaults.standard.bool(forKey: "showMessagingSystemTutorial1.0") {
            displayTutorial()
            UserDefaults.standard.set(false, forKey: "showMessagingSystemTutorial1.0")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    let tutorial = MessagingSystemTutorial()
    
    func displayTutorial() {
        tutorial.addTarget(self, action: #selector(handleTutorialButton), for: .touchUpInside)
        let window = UIApplication.shared.windows.last
        window?.addSubview(tutorial)
        window?.bringSubview(toFront: tutorial)
        
        tutorial.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        UIView.animate(withDuration: 1, animations: {
            self.tutorial.alpha = 1
        })
    }
    
    @objc func handleTutorialButton() {
        switch tutorial.count {
        case 0:
            UIView.animate(withDuration: 0.5, animations: {
                self.tutorial.label.alpha = 0
            }, completion: { _ in
                self.tutorial.label.text = self.tutorial.phrases[1]
                UIView.animate(withDuration: 0.5, animations: {
                    self.tutorial.label.alpha = 1
                })
            })
        case 1:
            UIView.animate(withDuration: 0.5, animations: {
                self.tutorial.label.alpha = 0
            }, completion: { _ in
                self.tutorial.label.text = self.tutorial.phrases[2]
                UIView.animate(withDuration: 0.5, animations: {
                    self.tutorial.label.alpha = 1
                    self.tutorial.view.alpha = 1
                    self.tutorial.image.alpha = 1
                }, completion: { _ in
                    UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {
                        self.tutorial.image.center.y += 10
                    })
                })
            })
        case 2:
            UIView.animate(withDuration: 0.5, animations: {
                self.tutorial.alpha = 0
            })
        default:
            return
        }
        
        tutorial.count += 1
    }
    
    func loadMessages() {
        let uid = AccountService.shared.currentUser.uid!
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("conversations").child(uid).child(userTypeString).child(receiverId).observe(.childAdded) { snapshot in
            let messageId = snapshot.key
            self.exitConnectionRequestMode()
            DataService.shared.getMessageById(messageId, completion: { message in
                self.messages.append(message)
                self.messagesCollection.reloadData()
                if message.senderId == uid {
                    self.removeCurrentStatusLabel()
                    self.addMessageStatusLabel(atIndex: self.messages.endIndex)
                }
                self.checkIfMessageIsConnectionRequest(message)
                self.studentKeyboardAccessory.hideQuickChatView()
                self.setActionViewUsable(true)
                self.scrollToBottom(animated: false)
            })
            self.markConversationRead()
        }
    }
    
    func checkIfMessageIsConnectionRequest(_ message: UserMessage) {
        let uid = AccountService.shared.currentUser.uid!
        if message.connectionRequestId != nil {
            canSendMessages = false
            Database.database().reference().child("connections").child(uid).child(message.partnerId()).observe(.value, with: { snapshot in
                guard let value = snapshot.value as? Bool else {
                    self.setActionViewUsable(false)
                    self.setMessageTextViewCoverHidden(false)
                    self.exitConnectionRequestMode()
                    return
                }
                if value {
                    self.canSendMessages = true
                    self.exitConnectionRequestMode()
                    self.setMessageTextViewCoverHidden(true)
                    self.messagesCollection.reloadData()
                } else {
                    self.canSendMessages = false
                    self.setActionViewUsable(false)
                    self.setMessageTextViewCoverHidden(false)
                }
            })
            connectionRequestAccepted = true
        }
    }
    
    func setMessageTextViewCoverHidden(_ result: Bool) {
        guard let keyboardAccessory = inputAccessoryView as? StudentKeyboardAccessory else { return }
        result ? keyboardAccessory.hideTextViewCover() : keyboardAccessory.showTextViewCover()
    }
    
    func checkForConnection(completion: @escaping (Bool) -> ()) {
        let uid = AccountService.shared.currentUser.uid!
        Database.database().reference().child("connections").child(uid).child(receiverId).observe(.value) { snapshot in
            guard let _ = snapshot.value as? Int else {
                self.connectionRequestAccepted = false
                self.enterConnectionRequestMode()
                completion(false)
                return
            }
            self.connectionRequestAccepted = true
            self.exitConnectionRequestMode()
            self.setActionViewUsable(true)
            self.setMessageTextViewCoverHidden(true)
            completion(true)
        }
    }
    func listenForSessionUpdates() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("userSessions").child(uid).child(userTypeString).observe(.childChanged) { (snapshot) in
            print("Data needs reload")
            self.reloadSessionWithId(snapshot.ref.key)
            snapshot.ref.setValue(1)
        }
        
    }
    
    func reloadSessionWithId(_ id: String) {
        DataService.shared.getSessionById(id) { (session) in
            if let fooOffset = self.messages.index(where: { (message) -> Bool in
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
                }
            } else {
                // item could not be found
            }
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

//class MessagingSystemTutorial : UIButton {
//    
//    let view : UIButton = {
//        let view = UIButton()
//        view.backgroundColor = Colors.purple
//        view.setImage(#imageLiteral(resourceName: "plusButton"), for: .normal)
//        view.applyDefaultShadow()
//        view.layer.cornerRadius = 17
//        view.isUserInteractionEnabled = false
//        view.alpha = 0
//        return view
//    }()
//    
//    let label : UILabel = {
//        let label = UILabel()
//        
//        label.font = Fonts.createBoldSize(18)
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.textColor = .white
//        
//        return label
//    }()
//    
//    let image : UIImageView = {
//        let view = UIImageView()
//        
//        view.image = #imageLiteral(resourceName: "finger")
//        view.transform = CGAffineTransform(scaleX: 1, y: -1)
//        view.scaleImage()
//        view.alpha = 0
//        
//        return view
//    }()
//    
//    var count : Int = 0
//    
//    let phrases = ["Your first message is a connection request. Write something friendly!", "You can continue messaging the tutor once they have accepted your connection request.", "Once they accept your connection request, you can use this button to schedule sessions or send images!"]
//    
//    required init() {
//        super.init(frame: .zero)
//
//        configureView()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configureView() {
//        addSubview(view)
//        addSubview(label)
//        addSubview(image)
//        backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        alpha = 0
//        label.text = phrases[0]
//        applyConstraints()
//    }
//    
//    func applyConstraints() {
//        label.snp.makeConstraints { (make) in
//            make.width.equalToSuperview().inset(15)
//            make.center.equalToSuperview()
//        }
//        
//        view.anchor(top: nil, left: self.leftAnchor, bottom: self.getBottomAnchor(), right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 34, height: 34)
//        
//        image.anchor(top: nil, left: self.leftAnchor, bottom: view.topAnchor, right: nil, paddingTop: 0, paddingLeft: 1, paddingBottom: 15, paddingRight: 0, width: 60, height: 60)
//    }
//}

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
            cell.bubbleWidthAnchor?.constant = 220
            cell.delegate = self
			cell.indexPath = [indexPath]
            cell.profileImageView.loadImage(urlString: chatPartner?.profilePicUrl ?? "")
            return cell
        }
        
        if message.connectionRequestId != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "connectionRequest", for: indexPath) as! ConnectionRequestCell
            cell.bubbleWidthAnchor?.constant = 220
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
            height = 158
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
        guard let message = messages[indexPath.item] as? UserMessage, let _ = message.sessionRequestId else {
            return
        }
    }
    
}

extension ConversationVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func handleSendingImage() {
        studentKeyboardAccessory.hideActionView()
        guard proceedWithCameraAccess() else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        }))
        present(ac, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var image: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = originalImage
        }
        guard let imageToUplaod = image else { return }
        uploadImageToFirebase(image: imageToUplaod)
    }
    
    func uploadImageToFirebase(image: UIImage) {
        dismiss(animated: true, completion: nil)
        guard let data = UIImageJPEGRepresentation(image, 0.2) else {
            return
        }
        let imageName = NSUUID().uuidString
        
        let metaDataDictionary = ["width": image.size.width, "height": image.size.height]
        let metaData = StorageMetadata(dictionary: metaDataDictionary)
        
        let storageRef = Storage.storage().reference().child(imageName)
        
        storageRef.putData(data, metadata: metaData) { metadataIn, _ in
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let imageMeta = metadataIn else { return }
            storageRef.downloadURL(completion: { url, error in
                if error != nil {
                    print(error.debugDescription)
                }
                guard let imageUrl = url else { return }
                let timestamp = Date().timeIntervalSince1970
                
                let message = UserMessage(dictionary: ["imageUrl": imageUrl, "timestamp": timestamp, "senderId": uid, "receiverId": self.receiverId])
                message.imageUrl = imageUrl.absoluteString
                message.data["imageWidth"] = image.size.width
                message.data["imageHeight"] = image.size.width
                self.sendMessage(message: message)
            })
        }
    }
    
    func proceedWithCameraAccess() -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            return true
        } else {
            let alert = UIAlertController(title: "Camera Required", message: "Camera access is absolutely necessary to use this app", preferredStyle: .alert)
            
            // Add "OK" Button to alert, pressing it will bring you to the settings app
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
            }))
            // Show the alert with animation
            self.present(alert, animated: true)
            return false
        }
    }
}

// MARK: Plus button actions -
extension ConversationVC: KeyboardAccessoryViewDelegate {
    
    func handleSessionRequest() {
        studentKeyboardAccessory.messageTextview.resignFirstResponder()
        studentKeyboardAccessory.hideActionView()
        showSessionRequestView()
    }

    func showSessionRequestView() {
        resignFirstResponder()
        FirebaseData.manager.fetchRequestSessionData(uid: receiverId) { (requestData) in
            guard let requestData = requestData else { return }
            let requestSessionModal = RequestSessionModal(uid: self.receiverId, requestData: requestData)
            requestSessionModal.frame = self.view.bounds
            self.view.addSubview(requestSessionModal)
        }
        
    }
    
    func shareUsernameForUserId() {
        studentKeyboardAccessory.toggleActionView()
        DynamicLinkFactory.shared.createLinkForUserId(receiverId) { shareUrl in
			guard let shareUrlString = shareUrl?.absoluteString else { print("her."); return }
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
            exitConnectionRequestMode()
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
		let eventStore : EKEventStore = EKEventStore()
		eventStore.requestAccess(to: .event) { (granted, error) in
			if error != nil {
				//AlertController.genericErrorAlertWithoutCancel(self, title: "Oops!", message: error!.localizedDescription)
				return
			}
			if granted {
				let event : EKEvent = EKEvent(eventStore: eventStore)
				event.title = "QuickTutor session: \(session.subject ?? "")"
				event.startDate = NSDate(timeIntervalSince1970: (session.startTime!)) as Date
				event.endDate =  NSDate(timeIntervalSince1970: (session.endTime!)) as Date
				event.calendar = eventStore.defaultCalendarForNewEvents
				do {
					try eventStore.save(event, span: .thisEvent)
				} catch let error as NSError {
					DispatchQueue.main.async {
						AlertController.genericErrorAlertWithoutCancel(self, title: "Oops!", message: error.localizedDescription)
					}
				}
				DispatchQueue.main.async {
					cell.setStatusLabel()
				}
			} else {
				DispatchQueue.main.async {
					AlertController.requestPermissionFromSettingsAlert(self, title: nil, message: "This action requires access to Calendar. Would you like to open settings and grant permission to Calendar?")
				}
			}
		}
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
    
    func handleNevermind() {
        
    }
	
    func handleCancel(id: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessions").child(id).child("status").setValue("cancelled")
        DataService.shared.getSessionById(id) { (session) in
            let chatPartnerId = session.partnerId()
            Database.database().reference().child("sessionCancels").child(chatPartnerId).child(uid).setValue(1)
            self.markSessionDataStale(id: id, partnerId: chatPartnerId)
        }
        cancelSessionModal?.dismiss()
        guard let index = cancelSessionIndex else { return }
        messagesCollection.reloadItems(at: [index])
        
    }
    
    func markSessionDataStale(id: String, partnerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        Database.database().reference().child("userSessions").child(uid)
            .child(userTypeString).child(id).setValue(0)
        Database.database().reference().child("userSessions").child(partnerId)
            .child(otherUserTypeString).child(id).setValue(0)
    }
}

extension ConversationVC: ImageMessageAnimatorDelegate {
    func imageAnimatorWillZoomIn(_ imageAnimator: ImageMessageAnimator) {
        studentKeyboardAccessory.messageTextview.resignFirstResponder()
    }
}
