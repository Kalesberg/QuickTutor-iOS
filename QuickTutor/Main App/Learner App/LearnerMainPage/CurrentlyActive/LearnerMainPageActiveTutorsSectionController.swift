//
//  LearnerMainPageActiveTutorsSectionController.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class LearnerMainPageActiveTutorsSectionController: UIViewController {
    
    var datasource = [AWTutor]()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.register(QTRecentlyActiveCollectionViewCell.self, forCellWithReuseIdentifier: QTRecentlyActiveCollectionViewCell.reuseIdentifier)
        collectionView.isSkeletonable = true
        collectionView.clipsToBounds = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 40)
        return collectionView
    }()
    
    var currentScrollOffset: CGPoint!
    var itemWidth: CGFloat = 0
    let cellSpacing: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isSkeletonable = true
        setupCollectionView()
        
        collectionView.prepareSkeleton { _ in
            self.view.showAnimatedSkeleton(usingColor: Colors.gray)
        }
        fetchTutors()
    }
    
    func setupViews() {
        setupCollectionView()
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func fetchTutors() {
        TutorSearchService.shared.getCurrentlyOnlineTutors { (tutors) in
            
            if tutors.isEmpty {
                self.view.hideSkeleton()
                self.datasource.append(contentsOf: tutors)
                self.collectionView.reloadData()
                return
            }
            
            let group = DispatchGroup()
            
            tutors.forEach({ (tutor) in
                group.enter()
                ConnectionService.shared.getConnectionStatus(partnerId: tutor.uid, completion: { (connected) in
                    tutor.isConnected = connected
                    group.leave()
                })
            })
            
            group.notify(queue: DispatchQueue.main, execute: {
                self.view.hideSkeleton()
                self.datasource.append(contentsOf: tutors)
                self.collectionView.reloadData()
            })
        }
    }
}

extension LearnerMainPageActiveTutorsSectionController: SkeletonCollectionViewDataSource {
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return ConnectionCell.reuseIdentifier
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConnectionCell.reuseIdentifier, for: indexPath) as! ConnectionCell
        cell.updateUI(user: datasource[indexPath.item])
        cell.updateToMainFeedLayout()
        return cell
    }
}

extension LearnerMainPageActiveTutorsSectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        itemWidth = UIScreen.main.bounds.width - 2 * cellSpacing
        return CGSize(width: itemWidth, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }    
}

extension LearnerMainPageActiveTutorsSectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ConnectionCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ConnectionCell
        cell.growSemiShrink {
            guard self.datasource.count > indexPath.item,
                let uid = self.datasource[indexPath.item].uid else { return }
            
            NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.activeTutorCellTapped, object: nil, userInfo: ["uid": uid])
        }
    }
}

extension LearnerMainPageActiveTutorsSectionController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentScrollOffset = scrollView.contentOffset
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let target = targetContentOffset.pointee
        //Current scroll distance is the distance between where the user tapped and the destination for the scrolling (If the velocity is high, this might be of big magnitude)
        let currentScrollDistance = target.x - currentScrollOffset.x
        //Make the value an integer between -1 and 1 (Because we don't want to scroll more than one item at a time)
        let coefficent = Int(max(-1, min(currentScrollDistance / 1, 1)))
        let currentIndex = Int(round(currentScrollOffset.x / itemWidth))
        let adjacentItemIndex = currentIndex + coefficent
        let adjacentItemIndexFloat = CGFloat(adjacentItemIndex)
        let adjacentItemOffsetX = adjacentItemIndexFloat * itemWidth
        targetContentOffset.pointee = CGPoint(x: adjacentItemOffsetX, y: target.y)
    }
}
