//
//  DurationCollectionViewFlowLayout.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class DurationCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    let standardItemAlpha: CGFloat = 0.5
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var attributesCopy = [UICollectionViewLayoutAttributes]()
        
        for itemAttributes in attributes! {
            let itemAttributesCopy = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            changeLayoutAttributes(itemAttributesCopy)
            attributesCopy.append(itemAttributesCopy)
        }
        
        return attributesCopy
    }
    
    override func prepare() {
        super.prepare()
    }
    
    func changeLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) {
        let collectionViewCenter = collectionView!.frame.size.width / 2
        let offset = collectionView!.contentOffset.x
        let normalizedCenter = attributes.center.x - offset
        
        let maxDistance = self.itemSize.height + self.minimumInteritemSpacing
        let distance = min(abs(collectionViewCenter - normalizedCenter), maxDistance)
        
        let ratio = (maxDistance - distance)/maxDistance
        let alpha = ratio * (1 - self.standardItemAlpha) + self.standardItemAlpha
        
        attributes.alpha = alpha
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

