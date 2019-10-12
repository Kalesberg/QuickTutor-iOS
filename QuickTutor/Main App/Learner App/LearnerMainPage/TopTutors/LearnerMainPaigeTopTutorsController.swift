//
//  LearnerMainPageTopTutorsController.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

protocol LearnerMainPageTopTutorsControllerDelegate {
    func learnerMainPageTopTutorsFetched(tutors: [AWTutor])
}

class LearnerMainPageTopTutorsController: UIViewController {
    
    var datasource = [AWTutor]()
    var delegate: LearnerMainPageTopTutorsControllerDelegate?
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(QTWideTutorCollectionViewCell.self, forCellWithReuseIdentifier: QTWideTutorCollectionViewCell.reuseIdentifier)
        collectionView.isSkeletonable = true
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isSkeletonable = true
        setupCollectionView()
        fetchTutors()
        
        collectionView.prepareSkeleton { _ in
            self.view.showAnimatedSkeleton(usingColor: Colors.gray)
        }
    }
    
    func setupViews() {
        setupCollectionView()
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 528)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func fetchTutors() {
        TutorSearchService.shared.getTopTutors { tutors in
            self.view.hideSkeleton()
            self.delegate?.learnerMainPageTopTutorsFetched(tutors: tutors)
            self.datasource.append(contentsOf: tutors.sorted(by: {$0.tNumSessions > $1.tNumSessions}))
            self.collectionView.reloadData()
        }
    }
}

extension LearnerMainPageTopTutorsController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return TutorCollectionViewCell.reuseIdentifier
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 4 < datasource.count ? 4 : datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTWideTutorCollectionViewCell.reuseIdentifier, for: indexPath) as! TutorCollectionViewCell
        cell.updateUI(datasource[indexPath.item])
        return cell
    }
}

extension LearnerMainPageTopTutorsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.size.width - 55) / 2
        return CGSize(width: width, height: 254)
    }
}

extension LearnerMainPageTopTutorsController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
        cell.growSemiShrink {
            guard self.datasource.count > indexPath.item,
                let uid = self.datasource[indexPath.item].uid else { return }
            let userInfo = ["uid": uid]
            NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.topTutorTapped, object: nil, userInfo: userInfo)
        }
    }
}
