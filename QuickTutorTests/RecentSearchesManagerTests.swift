//
//  RecentSearchesManagerTests.swift
//  QuickTutorTests
//
//  Created by Zach Fuller on 5/13/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import XCTest
@testable import QuickTutor

class RecentSearchesManagerTests: XCTestCase {

    func testRecentSearchManagerHasNoRecentSearchesReturnsFalse() {
        let sut = RecentSearchesManager.shared
        
        sut.searches = []
        
        XCTAssertTrue(sut.hasNoRecentSearches)
    }

}
