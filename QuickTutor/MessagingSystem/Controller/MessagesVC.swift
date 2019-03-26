//
//  ViewController.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase
import UIKit
import SwipeCellKit

class MessagesVC: UIViewController {
    let refreshControl = UIRefreshControl()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.allowsMultipleSelection = false
        cv.register(ConversationCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    var messages = [UserMessage]()
    var conversationsDictionary = [String: UserMessage]()
    var swipeRecognizer: UIPanDirectionGestureRecognizer!
    
    let emptyBackround: EmptyMessagesBackground = {
        let bg = EmptyMessagesBackground()
        bg.isHidden = true
        return bg
    }()
    
    func setupViews() {
        setupMainView()
        setupCollectionView()
//        setupRefreshControl()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        edgesForExtendedLayout = []
        navigationItem.title = "Messages"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "connectionsIcon"), style: .plain, target: self, action: #selector(showContacts))
        navigationController?.navigationBar.barTintColor = Colors.newBackground
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.view.backgroundColor = Colors.darkBackground
        }
    }
    
    @objc func showContacts() {
        let vc = ConnectionsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupEmptyBackground() {
        view.addSubview(emptyBackround)
        emptyBackround.anchor(top: collectionView.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 250)
        emptyBackround.setupForCurrentUserType()
    }
    
    func setupRefreshControl() {
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshMessages), for: .valueChanged)
    }
    
    @objc func refreshMessages() {
        refreshControl.beginRefreshing()
        fetchConversations()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.refreshControl.endRefreshing()
        })
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnect), name: Notifications.didDisconnect.name, object: nil)
    }
    
    func postOverlayDismissalNotfication() {
        NotificationCenter.default.post(name: Notifications.hideOverlay.name, object: nil)
    }
    
    func postOverlayDisplayNotification() {
        NotificationCenter.default.post(name: Notifications.showOverlay.name, object: nil)
    }
    
    @objc func didDisconnect() {
        collectionView.reloadData()
    }
    
    var metaDataDictionary = [String: ConversationMetaData]()
    @objc func fetchConversations() {
        postOverlayDisplayNotification()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.postOverlayDismissalNotfication()
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        setupEmptyBackground()
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).observe(.childAdded) { snapshot in
            self.postOverlayDismissalNotfication()
            let userId = snapshot.key
            
            Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(userId).observe(.value, with: { snapshot in
                guard let metaData = snapshot.value as? [String: Any] else { return }
                guard let messageId = metaData["lastMessageId"] as? String else { return }
                self.emptyBackround.removeFromSuperview()
                self.collectionView.alwaysBounceVertical = true
                let conversationMetaData = ConversationMetaData(dictionary: metaData)
                self.metaDataDictionary[userId] = conversationMetaData
                self.getMessageById(messageId)
            })
        }
    }
    
    func getMessageById(_ messageId: String) {
        Database.database().reference().child("messages").child(messageId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let message = UserMessage(dictionary: value)
            message.uid = snapshot.key
            
            DataService.shared.getUserOfOppositeTypeWithId(message.partnerId(), completion: { (user) in
                message.user = user
                self.conversationsDictionary[message.partnerId()] = message
                self.attemptReloadOfTable()
            })
        }
    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    @objc func handleReloadTable() {
        self.messages = Array(self.conversationsDictionary.values)
        self.messages.sort(by: { $0.timeStamp.intValue > $1.timeStamp.intValue })
        
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationManager.shared.disableAllConversationNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationManager.shared.enableAllConversationNotifications()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tabBarItem = UITabBarItem(title: "Chat", image: UIImage(named: "chatTabBarIcon"), selectedImage: UIImage(named: "chatTabBarIcon"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessagesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ConversationCell
        cell.updateUI(message: messages[indexPath.item])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emptyBackround.isHidden = !messages.isEmpty
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell else { return }
        cell.contentView.backgroundColor = cell.contentView.backgroundColor?.darker(by: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell else { return }
        cell.contentView.backgroundColor = cell.contentView.backgroundColor?.lighter(by: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 80)
    }
    
}

extension MessagesVC: UIGestureRecognizerDelegate {
    
}

extension MessagesVC {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ConversationCell
        cell.handleTouchDown()
        let vc = ConversationVC()
        vc.receiverId = messages[indexPath.item].partnerId()
        let tappedCell = collectionView.cellForItem(at: indexPath) as! ConversationCell
        vc.chatPartner = tappedCell.chatPartner
        if let data = metaDataDictionary[tappedCell.chatPartner.uid] {
            vc.metaData = data
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MessagesVC: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            self.deleteMessages(index: indexPath.item)
        }
        
        deleteAction.image = UIImage(named: "deleteCellIcon")
        deleteAction.font = Fonts.createSize(12)
        deleteAction.backgroundColor = Colors.darkBackground
        
        let requestSessionAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            self.requestSession(index: indexPath.item)
        }
        
        requestSessionAction.image = UIImage(named: "sessionIcon")
        requestSessionAction.font = Fonts.createSize(12)
        requestSessionAction.backgroundColor = Colors.darkBackground
        
        return AccountService.shared.currentUserType == .learner ? [deleteAction, requestSessionAction] : [deleteAction]
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .drag
        options.buttonPadding = 5
        options.maximumButtonWidth = 60
        return options
    }
    
    func deleteMessages(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        guard let uid = Auth.auth().currentUser?.uid,
            let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell,
            let id = cell.chatPartner.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let conversationRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(id)
        conversationRef.removeValue()
        conversationRef.childByAutoId().removeValue()
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(id).removeValue()
        messages.remove(at: indexPath.item)
        conversationsDictionary.removeValue(forKey: id)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.collectionView.reloadData()
        }
    }
    
    func requestSession(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell,
            let id = cell.chatPartner.uid else { return }
        FirebaseData.manager.fetchTutor(id, isQuery: false) { (tutor) in
            self.collectionView.reloadItems(at: [indexPath])
            let vc = SessionRequestVC()
            vc.tutor = tutor
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
