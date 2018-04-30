//
//  LearnerMainPageTableView.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class FeaturedTutorTableViewCell : UITableViewCell  {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let collectionView : UICollectionView =  {
		
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 0, right: 0)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0.0
		
		collectionView.collectionViewLayout = layout
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		
		return collectionView
	}()
	
	var datasource : [AWTutor]? {
		didSet {
			collectionView.reloadData()
		}
	}
	
	var category : Category! {
		didSet{
			collectionView.reloadData()
		}
	}
	
	func configureTableViewCell() {
		addSubview(collectionView)
		
		backgroundColor = .clear
		
		collectionView.delegate = self
		collectionView.dataSource = self
		
		collectionView.register(FeaturedTutorCollectionViewCell.self, forCellWithReuseIdentifier: "featuredCell")
		
		applyConstraints()
	}
	
	func applyConstraints() {
		collectionView.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalToSuperview()
			make.width.equalToSuperview()
		}
	}
}

extension FeaturedTutorTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return datasource?.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! FeaturedTutorCollectionViewCell

		cell.price.text = datasource![indexPath.item].price.priceFormat()
		cell.featuredTutor.imageView.loadUserImages(by: datasource![indexPath.item].images["image1"]!)
		cell.featuredTutor.namePrice.text = datasource![indexPath.item].name
		cell.featuredTutor.region.text = datasource![indexPath.item].region
		cell.featuredTutor.subject.text = datasource![indexPath.item].topSubject
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		if let current = UIApplication.getPresentedViewController() {
			
			let next = TutorConnect()
			let tutor = datasource![indexPath.item]
			
			next.featuredTutor = tutor
			next.contentView.rightButton.isHidden = true
			next.contentView.searchBar.isUserInteractionEnabled = false
			next.contentView.searchBar.placeholder = "\(category.mainPageData.displayName) • \(tutor.topSubject!)"
			
			let transition = CATransition()
			
			DispatchQueue.main.async {
				let nav = navigationController
				nav.view.layer.add(transition.segueFromBottom(), forKey: nil)
				nav.pushViewController(next, animated: false)
			}
		}
	}
	
	func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		let attributes = collectionView.layoutAttributesForItem(at: indexPath)
			attributes?.alpha = 1.0
			attributes?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		return attributes
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let screen = UIScreen.main.bounds
		let width = (screen.width / 3) - 13
		let height = collectionView.frame.height - 15
		
		return CGSize(width: width, height: height)
	}
}
