//
//  SubjectSearchCollectionViewLayout.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class SubjectSearchCollectionViewLayout: UICollectionViewFlowLayout {
	
	let cellsPerRow : Int
	
	override var itemSize: CGSize {
		get {
			guard let collectionView = collectionView else { return super.itemSize }
			let marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
			let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
			return CGSize(width: itemWidth, height: itemWidth)
		}
		set {
			super.itemSize = newValue
		}
	}
	
	init(cellsPerRow: Int, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
		self.cellsPerRow = cellsPerRow
		super.init()
		
		self.minimumInteritemSpacing = minimumInteritemSpacing
		self.minimumLineSpacing = minimumLineSpacing
		self.sectionInset = sectionInset
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
		let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
		context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
		return context
	}
}
