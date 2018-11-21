//
//  ConnectionsVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

class ConnectionsVC: UIViewController {
    var connections = [User]()

    var isTransitioning = false

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(ConnectionCell.self, forCellWithReuseIdentifier: "cellId")
        cv.backgroundColor = Colors.darkBackground
        cv.alwaysBounceVertical = true
        return cv
    }()

    func setupViews() {
        setupMainView()
        setupCollectionView()
    }
    
    func setupMainView() {
        navigationItem.title = "Connections"
        guard AccountService.shared.currentUserType == .learner else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "addTutorByUsernameButton"), style: .plain, target: self, action: #selector(handleRightViewTapped))
    }

    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchConnections()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isTransitioning = false
    }

    func fetchConnections() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("connections").child(uid).child(userTypeString).observeSingleEvent(of: .value) { snapshot in
            self.shouldShowEmptyBackground(snapshot.exists())
            guard let connections = snapshot.value as? [String: Any] else { return }
            connections.forEach({ key, _ in
                DataService.shared.getStudentWithId(key, completion: { userIn in
                    guard let user = userIn else { return }
                    self.connections.append(user)
                    self.collectionView.reloadData()
                })
            })
        }
    }
    
    func shouldShowEmptyBackground(_ result: Bool) {
        collectionView.backgroundView = result ? nil : ConnectionsBackgroundView()
    }
    
    func handleLeftViewTapped() {
        guard let nav = navigationController else { return }
        nav.popViewController(animated: true)
    }
    
    @objc func handleRightViewTapped() {
        if AccountService.shared.currentUserType == .learner {
            navigationController?.pushViewController(AddTutorVC(), animated: true)
        }
    }
}

extension ConnectionsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return connections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ConnectionCell
        cell.updateUI(user: connections[indexPath.item])
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isTransitioning else { return }
        isTransitioning = true
        let cell = collectionView.cellForItem(at: indexPath) as! ConnectionCell
        cell.handleTouchDown()
        let user = connections[indexPath.item]
        if AccountService.shared.currentUserType == .learner {
            FirebaseData.manager.fetchTutor(user.uid, isQuery: false, { tutor in
                guard let tutor = tutor else { return }
                let vc = TutorMyProfileVC()
                vc.tutor = tutor
                vc.isViewing = true
                vc.navigationItem.title = tutor.username
                self.navigationController?.pushViewController(vc, animated: true)
            })
        } else {
            FirebaseData.manager.fetchLearner(user.uid) { learner in
                guard let learner = learner else { return }
                let vc = LearnerMyProfileVC()
                vc.learner = learner
                vc.isViewing = true
                vc.isEditable = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension ConnectionsVC: ConnectionCellDelegate {
    func connectionCell(_ connectionCell: ConnectionCell, shouldShowConversationWith user: User) {
        let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.receiverId = user.uid
        vc.chatPartner = user
        vc.connectionRequestAccepted = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(vc, animated: true)
    }
}
