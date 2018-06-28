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

	let collectionView : UICollectionView =  {
		
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		
		let customLayout = CategorySearchCollectionViewLayout(cellsPerRow: 2, minimumInteritemSpacing: 5, minimumLineSpacing: 50, sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))

		collectionView.collectionViewLayout = customLayout
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
			make.top.equalTo(titleLabel.snp.bottom).inset(-10)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide)
			} else {
				make.bottom.equalToSuperview()
			}
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
		contentView.collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "trendingCell")
    }
}
extension TrendingCategories : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return category.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath) as! CategoryCollectionViewCell
		
		cell.label.text = category[indexPath.item].mainPageData.displayName
		cell.imageView.image = category[indexPath.item].mainPageData.image
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
		cell.growSemiShrink {
			let next = CategoryInfo()
			next.category = category[indexPath.item]
			self.navigationController?.pushViewController(next, animated: true)
		}
		collectionView.deselectItem(at: indexPath, animated: true)
	}
	
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
		cell.shrink()
	}
	
	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
		UIView.animate(withDuration: 0.2) {
			cell.transform = CGAffineTransform.identity
		}
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let screen = UIScreen.main.bounds
		let width = (screen.width / 2) - 25
		let height = (screen.height / 3)
		
		return CGSize(width: width, height: height)
	}
}
