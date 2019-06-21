//
//  LearnerMainPageCollectionViewHelper.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class LearnerMainPageCollectionViewHelper: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var handleScrollViewScroll: ((CGFloat) -> ())?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! LearnerMainPageFeaturedSectionContainerCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! LearnerMainPageCategorySectionContainerCell
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topTutors", for: indexPath) as! LearnerMainPageTopTutorsSectionContainerCell
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestionCell", for: indexPath) as! LearnerMainPageSuggestionSectionContainerCell
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activeCell", for: indexPath) as! LearnerMainPageActiveTutorsSectionContainerCell
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! LearnerMainPageFeaturedSectionContainerCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 0
        switch indexPath.section {
        case 0:
            height = 250
        case 1:
            height = 230
        case 2:
            height = 585
        case 3:
            height = 275
        case 4:
            height = 230
        default:
            break
        }
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let topPadding: CGFloat = section == 0 ? 0 : 40
        return UIEdgeInsets(top: topPadding, left: 0, bottom: 0, right: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let handleScrollViewScroll = handleScrollViewScroll {
            handleScrollViewScroll(scrollView.contentOffset.y)
        }
    }
}
