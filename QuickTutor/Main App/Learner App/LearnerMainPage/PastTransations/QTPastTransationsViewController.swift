//
//  QTPastTransationsViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import SkeletonView

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
    
    var isPastTransactions = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        addObservers()
        setupSkeletonView()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            removeObservers()
        }
        super.didMove(toParent: parent)
    }

    // MARK: - Functions
    func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        collectionView.isSkeletonable = true
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupSkeletonView() {
        self.collectionView.hideSkeleton(transition: .crossDissolve(0.1))
        collectionView.prepareSkeleton { (completed) in
            self.collectionView.showAnimatedSkeleton(usingColor: Colors.gray)
            // Past transactions and upcoming sessions are existed or not for a learner.
            // So if there is no data, the certain section should not display on the main screen.
            // That's why we call the following statement in here instead of their view controllers.
            QTLearnerSessionsService.shared.fetchSessions()
            QTLearnerSessionsService.shared.listenForSessionUpdates()
        }
    }
    
    func setupBackground() {
        self.view.backgroundColor = Colors.newScreenBackground
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadSessions), name: NotificationNames.LearnerMainFeed.reloadSessions, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @objc
    func handleReloadSessions() {
        self.collectionView.hideSkeleton(transition: .crossDissolve(0.1))
        self.collectionView.reloadData()
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

extension QTPastTransationsViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return QTLearnerSessionCardCollectionViewCell.reuseIdentifier
    }
}

extension QTPastTransationsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = UIScreen.main.bounds.width
        if isPastTransactions {
            width = width - (QTLearnerSessionsService.shared.pastSessions.count == 1 ? 40 : 60)
        } else {
            width = width - (QTLearnerSessionsService.shared.upcomingSessions.count == 1 ? 40 : 60)
        }
        return CGSize(width: width, height: 190)
    }
}
