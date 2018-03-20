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
    
    let mainCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.register(MessagesContentCell.self, forCellWithReuseIdentifier: "messagesContentCell")
        cv.register(SessionsContentCell.self, forCellWithReuseIdentifier: "sessionsContentCell")
        cv.alwaysBounceHorizontal = false
        cv.alwaysBounceHorizontal = false
        cv.isPagingEnabled = true
        cv.allowsSelection = false
        cv.isScrollEnabled = false
        return cv
    }()
    
    let messageSessionControl: MessagingSystemToggle = {
        let control = MessagingSystemToggle()
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        edgesForExtendedLayout = []
    }
    
    private func setupCollectionView() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        view.addSubview(mainCollectionView)
        mainCollectionView.anchor(top: messageSessionControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 29, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
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
    
    private func setupMessageSessionControl() {
        view.addSubview(messageSessionControl)
        messageSessionControl.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 45, paddingBottom: 0, paddingRight: 45, width: 0, height: 25)
        messageSessionControl.delegate = self
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
}


extension MessagesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messagesContentCell", for: indexPath) as! MessagesContentCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sessionsContentCell", for: indexPath) as! SessionsContentCell
            return cell
        }
    }
}

extension MessagesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.bounds.height)
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

extension MessagesVC: SegmentedViewDelegate {
    func scrollTo(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        mainCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}

extension MessagesVC: PageObservation {
    func getParentPageViewController(parentRef: PageViewController) {
        
    }
}
