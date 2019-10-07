//
//  QTTutorDiscoverOpportunitiesViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class QTTutorDiscoverOpportunitiesViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var quickRequests = [QTQuickRequestModel]()
    var reloadTimer: Timer?
    var noOpportunityCount = 0
    
    // MARK: - Functions
    func configureViews() {
        
        view.isSkeletonable = true
        
        // Register cells.
        collectionView.register(QTTutorDiscoverOpportunityCollectionViewCell.nib,
                                forCellWithReuseIdentifier: QTTutorDiscoverOpportunityCollectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isSkeletonable = true
    }
    
    func setupSkeletonView() {
        collectionView.prepareSkeleton { (completed) in
            self.view.showAnimatedSkeleton(usingColor: Colors.gray)
            QTQuickRequestService.shared.getOpportunities()
        }
    }
    
    func reloadContents() {
        
        // Show or hide the opportunities section on the tutor discover screen.
        NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.opportunityExistenceStatus,
                                        object: nil,
                                        userInfo: ["opportunityExistenceStatus": quickRequests.count > 0])
        
        // Reload opportunities
        reloadTimer?.invalidate()
        reloadTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            self.view.hideSkeleton(transition: SkeletonTransitionStyle.crossDissolve(0.1))
            self.collectionView.reloadData()
        })
        reloadTimer?.fire()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReceivedReloadOpportunity),
                                               name: NotificationNames.TutorDiscoverPage.reloadOpportinity,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReceivedQuickRequestAdded(_:)),
                                               name: NotificationNames.TutorDiscoverPage.quickRequestAdded,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReceivedQuickRequestRemoved(_:)),
                                               name: NotificationNames.TutorDiscoverPage.quickRequestRemoved,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReceivedNoQuickRequest(_:)),
                                               name: NotificationNames.TutorDiscoverPage.noQuickRequest,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReceivedAppliedToOpportunity(_:)),
                                               name: NotificationNames.TutorDiscoverPage.appliedToOpportunity,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReceivedRefershDiscoverPage),
                                               name: NotificationNames.TutorDiscoverPage.refreshDiscoverPage,
                                               object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @objc
    func onReceivedReloadOpportunity() {
        setupSkeletonView()
    }
    
    @objc
    func onReceivedQuickRequestAdded(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any],
            let quickRequest = userInfo["quickRequest"] as? QTQuickRequestModel {
            
            // Check whether the quick request has already been added or not.
            if let _ = quickRequests.first(where: {$0.id.compare(quickRequest.id) == .orderedSame}) {
                return
            }
            quickRequests.append(quickRequest)
            
            reloadContents()
        }
    }
    
    @objc
    func onReceivedQuickRequestRemoved(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any], let requestIds = userInfo["quickRequestIds"] as? [String] {
            quickRequests.removeAll { (request) -> Bool in
                return requestIds.contains(request.id)
            }
            
            reloadContents()
        }
    }
    
    @objc
    func onReceivedNoQuickRequest(_ notification:  Notification) {
        noOpportunityCount += 1
        if noOpportunityCount == 3 {
            reloadContents()
        }
    }
    
    @objc
    func onReceivedAppliedToOpportunity(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any], let requestId = userInfo["quickRequestId"] as? String {
            quickRequests.removeAll(where: {$0.id.compare(requestId) == .orderedSame})
            
            reloadContents()
        }
    }
    
    @objc
    func onReceivedRefershDiscoverPage() {
        noOpportunityCount = 0
        quickRequests.removeAll()
        let visibleCells = self.collectionView.visibleCells
        for item in visibleCells {
            if let cell = item as? QTTutorDiscoverOpportunityCollectionViewCell {
                cell.setSkeletionViews()
            }
        }
        self.view.showAnimatedSkeleton(usingColor: Colors.gray)
        QTQuickRequestService.shared.getOpportunities()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        addObservers()
        setupSkeletonView()
    }

    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            removeObservers()
            QTQuickRequestService.shared.removeOpportunityObservers()
        }
        super.didMove(toParent: parent)
    }
}

// MARK: - UICollectionViewDelegate
extension QTTutorDiscoverOpportunitiesViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension QTTutorDiscoverOpportunitiesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quickRequests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTTutorDiscoverOpportunityCollectionViewCell.reuseIdentifier, for: indexPath) as! QTTutorDiscoverOpportunityCollectionViewCell
        cell.setData(request: quickRequests[indexPath.row])
        cell.didApplyButtonClickHandler = { quickRequest in
            // TODO: Go to apply quick request screen.
            NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.applyToOpportunity, object: nil, userInfo: ["quickRequest": quickRequest])
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension QTTutorDiscoverOpportunitiesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - (quickRequests.count == 1 ? 40 : 60)
        return CGSize(width: width, height: 190)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}

extension QTTutorDiscoverOpportunitiesViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return QTTutorDiscoverOpportunityCollectionViewCell.reuseIdentifier
    }
}
