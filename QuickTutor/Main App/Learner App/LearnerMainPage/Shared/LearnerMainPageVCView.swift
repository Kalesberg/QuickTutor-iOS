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

    let searchBarContainer: LearnerMainPageSearchBarContainer = {
        let container = LearnerMainPageSearchBarContainer()
        return container
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(LearnerMainPageFeaturedSectionContainerCell.self, forCellWithReuseIdentifier: "featuredCell")
        collectionView.register(LearnerMainPageTopTutorsSectionContainerCell.self, forCellWithReuseIdentifier: "topTutors")
        collectionView.register(LearnerMainPageCategorySectionContainerCell.self, forCellWithReuseIdentifier: "categoryCell")
        collectionView.register(LearnerMainPageSuggestionSectionContainerCell.self, forCellWithReuseIdentifier: "suggestionCell")
        collectionView.register(LearnerMainPageActiveTutorsSectionContainerCell.self, forCellWithReuseIdentifier: "activeCell")
        return collectionView
    }()
    
    let collectionViewHelper = LearnerMainPageCollectionViewHelper()
    var searchBarContainerHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupMainView()
        setupSearchBarContainer()
        setupCollectionView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupSearchBarContainer() {
        addSubview(searchBarContainer)
        searchBarContainer.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        searchBarContainerHeightAnchor = searchBarContainer.heightAnchor.constraint(equalToConstant: 87)
        searchBarContainerHeightAnchor?.isActive = true
        layoutIfNeeded()
    }
    
    func setupCollectionView() {
        insertSubview(collectionView, at: 0)
        collectionView.anchor(top: searchBarContainer.bottomAnchor, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: -30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = collectionViewHelper
        collectionView.dataSource = collectionViewHelper
    }
    
    func setupScrollViewDidScrollAction() {
        collectionViewHelper.handleScrollViewScroll = { offset in
            guard RecentSearchesManager.shared.hasNoRecentSearches
                || (-offset < 0 && offset != -50) else {
                self.searchBarContainer.showRecentSearchesCV()
                return
            }
            self.searchBarContainer.hideRecentSearchesCV()
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSearchesLoaded), name: NotificationNames.LearnerMainFeed.searchesLoaded, object: nil)
    }
    
    @objc func handleSearchesLoaded() {
        searchBarContainer.recentSearchesCV.reloadData()
        if RecentSearchesManager.shared.hasNoRecentSearches {
            self.searchBarContainer.hideRecentSearchesCV()
            self.collectionView.setContentOffset(.zero, animated: true)
        } else {
            self.collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
            self.collectionView.setContentOffset(CGPoint(x: 0, y: -50), animated: true)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupScrollViewDidScrollAction()
        setupObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
