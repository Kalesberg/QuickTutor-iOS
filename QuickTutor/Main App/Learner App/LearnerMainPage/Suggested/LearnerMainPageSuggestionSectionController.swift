//
//  LearnerMainPageSuggestionSectionController.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/10/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class LearnerMainPageSuggestionController: UIViewController {
    
    var datasource = [AWTutor]()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(TutorCollectionViewCell.self, forCellWithReuseIdentifier: TutorCollectionViewCell.reuseIdentifier)
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
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func fetchTutors() {
        TutorSearchService.shared.getNewRecommentedTutors { (tutors) in
            guard tutors.count > 0 else {
                self.fetchDefaultTutors()
                return
            }
            
            var uniqueTutors = [AWTutor]()
            var addedTutors = [String]()
            for tutor in tutors {
                if addedTutors.contains(tutor.uid) {
                    continue
                }
                
                addedTutors.append(tutor.uid)
                uniqueTutors.append(tutor)
            }
            
            self.view.hideSkeleton()
            self.datasource.append(contentsOf: uniqueTutors)
            self.collectionView.reloadData()
        }
    }
    
    func fetchDefaultTutors() {
        TutorSearchService.shared.getTutorsByCategory("academics", lastKnownKey: nil, completion: { (tutors, _) in
            self.view.hideSkeleton()
            guard let tutors = tutors else { return }
            self.datasource.append(contentsOf: tutors)
            self.collectionView.reloadData()
        })
    }
}

extension LearnerMainPageSuggestionController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return TutorCollectionViewCell.reuseIdentifier
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorCollectionViewCell.reuseIdentifier, for: indexPath) as! TutorCollectionViewCell
        cell.updateUI(datasource[indexPath.item])
        return cell
    }
}

extension LearnerMainPageSuggestionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 50) / 2.5
        return CGSize(width: width, height: 254)
    }
}

extension LearnerMainPageSuggestionController: UICollectionViewDelegate {
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
            NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.suggestedTutorTapped, object: nil, userInfo: userInfo)
        }
    }
}
