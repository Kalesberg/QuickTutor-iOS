//
//  QTLearnerDiscoverForYouViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class QTLearnerDiscoverForYouViewController: UIViewController {

    var category: Category?
    var subcategory: String? = ""
    
    var didClickTutor: ((_ tutor: AWTutor) -> ())?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var aryTutorIds: [QTTutorSubjectInterface] = []
    private var aryTutors: [AWTutor] = []
    
    private var shouldLoadMore = false
    private var _observing = false
    private let limit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.register(QTLearnerDiscoverTutorCollectionViewCell.nib, forCellWithReuseIdentifier: QTLearnerDiscoverTutorCollectionViewCell.reuseIdentifier)
        collectionView.prepareSkeleton { _ in
            self.collectionView.isUserInteractionEnabled = false
            self.collectionView.showAnimatedSkeleton(usingColor: Colors.gray)
            self.loadLearnerRelativeTutorIds()
        }
    }

    private func loadLearnerRelativeTutorIds() {
        guard var interests = CurrentUser.shared.learner.interests else { return }
        
        if let category = category {
            interests = interests.filter({ category.mainPageData.name == SubjectStore.shared.findCategoryBy(subject: $0) })
        } else if let subcategory = subcategory {
            interests = interests.filter({ subcategory == SubjectStore.shared.findSubCategory(subject: $0) })
        }
        
        // load same subjects tutors
        var categories: [String] = []
        var subcategories: [String] = []
        let interestsGroup = DispatchGroup()
        for interest in interests {
            if let category = SubjectStore.shared.findCategoryBy(subject: interest),
                !categories.contains(category) {
                categories.append(category)
            }
            if let subcategory = SubjectStore.shared.findSubCategory(subject: interest),
                !subcategories.contains(subcategory) {
                subcategories.append(subcategory)
            }
            
            interestsGroup.enter()
            TutorSearchService.shared.getTutorIdsBySubject(interest) { tutorIds in
                guard let tutorIds = tutorIds else {
                    interestsGroup.leave()
                    return
                }
                tutorIds.forEach { tutorId in
                    if CurrentUser.shared.learner.uid != tutorId,
                        !self.aryTutorIds.contains(where: { $0.tutorId == tutorId }) {
                        self.aryTutorIds.append(QTTutorSubjectInterface(tutorId: tutorId, subject: interest))
                    }
                }
                interestsGroup.leave()
            }
        }
        
        interestsGroup.notify(queue: .global(qos: .userInitiated)) {
            // load same subcategory tutors
            let subcategoriesGroup = DispatchGroup()
            for subcategory in subcategories {
                subcategoriesGroup.enter()
                TutorSearchService.shared.getTutorIdsBySubcategory(subcategory) { tutorIds in
                    guard let tutorIds = tutorIds else {
                        subcategoriesGroup.leave()
                        return
                    }
                    tutorIds.forEach { tutorId in
                        if CurrentUser.shared.learner.uid != tutorId,
                            !self.aryTutorIds.contains(where: { $0.tutorId == tutorId }) {
                            // get any subject of this subcategory
                            if let subjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: subcategory) {
                                // get random subject
                                let rndIndex = Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(subjects.count))
                                self.aryTutorIds.append(QTTutorSubjectInterface(tutorId: tutorId, subject: subjects[rndIndex]))
                            }
                        }
                    }
                    subcategoriesGroup.leave()
                }
            }
            subcategoriesGroup.notify(queue: .global(qos: .userInitiated)) {
                // load same category tutors
                let categoriesGroup = DispatchGroup()
                for category in categories {
                    categoriesGroup.enter()
                    TutorSearchService.shared.getTutorIdsByCategory(category) { tutorIds in
                        guard let tutorIds = tutorIds else {
                            categoriesGroup.leave()
                            return
                        }
                        tutorIds.forEach { tutorId in
                            if CurrentUser.shared.learner.uid != tutorId,
                                !self.aryTutorIds.contains(where: { $0.tutorId == tutorId }) {
                                
                                // get any subcategory of this category
                                if let category = Category.category(for: category) {
                                    let rndIndex = Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(category.subcategory.subcategories.count))
                                    let rndSubcategoryName = category.subcategory.subcategories[rndIndex].title
                                    
                                    // get any subject of subcategory
                                    if let subjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: rndSubcategoryName) {
                                        // get random subject
                                        let rndIndex = Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(subjects.count))
                                        self.aryTutorIds.append(QTTutorSubjectInterface(tutorId: tutorId, subject: subjects[rndIndex]))
                                    }
                                }
                            }
                        }
                        categoriesGroup.leave()
                    }
                }
                categoriesGroup.notify(queue: .global(qos: .userInitiated)) {
                    self.loadTutors()
                }
            }
        }
    }
    
    private func loadTutors() {
        _observing = true
        let tutorsGroup = DispatchGroup()
        var tutors: [AWTutor] = []
        
        let realLimit = limit < aryTutorIds.count ? limit : aryTutorIds.count
        for index in 0 ..< realLimit {
            tutorsGroup.enter()
            FirebaseData.manager.fetchTutor(aryTutorIds[index].tutorId, isQuery: false, queue: .global(qos: .userInitiated)) { tutor in
                guard let tutor = tutor else {
                    tutorsGroup.leave()
                    return
                }
                tutor.featuredSubject = self.aryTutorIds[index].subject
                tutors.append(tutor)
                tutorsGroup.leave()
            }
        }
        tutorsGroup.notify(queue: .main) {
            self._observing = false
            if self.collectionView.isSkeletonActive {
                self.collectionView.hideSkeleton()
                self.collectionView.isUserInteractionEnabled = true
            }
            self.aryTutorIds = Array(self.aryTutorIds.dropFirst(realLimit))
            self.shouldLoadMore = 0 < self.aryTutorIds.count
            self.aryTutors.append(contentsOf: tutors)
            self.collectionView.reloadData()
        }
    }

}

extension QTLearnerDiscoverForYouViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return QTLearnerDiscoverTutorCollectionViewCell.reuseIdentifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryTutors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerDiscoverTutorCollectionViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTutorCollectionViewCell
        cell.setView(aryTutors[indexPath.item])
        
        return cell
    }
}

extension QTLearnerDiscoverForYouViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.size.width - 50) / 2.5
        return CGSize(width: width, height: 254)
    }
}

extension QTLearnerDiscoverForYouViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == aryTutors.count - 1,
            shouldLoadMore, !_observing {
            loadTutors()
        }
    }
    
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
