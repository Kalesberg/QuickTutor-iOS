//
//  BaseSessionVCTests.swift
//  QuickTutorTests
//
//  Created by Will Saults on 4/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import XCTest
@testable import QuickTutor

class BaseSessionVCTests: XCTestCase {
    var postSessionHelper: PostSessionHelper!

    override func setUp() {
        super.setUp()
        postSessionHelper = PostSessionHelper()
    }
    
    func testCalculateCostForSessionReturnsMinimumPrice() {
        
        let cost = postSessionHelper.calculateCostOfSession(price: 0, runtime: 1)
        
        XCTAssertEqual(cost, 5, "The minimum price is 5 dollars")
    }

    func testCalculateCostForSessionReturnsPriceWhenLessThanMinimumPrice() {
        
        let cost = postSessionHelper.calculateCostOfSession(price: 1, runtime: 5)
        
        XCTAssertEqual(cost, 5, "Price should be 5 dollars")
    }
    
    func testCalculateCostForSessionReturnsPriceWhenMoreThanMinimumPrice() {
        
        let cost = postSessionHelper.calculateCostOfSession(price: 6, runtime: 3600)
        
        XCTAssertEqual(cost, 6, "Price should be 6 dollars")
    }
    
    func testCalculateCostForSessionAtDifferentPrices() {
        var cost = postSessionHelper.calculateCostOfSession(price: 20, runtime: 3600)
        XCTAssertEqual(cost, 20, "Cost for $20 * 60min should be $20")
        
        cost = postSessionHelper.calculateCostOfSession(price: 20, runtime: 5400)
        XCTAssertEqual(cost, 30, "Cost for $20 * 90min should be $30")
        
        cost = postSessionHelper.calculateCostOfSession(price: 9, runtime: 4210)
        XCTAssertEqual(cost, 10.525, "Cost for $9 * 70.16667min should be $10.525")
        
        cost = postSessionHelper.calculateCostOfSession(price: 123, runtime: 6699)
        XCTAssertEqual(cost, 228.883, "Cost for $123 * 111.65min should be $228.883")
    }
    
    func testCalculatePricePerSecond() {
        let price = postSessionHelper.calculatePricePerSecond(price: 8, runtime: 294)
        
        XCTAssertEqual(price, 0.653, "Price should match")
    }
}
