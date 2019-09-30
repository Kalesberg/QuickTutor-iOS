//
//  QTTutorDiscoverMainView.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/2/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorDiscoverMainView: UIView {

    // MARK: - Properties
    let navigationView: QTLearnerMainPageNavigationView = {
        let view = QTLearnerMainPageNavigationView(frame: .zero)
        return view
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Colors.newScreenBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        // Register reusable identifiers
        collectionView.register(QTTutorDiscoverNewsSectionCollectionViewCell.self,
                                forCellWithReuseIdentifier: QTTutorDiscoverNewsSectionCollectionViewCell.reuseIdentifier)
        collectionView.register(QTTutorDiscoverOpportunitiesSectionCollectionViewCell.self,
                                forCellWithReuseIdentifier: QTTutorDiscoverOpportunitiesSectionCollectionViewCell.reuseIdentifier)
        collectionView.register(LearnerMainPageCategorySectionContainerCell.self,
                                forCellWithReuseIdentifier: LearnerMainPageCategorySectionContainerCell.reuseIdentifier)
        collectionView.register(QTTutorDiscoverTipsSectionCollectionViewCell.self,
                                forCellWithReuseIdentifier: QTTutorDiscoverTipsSectionCollectionViewCell.reuseIdentifier)
        collectionView.register(QTTutorDiscoverShareSectionCollectionViewCell.self,
                                forCellWithReuseIdentifier: QTTutorDiscoverShareSectionCollectionViewCell.reuseIdentifier)
        
        return collectionView
    }()
    
    var navigationViewTopAnchor: NSLayoutConstraint!
    var prevOffset: CGFloat = 0
    var transitionStartOffset: CGFloat = -1
    let navigationViewHeight: CGFloat = 82
    var hasOpportunities = true
    var collectionViewTopInset: CGFloat = 0
    
    // MARK: - Functions
    func setupViews() {
        setupMainView()
        setupNavigationView()
        setupCollectionView()
        setupBackgroundView()
        addObservers()
    }
    
    func setupBackgroundView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = Colors.newScreenBackground
        
        addSubview(backgroundView)
        backgroundView.anchor(top: topAnchor, left: leftAnchor, bottom: navigationView.topAnchor, right: rightAnchor,
                              paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                              width: 0, height: 0)
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupNavigationView() {
        addSubview(navigationView)
        navigationView.searchIconView.isHidden = true
        navigationView.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor,
                              paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                              width: 0, height: 0)
        navigationViewTopAnchor = navigationView.topAnchor.constraint(equalTo: getTopAnchor())
        navigationViewTopAnchor.isActive = true
    }
    
    func setupCollectionView() {
        insertSubview(collectionView, at: 0)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        collectionViewTopInset = navigationViewHeight + UIApplication.shared.statusBarFrame.height
        collectionView.contentInset = UIEdgeInsets(top: collectionViewTopInset, left: 0, bottom: 0, right: 0)
        collectionView.clipsToBounds = false
        collectionView.delegate = self
        collectionView.dataSource = self

        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            
        }
    }
    
    func animateTopBar(withOffset offset: CGFloat) {
        let delta = offset + self.collectionViewTopInset
        
        let scrollUp = self.prevOffset >= delta
        
        if self.transitionStartOffset > -1 {
            
            // If the offset is less than zero, will set navigationViewTopAnchor as 0
            if delta < 0 {
                self.navigationViewTopAnchor.constant = 0
            } else {
                self.navigationViewTopAnchor.constant = min(0, max(self.navigationViewTopAnchor.constant + self.prevOffset - delta, -self.navigationViewHeight))
            }
            
            // Control the alpha of navigationView
            self.navigationView.alpha = 1 - abs(self.navigationViewTopAnchor.constant) / self.navigationViewHeight
            
            // If the show/hide transition is completed, will rest transitionStartOffset as -1
            if self.navigationViewTopAnchor.constant == 0 || self.navigationViewTopAnchor.constant == -self.navigationViewHeight {
                self.transitionStartOffset = -1
            }
            
            self.prevOffset = delta
            return
        }
        
        // If you scroll up and the delta is greater than 10 or you scroll up closed to the top of view, start to show bar.
        if scrollUp && self.transitionStartOffset == -1 && self.navigationViewTopAnchor.constant == -self.navigationViewHeight && (abs(self.prevOffset - delta) >= 10 || delta <= self.navigationViewHeight) {
            self.transitionStartOffset = max(delta, 0)
            self.prevOffset = delta
            return
        }
        
        // If you scroll down when the navigation view is showing fully, it's about to hide the navigation bar.
        if !scrollUp && self.transitionStartOffset == -1 && self.navigationViewTopAnchor.constant == 0 {
            self.transitionStartOffset = max(delta, 0)
            self.prevOffset = delta
            return
        }
        
        self.prevOffset = delta
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReceivedOpportunityExistenceStatus(_:)),
                                               name: NotificationNames.TutorDiscoverPage.opportunityExistenceStatus,
                                               object: nil)
    }
    
    // MARK: - Actions
    @objc
    func onReceivedOpportunityExistenceStatus(_ notification: Notification) {
        if let userInfo = notification.userInfo, let existance = userInfo["opportunityExistenceStatus"] as? Bool {
            self.hasOpportunities = existance
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource
extension QTTutorDiscoverMainView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return hasOpportunities ? 1 : 0
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0: // News
            do {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTTutorDiscoverNewsSectionCollectionViewCell.reuseIdentifier, for: indexPath) as! QTTutorDiscoverNewsSectionCollectionViewCell
                return cell
            }
        case 1: // Opportunities
            do {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTTutorDiscoverOpportunitiesSectionCollectionViewCell.reuseIdentifier, for: indexPath) as! QTTutorDiscoverOpportunitiesSectionCollectionViewCell
                return cell
            }
        case 2:
            do {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LearnerMainPageCategorySectionContainerCell.reuseIdentifier, for: indexPath)
                return cell
            }
        case 3:
            do {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTTutorDiscoverTipsSectionCollectionViewCell.reuseIdentifier, for: indexPath)
                return cell
            }
        case 4:
            do {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTTutorDiscoverShareSectionCollectionViewCell.reuseIdentifier, for: indexPath)
                return cell
            }
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension QTTutorDiscoverMainView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width
        
        switch indexPath.section {
        case 0:
            return CGSize(width: width, height: 290)
        case 1:
            return CGSize(width: width, height: width * 189 / 315 + 44)
        case 2:
            return CGSize(width: width, height: 230)
        case 3:
            return CGSize(width: width, height: 527)
        case 4:
            return CGSize(width: width, height: 197)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var topPadding = CGFloat.leastNonzeroMagnitude
        if section == 0 {
            topPadding = 20
        } else if section == 1 {
            topPadding = hasOpportunities ? 40 : CGFloat.leastNonzeroMagnitude
        } else {
            topPadding = 40
        }
        
        return UIEdgeInsets(top: topPadding, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - UIScrollViewDelegate
extension QTTutorDiscoverMainView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        animateTopBar(withOffset: scrollView.contentOffset.y)
    }
}
