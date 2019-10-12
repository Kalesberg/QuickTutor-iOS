//
//  QTLearnerDiscoverTutorsViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class QTLearnerDiscoverTutorsViewController: UIViewController {
    
    var category: Category?
    var subcategory: String?
    var isRisingTalent: Bool = false
    var isFirstTop: Bool = false
    
    var didClickTutor: ((_ tutor: AWTutor) -> ())?
    var didClickViewAllTutors: ((_ subject: String?, _ subcategory: String?, _ category: String?, _ tutors: [AWTutor], _ loadedAllTutors: Bool) -> ())?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblFooterTitle: UILabel!
    @IBOutlet weak var btnFooterAction: UIButton!
    
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
            self.getTutors()
        }
        
        addShadows()
    }
    
    private func addShadows() {
        lblFooterTitle.superview?.superview?.layer.applyShadow(color: Colors.purple.cgColor, opacity: 0.1, offset: CGSize(width: 0, height: 0.5), radius: 2)        
        btnFooterAction.superview?.layer.applyShadow(color: Colors.darkGray.cgColor, opacity: 0.5, offset: CGSize(width: 0, height: 1), radius: 2)
    }
    
    func getTutors() {
        if isRisingTalent {
            TutorSearchService.shared.fetchLearnerRisingTalents(category: category?.mainPageData.name, subcategory: subcategory, limit: QTLearnerDiscoverService.shared.risingTalentLimit) { tutors in
                self.sortAndShowTutors(tutors)
                self.loadedAllTutors = true
                
                if self.lblFooterTitle.isSkeletonActive {
                    self.lblFooterTitle.hideSkeleton()
                }
                self.lblFooterTitle.text = "\(self.aryTutors.count) people in the list"
                self.btnFooterAction.superview?.isHidden = false
            }
        } else if let subcategory = subcategory {
            if let section = QTLearnerDiscoverService.shared.sectionTutors.first(where: { .subcategory == $0.type && subcategory == $0.key }),
                let tutors = section.tutors, let totalTutorIds = section.totalTutorIds {
                if self.lblFooterTitle.isSkeletonActive {
                    self.lblFooterTitle.hideSkeleton()
                }
                if collectionView.isSkeletonActive {
                    collectionView.isUserInteractionEnabled = true
                    collectionView.hideSkeleton()
                }
                if let topTutorsLimit = QTLearnerDiscoverService.shared.topTutorsLimit,
                    topTutorsLimit < totalTutorIds.count {
                    self.lblFooterTitle.text = "\(topTutorsLimit) people in the list"
                } else {
                    self.lblFooterTitle.text = "\(totalTutorIds.count) people in the list"
                }
                self.aryTutors = tutors
                if true == section.loadedAllTutors {
                    self.loadedAllTutors = true
                } else {
                    if let topTutorsLimit = QTLearnerDiscoverService.shared.topTutorsLimit,
                        topTutorsLimit < self.aryTutors.count {
                        self.loadedAllTutors = true
                    } else {
                        self.loadedAllTutors = false
                    }
                }
                self.btnFooterAction.superview?.isHidden = false
            }
        } else if let category = category {
            if let section = QTLearnerDiscoverService.shared.sectionTutors.first(where: { .category == $0.type && category.mainPageData.name == $0.key }),
                let tutors = section.tutors, let totalTutorIds = section.totalTutorIds {
                if self.lblFooterTitle.isSkeletonActive {
                    self.lblFooterTitle.hideSkeleton()
                }
                if collectionView.isSkeletonActive {
                    collectionView.isUserInteractionEnabled = true
                    collectionView.hideSkeleton()
                }
                if let topTutorsLimit = QTLearnerDiscoverService.shared.topTutorsLimit,
                    topTutorsLimit < totalTutorIds.count {
                    self.lblFooterTitle.text = "\(topTutorsLimit) people in the list"
                } else {
                    self.lblFooterTitle.text = "\(totalTutorIds.count) people in the list"
                }
                self.aryTutors = tutors
                if true == section.loadedAllTutors {
                    self.loadedAllTutors = true
                } else {
                    if let topTutorsLimit = QTLearnerDiscoverService.shared.topTutorsLimit,
                        topTutorsLimit < self.aryTutors.count {
                        self.loadedAllTutors = true
                    } else {
                        self.loadedAllTutors = false
                    }
                }
                self.btnFooterAction.superview?.isHidden = false
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
            } else if let subcategory = subcategory {
                let subcategoryReviews1 = tutor1.reviews?.filter({ subcategory == SubjectStore.shared.findSubCategory(subject: $0.subject) }).count ?? 0
                let subcategoryReviews2 = tutor2.reviews?.filter({ subcategory == SubjectStore.shared.findSubCategory(subject: $0.subject) }).count ?? 0
                return subcategoryReviews1 > subcategoryReviews2
                    || (subcategoryReviews1 == subcategoryReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                    || (subcategoryReviews1 == subcategoryReviews2 && tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            } else {
                return (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0)
                    || (tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            }
        }
        
        if let topTutorsLimit = QTLearnerDiscoverService.shared.topTutorsLimit,
            topTutorsLimit < aryTutors.count {
            aryTutors = aryTutors.suffix(topTutorsLimit)
        }
        
        if collectionView.isSkeletonActive {
            collectionView.isUserInteractionEnabled = true
            collectionView.hideSkeleton()
        }
        collectionView.reloadData()
    }
    
    @IBAction func onClickBtnViewAll(_ sender: Any) {
        didClickViewAllTutors?(nil, subcategory, category?.mainPageData.name, aryTutors, loadedAllTutors)
    }
}

extension QTLearnerDiscoverTutorsViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return QTLearnerDiscoverTutorCollectionViewCell.reuseIdentifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isRisingTalent || isFirstTop {
            return aryTutors.prefix(4).count
        } else {
            return aryTutors.prefix(8).count - 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerDiscoverTutorCollectionViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTutorCollectionViewCell
        if isRisingTalent || isFirstTop {
            cell.setView(aryTutors[indexPath.item], isRisingTalent: isRisingTalent)
        } else {
            cell.setView(aryTutors[indexPath.item + 4], isRisingTalent: isRisingTalent)
        }
        
        return cell
    }
}

extension QTLearnerDiscoverTutorsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.size.width - 55) / 2
        return CGSize(width: width, height: 254)
    }
}

extension QTLearnerDiscoverTutorsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QTLearnerDiscoverTutorCollectionViewCell else { return }
        UIView.animate(withDuration: 0.2) {
            cell.transform = .identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QTLearnerDiscoverTutorCollectionViewCell else { return }
        cell.growSemiShrink {
            if self.isRisingTalent || self.isFirstTop {
                self.didClickTutor?(self.aryTutors[indexPath.item])
            } else {
                self.didClickTutor?(self.aryTutors[indexPath.item + 4])
            }
        }
    }
}
