//
//  ConnectionsVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

class ConnectionsVC: UIViewController, ConnectionCellDelegate {
    var connections = [User]()
    var filteredConnections = [User]()

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "addTutor"), style: .plain, target: self, action: #selector(handleRightViewTapped))
        navigationController?.setNavigationBarHidden(false, animated: true)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .automatic
        }
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    var searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchConnections()
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            searchController.definesPresentationContext = true
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.tintColor = .white
            searchController.searchResultsUpdater = self
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isTransitioning = false
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func fetchConnections() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("connections").child(uid).child(userTypeString).observeSingleEvent(of: .value) { snapshot in
            self.shouldShowEmptyBackground(snapshot.exists())
            guard let connections = snapshot.value as? [String: Any] else { return }
            connections.forEach({ key, _ in
                DataService.shared.getUserOfOppositeTypeWithId(key, completion: { userIn in
                    guard let user = userIn else { return }
                    self.connections.append(user)
                    self.collectionView.reloadData()
                })                
            })
            self.connections = self.connections.sorted(by: {$0.formattedName > $1.formattedName})
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
        navigationController?.pushViewController(AddTutorVC(), animated: true)
    }
    
    func connectionCell(_ connectionCell: ConnectionCell, shouldShowConversationWith user: User) {
        let vc = ConversationVC()
        vc.receiverId = user.uid
        vc.chatPartner = user
        vc.connectionRequestAccepted = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func connectionCell(_ connectionCell: ConnectionCell, shouldRequestSessionWith user: User) {
        let vc = SessionRequestVC()
        FirebaseData.manager.fetchTutor(user.uid, isQuery: false) { (tutor) in
            vc.tutor = tutor
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterUserForSearchText(_ searchText: String, scope: String = "All") {
        filteredConnections = connections.filter({$0.formattedName.contains(searchText)})
        collectionView.reloadData()
    }
    
    func inSearchMode() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension ConnectionsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inSearchMode() ? filteredConnections.count : connections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ConnectionCell
        let connection = inSearchMode() ? filteredConnections[indexPath.item] : connections[indexPath.item]
        cell.updateUI(user: connection)
        cell.requestSessionButton.isHidden = false
        cell.delegate = self
        if AccountService.shared.currentUserType == .tutor {
            cell.updateAsLearnerCell()
            cell.requestSessionButton.isHidden = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isTransitioning else { return }
        isTransitioning = true
        let cell = collectionView.cellForItem(at: indexPath) as! ConnectionCell
        cell.handleTouchDown()
        let user = inSearchMode() ? filteredConnections[indexPath.item] : connections[indexPath.item]
        if AccountService.shared.currentUserType == .learner {
            FirebaseData.manager.fetchTutor(user.uid, isQuery: false, { tutor in
                guard let tutor = tutor else { return }
                let controller = QTProfileViewController.controller
                controller.user = tutor
                controller.profileViewType = .tutor
                self.navigationController?.pushViewController(controller, animated: true)
            })
        } else {
            FirebaseData.manager.fetchLearner(user.uid) { learner in
                guard let learner = learner else { return }
                let controller = QTProfileViewController.controller
                let tutor = AWTutor(dictionary: [:])
                controller.user = tutor.copy(learner: learner)
                controller.profileViewType = .learner
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


class SessionRequestViewConnectionsVC: ConnectionsVC {
    
    func postSelectionNotification(_ user: User) {
        let userInfo = ["tutor": user]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "com.quicktutor.didSelectTutor"), object: nil, userInfo: userInfo)
    }
    
    override func connectionCell(_ connectionCell: ConnectionCell, shouldShowConversationWith user: User) {
        postSelectionNotification(user)
        navigationController?.popViewController(animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ConnectionCell
        cell.updateUI(user: connections[indexPath.item])
        cell.messageButton.setImage(UIImage(named: "addIconCircle"), for: .normal)
        cell.delegate = self
        return cell
    }
}

extension ConnectionsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterUserForSearchText(searchController.searchBar.text!)
    }
}
