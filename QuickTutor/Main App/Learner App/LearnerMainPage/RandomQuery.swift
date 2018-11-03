//
//  RandomQuery.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/1/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class RandomQuery {
	
	private let category : Category
	private let itemsPerBatch: UInt = 8
	
	var allTutorsQueried: Bool = false
	var didLoadMore: Bool = false
	
	
	init(category: Category) {
		self.category = category
	}
}
