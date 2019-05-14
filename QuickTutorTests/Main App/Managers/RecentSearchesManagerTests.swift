//
//  RecentSearchesManagerTests.swift
//  QuickTutorTests
//
//  Created by Zach Fuller on 5/14/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import XCTest
@testable import QuickTutor

class RecentSearchesManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRecentSearchesManagerAddsSearch() {
        let sut = RecentSearchesManager.shared
    
        let searchTerm = "iOS"
        sut.saveSearch(term: searchTerm)
        
        XCTAssertTrue(sut.searches.contains(searchTerm))
    }

    func testDuplicatesAreNotAdded() {
        let sut = RecentSearchesManager.shared
        
        let searchTerm = "Basketball"
        sut.saveSearch(term: searchTerm)
        sut.saveSearch(term: searchTerm)
        
        XCTAssert(sut.searches.count == 1)
    }
    
    func testNoRecentSearchs() {
        let sut = RecentSearchesManager.shared
        
        sut.searches = []
        
        XCTAssertTrue(sut.searches.isEmpty)
    }
}
