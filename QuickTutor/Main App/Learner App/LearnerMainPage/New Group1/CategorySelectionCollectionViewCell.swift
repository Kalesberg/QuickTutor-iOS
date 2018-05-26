//
//  CategorySelectionCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class CategorySelectionCollectionViewCell : UICollectionViewCell {
    
    required override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let customLayout = SubjectSearchCollectionViewLayout(cellsPerRow: 3, minimumInteritemSpacing: 10, minimumLineSpacing: 10, sectionInset: UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5))

    let collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.tag = 0
        
        return collectionView
    }()
    
    
    let categoryLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(24)
        
        return label
    }()
    
    var delegate : SelectedSubcategory?
    
    var category : Category! {
        didSet{
            categoryLabel.text = category.mainPageData.displayName
            collectionView.reloadData()
        }
    }
    
    var colors = ["1EAD4A", "3F578C", "524D8C", "E2B700", "F48619", "1EADFC"]
    
    func configureView() {
        addSubview(categoryLabel)
        addSubview(collectionView)
        
        colors.shuffle()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SubjectCollectionViewCell.self, forCellWithReuseIdentifier: "subcategoryCell")
        collectionView.collectionViewLayout = customLayout
        
        applyConstraints()
    }
    
    func applyConstraints(){
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.88)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        categoryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }
}

extension CategorySelectionCollectionViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subcategoryCell", for: indexPath) as! SubjectCollectionViewCell
        
        let subcat = category.subcategory
        
		cell.imageView.image = subcat.icon[indexPath.item]
		cell.label.text = subcat.subcategories[indexPath.item]
        
		var index : Int
		
		if subcat.subcategories[indexPath.item].count > 11 {
			index = 0
		} else {
			index = colors.count - 1
		}
		
		cell.contentView.backgroundColor = UIColor(hex: colors[index])
		colors.remove(at: index)		
		if colors.count == 0 {
			colors = ["1EAD4A", "3F578C", "524D8C", "E2B700", "F48619", "1EADFC"]
		}

        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        delegate?.didSelectSubcategory(resource: category.subcategory.fileToRead, subject: category.subcategory.subcategories[indexPath.item], index: indexPath.item)

    }
}
