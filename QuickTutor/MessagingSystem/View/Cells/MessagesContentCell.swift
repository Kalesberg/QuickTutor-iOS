//
//  MessageContentCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import Firebase

enum PanDirection {
    case vertical
    case horizontal
}

class UIPanDirectionGestureRecognizer: UIPanGestureRecognizer {
    
    let direction : PanDirection
    
    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if state == .began {
            
            let vel = velocity(in: self.view!)
            switch direction {
            case .horizontal where fabs(vel.y) > fabs(vel.x):
                state = .cancelled
            case .vertical where fabs(vel.x) > fabs(vel.y):
                state = .cancelled
            default:
                break
            }
        }
    }
}


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
        setupEmptyBackground()
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
    
    @objc func fetchConversations() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("conversations").child(uid).child(userTypeString).observe(.childAdded) { snapshot in
            let userId = snapshot.key
            Database.database().reference().child("conversations").child(uid).child(userTypeString).child(userId).observe( .childAdded, with: { (snapshot) in
                let messageId = snapshot.key
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
//        cell.clearData()
        cell.updateUI(message: messages[indexPath.item])
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emptyBackround.isHidden = !messages.isEmpty
        return messages.count
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
        cell.backgroundRightAnchor?.constant = 0
        UIView.animate(withDuration: 0.25) {
            cell.layoutIfNeeded()
        }
    }
    
    func handleSwipeLeft(cell: ConversationCell, distance: CGFloat) {
        guard distance > -130 else { return }
        guard cell.backgroundRightAnchor?.constant != -130 else { return }
        cell.backgroundRightAnchor?.constant = distance
        cell.animator?.fractionComplete = abs(distance / 130)
        cell.layoutIfNeeded()
    }
    
    func handlePanEnd(cell: ConversationCell, distance: CGFloat) {
        if distance > -65 {
            cell.backgroundRightAnchor?.constant = 0
            cell.animator?.fractionComplete = 0
        } else {
            cell.backgroundRightAnchor?.constant = -130
            cell.animator?.fractionComplete = 100
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
        conversationRef.childByAutoId().setValue(["removed": true, "removedAt": Date().timeIntervalSince1970])
        let indexPath = collectionView.indexPath(for: conversationCell)!
        messages.remove(at: indexPath.item)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.collectionView.reloadData()
        }
    }
    
    func conversationCellShouldDeleteMessages(_ conversationCell: ConversationCell) {
        guard let uid = Auth.auth().currentUser?.uid, let id = conversationCell.chatPartner.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let conversationRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(id)
        conversationRef.removeValue()
        conversationRef.childByAutoId().setValue(["removed": true, "removedAt": Date().timeIntervalSince1970])
        let indexPath = collectionView.indexPath(for: conversationCell)!
        messages.remove(at: indexPath.item)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.collectionView.reloadData()
        }
    }
}
