//
//  LearnerMainPageVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 9/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

struct MainPageFeaturedItem {
    var subject: String?
    var backgroundImageUrl: URL
    var title: String
    var subcategoryTitle: String?
    var categoryTitle: String?
}

class LearnerMainPageVCView: UIView {

    let searchBar: PaddedTextField = {
        let field = PaddedTextField()
        field.padding.left = 40
        field.backgroundColor = Colors.gray
        field.textColor = .white
        let searchIcon = UIImageView(image: UIImage(named:"searchIconMain"))
        field.leftView = searchIcon
        field.leftView?.transform = CGAffineTransform(translationX: 12.5, y: 0)
        field.leftViewMode = .unlessEditing
        field.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.75)])
        field.font = Fonts.createBoldSize(16)
        field.layer.cornerRadius = 4
        return field
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.backgroundColor = Colors.darkBackground
        collectionView.register(LearnerMainPageFeaturedSectionContainerCell.self, forCellWithReuseIdentifier: "featuredCell")
        collectionView.register(LearnerMainPageTopTutorsSectionContainerCell.self, forCellWithReuseIdentifier: "topTutors")
        collectionView.register(LearnerMainPageCategorySectionContainerCell.self, forCellWithReuseIdentifier: "categoryCell")
        collectionView.register(LearnerMainPageSuggestionSectionContainerCell.self, forCellWithReuseIdentifier: "suggestionCell")
        collectionView.register(LearnerMainPageActiveTutorsSectionContainerCell.self, forCellWithReuseIdentifier: "activeCell")
        return collectionView
    }()
    
    let collectionViewHelper = LearnerMainPageCollectionViewHelper()
    
    func setupViews() {
        setupMainView()
        setupSearchBar()
        setupCollectionView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupSearchBar() {
        addSubview(searchBar)
        searchBar.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 47)
        searchBar.delegate = self
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = collectionViewHelper
        collectionView.dataSource = collectionViewHelper
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
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
