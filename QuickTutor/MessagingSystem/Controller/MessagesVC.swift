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
    
    let emptyBackround: EmptyMessagesBackground = {
        let bg = EmptyMessagesBackground()
        bg.isHidden = true
        return bg
    }()
    
    private var userStatuses: [UserStatus] = []
    
    private var aryConversationMetadata: [ConversationMetaData] = []
    private var aryFilteredConversationMetadata: [ConversationMetaData] = []
    
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
        let searchButton = UIBarButtonItem(image: UIImage(named: "ic_search"), style: .plain, target: self, action: #selector(onClickSearch))
        navigationItem.rightBarButtonItems = [connectionButton, searchButton]
        
        navigationController?.navigationBar.barTintColor = Colors.newNavigationBarBackground
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.view.backgroundColor = Colors.newNavigationBarBackground
        }
    }
    
    @objc func showContacts() {
        self.view.endEditing(true)
        
        let vc = ConnectionsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func onClickSearch () {
        DispatchQueue.main.async {
            if #available(iOS 11.0, *) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.navigationItem.hidesSearchBarWhenScrolling = false
                    self.navigationItem.largeTitleDisplayMode = .always
                    if !self.aryConversationMetadata.isEmpty {
                        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                    }
                    self.view.setNeedsLayout()
                }) { finished in
                    if finished {
                        self.navigationItem.hidesSearchBarWhenScrolling = true
                        self.navigationItem.largeTitleDisplayMode = .automatic
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
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshMessages), for: .valueChanged)
    }
    
    @objc func refreshMessages() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Search Controler Handlers
    var searchController = UISearchController(searchResultsController: nil)
    func setupSearchController() {
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            searchController.searchBar.autocorrectionType = .yes
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
        aryFilteredConversationMetadata = aryConversationMetadata.filter {
            $0.partner?.formattedName.lowercased().contains(searchText.lowercased()) == true
                || $0.lastMessageContent?.lowercased().contains(searchText.lowercased()) == true
        }
    }
    
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnect), name: Notifications.didDisconnect.name, object: nil)
    }
    
    @objc func didDisconnect() {
        collectionView.reloadData()
    }
    
    var metaDataDictionary = [String: ConversationMetaData]()
    private func fetchConversations() {
        guard let uid = Auth.auth().currentUser?.uid else {
            emptyBackround.isHidden = false
            endOfFetchConversations()
            return
        }
        
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let reference = Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString)
        reference.observe(.value) { snapshot in
            guard let dicMetadatas = snapshot.value as? [String: Any] else {
                self.emptyBackround.isHidden = false
                self.endOfFetchConversations()
                self.updateTabBarBadge()
                return
            }
            
            var tmpConversationMetaData: [ConversationMetaData] = []
            let metadataGroup = DispatchGroup()
            for partnerId in dicMetadatas.keys {
                guard let dicMetadata = dicMetadatas[partnerId] as? [String: Any],
                    let lastMessageId = dicMetadata["lastMessageId"] as? String,
                    !lastMessageId.isEmpty else { continue }
                
                
                let objConversationMetadata = ConversationMetaData(uid: partnerId, dictionary: dicMetadata)
                metadataGroup.enter()
                UserFetchService.shared.getUserOfOppositeTypeWithId(partnerId) { objPartner in
                    guard let objPartner = objPartner else {
                        metadataGroup.leave()
                        return
                    }
                    
                    if !self.userStatuses.isEmpty {
                        objPartner.isOnline = self.userStatuses.first(where: { $0.userId == partnerId })?.status == .online
                    }
                    objConversationMetadata.partner = objPartner
                    
                    Database.database().reference().child("messages").child(lastMessageId).observeSingleEvent(of: .value) { snapshot in
                        metadataGroup.leave()
                        guard let dicMessage = snapshot.value as? [String: Any] else { return }
                        
                        let message = UserMessage(dictionary: dicMessage)
                        message.uid = snapshot.key
                        objConversationMetadata.message = message
                        tmpConversationMetaData.append(objConversationMetadata)
                    }
                }
            }
            
            metadataGroup.notify(queue: .main) {
                self.aryConversationMetadata = tmpConversationMetaData.sorted(by: { ($0.lastUpdated ?? 0) > ($1.lastUpdated ?? 0) })
                self.filterMessageForSearchText(self.searchController.searchBar.text ?? "")
                
                self.emptyBackround.isHidden = !self.aryConversationMetadata.isEmpty                
                self.endOfFetchConversations()
                self.collectionView.reloadData()
                self.updateTabBarBadge()
            }
        }
    }
    
    private func endOfFetchConversations() {
        if self.collectionView.isSkeletonActive {
            self.collectionView.isUserInteractionEnabled = true
            self.collectionView.hideSkeleton()
        }
    }
    
    private func updateTabBarBadge() {
        let messageIndex = .learner == AccountService.shared.currentUserType ? 3 : 2
        
        guard let rootVC = tabBarController?.viewControllers?[messageIndex] else { return }
        
        let badgeCount = aryConversationMetadata.filter({ false == $0.hasRead }).count
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
    
    private func getUserStatuses() {
        UserStatusService.shared.getUserStatuses { statuses in
            if !statuses.isEmpty {
                self.userStatuses = statuses
                
                var reloadIndexPaths: [IndexPath] = []
                for index in 0 ..< self.aryConversationMetadata.count {
                    let isOnline = self.userStatuses.first(where: { $0.userId == self.aryConversationMetadata[index].partner?.uid })?.status == .online
                    if isOnline != self.aryConversationMetadata[index].partner?.isOnline {
                        self.aryConversationMetadata[index].partner?.isOnline = isOnline
                        if !self.inSearchMode() {
                            reloadIndexPaths.append(IndexPath(item: index, section: 0))
                        }
                    }
                }
                
                for index in 0 ..< self.aryFilteredConversationMetadata.count {
                    let isOnline = self.userStatuses.first(where: { $0.userId == self.aryFilteredConversationMetadata[index].partner?.uid })?.status == .online
                    if isOnline != self.aryFilteredConversationMetadata[index].partner?.isOnline {
                        self.aryFilteredConversationMetadata[index].partner?.isOnline = isOnline
                        if self.inSearchMode() {
                            reloadIndexPaths.append(IndexPath(item: index, section: 0))
                        }
                    }
                }
                
                if !reloadIndexPaths.isEmpty {
                    self.collectionView.reloadItems(at: reloadIndexPaths)
                }
            }
        }
    }
    
    private func showDeleteMessagesAlert(index: Int) {
        var title = "Delete Message"
        let data = inSearchMode() ? aryFilteredConversationMetadata : aryConversationMetadata
        if let name = data[index].partner?.firstName {
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
            self.collectionView.isUserInteractionEnabled = false
            self.collectionView.showAnimatedSkeleton(usingColor: Colors.gray)
            self.fetchConversations()
        }
        
        // add notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow (_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide (_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationManager.shared.disableAllConversationNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(hidden: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        collectionView.reloadData()
        view.setNeedsLayout()
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
    
    // MARK: - Notification Handler
    @objc
    private func keyboardWillShow (_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            collectionView.contentInset = UIEdgeInsets (top: 0.0, left: 0.0, bottom: keyboardFrame.cgRectValue.height, right: 0.0)
        }
    }
    
    @objc
    private func keyboardWillHide (_ notification: Notification) {
        collectionView.contentInset = UIEdgeInsets (top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
}

extension MessagesVC: UICollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cellId"
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ConversationCell
        let objConversationMetadata = inSearchMode() ? aryFilteredConversationMetadata[indexPath.item] : aryConversationMetadata[indexPath.item]
        cell.updateUI(metadata: objConversationMetadata)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inSearchMode() ? aryFilteredConversationMetadata.count : aryConversationMetadata.count
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

extension MessagesVC {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = inSearchMode() ? aryFilteredConversationMetadata : aryConversationMetadata
        let objConversationMetadata = data[indexPath.item]
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell else { return }
        cell.handleTouchDown()
        
        self.view.endEditing(true)
        
        let vc = ConversationVC()
        vc.receiverId = objConversationMetadata.chatPartnerId()
        vc.chatPartner = data[indexPath.item].partner
        vc.metaData = objConversationMetadata
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
            if let index = aryConversationMetadata.firstIndex(where: { $0.uid == aryFilteredConversationMetadata[indexPath.item].uid }) {
                aryConversationMetadata.remove(at: index)
            }
            aryFilteredConversationMetadata.remove(at: indexPath.item)
        } else {
            aryConversationMetadata.remove(at: indexPath.item)
        }
        emptyBackround.isHidden = !aryConversationMetadata.isEmpty
        collectionView.deleteItems(at: [indexPath])
    }
    
    func requestSession(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell,
            let id = cell.chatPartner.uid else { return }
        FirebaseData.manager.fetchTutor(id, isQuery: false) { (tutor) in            
            DispatchQueue.main.async {
                self.view.endEditing(true)
                
                self.collectionView.reloadItems(at: [indexPath])
                let vc = SessionRequestVC()
                vc.tutor = tutor
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension MessagesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        filterMessageForSearchText(query)
        collectionView.reloadData()
    }
}
