//
//  QTLearnerDiscoverRecentlyActiveViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class QTLearnerDiscoverRecentlyActiveViewController: UIViewController {
    
    var category: Category?
    var subcategory: String? = ""
    
    var didClickTutor: ((_ tutor: AWTutor) -> ())?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var aryActiveTutors: [AWTutor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.register(QTRecentlyActiveCollectionViewCell.self, forCellWithReuseIdentifier: QTRecentlyActiveCollectionViewCell.reuseIdentifier)
                
        collectionView.prepareSkeleton { _ in
            self.collectionView.isUserInteractionEnabled = false
            self.collectionView.showAnimatedSkeleton(usingColor: Colors.gray)
        }
    }
    
    func loadRecentlyActiveTutors() {
        TutorSearchService.shared.fetchRecentlyActiveTutors(category: category?.mainPageData.name, subcategory: subcategory) { tutors in
            let group = DispatchGroup()
            tutors.forEach { tutor in
                group.enter()
                ConnectionService.shared.getConnectionStatus(partnerId: tutor.uid) { connected in
                    tutor.isConnected = connected
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                if self.collectionView.isSkeletonActive {
                    self.collectionView.hideSkeleton()
                    self.collectionView.isUserInteractionEnabled = true
                }
                self.aryActiveTutors = tutors
                self.collectionView.reloadData()
            }
        }
    }
}
    
extension QTLearnerDiscoverRecentlyActiveViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return QTRecentlyActiveCollectionViewCell.reuseIdentifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryActiveTutors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTRecentlyActiveCollectionViewCell.reuseIdentifier, for: indexPath) as! QTRecentlyActiveCollectionViewCell
        cell.updateUI(user: aryActiveTutors[indexPath.item])
        cell.updateToMainFeedLayout()
        cell.delegate = self
        
        return cell
    }
}

extension QTLearnerDiscoverRecentlyActiveViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width - 50, height: 60)
    }
}

extension QTLearnerDiscoverRecentlyActiveViewController: ConnectionCellDelegate {
    func connectionCell(_ connectionCell: ConnectionCell, shouldShowConversationWith user: User) {
        guard let tutor = user as? AWTutor else { return }
        didClickTutor?(tutor)
    }
    
    func connectionCell(_ connectionCell: ConnectionCell, shouldRequestSessionWith user: User) {
        
    }
}
