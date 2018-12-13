//
//  TutorCardInfoViewFlowLayout.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorCardInfoViewFlowLayout: UICollectionViewFlowLayout {
    
    let spacing = 10
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let answer = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        let count = answer.count
        guard count > 1 else { return nil }
        for i in 1..<count {
            let currentLayoutAttributes = answer[i]
            let prevLayoutAttributes = answer[i-1]
            let origin = prevLayoutAttributes.frame.maxX
            if (origin + CGFloat(spacing) + currentLayoutAttributes.frame.size.width) < self.collectionViewContentSize.width && currentLayoutAttributes.frame.origin.x > prevLayoutAttributes.frame.origin.x {
                var frame = currentLayoutAttributes.frame
                frame.origin.x = origin + CGFloat(spacing)
                currentLayoutAttributes.frame = frame
            }
        }
        return answer
    }
}
