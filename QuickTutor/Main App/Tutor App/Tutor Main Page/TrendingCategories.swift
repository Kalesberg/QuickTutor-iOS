//
//  TrendingCategories.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TrendingCategoriesView : MainLayoutTitleBackButton {
    
    let titleLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(18)
        label.text = "Top Categories"
        label.textColor = .white
        
        return label
    }()
    
    let collectionView : UICollectionView = {
        
        let collectionView : UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    override func configureView() {
        addSubview(titleLabel)
        addSubview(collectionView)
        super.configureView()
        
        title.label.text = "Trending Categories"

    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom).inset(-20)
            make.left.equalToSuperview().inset(15)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).inset(-15)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(205)
        }
    }
}

class TrendingCategories : BaseViewController {
    
    override var contentView: TrendingCategoriesView {
        return view as! TrendingCategoriesView
    }
    override func loadView() {
        view = TrendingCategoriesView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "categoryCollectionViewCell")
    }
}

extension TrendingCategories : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.label.text = category[indexPath.row].mainPageData.displayName
        cell.imageView.image = category[indexPath.row].mainPageData.image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CategorySelected.title = category[indexPath.item].mainPageData.displayName
        
        let next = CategoryInfo()
        next.category = category[indexPath.item]
        next.contentView.title.label.text = category[indexPath.item].mainPageData.displayName
        navigationController?.pushViewController(next, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        let width = (screenWidth / 2) - 10
        
        return CGSize(width: width, height: contentView.frame.height)
    }
}
