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
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        // Register reusable identifiers
        collectionView.register(QTTutorDiscoverNewsSectionCollectionViewCell.self,
                                forCellWithReuseIdentifier: QTTutorDiscoverNewsSectionCollectionViewCell.reuseIdentifier)
        collectionView.register(QTTutorDiscoverOpportunitiesSectionCollectionViewCell.self,
                                forCellWithReuseIdentifier: QTTutorDiscoverOpportunitiesSectionCollectionViewCell.reuseIdentifier)
        
        return collectionView
    }()
    
    var navigationViewTopAnchor: NSLayoutConstraint!
    var prevOffset: CGFloat = 0
    var transitionStartOffset: CGFloat = -1
    let navigationViewHeight: CGFloat = 81
    var hasOpportunities = true
    
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
        navigationView.searchIconImageView.isHidden = true
        navigationView.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor,
                              paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                              width: 0, height: 0)
        navigationViewTopAnchor = navigationView.topAnchor.constraint(equalTo: getTopAnchor())
        navigationViewTopAnchor.isActive = true
    }
    
    func setupCollectionView() {
        insertSubview(collectionView, at: 0)
        collectionView.anchor(top: getTopAnchor(), left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor,
                              paddingTop: 81, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                              width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            
        }
    }
    
    func animateTopBar(withOffset offset: CGFloat) {
        let scrollUp = self.prevOffset >= offset
        
        if self.transitionStartOffset > -1 {
            
            // If the offset is less than zero, will set navigationViewTopAnchor as 0
            if offset < 0 {
                self.navigationViewTopAnchor.constant = 0
            } else {
                self.navigationViewTopAnchor.constant = min(0, max(self.navigationViewTopAnchor.constant + self.prevOffset - offset, -self.navigationViewHeight))
            }
            
            // Control the alpha of navigationView
            self.navigationView.alpha = 1 - abs(self.navigationViewTopAnchor.constant) / self.navigationViewHeight
            
            // If the show/hide transition is completed, will rest transitionStartOffset as -1
            if self.navigationViewTopAnchor.constant == 0 || self.navigationViewTopAnchor.constant == -self.navigationViewHeight {
                self.transitionStartOffset = -1
            }
            
            self.prevOffset = offset
            return
        }
        
        // If you scroll up and the delta is greater than 10 or you scroll up closed to the top of view, start to show bar.
        if scrollUp && self.transitionStartOffset == -1 && self.navigationViewTopAnchor.constant == -self.navigationViewHeight && (abs(self.prevOffset - offset) >= 10 || offset <= self.navigationViewHeight) {
            self.transitionStartOffset = max(offset, 0)
            self.prevOffset = offset
            return
        }
        
        // If you scroll down when the navigation view is showing fully, it's about to hide the navigation bar.
        if !scrollUp && self.transitionStartOffset == -1 && self.navigationViewTopAnchor.constant == 0 {
            self.transitionStartOffset = max(offset, 0)
            self.prevOffset = offset
            return
        }
        
        self.prevOffset = offset
        return
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
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return hasOpportunities ? 1 : 0
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
            return CGSize(width: width, height: width  * 110 / 165.5 + 57)
        case 1:
            return CGSize(width: width, height: width * 189 / 315 + 44)
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
