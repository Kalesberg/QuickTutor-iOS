//
//  ConnectionsVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class ConnectionsVC: UIViewController, CustomNavBarDisplayer {
    
    var connections = [User]()
    var parentPageViewController : PageViewController!

    var navBar: ZFNavBar = {
        let bar = ZFNavBar()
        bar.leftAccessoryView.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        if AccountService.shared.currentUserType == .learner {
            bar.rightAccessoryView.setImage(#imageLiteral(resourceName: "addTutorByUsernameButton"), for: .normal)
        }
        bar.backgroundColor = Colors.navBarGreen
        return bar
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(ConnectionCell.self, forCellWithReuseIdentifier: "cellId")
        cv.backgroundColor = Colors.darkBackground
        return cv
    }()
    
    func setupViews() {
        setupNavBar()
        setupCollectionView()
    }
    
    func setupNavBar() {
        addNavBar()
        navBar.setupTitleLabelWithText("Connections")
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: navBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchConnections()
    }
    
    func fetchConnections() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("connections").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let connections = snapshot.value as? [String: Any] else { return }
            connections.forEach({ key, _ in
                DataService.shared.getStudentWithId(key, completion: { (userIn) in
                    guard let user = userIn else { return }
                    self.connections.append(user)
                    self.collectionView.reloadData()
                })

            })
        }
    }
    
    func handleLeftViewTapped() {
        guard let nav = navigationController else { return }
        nav.popViewController(animated: true)
    }
    
    func handleRightViewTapped() {
        navigationController?.pushViewController(AddTutorVC(), animated: true)
    }
    
}

extension ConnectionsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return connections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ConnectionCell
        if indexPath.item % 2 != 0 {
            cell.backgroundColor = Colors.navBarColor
        }
        cell.titleLabel.text = connections[indexPath.item].username
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.receiverId = connections[indexPath.item].uid
        vc.navigationItem.title = connections[indexPath.item].username
        vc.chatPartner = connections[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
