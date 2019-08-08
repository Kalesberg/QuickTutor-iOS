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
import SkeletonView

class MessagesVC: UIViewController {
    let refreshControl = UIRefreshControl()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.newScreenBackground
        cv.allowsMultipleSelection = false
        cv.register(ConversationCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    var messages = [UserMessage]()
    var filteredMessages = [UserMessage]()
    var conversationsDictionary = [String: UserMessage]()
    var swipeRecognizer: UIPanDirectionGestureRecognizer!
    
    let emptyBackround: EmptyMessagesBackground = {
        let bg = EmptyMessagesBackground()
        bg.isHidden = true
        return bg
    }()
    
    private var userStatuses = [UserStatus]()
    
    // Save the old database reference in order to avoid duplicated calls.
    var conversationMetaDataRef: DatabaseReference?
    var conversationMetaDataHandle: DatabaseHandle?
    
    func setupViews() {
        setupMainView()
        setupCollectionView()
        setupEmptyBackground()
        setupRefreshControl()
        setupSearchController()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.newScreenBackground
        edgesForExtendedLayout = []
        navigationItem.title = "Messages"
        let connectionButton = UIBarButtonItem(image: UIImage(named: "connectionsIcon"), style: .plain, target: self, action: #selector(showContacts))
        let searchButton = UIBarButtonItem(image: UIImage(named: "searchIconMain"), style: .plain, target: self, action: #selector(onClickSearch))
        navigationItem.rightBarButtonItems = [connectionButton, searchButton]
        
        navigationController?.navigationBar.barTintColor = Colors.newNavigationBarBackground
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.view.backgroundColor = Colors.newNavigationBarBackground
        }
    }
    
    @objc func showContacts() {
        let vc = ConnectionsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func onClickSearch () {
        DispatchQueue.main.async {
            if #available(iOS 11.0, *) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.navigationItem.hidesSearchBarWhenScrolling = false
                    self.view.setNeedsLayout()
                }) { finished in
                    if finished {
                        self.navigationItem.hidesSearchBarWhenScrolling = true
                    }
                }
            }
        }
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupEmptyBackground() {
        emptyBackround.isHidden = true
        view.addSubview(emptyBackround)
        emptyBackround.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 250)
        emptyBackround.setupForCurrentUserType()
    }
    
    func setupRefreshControl() {
        
        if #available(iOS 11.0, *) {
            // Extend the view to the top of screen.
            self.edgesForExtendedLayout = UIRectEdge.top
            self.extendedLayoutIncludesOpaqueBars = true
            self.navigationController?.navigationBar.isTranslucent = false
        }
        
