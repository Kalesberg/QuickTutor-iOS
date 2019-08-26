//
//  LearnerMainPageVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 9/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

struct MainPageFeaturedItem {
    var subject: String?
    var backgroundImageUrl: URL
    var title: String
    var subcategoryTitle: String?
    var categoryTitle: String?
}


class LearnerMainPageVCView: UIView {

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
        collectionView.register(LearnerMainPageTopTutorsSectionContainerCell.self, forCellWithReuseIdentifier: "topTutors")
        collectionView.register(LearnerMainPageCategorySectionContainerCell.self, forCellWithReuseIdentifier: "categoryCell")
        collectionView.register(QTLearnerMainPageQuickActionSectionContainerCell.self, forCellWithReuseIdentifier: QTLearnerMainPageQuickActionSectionContainerCell.reuseIdentifier)
        collectionView.register(LearnerMainPageSuggestionSectionContainerCell.self, forCellWithReuseIdentifier: "suggestionCell")
        collectionView.register(LearnerMainPageActiveTutorsSectionContainerCell.self, forCellWithReuseIdentifier: "activeCell")
        collectionView.register(QTLearnerMainPagePastTransactionContainerCell.self, forCellWithReuseIdentifier: QTLearnerMainPagePastTransactionContainerCell.reuseIdentifier)
        collectionView.register(QTLearnerMainPageUpcomingSessionContainerCell.self, forCellWithReuseIdentifier: QTLearnerMainPageUpcomingSessionContainerCell.reuseIdentifier)
        return collectionView
    }()
    
    let collectionViewHelper = LearnerMainPageCollectionViewHelper()
    var navigationViewTopAnchor: NSLayoutConstraint!
    var prevOffset: CGFloat = 0
    var transitionStartOffset: CGFloat = -1
    let navigationViewHeight: CGFloat = 81
    
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
        backgroundView.anchor(top: topAnchor, left: leftAnchor, bottom: navigationView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupNavigationView() {
        addSubview(navigationView)
        navigationView.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        navigationViewTopAnchor = navigationView.topAnchor.constraint(equalTo: getTopAnchor())
        navigationViewTopAnchor.isActive = true
    }
    
    func setupCollectionView() {
        insertSubview(collectionView, at: 0)
        collectionView.anchor(top: getTopAnchor(), left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 81, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = collectionViewHelper
        collectionView.dataSource = collectionViewHelper
        collectionView.clipsToBounds = false
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            
        }
    }
    
    func setupScrollViewDidScrollAction() {
        collectionViewHelper.handleScrollViewScroll = { [weak self] offset in
            guard let self = self else { return }
            
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
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadSessions), name: NotificationNames.LearnerMainFeed.reloadSessions, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupScrollViewDidScrollAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleReloadSessions() {
        DispatchQueue.main.async(execute: {
            // TODO reload past sessions and upcoming sessions.
            self.collectionViewHelper.hasPastSessions = !QTLearnerSessionsService.shared.pastSessions.isEmpty
            self.collectionViewHelper.hasUpcomingSessions = !QTLearnerSessionsService.shared.upcomingSessions.isEmpty
            self.collectionView.reloadData()
        })
    }
}

extension LearnerMainPageVCView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let field = textField as? PaddedTextField else { return }
        UIView.animate(withDuration: 0.25) {
            guard field.padding.left == 40 else { return }
            field.padding.left -= 30
            field.layoutIfNeeded()
            field.leftView?.alpha = 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.alpha = 1
    }
}
