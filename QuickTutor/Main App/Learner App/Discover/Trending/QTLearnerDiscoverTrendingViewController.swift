//
//  QTLearnerDiscoverTrendingViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class QTLearnerDiscoverTrendingViewController: UIViewController {

    var didClickTrending: ((_ trending: MainPageFeaturedItem) -> ())?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageCtrl: UIPageControl!
    @IBOutlet weak var constraintCollectionViewHeight: NSLayoutConstraint!
    
    private var aryTrendings: [MainPageFeaturedItem] = [] {
        didSet {
            pageCtrl.isHidden = !(1 < aryTrendings.count)
            pageCtrl.numberOfPages = aryTrendings.count
            pageCtrl.currentPage = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pageCtrl.isHidden = true
        collectionView.register(QTTutorDiscoverNewsCollectionViewCell.nib, forCellWithReuseIdentifier: QTTutorDiscoverNewsCollectionViewCell.reuseIdentifier)
        collectionView.prepareSkeleton { _ in
            self.collectionView.isUserInteractionEnabled = false
            self.collectionView.showAnimatedSkeleton(usingColor: Colors.gray)
            DataService.shared.featchMainPageFeaturedSubject { items in
                self.aryTrendings = items
                if self.collectionView.isSkeletonActive {
                    self.collectionView.isUserInteractionEnabled = true
                    self.collectionView.hideSkeleton()
                }
                self.collectionView.reloadData()
            }
        }
        constraintCollectionViewHeight.constant = getCollectionViewHeight() + 10
    }
    
    private func getCollectionViewHeight() -> CGFloat {
        let width = UIScreen.main.bounds.width - 40
        return ceil(width * 110 / 167.5)
    }

}

extension QTLearnerDiscoverTrendingViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return QTTutorDiscoverNewsCollectionViewCell.reuseIdentifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryTrendings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTTutorDiscoverNewsCollectionViewCell.reuseIdentifier, for: indexPath) as! QTTutorDiscoverNewsCollectionViewCell
        cell.setTrending(trending: aryTrendings[indexPath.row])
        cell.didReadButtonClickedHandler = { trending in
            guard let trending = trending as? MainPageFeaturedItem else { return }
            self.didClickTrending?(trending)
        }
        
        return cell
    }
}

extension QTLearnerDiscoverTrendingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 40
        return CGSize(width: width, height: getCollectionViewHeight())
    }
}

extension QTLearnerDiscoverTrendingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        pageCtrl.currentPage = currentPage
    }
}

