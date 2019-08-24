//
//  QTOpacityAnimationCollectionViewFlowLayout.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/8/20.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTOpacityAnimationCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var insertedIndexPaths: [IndexPath]?
    var removedIndexPaths: [IndexPath]?

    var currentCellAttributes: [IndexPath : UICollectionViewLayoutAttributes] = [:]
    var cachedCellAttributes: [IndexPath : UICollectionViewLayoutAttributes] = [:]

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        attributes?.forEach { attribute in
            if attribute.representedElementCategory == .cell {
                self.currentCellAttributes[attribute.indexPath] = attribute
            }
        }
        return attributes
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        insertedIndexPaths = []
        removedIndexPaths  = []
        
        updateItems.forEach { updateItem in
            if updateItem.updateAction == .insert {
                // If the update item's index path has an "item" value of NSNotFound, it means it was a section update, not an individual item.
                // This is 100% undocumented but 100% reproducible.
                if let insertIndexPath = updateItem.indexPathAfterUpdate, insertIndexPath.item != NSNotFound {
                    self.insertedIndexPaths?.append(insertIndexPath)
                }
            } else if updateItem.updateAction == .delete {
                if let deleteIndexPath = updateItem.indexPathBeforeUpdate, deleteIndexPath.item != NSNotFound {
                    self.removedIndexPaths?.append(deleteIndexPath)
                }
            }
        }
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        if insertedIndexPaths?.contains(itemIndexPath) == true {
            attributes = currentCellAttributes[itemIndexPath]?.copy() as? UICollectionViewLayoutAttributes
            attributes?.alpha = 0.3
        }
        
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        
        if removedIndexPaths?.contains(itemIndexPath) == true {
            attributes = cachedCellAttributes[itemIndexPath]?.copy() as? UICollectionViewLayoutAttributes
            attributes?.alpha = 0.0
        }
        
        return attributes
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        insertedIndexPaths = nil
        removedIndexPaths  = nil
    }
}
