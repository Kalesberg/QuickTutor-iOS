//
//  LearnerMainPageCollectionViewHelper.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class LearnerMainPageCollectionViewHelper: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var hasPastSessions = true
    var hasUpcomingSessions = true
    
    var handleScrollViewScroll: ((CGFloat) -> ())?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5 + (hasPastSessions ? 1 : 0) + (hasUpcomingSessions ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if hasPastSessions {
            if hasUpcomingSessions {
                switch indexPath.section {
                case 0:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! LearnerMainPageCategorySectionContainerCell
                    return cell
                case 1:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerMainPageQuickActionSectionContainerCell.reuseIdentifier, for: indexPath) as! QTLearnerMainPageQuickActionSectionContainerCell
                    return cell
                case 2:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerMainPagePastTransactionContainerCell.reuseIdentifier, for: indexPath) as! QTLearnerMainPagePastTransactionContainerCell
                    return cell
                case 3:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerMainPageUpcomingSessionContainerCell.reuseIdentifier, for: indexPath)
                    return cell
                case 4:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topTutors", for: indexPath) as! LearnerMainPageTopTutorsSectionContainerCell
                    return cell
                case 5:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestionCell", for: indexPath) as! LearnerMainPageSuggestionSectionContainerCell
                    return cell
                case 6:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activeCell", for: indexPath) as! LearnerMainPageActiveTutorsSectionContainerCell
                    return cell
                default:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! LearnerMainPageFeaturedSectionContainerCell
                    return cell
                }
            } else {
                switch indexPath.section {
                case 0:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! LearnerMainPageCategorySectionContainerCell
                    return cell
                case 1:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerMainPageQuickActionSectionContainerCell.reuseIdentifier, for: indexPath) as! QTLearnerMainPageQuickActionSectionContainerCell
                    return cell
                case 2:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerMainPagePastTransactionContainerCell.reuseIdentifier, for: indexPath) as! QTLearnerMainPagePastTransactionContainerCell
                    return cell
                case 3:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topTutors", for: indexPath) as! LearnerMainPageTopTutorsSectionContainerCell
                    return cell
                case 4:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestionCell", for: indexPath) as! LearnerMainPageSuggestionSectionContainerCell
                    return cell
                case 5:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activeCell", for: indexPath) as! LearnerMainPageActiveTutorsSectionContainerCell
                    return cell
                default:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! LearnerMainPageFeaturedSectionContainerCell
                    return cell
                }
            }
        } else {
            if hasUpcomingSessions {
                switch indexPath.section {
                case 0:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! LearnerMainPageCategorySectionContainerCell
                    return cell
                case 1:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerMainPageQuickActionSectionContainerCell.reuseIdentifier, for: indexPath) as! QTLearnerMainPageQuickActionSectionContainerCell
                    return cell
                case 2:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerMainPageUpcomingSessionContainerCell.reuseIdentifier, for: indexPath)
                    return cell
                case 3:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topTutors", for: indexPath) as! LearnerMainPageTopTutorsSectionContainerCell
                    return cell
                case 4:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestionCell", for: indexPath) as! LearnerMainPageSuggestionSectionContainerCell
                    return cell
                case 5:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activeCell", for: indexPath) as! LearnerMainPageActiveTutorsSectionContainerCell
                    return cell
                default:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! LearnerMainPageFeaturedSectionContainerCell
                    return cell
                }
            } else {
                switch indexPath.section {
                case 0:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! LearnerMainPageCategorySectionContainerCell
                    return cell
                case 1:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerMainPageQuickActionSectionContainerCell.reuseIdentifier, for: indexPath) as! QTLearnerMainPageQuickActionSectionContainerCell
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
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 0
        let width = UIScreen.main.bounds.width
        
        if hasPastSessions {
            if hasUpcomingSessions {
                switch indexPath.section {
                case 0:
                    height = ((width - 50) / 2.5) * 18 / 13 + 58
                case 1:
                    height = 108
                case 2:
                    height = 234
                case 3:
                    height = 234
                case 4:
                    height = 642
                case 5:
                    height = 298
                case 6:
                    height = 230
                default:
                    break
                }
            } else {
                switch indexPath.section {
                case 0:
                    height = ((width - 50) / 2.5) * 18 / 13 + 58
                case 1:
                    height = 108
                case 2:
                    height = 234
                case 3:
                    height = 642
                case 4:
                    height = 298
                case 5:
                    height = 230
                default:
                    break
                }
            }
        } else {
            if hasUpcomingSessions {
                switch indexPath.section {
                case 0:
                    height = ((width - 50) / 2.5) * 18 / 13 + 58
                case 1:
                    height = 108
                case 2:
                    height = 234
                case 3:
                    height = 642
                case 4:
                    height = 298
                case 5:
                    height = 230
                default:
                    break
                }
            } else {
                switch indexPath.section {
                case 0:
                    height = ((width - 50) / 2.5) * 18 / 13 + 58
                case 1:
                    height = 108
                case 2:
                    height = 642
                case 3:
                    height = 298
                case 4:
                    height = 230
                default:
                    break
                }
            }
        }
        
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        var topPadding = CGFloat.leastNonzeroMagnitude
        
        if 0 == section {
            topPadding = 20
        } else {
            topPadding = 40
        }
        
        return UIEdgeInsets(top: topPadding, left: 0, bottom: 0, right: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let handleScrollViewScroll = handleScrollViewScroll {
            handleScrollViewScroll(scrollView.contentOffset.y)
        }
    }
}
