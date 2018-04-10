//
//  NewMessageVC.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/13/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

protocol NewMessageDelegate {
    func showConversationWithUser(user: User, isConnection: Bool)
}

protocol ConnectionRequestCellDelegate {
    func handleApprovedRequestForUser(_ user: User)
    func handleDeniedRequestForUser(_ user: User)
}

class NewMessageVC: UIViewController {
    
    var allUsers = [User]()
    var connections = [User]()
    var connectionRequests = [User]()
    var delegate: NewMessageDelegate?
    
    let contactsCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.register(ContactCell.self, forCellWithReuseIdentifier: "cellId")
        cv.register(ConnectionRequestCell.self, forCellWithReuseIdentifier: "connectionRequest")
        cv.register(NewMessageHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
        fetchConnections()
        fetchAllUsers()
        fetchConnectionRequests()
    }
    
    func setupViews() {
        setupMainView()
        setupCollectionView()
        setupNavBar()
    }
    
    func setupMainView() {
        view.backgroundColor = Colors.darkBackground
    }
    
    func setupCollectionView() {
        contactsCV.delegate = self
        contactsCV.dataSource = self
        view.addSubview(contactsCV)
        contactsCV.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Contacts"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
    }
    
    func fetchAllUsers() {
        Database.database().reference().child("accounts").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("Snapshot was empty")
                return
            }
            value.forEach({ key, value in
                let user = User(dictionary: value as! [String: Any])
                user.uid = key
                if user.type == "teacher" && user.uid != AccountService.shared.currentUser.uid! {
                    self.allUsers.append(user)
                }
            })
            self.contactsCV.reloadData()
            print(value)
        }
    }
    
    func fetchConnections() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("connections").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let connections = snapshot.value as? [String: Any] else { return }
            connections.forEach({ key, _ in
                DataService.shared.getUserWithUid(key, completion: { userIn in
                    guard let user = userIn else { return }
                    self.connections.append(user)
                })
            })
        }
    }
    
    func fetchConnectionRequests() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("connectionRequests").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let connections = snapshot.value as? [String: Any] else { return }
            connections.forEach({ arg in
                
                let (key, _) = arg
                DataService.shared.getUserWithUid(key, completion: { userIn in
                    guard let user = userIn else { return }
                    self.connectionRequests.append(user)
                    self.contactsCV.reloadSections(IndexSet(integer: 0))
                })
            })
        }
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension NewMessageVC {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        if connections.contains(where: { $0.uid == allUsers[indexPath.item].uid }) {
            self.delegate?.showConversationWithUser(user: allUsers[indexPath.item], isConnection: true)
        } else {
            delegate?.showConversationWithUser(user: allUsers[indexPath.item], isConnection: false)
        }
    }
    
}

extension NewMessageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as? ContactCell else {
            assertionFailure("[QUICK TUTOR]: Couldn't load cell with reuse identifier")
            return UICollectionViewCell()
        }
        cell.updateUI(user: allUsers[indexPath.item])
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

let headerTitles = ["Chat Now"]
extension NewMessageVC {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader, let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId", for: indexPath) as? NewMessageHeader else {
            fatalError("Should not get here")
        }
        headerView.updateUI(text: headerTitles[indexPath.section])
        return headerView
        
    }
}

extension NewMessageVC: ConnectionRequestCellDelegate {
    func handleApprovedRequestForUser(_ user: User) {
        guard let index = connectionRequests.index(where: { $0.uid == user.uid }) else { return }
        connectionRequests.remove(at: index)
        connections.append(user)
        contactsCV.reloadSections(IndexSet(integersIn: 0...1))
    }
    
    func handleDeniedRequestForUser(_ user: User) {
        guard let index = connectionRequests.index(where: { $0.uid == user.uid }) else { return }
        connectionRequests.remove(at: index)
        contactsCV.reloadSections(IndexSet(integer: 0))
    }
}
