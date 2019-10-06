//
//  FeaturedSectionController.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class FeaturedSectionController: UIViewController {
    
    var featuredItems: [MainPageFeaturedItem] = []
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(LearnerMainPageFeaturedSubjectCell.self, forCellWithReuseIdentifier: LearnerMainPageFeaturedSubjectCell.reuseIdentifier)
        collectionView.isSkeletonable = true
        
        return collectionView
    }()
    
    let pageCtrl: UIPageControl = {
        let pageCtrl = UIPageControl()
        pageCtrl.hidesForSinglePage = true
        
        return pageCtrl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isSkeletonable = true
        setupCollectionView()
        setupPageControl()
        
        collectionView.prepareSkeleton { _ in
            self.collectionView.showAnimatedSkeleton(usingColor: Colors.gray)
            self.loadFeaturedSubjects()
        }
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview()
            }
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupPageControl() {
        view.addSubview(pageCtrl)
        pageCtrl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.height.equalTo(30)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
    
    func loadFeaturedSubjects() {
        DataService.shared.featchMainPageFeaturedSubject { items in
            if self.collectionView.isSkeletonActive {
                self.collectionView.hideSkeleton()
            }
            
            self.featuredItems = items
            self.pageCtrl.numberOfPages = items.count
            self.collectionView.reloadData()
        }
    }    
}

extension FeaturedSectionController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return LearnerMainPageFeaturedSubjectCell.reuseIdentifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featuredItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LearnerMainPageFeaturedSubjectCell.reuseIdentifier, for: indexPath) as! LearnerMainPageFeaturedSubjectCell
        cell.updateUI(featuredItems[indexPath.item])
        cell.didClickBtnTryIt = {
            self.collectionView(collectionView, didSelectItemAt: indexPath)
        }
        return cell
    }
    
}

extension FeaturedSectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension FeaturedSectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard featuredItems.count > indexPath.item else { return }
        
        let userInfo: [AnyHashable: Any] = ["featuredItem": featuredItems[indexPath.item]]
        NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.featuredSectionTapped, object: nil, userInfo: userInfo)
        let vc = CategorySearchVC()
        let item = featuredItems[indexPath.item]
        if let subject = item.subject {
            vc.subject = subject
            vc.navigationItem.title = subject.capitalized
        } else if let subcategoryTitle = item.subcategoryTitle {
            vc.subcategory = subcategoryTitle
            vc.navigationItem.title = subcategoryTitle.capitalized
        } else if let cateogryTitle = item.categoryTitle {
            vc.category = cateogryTitle
            vc.navigationItem.title = cateogryTitle
        }
        vc.navigationItem.title = featuredItems[indexPath.item].subject
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageCtrl.currentPage = indexPath.item
    }
}
