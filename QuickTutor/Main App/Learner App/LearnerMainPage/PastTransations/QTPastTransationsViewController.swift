//
//  QTPastTransationsViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class QTPastTransationsViewController: UIViewController {

    // MARK: - Properties
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 15
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(QTLearnerSessionCardCollectionViewCell.nib, forCellWithReuseIdentifier: QTLearnerSessionCardCollectionViewCell.reuseIdentifier)
        
        return collectionView
    }()
    
    var pastSessions = [Session]()
    var upcomingSessions = [Session]()
    var userSessionsRef: DatabaseReference?
    var userSessionsHandle: DatabaseHandle?
    var timer: Timer?
    
    var isPastTransactions = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
    }
    

    // MARK: - Functions
    func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupBackground() {
        self.view.backgroundColor = Colors.newScreenBackground
    }
}

extension QTPastTransationsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension QTPastTransationsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isPastTransactions {
            return QTLearnerSessionsService.shared.pastSessions.isEmpty ? 0 : QTLearnerSessionsService.shared.pastSessions.count
        } else {
            return QTLearnerSessionsService.shared.upcomingSessions.isEmpty ? 0 : QTLearnerSessionsService.shared.upcomingSessions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerSessionCardCollectionViewCell.reuseIdentifier, for: indexPath) as! QTLearnerSessionCardCollectionViewCell
        if isPastTransactions {
            cell.setData(session: QTLearnerSessionsService.shared.pastSessions[indexPath.row])
        } else {
            cell.setData(session: QTLearnerSessionsService.shared.upcomingSessions[indexPath.row])
        }
        return cell
    }
}

extension QTPastTransationsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 60
        return CGSize(width: width, height: 181)
    }
}
