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
    
    let emptyBackround: EmptyMessagesBackground = {
        let bg = EmptyMessagesBackground()
        bg.isHidden = true
        return bg
    }()
    
    override func setupViews() {
        super.setupViews()
        setupEmptyBackground()
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.register(ConversationCell.self, forCellWithReuseIdentifier: "cellId")
    }
    
    private func setupEmptyBackground() {
        addSubview(emptyBackround)
        emptyBackround.anchor(top: collectionView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 250)
        emptyBackround.setupForTutor()
    }
    
    override func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(fetchConversations), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc func fetchConversations() {
        conversationsDictionary.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("conversations").child(uid).observe(.childAdded) { snapshot in
            let userId = snapshot.key
            Database.database().reference().child("conversations").child(uid).child(userId).observe(.childAdded, with: { snapshot in
                let messageId = snapshot.key
                self.getMessageById(messageId)
            })
            self.refreshControl.endRefreshing()
        }
    }
    
    func getMessageById(_ messageId: String) {
        Database.database().reference().child("messages").child(messageId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let message = UserMessage(dictionary: value)
            message.uid = snapshot.key
            self.conversationsDictionary[message.partnerId()] = message
            self.messages = Array(self.conversationsDictionary.values)
            self.messages.sort(by: { $0.timeStamp.intValue > $1.timeStamp.intValue })
            self.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ConversationCell
        cell.updateUI(message: messages[indexPath.item])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emptyBackround.isHidden = !messages.isEmpty
        return messages.count
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fetchConversations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension MessagesContentCell {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.receiverId = messages[indexPath.item].partnerId()
        let tappedCell = collectionView.cellForItem(at: indexPath) as! ConversationCell
        vc.navigationItem.title = tappedCell.usernameLabel.text
        vc.chatPartner = tappedCell.chatPartner
        navigationController.pushViewController(vc, animated: true)
    }
}