        refreshControl.tintColor = Colors.purple
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshMessages), for: .valueChanged)
    }
    
    @objc func refreshMessages() {
        conversationsDictionary.removeAll()
        messages.removeAll()
        filteredMessages.removeAll()
        collectionView.reloadData()
        
        // End the animation of refersh control
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.fetchConversations()
            self.refreshControl.endRefreshing()
        })
    }
    
    // MARK: - Search Controler Handlers
    var searchController = UISearchController(searchResultsController: nil)
    func setupSearchController() {
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            searchController.definesPresentationContext = true
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.tintColor = .white
            searchController.searchResultsUpdater = self
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func inSearchMode() -> Bool {
        return !searchBarIsEmpty()
    }
    
    func filterMessageForSearchText(_ searchText: String, scope: String = "All") {
        filteredMessages = messages.filter { $0.user?.formattedName.contains(searchText) == true || $0.text?.contains(searchText) == true }
        collectionView.reloadData()
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        collectionView.isUserInteractionEnabled = false
        collectionView.showAnimatedSkeleton(usingColor: Colors.gray)
        
        let userTypeString = AccountService.shared.currentUserType.rawValue
        
        Database
            .database()
            .reference()
            .child("conversationMetaData")
            .child(uid)
            .child(userTypeString)
            .queryLimited(toLast: 100).observeSingleEvent(of: .value) { (snapshot) in
                guard let snap = snapshot.children.allObjects as? [DataSnapshot], snap.count > 0 else {
                    // TODO: end of loading
                    self.emptyBackround.isHidden = false
                    self.collectionView.isUserInteractionEnabled = true
                    self.collectionView.hideSkeleton()
                    return
                }
                
                var index = -1
                var hasMessage = false
                for child in snap {
                    index += 1;
                    guard let meta = child.value as? [String: Any] else {
                        if index == snap.count - 1 {
                            self.emptyBackround.isHidden = false
                        }
                        self.collectionView.isUserInteractionEnabled = true
                        self.collectionView.hideSkeleton()
                        return
                    }
                    
                    if let _ = meta["lastMessageId"] as? String {
                        hasMessage = true
                        break
                    }
                }
                
                self.emptyBackround.isHidden = hasMessage
                
                // Remove old database reference and handle.
                if let ref = self.conversationMetaDataRef, let handle = self.conversationMetaDataHandle {
                    ref.removeObserver(withHandle: handle)
                    self.conversationMetaDataRef = nil
                    self.conversationMetaDataHandle = nil
                }
                
                self.conversationMetaDataRef = Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString)
                self.conversationMetaDataHandle = self.conversationMetaDataRef?.observe(.childAdded) { snapshot in
                    let userId = snapshot.key
                    Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(userId).observe(.value, with: { snapshot in
                        guard let metaData = snapshot.value as? [String: Any],
                            let messageId = metaData["lastMessageId"] as? String else {
                                // TODO: end of loading
                                self.collectionView.isUserInteractionEnabled = true
                                self.collectionView.hideSkeleton()
                                return
                        }
                        self.collectionView.alwaysBounceVertical = true
                        let conversationMetaData = ConversationMetaData(dictionary: metaData)
                        self.metaDataDictionary[userId] = conversationMetaData
                        self.updateTabBarBadge()
                        self.getMessageById(messageId)
                    })
                }
        }
    }
    
    func getMessageById(_ messageId: String) {
        Database.database().reference().child("messages").child(messageId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                self.collectionView.isUserInteractionEnabled = true
                self.collectionView.hideSkeleton()
                return
            }
            let message = UserMessage(dictionary: value)
            message.uid = snapshot.key
            guard let partnerId = message.partnerId() else { return }
            UserFetchService.shared.getUserOfOppositeTypeWithId(partnerId) { user in
                guard let user = user else {
                    self.collectionView.isUserInteractionEnabled = true
                    self.collectionView.hideSkeleton()
                    return
                }
                
                message.user = user
                
                if !self.userStatuses.isEmpty {
                    message.user?.isOnline = self.userStatuses.first(where: { $0.userId == user.uid })?.status == .online
                }
                
                self.conversationsDictionary[partnerId] = message
                self.attemptReloadOfTable()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.collectionView.isUserInteractionEnabled = true
                    self.collectionView.hideSkeleton()
                }
            }
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
        
        self.emptyBackround.isHidden = self.messages.count != 0
        
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
    }
    
    private func updateTabBarBadge() {
        let messageIndex = .learner == AccountService.shared.currentUserType ? 3 : 2
        
        guard let rootVC = tabBarController?.viewControllers?[messageIndex] else { return }
        
        let badgeCount = metaDataDictionary.values.filter({ false == $0.hasRead }).count
        if 0 < badgeCount {
            rootVC.tabBarItem.badgeColor = .qtAccentColor
            rootVC.tabBarItem.badgeValue = 9 < badgeCount ? "9+" : "\(badgeCount)"
            // Update the badge position
            if let tabBarController = rootVC.tabBarController {
                tabBarController.adjustBadgePosition(tabBarItemView: tabBarController.tabBar.subviews[messageIndex + 1])
            }
        } else {
            rootVC.tabBarItem.badgeValue = nil
        }
    }
    
    private func getUserStatuses () {
        UserStatusService.shared.getUserStatuses { statuses in
            if !statuses.isEmpty {
                self.userStatuses = statuses
                
                var reloadIndexPaths = [IndexPath]()
                for index in 0..<self.messages.count {
                    let isOnline = self.userStatuses.first(where: { $0.userId == self.messages[index].user?.uid })?.status == .online
                    if isOnline != self.messages[index].user?.isOnline {
                        self.messages[index].user?.isOnline = isOnline
                        reloadIndexPaths.append(IndexPath(item: index, section: 0))
                    }
                }
                
                if !reloadIndexPaths.isEmpty {
                    self.collectionView.reloadItems(at: reloadIndexPaths)
                }
            }
        }
    }
    
    private func showDeleteMessagesAlert(index: Int) {
        var title = "Delete Messages"
        let data = inSearchMode() ? filteredMessages : messages
        if let name = data[index].user?.firstName {
            title.append(contentsOf: " with \(name)")
        }
        
        let actionSheet = UIAlertController(title: "\(title)?", message: "The messages will be permanently deleted.", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Delete Messages", style: .destructive) { _ in
            self.deleteMessages(index: index)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getUserStatuses()
        
        collectionView.isSkeletonable = true
        collectionView.prepareSkeleton { _ in
            self.fetchConversations()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationManager.shared.disableAllConversationNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(hidden: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) {
            self.collectionView.reloadData() // Reload cells to remove UI state changes
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationManager.shared.enableAllConversationNotifications()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "chatTabBarIcon"), selectedImage: UIImage(named: "chatTabBarIcon"))
        tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessagesVC: UICollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cellId"
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ConversationCell
        let message = inSearchMode() ? filteredMessages[indexPath.item] : messages[indexPath.item]
        cell.updateUI(message: message)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inSearchMode() ? filteredMessages.count : messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell else { return }
        cell.contentView.backgroundColor = cell.contentView.backgroundColor?.darker(by: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell else { return }
        cell.contentView.backgroundColor = cell.contentView.backgroundColor?.lighter(by: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 80)
    }
    
}

extension MessagesVC: UIGestureRecognizerDelegate {
    
}

extension MessagesVC {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = inSearchMode() ? filteredMessages : messages
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell,
            indexPath.item <= data.count,
            let receiverId = data[indexPath.item].partnerId() else { return }
        
        cell.handleTouchDown()
        let vc = ConversationVC()
        vc.receiverId = receiverId
        vc.chatPartner = cell.chatPartner
        if let data = metaDataDictionary[cell.chatPartner.uid] {
            vc.metaData = data
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.resignFirstResponder()
    }
}

extension MessagesVC: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            self.showDeleteMessagesAlert(index: indexPath.item)
        }
        
        deleteAction.image = UIImage(named: "ic_payment_del")
        deleteAction.highlightedImage = UIImage(named: "ic_payment_del")?.alpha(0.2)
        deleteAction.font = Fonts.createSize(12)
        deleteAction.backgroundColor = Colors.newScreenBackground
        deleteAction.highlightedBackgroundColor = Colors.newScreenBackground
        deleteAction.hidesWhenSelected = true
        
        let requestSessionAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            self.requestSession(index: indexPath.item)
        }
        
        requestSessionAction.image = UIImage(named: "sessionIcon")
        requestSessionAction.highlightedImage = UIImage(named: "sessionIcon")?.alpha(0.2)
        requestSessionAction.font = Fonts.createSize(12)
        requestSessionAction.backgroundColor = Colors.newScreenBackground
        requestSessionAction.highlightedBackgroundColor = Colors.newScreenBackground
        requestSessionAction.hidesWhenSelected = true
        
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
        
        if inSearchMode() {
            if let messageIndex = messages.firstIndex(where: { $0.uid == filteredMessages[indexPath.item].uid }) {
                messages.remove(at: messageIndex)
            }
            filteredMessages.remove(at: indexPath.item)
            
        } else {
            messages.remove(at: indexPath.item)
            self.emptyBackround.isHidden = self.messages.count != 0
        }
        
        conversationsDictionary.removeValue(forKey: id)
        metaDataDictionary.removeValue(forKey: id)
        updateTabBarBadge()
        
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

extension MessagesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterMessageForSearchText(searchController.searchBar.text!)
    }
}
