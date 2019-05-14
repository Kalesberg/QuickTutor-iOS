//
//  LearnerMainPageSearchBarContainer.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/13/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class LearnerMainPageSearchBarContainer: UIView {
    
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
    
    let recentSearchesCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceHorizontal = true
        cv.delaysContentTouches = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cv.register(RecentSearchCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    var recentSearchesCVHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupSearchBar()
        setupRecentSearchesCV()
    }
    
    func setupSearchBar() {
        addSubview(searchBar)
        searchBar.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 47)
        searchBar.delegate = self
    }
    
    func setupRecentSearchesCV() {
        addSubview(recentSearchesCV)
        recentSearchesCV.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        recentSearchesCVHeightAnchor = recentSearchesCV.heightAnchor.constraint(equalToConstant: 30)
        recentSearchesCVHeightAnchor?.isActive = true
        layoutIfNeeded()
        recentSearchesCV.delegate = self
        recentSearchesCV.dataSource = self
    }
    
    func hideRecentSearchesCV() {
        UIView.animate(withDuration: 0.25) {
            self.recentSearchesCV.alpha = 0
        }
    }
    
    func showRecentSearchesCV() {
        UIView.animate(withDuration: 0.25) {
            self.recentSearchesCV.alpha = 1
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LearnerMainPageSearchBarContainer: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RecentSearchesManager.shared.searches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! RecentSearchCell
        cell.titleLabel.text = RecentSearchesManager.shared.searches[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = RecentSearchesManager.shared.searches[indexPath.item].estimateFrameForFontSize(12).width + 19
        return CGSize(width: width, height: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let subject = RecentSearchesManager.shared.searches[indexPath.item]
        
        let userInfo: [AnyHashable: Any] = ["subject": subject]
        NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.recentSearchCellTapped, object: nil, userInfo: userInfo)
    }
    
}

extension LearnerMainPageSearchBarContainer: UITextFieldDelegate {
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
