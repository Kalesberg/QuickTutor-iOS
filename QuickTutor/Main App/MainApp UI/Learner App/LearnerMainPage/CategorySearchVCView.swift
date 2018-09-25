//
//  CategorySearchVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 9/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class CategorySearchVCView: MainLayoutTwoButton {
    
    var back = NavbarButtonBack()
    let subtitle = SectionHeader()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.searchBarStyle = .prominent
        searchBar.backgroundImage = UIImage(color: UIColor.clear)
        let textField = searchBar.value(forKey: "searchField") as? UITextField
        textField?.font = Fonts.createSize(18)
        textField?.textColor = .white
        textField?.adjustsFontSizeToFitWidth = true
        textField?.autocapitalizationType = .words
        textField?.attributedPlaceholder = NSAttributedString(string: CategorySelected.title, attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
        textField?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        textField?.keyboardAppearance = .dark
        return searchBar
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let customLayout = CategorySearchCollectionViewLayout(cellsPerRow: 3, minimumInteritemSpacing: 5, minimumLineSpacing: 50, sectionInset: UIEdgeInsets(top: 15, left: 10, bottom: 0, right: 10))
        collectionView.collectionViewLayout = customLayout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    override var leftButton: NavbarButton {
        get {
            return back
        } set {
            back = newValue as! NavbarButtonBack
        }
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        setupSearchBar()
        setupSubtitle()
        setupCollectionView()
    }
    
    func setupSearchBar() {
        navbar.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.left.equalTo(back.snp.right)
            make.right.equalTo(rightButton.snp.left)
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    
    func setupSubtitle() {
        addSubview(subtitle)
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalToSuperview()
        }
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(subtitle.snp.bottom).inset(-20)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
}
