//
//  QTQuickActionViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTQuickActionViewController: UIViewController {

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
        collectionView.register(QTQAQuickRequestCollectionViewCell.nib, forCellWithReuseIdentifier: QTQAQuickRequestCollectionViewCell.reuseIdentifier)
        
        return collectionView
    }()
    
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
    
    // MARK: - Actions
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupCollectionView()
    }

}

// MARK: - UICollectionViewDelegate
extension QTQuickActionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.shrink()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.2) {
            cell?.transform = CGAffineTransform.identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.quickRequestCellTapped, object: nil, userInfo: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension QTQuickActionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTQAQuickRequestCollectionViewCell.reuseIdentifier, for: indexPath)
        return cell
    }
}

extension QTQuickActionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 40 // both side margins
        return CGSize(width: width, height: 108)
    }
}
