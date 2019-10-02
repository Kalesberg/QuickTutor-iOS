//
//  QTTutorDiscoverTipsViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/13/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class QTTutorDiscoverTipsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tips = [QTNewsModel]()
    
    // MARK: - Functions
    func setupSkeletonView() {
        self.view.isSkeletonable = true
        
        collectionView.prepareSkeleton { (completed) in
            self.collectionView.showAnimatedSkeleton(usingColor: Colors.gray)
            FirebaseData.manager.getTips(completion: { data in
                if self.collectionView.isSkeletonActive {
                    self.collectionView.hideSkeleton()
                }
                self.tips = data
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    func configureViews() {
        collectionView.register(QTTutorDiscoverTipCollectionViewCell.self,
                                forCellWithReuseIdentifier: QTTutorDiscoverTipCollectionViewCell.reuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReceivedRefershDiscoverPage),
                                               name: NotificationNames.TutorDiscoverPage.refreshDiscoverPage,
                                               object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @objc
    func onReceivedRefershDiscoverPage() {
        tips.removeAll()
        collectionView.reloadData()
        
        setupSkeletonView()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        setupSkeletonView()
        addObservers()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            removeObservers()
        }
        super.didMove(toParent: parent)
    }
}

// MARK: - UICollectionViewDelegate
extension QTTutorDiscoverTipsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! QTTutorDiscoverTipCollectionViewCell
        cell.growSemiShrink {
            NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.tipTapped, object: nil, userInfo: ["tip": self.tips[indexPath.row]])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension QTTutorDiscoverTipsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (UIScreen.main.bounds.size.width - 44) / 2
        return CGSize(width: width, height: 222)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
    }    
}


// MARK: - UICollectionViewDataSource
extension QTTutorDiscoverTipsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTTutorDiscoverTipCollectionViewCell.reuseIdentifier, for: indexPath) as! QTTutorDiscoverTipCollectionViewCell
        
        cell.setData(tip: tips[indexPath.row])
        return cell
    }
}

extension QTTutorDiscoverTipsViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return QTTutorDiscoverTipCollectionViewCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
}
