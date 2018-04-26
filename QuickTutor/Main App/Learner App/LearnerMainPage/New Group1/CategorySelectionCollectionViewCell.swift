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
        //collectionView.backgroundColor = .gray
		
		return collectionView
	}()
	
	
	let categoryLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createBoldSize(24)
		label.alpha = 0.6
		
		return label
	}()

	override var isSelected : Bool {
		didSet {
			categoryLabel.alpha = isSelected ? 1.0 : 0.6
			isUserInteractionEnabled = isSelected ? false : true
		}
	}
	
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
        
		cell.imageView.image = category.subcategory.icon[indexPath.item]
		cell.label.text = category.subcategory.subcategories[indexPath.item]
        
        let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
        cell.contentView.backgroundColor = UIColor(hex: colors[randomIndex])
        colors.remove(at: randomIndex)

        if colors.count == 0 {
            colors = ["1EAD4A", "3F578C", "524D8C", "E2B700", "F48619", "1EADFC"]
        }
        
		return cell
	}
	
	internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print(category.subcategory.fileToRead)
		print(category.subcategory.subcategories[indexPath.item])
		delegate?.didSelectSubcategory(resource: category.subcategory.fileToRead, subject: category.subcategory.subcategories[indexPath.item], index: indexPath.item)

	}
}
