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
		
		layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0.0
		
		collectionView.collectionViewLayout = layout
		collectionView.backgroundColor = .clear
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.alwaysBounceHorizontal = true
		
		return collectionView
	}()
	
	let itemsPerBatch : UInt = 6
	var allTutorsQueried : Bool = false
	var didLoadMore : Bool = false
	
	var datasource = [FeaturedTutor]() {
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
	
	private func queryTutorsByCategory(lastKnownKey: String?) {
		QueryData.shared.queryAWTutorByCategory(category: category, lastKnownKey: lastKnownKey, limit: itemsPerBatch, { (tutors) in
			if let tutors = tutors {
				
				self.allTutorsQueried = tutors.count != self.itemsPerBatch
				
				let startIndex = self.datasource.count
				self.collectionView.performBatchUpdates({
					self.datasource.append(contentsOf: tutors)
					let endIndex = self.datasource.count
					
					let insertPaths = Array(startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
					self.collectionView.insertItems(at: insertPaths)
				}, completion: { (finished) in
					self.didLoadMore = false
				})
			}
		})
	}
}

extension FeaturedTutorTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return datasource.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! FeaturedTutorCollectionViewCell

		cell.price.text = datasource[indexPath.item].price.priceFormat()
		cell.featuredTutor.imageView.loadUserImagesWithoutMask(by: datasource[indexPath.item].imageUrl)
		cell.featuredTutor.namePrice.text = datasource[indexPath.item].name
		cell.featuredTutor.region.text = datasource[indexPath.item].region
		cell.featuredTutor.subject.text = datasource[indexPath.item].subject
		
		let formattedString = NSMutableAttributedString()
		formattedString
            .bold("\(datasource[indexPath.item].rating)  ", 14, Colors.gold)
			.regular("(\(datasource[indexPath.item].reviews) ratings)", 13, Colors.gold)
		cell.featuredTutor.ratingLabel.attributedText = formattedString
        cell.layer.cornerRadius = 6
        cell.featuredTutor.applyDefaultShadow()
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
		cell.shrink()
	}
	
	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
		UIView.animate(withDuration: 0.2) {
			cell.transform = CGAffineTransform.identity
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
		cell.growSemiShrink {
			let next = TutorConnect()
			next.featuredTutorUid = self.datasource[indexPath.item].uid
			next.contentView.searchBar.placeholder = "\(self.category.mainPageData.displayName) • \(self.datasource[indexPath.item].subject)"
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
        
        if screen.height == 568 || screen.height == 480 {
            return CGSize(width: (screen.width / 2.5) - 13, height: collectionView.frame.height - 20)
        } else {
            return CGSize(width: (screen.width / 2.5) - 13, height: collectionView.frame.height - 20)
        }
	}

}

extension FeaturedTutorTableViewCell : UIScrollViewDelegate {
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if allTutorsQueried { return }
		
		let currentOffset = scrollView.contentOffset.x
		let maximumOffset = scrollView.contentSize.width - scrollView.frame.size.width

		if maximumOffset - currentOffset <= -50.0 && datasource.count > 0 {
			queryTutorsByCategory(lastKnownKey: datasource[datasource.endIndex - 1].uid)
		}
	}
}
