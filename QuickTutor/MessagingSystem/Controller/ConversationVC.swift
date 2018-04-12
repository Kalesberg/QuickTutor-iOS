//
//  ConversationVC.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class ConversationVC: UICollectionViewController {
    
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
    
    var imageCellImageView: UIImageView?
    let zoomView = UIImageView()
    let zoomBackground = UIView()
    
    let navBarCover: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let inputAccessoryCover: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let studentKeyboardAccessory = StudentKeyboardAccessory()
    let teacherKeyboardAccessory = TeacherKeyboardAccessory()
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupMainView()
        setupMessagesCollection()
        setupNavBar()
        setupEmptyBackground()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        studentKeyboardAccessory.delegate = self
        teacherKeyboardAccessory.delegate = self
    }
    
    private func setupMessagesCollection() {
        messagesCollection.dataSource = self
        messagesCollection.delegate = self
        collectionView = messagesCollection
    }
    
    private func setupEmptyBackground() {
        view.addSubview(emptyCellBackground)
        emptyCellBackground.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 300)
        view.addConstraint(NSLayoutConstraint(item: emptyCellBackground, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "backButton")
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"backButton")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(pop))
        setupTitleView()
    }
    
    private func setupTitleView() {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        let titleView = CustomTitleView(frame: frame)
        titleView.updateUI(user: chatPartner)
        navigationItem.titleView = titleView
        guard let profilePicUrl = chatPartner?.profilePicUrl else { return }
        titleView.imageView.imageView.loadImage(urlString: profilePicUrl)
    }
    
    func teardownConnectionRequest() {
        self.studentKeyboardAccessory.hideQuickChatView()
        self.emptyCellBackground.removeFromSuperview()
    }
    
    @objc func pop() {
        navigationController?.popViewController(animated: true)
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
                self.studentKeyboardAccessory.hideQuickChatView()
                self.scrollToBottom(animated: false)
            })
            self.markConversationRead()
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
            cell.delegate = self
            cell.updateUI(message: message)
            cell.profileImageView.loadImage(urlString: (chatPartner?.profilePicUrl)!)
            return cell
        }
        
        if message.sessionRequestId != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sessionMessage", for: indexPath) as! SessionRequestCell
            cell.updateUI(message: message)
            cell.profileImageView.loadImage(urlString: (chatPartner?.profilePicUrl)!)
            return cell
        }
        
        if message.connectionRequestId != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "connectionRequest", for: indexPath) as! ConnectionRequestCell
            cell.bubbleWidthAnchor?.constant = 200
            cell.chatPartner = chatPartner
            cell.updateUI(message: message)
            cell.profileImageView.loadImage(urlString: (chatPartner?.profilePicUrl)!)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textMessage", for: indexPath) as! UserMessageCell
        cell.updateUI(message: message)
        cell.bubbleWidthAnchor?.constant = cell.textView.text.estimateFrameForFontSize(14).width + 20
        cell.profileImageView.loadImage(urlString: (chatPartner?.profilePicUrl)!)
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
        let vc = ViewSessionRequestVC()
        vc.sessionRequestId = sessionRequestId
        vc.senderId = message.senderId
        navigationController?.pushViewController(vc, animated: true)
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

extension ConversationVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func handleSendingImage() {
        studentKeyboardAccessory.hideActionView()
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
        
        Storage.storage().reference().child(imageName).putData(data, metadata: metaData) { metadata, _ in
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            let timestamp = Date().timeIntervalSince1970
            
            let message = UserMessage(dictionary: ["imageUrl": imageUrl, "timestamp": timestamp, "senderId": uid, "receiverId": self.receiverId])
            message.data["imageWidth"] = image.size.width
            message.data["imageHeight"] = image.size.width
            self.sendMessage(message: message)
        }
    }
}

// MARK: Image zooming -
extension ConversationVC: ImageMessageCellDelegate {
    
    func handleZoomFor(imageView: UIImageView) {
        studentKeyboardAccessory.messageTextview.resignFirstResponder()
        teacherKeyboardAccessory.messageTextview.resignFirstResponder()
        guard let window = UIApplication.shared.keyWindow else { return }
        navBarCover.alpha = 0
        inputAccessoryCover.alpha = 0
        window.addSubview(navBarCover)
        
        guard let navBarHeight = navigationController?.navigationBar.frame.height else { return }
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        navBarCover.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: nil, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: navBarHeight + statusBarHeight)
        
        imageCellImageView = imageView
        
        zoomBackground.backgroundColor = .black
        zoomBackground.alpha = 0
        zoomBackground.frame = view.frame
        zoomBackground.isUserInteractionEnabled = true
        zoomBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        view.addSubview(zoomBackground)
        
        imageView.alpha = 0
        guard let startingFrame = imageView.superview?.convert(imageView.frame, to: nil) else { return }
        zoomView.image = imageView.image
        zoomView.contentMode = .scaleAspectFill
        zoomView.clipsToBounds = true
        zoomView.backgroundColor = .black
        zoomView.frame = startingFrame
        zoomView.isUserInteractionEnabled = true
        view.addSubview(zoomView)
        
        zoomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        
        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            let height = (self.view.frame.width / startingFrame.width) * startingFrame.height
            let y = self.view.frame.height / 2 - height / 2
            self.zoomView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
            self.zoomBackground.alpha = 1
            self.navBarCover.alpha = 1
            self.inputAccessoryView?.alpha = 0
        }.startAnimation()
        
    }
    
    @objc func zoomOut() {
        guard let startingFrame = imageCellImageView!.superview?.convert(imageCellImageView!.frame, to: nil) else { return }
        
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.zoomView.frame = startingFrame
            self.zoomBackground.alpha = 0
            self.navBarCover.alpha = 0
            self.inputAccessoryView?.alpha = 1
        }
        
        animator.addCompletion { _ in
            self.zoomBackground.removeFromSuperview()
            self.zoomView.removeFromSuperview()
            self.imageCellImageView?.alpha = 1
            self.navBarCover.removeFromSuperview()
            self.becomeFirstResponder()
        }
        
        animator.startAnimation()
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
