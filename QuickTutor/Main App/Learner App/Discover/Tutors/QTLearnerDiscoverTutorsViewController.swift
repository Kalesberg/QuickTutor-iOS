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
        collectionView.register(QTWideTutorCollectionViewCell.self, forCellWithReuseIdentifier: QTWideTutorCollectionViewCell.reuseIdentifier)
//        collectionView.register(QTLearnerDiscoverTutorCollectionViewCell.nib, forCellWithReuseIdentifier: QTLearnerDiscoverTutorCollectionViewCell.reuseIdentifier)
        
        lblFooterTitle.showAnimatedSkeleton(usingColor: Colors.gray)
        collectionView.prepareSkeleton { _ in
            self.collectionView.isUserInteractionEnabled = false
            self.collectionView.isScrollEnabled = false
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
            TutorSearchService.shared.fetchLearnerRisingTalents(category: category?.mainPageData.name, subcategory: subcategory) { tutors in
                self.showTutors(tutors)
                self.loadedAllTutors = true
                
                if self.lblFooterTitle.isSkeletonActive {
                    self.lblFooterTitle.hideSkeleton()
                }
                self.lblFooterTitle.text = "\(self.aryTutors.count) people in the list"
                self.btnFooterAction.superview?.isHidden = false
            }
        } else if let subcategory = subcategory {
            if let section = QTLearnerDiscoverService.shared.sectionTutors.first(where: { .subcategory == $0.type && subcategory == $0.key }),
                let tutors = section.tutors {
                if self.lblFooterTitle.isSkeletonActive {
                    self.lblFooterTitle.hideSkeleton()
                }
                if collectionView.isSkeletonActive {
                    collectionView.hideSkeleton()
                    collectionView.isUserInteractionEnabled = true
                    collectionView.isScrollEnabled = false
                }
                if let topTutorsLimit = QTLearnerDiscoverService.shared.topTutorsLimit,
                    topTutorsLimit < tutors.count {
                    self.lblFooterTitle.text = "\(topTutorsLimit) people in the list"
                } else {
                    self.lblFooterTitle.text = "\(tutors.count) people in the list"
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
                let tutors = section.tutors {
                if self.lblFooterTitle.isSkeletonActive {
                    self.lblFooterTitle.hideSkeleton()
                }
                if collectionView.isSkeletonActive {
                    collectionView.hideSkeleton()
                    collectionView.isUserInteractionEnabled = true
                    collectionView.isScrollEnabled = false
                }
                if let topTutorsLimit = QTLearnerDiscoverService.shared.topTutorsLimit,
                    topTutorsLimit < tutors.count {
                    self.lblFooterTitle.text = "\(topTutorsLimit) people in the list"
                } else {
                    self.lblFooterTitle.text = "\(tutors.count) people in the list"
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
    
    private func showTutors(_ tutors: [AWTutor]) {
        if let topTutorsLimit = QTLearnerDiscoverService.shared.topTutorsLimit,
            topTutorsLimit < aryTutors.count {
            aryTutors = aryTutors.suffix(topTutorsLimit)
        } else {
            aryTutors = tutors
        }
        
        if collectionView.isSkeletonActive {
            collectionView.hideSkeleton()
            collectionView.isUserInteractionEnabled = true
            collectionView.isScrollEnabled = false
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
        return QTWideTutorCollectionViewCell.reuseIdentifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isRisingTalent || isFirstTop {
            return aryTutors.prefix(4).count
        } else {
            return aryTutors.prefix(8).count - 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTWideTutorCollectionViewCell.reuseIdentifier, for: indexPath) as! QTWideTutorCollectionViewCell
        if isRisingTalent || isFirstTop {
            cell.updateUI(aryTutors[indexPath.item])
//            cell.setView(aryTutors[indexPath.item], isRisingTalent: isRisingTalent)
        } else {
            cell.updateUI(aryTutors[indexPath.item + 4])
//            cell.setView(aryTutors[indexPath.item + 4], isRisingTalent: isRisingTalent)
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
        guard let cell = collectionView.cellForItem(at: indexPath) as? QTWideTutorCollectionViewCell else { return }
        UIView.animate(withDuration: 0.2) {
            cell.transform = .identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QTWideTutorCollectionViewCell else { return }
        cell.growSemiShrink {
            if self.isRisingTalent || self.isFirstTop {
                self.didClickTutor?(self.aryTutors[indexPath.item])
            } else {
                self.didClickTutor?(self.aryTutors[indexPath.item + 4])
            }
        }
    }
}
