//
//  ViewController.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class MessagesVC: UIViewController {
    
    var messages = [UserMessage]()
    var conversationsDictionary = [String: UserMessage]()
    let refreshControl = UIRefreshControl()
    
    let messagesCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.register(ConversationCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    let messageSessionControl: MessagingSystemToggle = {
        let control = MessagingSystemToggle()
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupViews() {
        setupMainView()
        setupMessageSessionControl()
        setupCollectionView()
        setupNavBar()
        setupRefreshControl()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        edgesForExtendedLayout = []
    }
    
    private func setupCollectionView() {
        messagesCV.delegate = self
        messagesCV.dataSource = self
        view.addSubview(messagesCV)
        messagesCV.anchor(top: messageSessionControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 29, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Messages"
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationItem.backBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "newMessageIcon"), style: .plain, target: self, action: #selector(showContacts))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backItem?.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settingsIcon"), style: .plain, target: self, action: #selector(showSettings))
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(fetchConversations), for: .valueChanged)
        messagesCV.refreshControl = refreshControl
    }
    
    private func setupMessageSessionControl() {
        view.addSubview(messageSessionControl)
        messageSessionControl.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 200, paddingLeft: 45, paddingBottom: 0, paddingRight: 45, width: 0, height: 25)
    }
    
    @objc func showContacts() {
        let vc = NewMessageVC()
        vc.delegate = self
        let navVC = CustomNavVC(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func showSettings() {
        let vc = SettingsVC()
        let navVC = CustomNavVC(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
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
            self.messagesCV.reloadData()
        }
    }
}

extension MessagesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.receiverId = messages[indexPath.item].partnerId()
        let tappedCell = collectionView.cellForItem(at: indexPath) as! ConversationCell
        vc.navigationItem.title = tappedCell.usernameLabel.text
        vc.chatPartner = tappedCell.chatPartner
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MessagesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
        return conversationsDictionary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as? ConversationCell else {
            fatalError("Couldn't get cell for collectionView")
        }
        //        cell.updateUI(message: messages[indexPath.item])
        return cell
    }
}

extension MessagesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension MessagesVC: NewMessageDelegate {
    func showConversationWithUser(user: User, isConnection: Bool) {
        let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.receiverId = user.uid
        vc.connectionRequestAccepted = isConnection
        vc.chatPartner = user
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MessagesVC: PageObservation {
    func getParentPageViewController(parentRef: PageViewController) {
        
    }
    
    
}

