//
//  MessageContentCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        self.setupEmptyBackground()
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).observe(.childAdded) { snapshot in
            if snapshot.exists() {
                self.emptyBackround.removeFromSuperview()
            }
            let userId = snapshot.key
            
            Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(userId).observe( .value, with: { (snapshot) in
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
        if messages[indexPath.item].connectionRequestId != nil {
            cell.disconnectButtonWidthAnchor?.constant = 0
        } else {
            cell.disconnectButtonWidthAnchor?.constant = 75
        }
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emptyBackround.isHidden = !messages.isEmpty
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell else { return }
        cell.background.backgroundColor = cell.background.backgroundColor?.darker(by: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCell else { return }
        cell.background.backgroundColor = cell.background.backgroundColor?.lighter(by: 15)
    }
    
    func setupSwipeActions() {
        swipeRecognizer = UIPanDirectionGestureRecognizer(direction: .horizontal, target: self, action: #selector(handleSwipe(sender:)))
        collectionView.addGestureRecognizer(swipeRecognizer)
        swipeRecognizer.delegate = self
    }
    
    @objc func handleSwipe(sender: UIPanDirectionGestureRecognizer) {
        
        guard sender == swipeRecognizer else { return }
        let swipeLocation = sender.location(in: collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: swipeLocation), let cell = self.collectionView.cellForItem(at: indexPath) as? ConversationCell else { return }
        let distance = sender.translation(in: self).x
        switch sender.state {
        case .changed:
            distance < 0 ? handleSwipeLeft(cell: cell, distance: distance) : handleSwipeRight(cell: cell, distance: distance)
        case .ended:
            handlePanEnd(cell: cell, distance: distance)
        case .cancelled:
            handlePanEnd(cell: cell, distance: distance)
        default:
            break
        }
        
        
    }
    
    func handleSwipeRight(cell: ConversationCell, distance: CGFloat) {
        cell.closeSwipeActions()
    }
    
    func handleSwipeLeft(cell: ConversationCell, distance: CGFloat) {
        cell.showAccessoryButtons(distance: distance)
    }
    
    func handlePanEnd(cell: ConversationCell, distance: CGFloat) {
        if distance > -75 {
            cell.backgroundRightAnchor?.constant = 0
            cell.animator?.fractionComplete = 0
        } else {
            if cell.disconnectButtonWidthAnchor?.constant == 0 {
                cell.backgroundRightAnchor?.constant = -75
                cell.animator?.fractionComplete = 100
            } else {
                cell.backgroundRightAnchor?.constant = -150
                cell.animator?.fractionComplete = 100
            }
        }
        
        UIView.animate(withDuration: 0.25) {
            cell.layoutIfNeeded()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fetchConversations()
        setupSwipeActions()
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

extension MessagesContentCell: ConversationCellDelegate {
    func conversationCellShouldDisconnect(_ conversationCell: ConversationCell) {
        guard let uid = Auth.auth().currentUser?.uid, let id = conversationCell.chatPartner.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let conversationRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(id)
        Database.database().reference().child("connections").child(uid).child(id).removeValue()
        Database.database().reference().child("connections").child(id).child(uid).removeValue()
        conversationRef.removeValue()
        let indexPath = collectionView.indexPath(for: conversationCell)!
        messages.remove(at: indexPath.item)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.collectionView.reloadData()
        }
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(id).removeValue()
    }
    
    func conversationCellShouldDeleteMessages(_ conversationCell: ConversationCell) {
        guard let uid = Auth.auth().currentUser?.uid, let id = conversationCell.chatPartner.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let conversationRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(id)
        conversationRef.removeValue()
        conversationRef.childByAutoId().removeValue()
        let indexPath = collectionView.indexPath(for: conversationCell)!
        messages.remove(at: indexPath.item)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.collectionView.reloadData()
        }
    }
}
