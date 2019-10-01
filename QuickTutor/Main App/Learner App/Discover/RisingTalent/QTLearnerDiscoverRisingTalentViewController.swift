//
//  QTLearnerDiscoverRisingTalentViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class QTLearnerDiscoverRisingTalentViewController: UIViewController {

    var category: Category? {
        didSet {
            getTutors()
        }
    }
    
    var didClickTutor: ((_ tutor: AWTutor) -> ())?
    var didClickViewAllTutors: ((_ tutors: [AWTutor], _ loadedAllTutors: Bool) -> ())?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblFooterTitle: UILabel!
    @IBOutlet weak var btnFooterAction: UIButton!
    
    private let MAX_RISING_TALENTS: UInt = 50
    private var aryTutors: [AWTutor] = []
    private var loadedAllTutors = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.register(QTLearnerDiscoverTutorCollectionViewCell.nib, forCellWithReuseIdentifier: QTLearnerDiscoverTutorCollectionViewCell.reuseIdentifier)
        
        lblFooterTitle.showAnimatedSkeleton(usingColor: Colors.gray)
        collectionView.prepareSkeleton { _ in
            self.collectionView.isUserInteractionEnabled = false
            self.collectionView.showAnimatedSkeleton(usingColor: Colors.gray)
        }
     
        addShadows()
    }
    
    private func addShadows() {
        if let bottomView = lblFooterTitle.superview {
            bottomView.layer.shadowColor = Colors.purple.cgColor
            bottomView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
            bottomView.layer.shadowRadius = 5
            bottomView.layer.shadowOpacity = 0.1
        }
        btnFooterAction.layer.shadowColor = Colors.newNavigationBarBackground.cgColor
        btnFooterAction.layer.shadowOffset = CGSize(width: 0, height: 1)
        btnFooterAction.layer.shadowRadius = 5
        btnFooterAction.layer.shadowOpacity = 0.5
    }
    
    private func getTutors() {
        if let category = category {
            TutorSearchService.shared.getTutorsByCategory(category.mainPageData.name, lastKnownKey: nil) { tutors, loadedAllTutors  in
                guard let tutors = tutors else {
                    if self.collectionView.isSkeletonActive {
                        self.collectionView.isUserInteractionEnabled = true
                        self.collectionView.hideSkeleton()
                    }
                    return
                }
                
                self.sortAndShowTutors(tutors)
                self.loadedAllTutors = loadedAllTutors
            }
            
            TutorSearchService.shared.getTutorIdsByCategory(category.mainPageData.name) { tutorIds in
                guard let tutorIds = tutorIds else {
                    if self.lblFooterTitle.isSkeletonActive {
                        self.lblFooterTitle.hideSkeleton()
                    }
                    self.lblFooterTitle.text = "No people in the list"
                    return
                }
                
                if self.lblFooterTitle.isSkeletonActive {
                    self.lblFooterTitle.hideSkeleton()
                }
                self.lblFooterTitle.text = "\(tutorIds.count) people in the list"
                self.btnFooterAction.isHidden = false
            }
        } else {
            TutorSearchService.shared.getTopTutors(limit: MAX_RISING_TALENTS) { tutors in
                self.sortAndShowTutors(tutors)
                self.loadedAllTutors = true
                
                if self.lblFooterTitle.isSkeletonActive {
                    self.lblFooterTitle.hideSkeleton()
                }
                self.lblFooterTitle.text = "\(self.aryTutors.count) people in the list"
                self.btnFooterAction.isHidden = false
            }
        }
    }
    
    private func sortAndShowTutors(_ tutors: [AWTutor]) {
        aryTutors = tutors.sorted() { tutor1, tutor2 -> Bool in
            if let category = category {
                let categoryReviews1 = tutor1.categoryReviews(category.mainPageData.name).count
                let categoryReviews2 = tutor2.categoryReviews(category.mainPageData.name).count
                return categoryReviews1 > categoryReviews2
                    || (categoryReviews1 == categoryReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                    || (categoryReviews1 == categoryReviews2 && tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            } else {
                return (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0)
                    || (tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            }
        }
        
        if collectionView.isSkeletonActive {
            collectionView.isUserInteractionEnabled = true
            collectionView.hideSkeleton()
        }
        collectionView.reloadData()
    }
    
    @IBAction func onClickBtnViewAll(_ sender: Any) {
        didClickViewAllTutors?(aryTutors, loadedAllTutors)
    }
}

extension QTLearnerDiscoverRisingTalentViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return QTLearnerDiscoverTutorCollectionViewCell.reuseIdentifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryTutors.suffix(4).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerDiscoverTutorCollectionViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTutorCollectionViewCell
        cell.setView(aryTutors[indexPath.item], isRisingTalent: nil == category)
        
        return cell
    }
}

extension QTLearnerDiscoverRisingTalentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.size.width - 55) / 2
        return CGSize(width: width, height: 254)
    }
}

extension QTLearnerDiscoverRisingTalentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QTLearnerDiscoverTutorCollectionViewCell else { return }
        UIView.animate(withDuration: 0.2) {
            cell.transform = .identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QTLearnerDiscoverTutorCollectionViewCell else { return }
        cell.growSemiShrink {
            self.didClickTutor?(self.aryTutors[indexPath.item])
        }
    }
}
