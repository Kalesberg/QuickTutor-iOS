//
//  CollectionExtensions.swift
//  QuickTutor
//
//  Created by Will Saults on 5/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import Foundation

extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
