//
//  MessageContentCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit
import Lottie

class MessagesContentCell: BaseContentCell {
    
    var messages = [UserMessage]()
    var conversationsDictionary = [String: UserMessage]()
    var parentViewController: UIViewController?
    var swipeRecognizer: UIPanDirectionGestureRecognizer!
    
    let emptyBackround: EmptyMessagesBackground = {
        let bg = EmptyMessagesBackground()
        bg.isHidden = true
        return bg
    }()
    
    override func setupViews() {
        super.setupViews()
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.register(ConversationCell.self, forCellWithReuseIdentifier: "cellId")
    }
	
    private func setupEmptyBackground() {
        addSubview(emptyBackround)
        emptyBackround.anchor(top: collectionView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 250)
        emptyBackround.setupForCurrentUserType()
    }
    
    override func setupRefreshControl() {
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
    
    var metaDataDictionary = [String: ConversationMetaData]()
    @objc func fetchConversations() {
        postOverlayDisplayNotification()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        self.setupEmptyBackground()
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).observe(.childAdded) { snapshot in
            self.postOverlayDismissalNotfication()
            let userId = snapshot.key
            
            Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(userId).observe( .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.emptyBackround.removeFromSuperview()
                }
                guard let metaData = snapshot.value as? [String: Any] else { return }
                guard let messageId = metaData["lastMessageId"] as? String else { return }
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ConversationCell
        cell.updateUI(message: messages[indexPath.item])
//        if messages[indexPath.item].connectionRequestId != nil {
//            cell.disconnectButtonWidthAnchor?.constant = 0
//        } else {
//            cell.disconnectButtonWidthAnchor?.constant = 75
//        }
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fetchConversations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MessagesContentCell: UIGestureRecognizerDelegate {
    
}

extension MessagesContentCell {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.receiverId = messages[indexPath.item].partnerId()
        let tappedCell = collectionView.cellForItem(at: indexPath) as! ConversationCell
        vc.navigationItem.title = tappedCell.usernameLabel.text
        vc.chatPartner = tappedCell.chatPartner
        if let data = metaDataDictionary[tappedCell.chatPartner.uid] {
            vc.metaData = data
        }
        navigationController.pushViewController(vc, animated: true)
    }
}

extension MessagesContentCell: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            // handle action by updating model with deletion
            self.deleteMessages(index: indexPath.item)
        }
        
        // customize the action appearance
        deleteAction.image = #imageLiteral(resourceName: "deleteMessagesIcon")
        deleteAction.title = "Delete"
        deleteAction.font = Fonts.createSize(12)
        deleteAction.backgroundColor = UIColor(hex: "#AF1C49")
        
        let disconnectAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            self.disconnect(index: indexPath.item)
        }
        disconnectAction.image = #imageLiteral(resourceName: "disconnectIcon")
        disconnectAction.title = "Disconnect"
        disconnectAction.font = Fonts.createSize(12)
        disconnectAction.backgroundColor = UIColor(hex: "#851537")
        
        return [deleteAction, disconnectAction]
    }
    
    func disconnect(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        guard let uid = Auth.auth().currentUser?.uid,
            let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell,
            let id = cell.chatPartner.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let conversationRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(id)
        Database.database().reference().child("connections").child(uid).child(id).removeValue()
        Database.database().reference().child("connections").child(id).child(uid).removeValue()
        conversationRef.removeValue()
        messages.remove(at: indexPath.item)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.collectionView.reloadData()
        }
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(id).removeValue()
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.collectionView.reloadData()
        }
    }
}
